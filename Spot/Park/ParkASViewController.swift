//
//  ParkASViewController.swift
//  Spot
//
//  Created by Mats Becker on 11/6/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import FirebaseAuth
import Kingfisher
import EZAlertController

import FacebookLogin
import FacebookCore

protocol SelectParkDelegate {
    func selectPark()
    func selectPark(park: String, name: String)
}

class ParkASViewController: ASViewController<ASDisplayNode> {
    
    /**
    * AsyncDisplayKit
    */
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    /**
     * Data
     */
    let _park: Park
    var delegate: SelectParkDelegate?
    
    var showConfig = false
    
    init(park: Park){
        self._park = park
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        self.view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        // TableView
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.view.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
        
        loadPark()
        
        /**
         * SETUP DATA
         */
        subscribeMessaging(toTopic: "/topics/addo")
    }
    
    
    func loadPark(){
        let parkTableHeader                 = ParkTableHeaderUIView(parkName: self._park.parkName)
        parkTableHeader.delegate            = self
        self.tableNode.view.tableHeaderView = parkTableHeader
        
        self._park.load { (loaded) in
            if loaded {
                let parkTableHeader = ParkTableHeaderUIView.init(park: self._park)
                parkTableHeader.delegate = self
                self.tableNode.view.tableHeaderView = parkTableHeader
                self.tableNode.view.tableFooterView = self.tableFooterView()
            }
        }
    }
    
    func subscribeMessaging(toTopic: String){
        // Firebase Messaging
        print("-- FIREBASE -- subscribe toTopic \(toTopic)")
        // "/topics/addo"
        FIRMessaging.messaging().subscribe(toTopic: "/topics/addo")
    }
    
    func mapViewTouched(_ sender:UITapGestureRecognizer){
        // self.mapView touched
        let touch = sender.location(in: self.view)
        print(touch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        // self.navigationController?.isNavigationBarHidden = true
        
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: ASDisplayProperties.backgroundColor)) {
            statusBar.backgroundColor = UIColor.white
        }
        
        // User Settings: Change view based on settings
        self.showConfig = UserDefaults.standard.object(forKey: UserDefaultTypes.showConfig.rawValue) as? Bool ?? false
        self.tableNode.view.tableFooterView = self.tableFooterView()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableFooterView() -> UIView {
        if(!self.showConfig){
            return UIView(frame: CGRect.zero)
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 240))
        view.backgroundColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        
        let buttonClearCache = UIButton(frame: CGRect(x: 20, y: 20, width: 150, height: 50))
        buttonClearCache.setBackgroundColor(color: UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00), forState: .normal)
        buttonClearCache.setBackgroundColor(color: UIColor(red:0.83, green:0.29, blue:0.31, alpha:1.00), forState: .highlighted)
        buttonClearCache.setTitle("Clear Cache", for: .normal)
        buttonClearCache.addTarget(self, action: #selector(didTapClearCache), for: .touchUpInside)
        
        let addItems = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 20 - 150, y: 20, width: 150, height: 50))
        addItems.setBackgroundColor(color: UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00), forState: .normal)
        addItems.setBackgroundColor(color: UIColor(red:0.83, green:0.29, blue:0.31, alpha:1.00), forState: .highlighted)
        addItems.setTitle("Add items", for: .normal)
        addItems.addTarget(self, action: #selector(didTapAddItems), for: .touchUpInside)
        
        let deleteItems = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 20 - 150, y: 90, width: 150, height: 50))
        deleteItems.setBackgroundColor(color: UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00), forState: .normal)
        deleteItems.setBackgroundColor(color: UIColor(red:0.83, green:0.29, blue:0.31, alpha:1.00), forState: .highlighted)
        deleteItems.setTitle("Delete items", for: .normal)
        deleteItems.addTarget(self, action: #selector(didTapDeleteItems), for: .touchUpInside)
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.center = view.center
        loginButton.delegate = self
        
        let fbPhoto = UIImageView(frame: CGRect(x: 20, y: view.bounds.height - 20 - 60, width: 60, height: 60))
        var handle: FIRAuthStateDidChangeListenerHandle!
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            print(":: FIREBASE HANDLER ::")
            print(auth)
            if let image = user?.photoURL {
                let processor = RoundCornerImageProcessor(cornerRadius: 30)
                fbPhoto.kf.setImage(with: image, placeholder: nil, options: [.processor(processor)])
            } else {
                fbPhoto.image = nil
            }
        }
        view.addSubview(fbPhoto)
        view.addSubview(buttonClearCache)
        view.addSubview(addItems)
        view.addSubview(deleteItems)
        view.addSubview(loginButton)
        
        return view
    }
    
    @objc fileprivate func didTapClearCache() {
        ImageCache.default.calculateDiskCacheSize { size in
            let alert = UIAlertController(title: "Cache", message: "Used disk size: \(size / 1024 / 1024) MB", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Clear cache", style: UIAlertActionStyle.destructive, handler: { action in
                // Clear memory cache right away.
                ImageCache.default.clearMemoryCache()
                
                // Clear disk cache. This is an async operation.
                ImageCache.default.clearDiskCache()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc fileprivate func didTapAddItems() {
        let firebaseModels = FirebaseModel()
        firebaseModels.addAnimals(count: 5, parkName: self._park.parkName)
    }
    
    @objc fileprivate func didTapDeleteItems(){
        let firebaseModel = FirebaseModel()
        firebaseModel.deleteItems(parkName: self._park.parkName)
    }
    
    func sectionHeaderView(text: String, sectionId: Int = 0) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let detailButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 20 - 42.5947265625 - 20 - 20, y: 42 / 2 - 16.70703125, width: 20 + 42.5947265625 + 20, height: 16.70703125 * 2))
        detailButton.setAttributedTitle(NSAttributedString(
            string: "See all",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:1.00, green:0.22, blue:0.22, alpha:1.00), // iOS Red
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
            ])
            , for: .normal)
        detailButton.setAttributedTitle(NSAttributedString(
            string: "See all",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:1.00, green:0.22, blue:0.22, alpha:1.00).withAlphaComponent(0.6), // iOS Red
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
            ])
            , for: .highlighted)
        
        detailButton.setImage(UIImage(named: "next48")?.withRenderingMode(.alwaysTemplate), for: .normal)
        detailButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        detailButton.tintColor = UIColor(red:1.00, green:0.22, blue:0.22, alpha:1.00)
        detailButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        detailButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        detailButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        detailButton.tag = sectionId
        detailButton.addTarget(self, action: #selector(self.pushDetail(sender:)), for: UIControlEvents.touchUpInside)
        
        view.addSubview(title)
        view.addSubview(detailButton)
        
        let constraintLeftTitle = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let constraintCenterYTitle = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        view.addConstraint(constraintLeftTitle)
        view.addConstraint(constraintCenterYTitle)
        
        return view
    }
    
    @objc func pushDetail(sender: UIButton) {
        // self.tabBarController?.selectedIndex = 1
        print("-- TAGS --")
        print(sender.tag)
        
        if let vc = self.tabBarController!.viewControllers![1] as? ASNavigationController {
            vc.popToRootViewController(animated: false)
            if let view = vc.topViewController as? ChangePage {
                view.changePage(tab: sender.tag, showSelectedPage: true)
            }
        }
        
        
        self.tabBarController?.selectedIndex = 1
    }
    


}

