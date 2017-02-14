//
//  ParkItemsASViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/9/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import Kingfisher
import NVActivityIndicatorView

class ParkItemsASViewController: ASViewController<ASDisplayNode> {
    
    let _realmTransaction = RealmTransactions()
    
    let _firebaseRef    : FIRDatabaseReference
    let _realmPark      : RealmPark
    let _type           : ItemType
    let _path           : String!
    
    
    weak var delegate:ParkASCellNodeDelegate?
    
    var _realmEncyclopediaItems: [RealmEncyclopediaItem] = [RealmEncyclopediaItem]()
    
    var observerChildAdded: FIRDatabaseHandle?
    var observerChildChanged: FIRDatabaseHandle?
    let errorLabelNoItems = UILabel()
    let errorImageNoItems = UIImageView()
    
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
    private var shadowImageView: UIImageView?
    
    init(realmPark: RealmPark, type: ItemType){
        self._firebaseRef    = FIRDatabase.database().reference()
        self._realmPark      = realmPark
        self._type           = type
        self._path           = "park/" + type.rawValue + "/" + self._realmPark.key + "/"
        
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
//    func addObserver(){
//        removeObserver()
//        self.toggleErrorLabelNoItems(show: false)
//        
//        
//        // 1: .childAdded observer
//        self.observerChildAdded = self._firebaseRef.child(self._path).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
//            // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
//            if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark, type: self._type), self.items2.contains(where: {$0.key == item2.key}) == false {
//                
//                if self.loadingIndicatorView.animating {
//                    self.loadingIndicatorView.stopAnimating()
//                }
//                
//                
//                OperationQueue.main.addOperation({
//                    self.items2.insert(item2, at: 0)
//                    let indexPath = IndexPath(item: 0, section: 0)
//                    self.tableNode.insertRows(at: [indexPath], with: .none)
//                    self.tableNode.reloadRows(at: [indexPath], with: .none)
//                })
//                
//            }
//            
//        })
//        
//        // 2: .childChanged observer
//        self.observerChildChanged = self._firebaseRef.child(self._path).observe(.childChanged, with: { (snapshot) -> Void in
//            // ParkItem2 is updated; replace item in table array
//            if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject] {
//                for i in 0...self.items2.count-1 {
//                    if let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark, type: self._type), self.items2[i].key == item2.key {
//                        let index = i
//                        OperationQueue.main.addOperation({
//                            self.items2[index]  = item2
//                            let indexPath = IndexPath(item: index, section: 0)
//                            self.tableNode.reloadRows(at: [indexPath], with: .fade)
//                        })
//                        
//                    }
//                }
//            }
//            
//        })
//        
//        
//    }
//    
//    func toggleErrorLabelNoItems(show: Bool, shouldRemoveObserver: Bool = true) {
//        if show {
//            if shouldRemoveObserver {
//                removeObserver()
//            }
//            self.loadingIndicatorView.stopAnimating()
//            self.view.addSubview(self.errorLabelNoItems)
//            self.view.addSubview(self.errorImageNoItems)
//            self.errorImageNoItems.rotate360Degrees(duration: 2, completionDelegate: self)
//        } else {
//            self.errorLabelNoItems.removeFromSuperview()
//            self.errorImageNoItems.removeFromSuperview()
//            self.loadingIndicatorView.startAnimating()
//        }
//        
//    }
//    
//    func removeObserver(){
//        if self.observerChildAdded != nil {
//            self._firebaseRef.removeObserver(withHandle: self.observerChildAdded!)
//        }
//        if self.observerChildChanged != nil {
//            self._firebaseRef.removeObserver(withHandle: self.observerChildChanged!)
//        }
//    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigationcontroller
        self.navigationController?.visibleViewController?.title = "All \(self._type.rawValue.firstCharacterUpperCase())"
        
        // TableView
        self.view.backgroundColor = UIColor.white
        self.tableNode.view.showsVerticalScrollIndicator    = true
        self.tableNode.allowsSelection                      = true
        self.tableNode.view.backgroundColor                 = UIColor.white
        self.tableNode.view.separatorColor                  = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00) // Bonjour
        
        
        // Loading indicator
        var tabBarHeight: CGFloat = 0
        var navControllerHeight: CGFloat = 0
        if let tabBarHeightFromTabBarController = self.tabBarController?.tabBar.bounds.height {
            tabBarHeight = tabBarHeightFromTabBarController
        }
        if let navControllerHeightFromNavController = self.navigationController?.navigationBar.bounds.height {
            navControllerHeight = navControllerHeightFromNavController
        }
        self.loadingIndicatorView.frame = CGRect(x: self.view.bounds.width / 2 - 22, y: (self.view.bounds.height - navControllerHeight - tabBarHeight) / 2 - 22, width: 44, height: 44)
        self.loadingIndicatorView.startAnimating()
        self.view.addSubview(self.loadingIndicatorView)
        
