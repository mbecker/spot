//
//  LoginViewController.swift
//  Spot
//
//  Created by Mats Becker on 09/12/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore
import ImageSlideshow

class LoginViewController: UIViewController {
    
    var errorLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        //self.navigationController?.isNavigationBarHidden = true
        //Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        /**
         * Header
         */
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 262))
        headerView.backgroundColor = UIColor(red:0.93, green:0.33, blue:0.39, alpha:1.00) // UIColor(red:0.92, green:0.20, blue:0.29, alpha:1.00)
        
        let logo = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 112 / 2, y: 262 / 2 - 112 / 2, width: 112, height: 112))
        logo.image = #imageLiteral(resourceName: "logo")
        logo.contentMode = .scaleAspectFit
        headerView.addSubview(logo)
        
        let label = UILabel()
        let attributedText = NSAttributedString(
            string: "safari.digital",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 32, weight: UIFontWeightThin),
                NSForegroundColorAttributeName: UIColor.white,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        label.attributedText = attributedText
        let size = attributedText.size()
        label.frame = CGRect(x: UIScreen.main.bounds.width / 2 - size.width / 2, y: 262 / 2 + 112 / 2 + 24, width: size.width, height: size.height)
        headerView.addSubview(label)
        
        self.view.addSubview(headerView)
        
        /**
         * Footer
         */
        let footer = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 54, width: UIScreen.main.bounds.width, height: 0.8))
        footer.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.85, alpha:1.00).withAlphaComponent(0.6)
        
        let labelTerms = UILabel()
        labelTerms.lineBreakMode = .byWordWrapping
        labelTerms.numberOfLines = 0
        labelTerms.frame = CGRect(x: 8, y: UIScreen.main.bounds.height - 64, width: UIScreen.main.bounds.width - 16, height: 64)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let termsString = "By signing in, you agree to our Terms and that you have read our Data Use Policy, including our Cookie Use."
        let terms = "Terms"
        let termsRange = (termsString as NSString).range(of: terms)
        let dataUsePolicy = "Data Use Policy"
        let dataUsePolicyRange = (termsString as NSString).range(of: dataUsePolicy)
        let cookieUse = "Cookie Use"
        let cookieUseRange = (termsString as NSString).range(of: cookieUse)
        
        let termsAttributedText2 = NSMutableAttributedString.init(string: termsString)
        termsAttributedText2.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium), range: NSRange(location: 0, length: termsString.characters.count))
        termsAttributedText2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.80, green:0.82, blue:0.85, alpha:1.00), range: NSRange(location: 0, length: termsString.characters.count))
        termsAttributedText2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.00).withAlphaComponent(0.6), range: termsRange)
        termsAttributedText2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.00).withAlphaComponent(0.6), range: dataUsePolicyRange)
        termsAttributedText2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.00).withAlphaComponent(0.6), range: cookieUseRange)
        termsAttributedText2.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSRange(location: 0, length: termsString.characters.count))
        labelTerms.attributedText = termsAttributedText2
        
        self.view.addSubview(footer)
        self.view.addSubview(labelTerms)
        
        /**
         * Login
         */
        let loginButton     = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.frame   = CGRect(x: UIScreen.main.bounds.width / 2 - 240 / 2, y: UIScreen.main.bounds.height - 68 - 44 - 28, width: 240, height: 44)
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        let infoAttributedText = NSAttributedString(
            string: "We use Facebook as a login provider and would never post anything without your permission.",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium),
                NSForegroundColorAttributeName: UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.00),
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                NSParagraphStyleAttributeName: paragraph
                ])
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.numberOfLines = 0
        errorLabel.attributedText = infoAttributedText
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(errorLabel)
        errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        errorLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 64).isActive = true
        
        var imageHeight = loginButton.frame.minY - headerView.frame.maxY - 32 - 16
        if imageHeight > 217 - 16 {
            imageHeight = 217 - 16
        }
        
        let spotCircle = UIImageView()
        // spotCircle.image = #imageLiteral(resourceName: "login1")
        spotCircle.contentMode = .scaleAspectFill
        spotCircle.clipsToBounds = true
        spotCircle.layer.masksToBounds = true
        spotCircle.layer.cornerRadius = imageHeight / 2
        spotCircle.frame = CGRect(x: UIScreen.main.bounds.width / 2 - imageHeight / 2, y: headerView.frame.maxY + 16, width: imageHeight, height: imageHeight)
        
        let imageView = UIView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 185 / 2, y: headerView.frame.maxY + 32, width: 185, height: 185))
        imageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        imageView.layer.shadowOpacity = 0.8
        imageView.layer.shadowRadius = 5
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowPath = UIBezierPath(roundedRect: spotCircle.frame, cornerRadius: 185 / 2).cgPath
        
        // imageView.addSubview(spotCircle)
        
        // self.view.addSubview(spotCircle)
        
        let slideShow = ImageSlideshow(frame: CGRect(x: UIScreen.main.bounds.width / 2 - imageHeight / 2, y: headerView.frame.maxY + 16, width: imageHeight, height: imageHeight))
        slideShow.backgroundColor = UIColor.white
        slideShow.cornerRadius = imageHeight / 2
        slideShow.slideshowInterval = 5.0
        slideShow.pageControlPosition = PageControlPosition.custom(padding: -30)
        slideShow.pageControl.currentPageIndicatorTintColor = UIColor.white
        slideShow.pageControl.pageIndicatorTintColor = UIColor.linkWater
        slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        slideShow.setImageInputs([
//            ImageSource(image: #imageLiteral(resourceName: "login1")),
//            ImageSource(image: #imageLiteral(resourceName: "login2")),
//            ImageSource(image: #imageLiteral(resourceName: "login4")),
//            ImageSource(image: #imageLiteral(resourceName: "login3")),
            ])
        self.view.addSubview(slideShow)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        switch result {
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    self.errorLabel.attributedText = NSAttributedString(
                        string: error.localizedDescription,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium),
                            NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.0,
                            NSParagraphStyleAttributeName: paragraph
                        ])
                    return
                }
                print(":: FIREBASE :: LOGGED IN ")
                print("displayname: \(user!.displayName)")
                print("email: \(user!.email)")
                print("image: \(user!.photoURL)")
                print(grantedPermissions)
                print(declinedPermissions)
                // self.navigationController?.pushViewController(MainASTabBarController(), animated: true)
                
            }
            break
        case .cancelled:
            print(":: FACEBOOK LOGIN CANCELLED ::")
            self.errorLabel.attributedText = NSAttributedString(
                string: "Facebook Login cancelled",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    NSParagraphStyleAttributeName: paragraph
                ])
            break
        case .failed(let error):
            print(":: FACEBOOK LOGIN ERROR ::")
            print(error)
            self.errorLabel.attributedText = NSAttributedString(
                string: error.localizedDescription,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    NSParagraphStyleAttributeName: paragraph
                ])
            break
        }
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print(":: FACEBOOK LOGOUT ::")
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print(":: FIREBASE LOGOUT ::")
            print ("Error signing out: %@", signOutError)
            self.errorLabel.text = signOutError.localizedDescription
        }
        
    }
}