extension ParkASViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
//        let grantedPermissions:     Set<Permission>
//        let declinedPermissions:    Set<Permission>
//        let token:                  AccessToken
        
        switch result {
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                // ...
                if let error = error {
                    print(error)
                    return
                }
                print(":: FIREBASE :: LOGGED IN ")
                print("displayname: \(user!.displayName)")
                print("email: \(user!.email)")
                print("image: \(user!.photoURL)")
            }
            break
        case .cancelled:
            print(":: FACEBOOK LOGIN CANCELLED ::")
            break
        case .failed(let error):
            print(":: FACEBOOK LOGIN ERROR ::")
            print(error)
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
        }
        
    }
}

extension ParkASViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return self._park.sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self._park.sections.indices.contains(section) {
            return sectionHeaderView(text: self._park.sections[section].name, sectionId: section)
        }
        return sectionHeaderView(text: "Section: \(section)")
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.white
        if section < self._park.sections.count - 1 {
            // Show not border line for last section
            let borderLine = UIView(frame: CGRect(x: 20, y: 14, width: self.view.bounds.width - 40, height: 1))
            borderLine.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00) // Bonjour
            footer.addSubview(borderLine)
        }
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let node = ParkASCellNode(park: self._park, section: indexPath.section, type: self._park.sections[indexPath.section].type)
        node.delegate = self
        return node
    }
}

extension ParkASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 144), max: CGSize(width: 0, height: 188))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

extension ParkASViewController : ParkASCellNodeDelegate {
    func didSelectPark(_ item: ParkItem2) {
        let detailTableViewConroller = DetailASViewController(park: self._park, parkItem: item)
        self.navigationController?.pushViewController(detailTableViewConroller, animated: true)
    }
}

extension ParkASViewController: SelectParkDelegate {
    func selectPark() {
        EZAlertController.alert("Park", message: "Select park", buttons: ["Addo", "Kruger"], tapBlock: { (alertAction, position) -> Void in
            var park: String!
            var parkName: String!
            switch position {
            case 0:
                park = "addo"
                parkName = "Addo Elephant National Park"
            case 1:
                park = "kruger"
                parkName = "Kruger National Park"
            default:
                park = "addo"
                parkName = "Addo Elephant National Park"
            }
            self.delegate?.selectPark(park: park, name: parkName)
        })
        
    }
    
    func selectPark(park: String, name: String) {
        
    }
}
