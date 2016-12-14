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

class LoginViewController: UIViewController {
    
    var errorLabel = UILabel()
    
    let images = [#imageLiteral(resourceName: "login1"), #imageLiteral(resourceName: "login2"), #imageLiteral(resourceName: "login3"), #imageLiteral(resourceName: "login4")]

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
        
        let image   = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - UIScreen.main.bounds.width / 2 / 2, y: UIScreen.main.bounds.height / 2 - UIScreen.main.bounds.width / 2, width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2))
        image.image = images[randomNumber()]
        image.cornerRadius = UIScreen.main.bounds.width / 4
        image.clipsToBounds = true
        
        let loginButton     = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.frame   = CGRect(x: UIScreen.main.bounds.width / 2 - 240 / 2, y: 264 + (UIScreen.main.bounds.height - 264) / 2 - 44 / 2, width: 240, height: 44)
        loginButton.delegate = self
        
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = "What's going on?"
        
        self.view.addSubview(image)
        self.view.addSubview(loginButton)
        self.view.addSubview(errorLabel)
        
        errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        // errorLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20).isActive = true
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomNumber(range: ClosedRange<Int> = 0...3) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }

}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        switch result {
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    self.errorLabel.text = error.localizedDescription
                    return
                }
                print(":: FIREBASE :: LOGGED IN ")
                print("displayname: \(user!.displayName)")
                print("email: \(user!.email)")
                print("image: \(user!.photoURL)")
                // self.navigationController?.pushViewController(MainASTabBarController(), animated: true)
                
            }
            break
        case .cancelled:
            print(":: FACEBOOK LOGIN CANCELLED ::")
            self.errorLabel.text = "Facebook Login cancelled"
            break
        case .failed(let error):
            print(":: FACEBOOK LOGIN ERROR ::")
            print(error)
            self.errorLabel.text = error.localizedDescription
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