        // Error label
        self.errorLabelNoItems.frame = CGRect(x: 0, y: (self.view.bounds.height - navControllerHeight - tabBarHeight) / 2 - 22, width: self.view.bounds.width, height: 44)
        self.errorLabelNoItems.text = "No items uploaded ..."
        self.errorLabelNoItems.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
        self.errorLabelNoItems.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.00)
        self.errorLabelNoItems.textAlignment = .center
        
        self.errorImageNoItems.frame = CGRect(x: self.view.bounds.width / 2 - 15, y: (self.view.bounds.height - navControllerHeight - tabBarHeight) / 2 + 22, width: 30, height: 30)
        self.errorImageNoItems.image = UIImage(named:"Turtle-66")
        
        
        if let parkItems: [RealmEncyclopediaItem] = self._realmTransaction.loadParkItemsFromRealm(parkKey: self._realmPark.key, itemType: self._type), parkItems.count > 0 {
            self.loadingIndicatorView.removeFromSuperview()
            _realmEncyclopediaItems = parkItems
        } else {
            self.loadingIndicatorView.removeFromSuperview()
            self.view.addSubview(self.errorImageNoItems)
            self.view.addSubview(self.errorLabelNoItems)
        }
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
        
        /**
         * Firebase:
         * 1. Count the items in DB
         * 2. Only attach observer if items.count > 0
         * (only attach once an observer)
         */
//        self._firebaseRef.child(self._path).child("count").observe(.value, with: { (snapshot) -> Void in
//            if snapshot.exists(), let count: Int = snapshot.value as? Int, count > 0 {
//                self.addObserver()
//            }
//        })
//        self._firebaseRef.child(self._path).child("count").observe(.childChanged, with: { (snapshot) -> Void in
//            if let count: Int = snapshot.value as? Int, count > 0 {
//                self.addObserver()
//            }
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        removeObserver()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Helpers
     */
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
    
    
}

extension ParkItemsASViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self._realmEncyclopediaItems.count
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0000000000001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0000000000001
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        
        var url: URL? = nil
        if let results = self._realmEncyclopediaItems[indexPath.row].image?.resized.filter("type = %@", "375x300"), let image: RealmImage = results.first, let imageURL: URL = URL(string: image.publicURL) {
            // 1. resized 375x300
            url = imageURL
        } else if let results = self._realmEncyclopediaItems[indexPath.row].image?.resized, let image: RealmImage = results.first, let imageURL: URL = URL(string: image.publicURL) {
            // 2. any resized image (first image; better than public image)
            url = imageURL
        } else if let image: String = self._realmEncyclopediaItems[indexPath.row].image?.original?.publicURL, let imageURL: URL = URL(string: image) {
            // 3. public image
            url = imageURL
        }
        
        return EncycnlopediaItemASCellNode(key: self._realmEncyclopediaItems[indexPath.row].key, name: self._realmEncyclopediaItems[indexPath.row].name, detail: "", url: url)
    }
}

extension ParkItemsASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 66), max: CGSize(width: 0, height: 66))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
        let encyclopdeItemASViewController = EncyclopediaItemASViewController(realmEnyclopediaItemKey: self._realmEncyclopediaItems[indexPath.row].key, realmParkKey: self._realmPark.key)
        self.navigationController?.pushViewController(encyclopdeItemASViewController, animated: true)
    }
}

extension ParkItemsASViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.errorImageNoItems.rotate360Degrees(duration: CFTimeInterval(randomNumber(range: 1...6)), completionDelegate: self)
    }
}
