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
import SwiftMessages

class ParkDetailViewController: UIViewController {
    
    private var shadowImageView: UIImageView?
    
    let _realmPark: RealmPark
    
    var loadingIndicatorView: NVActivityIndicatorView?
    
    init(realmPark: RealmPark){
        self._realmPark = realmPark
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
        
        // Navgationconroller
        self.navigationController?.visibleViewController?.title = self._realmPark.name
        
        // View - Scrollview
        self.view = self.scrollView
        self.scrollView.backgroundColor = UIColor.white
        self.scrollView.isUserInteractionEnabled = true
        
        self.loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: self.view.bounds.width / 2 - 44, y: self.view.bounds.height / 2 - 22 - self.navigationController!.navigationBar.bounds.height, width: 88, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
        self.loadingIndicatorView!.startAnimating()
        self.scrollView.addSubview(self.loadingIndicatorView!)
        
        
        /**
         * Mapimage of park
         */
        let mapImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: self.scrollView.bounds.width - 40, height: 206))
        self.scrollView.addSubview(mapImageView)
        if let mapImageString: String = self._realmPark.mapURL, let mapImageURL: URL = URL(string: mapImageString) {
            let processor = RoundCornerImageProcessor(cornerRadius: 10)
            mapImageView.kf.indicatorType = .activity
            mapImageView.kf.setImage(with: mapImageURL, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                if error != nil {
                    print(error!)
                    // ToDo: Map Image can't be download; show error?
                } else {
                    // We can not store an image to realm; but the image is cached anyway
                }
            })
        }
        
        /**
         * Markdown
         */
        let realmTransactions = RealmTransactions()
        realmTransactions.loadMarkdownFromFirebaseAndSaveToRealm(realmPark: self._realmPark, completion: { (result, returnError) in
            if let markdown: String = result?.markdown {
                self.showMarkdown(markdown: markdown)
            } else if let error: MarkdownError = returnError {
                let errorLabel = UILabel()
                errorLabel.text = "Sorry :-("
                errorLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
                errorLabel.textColor = UIColor.scarlet
                errorLabel.textAlignment = .center
                errorLabel.translatesAutoresizingMaskIntoConstraints = false
                self.loadingIndicatorView?.removeFromSuperview()
                self.view.addSubview(errorLabel)
                errorLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
                errorLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 24).isActive = true
                errorLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
                
                
                switch (error) {
                case .MarkdownDoesNotExist:
                    self.showMessage(message: "The park information does not exsist.")
                    break;
                case .FirebaseError:
                    self.showMessage(message: "We couldn't fetch any data from the database.")
                    break;
                case .MarkdownError:
                    self.showMessage(message: "We had problems to load the park informtion.")
                    break;
                default:
                    break;
                }
                print(error)
                
            }
        })
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
    
    // - Helpers
    func showMessage(message: String) {
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        self.dismiss(animated: false, completion: nil)
        
        let image = UIImage(named:"Dinosaur-66")?.withRenderingMode(.alwaysTemplate)
        let info = MessageView.viewFromNib(layout: .MessageView)
        info.configureTheme(.error)
        info.button?.isHidden = true
        info.iconLabel?.isHidden = true
        info.configureContent(title: "Error", body: message, iconImage: image!)
        info.iconImageView?.isHidden = false
        info.iconImageView?.tintColor = UIColor.white
        info.configureIcon(withSize: CGSize(width: 30, height: 30), contentMode: .scaleAspectFill)
        info.backgroundView.backgroundColor = UIColor(red:0.93, green:0.33, blue:0.39, alpha:1.00)
        var infoConfig = SwiftMessages.defaultConfig
        infoConfig.presentationStyle = .bottom
        infoConfig.duration = .seconds(seconds: 2)
        
        
        SwiftMessages.show(config: infoConfig, view: info)
    }
    
}

extension ParkDetailViewController: DownViewProtocol {
    func didFinish(){
        self.loadingIndicatorView?.removeFromSuperview()
        // Add a frame for downview to do a proper setneedslayout
        self.downView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.scrollView.bounds.height)
        self.scrollView.addSubview(downView)
        
        // do the needslayou to update to correct body.offsezHeight; get the body.offsetHeight and assign it to downview and scrollview.contentsite
        self.downView.setNeedsLayout()
        self.downView.evaluateJavaScript("document.body.offsetHeight") { (result, error) in
            if error == nil {
                if let height: CGFloat = result as! CGFloat? {
                    self.downView.frame = CGRect(x: 0, y: 226, width: self.view.bounds.width, height: height)
                    self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: height + 226)
                }
            }
        }
    }
}
