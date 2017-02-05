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
        
        // Hide text "Back"
        let backImage = UIImage(named: "back64")?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.visibleViewController?.title = self._park.name
        self.view.backgroundColor = UIColor.white
        
        self.loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: self.view.bounds.width / 2 - 44, y: self.view.bounds.height / 2 - 22 - self.navigationController!.navigationBar.bounds.height, width: 88, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
        
        self.loadingIndicatorView!.startAnimating()
        self.view.addSubview(self.loadingIndicatorView!)
        
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
            let downViewFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            let downView = try DownView(frame: downViewFrame, markdownString: markdown)
            downView.delegate = self
            self.view.addSubview(downView)
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
    func didFinish(){
        self.loadingIndicatorView?.removeFromSuperview()
    }
}
