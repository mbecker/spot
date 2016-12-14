//
//  MainNavigationController.swift
//  Spot
//
//  Created by Mats Becker on 10/12/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MainNavigationController: UINavigationController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
//        var handle: FIRAuthStateDidChangeListenerHandle!
//        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
//            print(":: FIREBASE HANDLER ::")
//            print(auth)
//            print(user)
//            if  user == nil && self.topViewController is MainASTabBarController {
//                self.pushViewController(LoginViewController(), animated: false)
//            }
//        }
//        
//        if FIRAuth.auth()?.currentUser == nil {
//            self.pushViewController(LoginViewController(), animated: false)
//        } else {
//            self.pushViewController(MainASTabBarController(), animated: false)
//        }
//
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
