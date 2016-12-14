//
//  MainViewController.swift
//  Spot
//
//  Created by Mats Becker on 12/11/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseAuth

class MainViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let launchImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        launchImageView.image = #imageLiteral(resourceName: "SplahScreenAirBNB")
        
        let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 88 / 2, y: UIScreen.main.bounds.height / 2 + UIScreen.main.bounds.height / 4 - 44 / 2, width: 88, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0)
        loadingIndicatorView.startAnimating()
        
        self.view.addSubview(launchImageView)
        self.view.addSubview(loadingIndicatorView)
        
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .fullScreen
        
        let handle: FIRAuthStateDidChangeListenerHandle = (FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            print(":: FIREBASE HANDLER ::")
            if  user == nil && !(self.navigationController?.topViewController is LoginViewController) {
                
                self.present(LoginViewController(), animated: true, completion: nil)
                // self.navigationController?.pushViewController(LoginViewController(), animated: true)
            } else {
                self.navigationController?.pushViewController(MainASTabBarController(), animated: false)
                self.dismiss(animated: true, completion: nil)
            }
            })!
        
        if FIRAuth.auth()?.currentUser == nil {
            // self.navigationController?.pushViewController(LoginViewController(), animated: false)#
            self.present(LoginViewController(), animated: false, completion: nil)
        } else {
            // self.navigationController?.pushViewController(MainASTabBarController(), animated: false)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
