//
//  SettingsTableViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/15/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

//
//  FormCountriesTableViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/3/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore

class SettingsTableViewController: UITableViewController {
    
    private var shadowImageView: UIImageView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navgationconroller
        // self.navigationController?.visibleViewController?.title = "Profile"
        // self.navigationController?.title = "Profile"
        self.navigationItem.title = "Profile"
        
        
        // View
        self.view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.99, alpha:1.00)
        self.tableView.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.99, alpha:1.00)
        
        self.definesPresentationContext = true
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.tableFooterView = tableFooterView
        self.tableView.separatorStyle = .singleLine
        self.tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Footer
     */
    lazy var tableFooterView: UIView = {
        let logutView = FacebookView()
        logutView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 96)
        logutView.backgroundColor = UIColor.clear
        return logutView
    }()
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        default:
            return 1
        }
    }
    
    /*
     * Cell
     */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = SettingsTableViewCell(style: .default, reuseIdentifier: "cell")
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = "Parks"
        default:
            cell.textLabel!.text = "Facebook"
        }
//        let vw = UIView()
//        vw.frame = CGRect(x: 20, y: 47, width: UIScreen.main.bounds.width - 40, height: 1)
//        vw.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00).withAlphaComponent(0.6)
//        cell.addSubview(vw)
        
//        let selectedView = UIView()
//        selectedView.backgroundColor = UIColor.radicalRed
//        cell.selectedBackgroundView = selectedView
//        cell.textLabel?.highlightedTextColor = UIColor.white
//        cell.backgroundColor = UIColor.white
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
//        cell.textLabel?.textColor = UIColor.radicalRed
//        let chevronImage = UIImage(named: "chevronright_32x17")?.withRenderingMode(.alwaysTemplate)
//        cell.imageView?.image = chevronImage
//        cell.imageView?.tintColor = UIColor.white
//        let imageView = UIImageView(image: chevronImage)
//        cell.accessoryView = imageView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    /*
     * Section
     */
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        vw.borderWidth = 0
        vw.borderColor = UIColor.clear
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        vw.addSubview(title)
        title.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 16).isActive = true
        title.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: vw.bottomAnchor, constant: 8).isActive = true
        
        switch section {
        case 0:
            title.text = "Packs"
        default:
            title.text = "User"
        }
        
        return vw
    }
    
    // MARK: - Helpers
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

class FacebookView: UIView {
    
    let errorLabel = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        let loginButton = LoginButton(frame: CGRect.zero, readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.delegate = self
        self.addSubview(loginButton)
        loginButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 164).isActive = true
        
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let infoAttributedText = NSAttributedString(
            string: "We use Facebook as a login provider and would never post anything without your permission.",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightLight),
                NSForegroundColorAttributeName: UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.00),
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                NSParagraphStyleAttributeName: paragraph
            ])
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.numberOfLines = 0
        errorLabel.attributedText = infoAttributedText
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(errorLabel)
        errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        errorLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 64).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FacebookView: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print(":: FACEBOOK LOGOUT ::")
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            print(":: FIREBASE LOGOUT ::")
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
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
    
}
