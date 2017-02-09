//
//  ParkDetailViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/1/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import Down
import Kingfisher
import NVActivityIndicatorView

class ParkDetailViewController: UIViewController {
    
    private var shadowImageView: UIImageView?
    
    let _park: Park
    
    var loadingIndicatorView: NVActivityIndicatorView?
    
    init(park: Park){
        self._park = park
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        // Navigationbar
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = false
        
        // Navigationcontroller back image, tint color, text attributes
        let backImage = UIImage(named: "back64")?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
            NSForegroundColorAttributeName: UIColor.black,
            NSBackgroundColorAttributeName: UIColor.clear,
            NSKernAttributeName: 0.0,
        ]
        
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
    let scrollView = UIScrollView(frame: UIScreen.main.bounds)
    var downView: DownView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navgationconroller
        self.navigationController?.visibleViewController?.title = self._park.name
        
        // View - Scrollview
        self.view = self.scrollView
        self.scrollView.backgroundColor = UIColor.white
        self.scrollView.isUserInteractionEnabled = true
        
        self.loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: self.view.bounds.width / 2 - 44, y: self.view.bounds.height / 2 - 22 - self.navigationController!.navigationBar.bounds.height, width: 88, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
        self.loadingIndicatorView!.startAnimating()
        self.scrollView.addSubview(self.loadingIndicatorView!)
        
        
        /**
         * Additional image
         */
        let mapImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: self.scrollView.bounds.width - 40, height: 206))
        self.scrollView.addSubview(mapImageView)
        if let mapImageString: String = self._park.mapURL, let mapImageURL: URL = URL(string: mapImageString) {
            let processor = RoundCornerImageProcessor(cornerRadius: 10)
            mapImageView.kf.indicatorType = .activity
            mapImageView.kf.setImage(with: mapImageURL, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                if error != nil {
                    print(error!)
                    // ToDo: Map Image can't be download; show error?
                } else {
                    self._park.mapImage = image
                }
            })
        }
        
        
        /**
         * Markdown
         */
        if let markdown: String = self._park.markdown?.markdown {
            showMarkdown(markdown: markdown)
        } else {
            let realmTransactions = RealmTransactions()
            realmTransactions.loadMarkdownFromFirebaseAndSaveToRealm(park: self._park, completion: { (result) in
                if let markdown: String = result?.markdown {
                    self.showMarkdown(markdown: markdown)
                }
            })
        }
    }
    
    func showMarkdown(markdown: String){
        do {
            downView = try DownView(frame: CGRect.zero, markdownString: markdown)
            downView.delegate = self
            
        } catch {
            print("Error: DownView")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ParkDetailViewController: DownViewProtocol {
    func didFinish(height: CGFloat){
        self.loadingIndicatorView?.removeFromSuperview()
        self.downView.frame = CGRect(x: 0, y: 226, width: self.view.bounds.width, height: height)
        self.scrollView.addSubview(downView)
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: height + 226)
    }
}
