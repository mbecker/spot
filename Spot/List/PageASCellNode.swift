//
//  PageASCellNode.swift
//  Spot
//
//  Created by Mats Becker on 2/12/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import NVActivityIndicatorView

class PageASCellNode: ASCellNode {
    
    let _realmPark          : RealmPark
    let _realmParkSection   : RealmParkSection
    
    var items2: [ParkItem2] = [ParkItem2]()
    
    let _firebaseRef        : FIRDatabaseReference
    let _firebasePath       : String!
    
    var observerChildAdded      : FIRDatabaseHandle?
    var observerChildChanged    : FIRDatabaseHandle?
    var obseverCount            : FIRDatabaseHandle?
    let errorLabelNoItems       = UILabel()
    let errorImageNoItems       = UIImageView()
    let loadingIndicatorView    = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
    
    var tableNode: ASTableNode!
    
    weak var delegate:ParkASCellNodeDelegate?
    
    
    
    init(realmPark: RealmPark, realmParkSection: RealmParkSection) {
        self._firebaseRef         = FIRDatabase.database().reference()
        self._firebasePath        = "park/" + realmPark.key + "/" + realmParkSection.path + "/"
        
        self._realmPark           = realmPark
        self._realmParkSection    = realmParkSection
        
        self.tableNode = ASTableNode(style: .grouped)
        
        super.init()
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    func addObserver(){
        removeObserver()
        
        
        // 0. At least 1 x item is in DB; remove error image & label; add loadingindicator
        if self.obseverCount != nil {
            self.errorLabelNoItems.removeFromSuperview()
            self.errorImageNoItems.removeFromSuperview()
            self.view.addSubview(self.loadingIndicatorView)
            self.loadingIndicatorView.startAnimating()
            
            // 1: .childAdded observer
            self.observerChildAdded = self._firebaseRef.child(self._firebasePath).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
                // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
                if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark, type: self._realmParkSection.getType()), self.items2.first(where:{$0.key == item2.key}) == nil {
                    
                    
                    self.items2.insert(item2, at: 0)
                    
                    self.tableNode.performBatchUpdates({
                        self.tableNode.insertRows(at: [[0,0]], with: .none)
                    }, completion: { (inserted) in
                        
                        if inserted {
                            if self.loadingIndicatorView.animating {
                                self.loadingIndicatorView.removeFromSuperview()
                            }
                            self.tableNode.reloadRows(at: [[0, 0]], with: .none)
                        }
                        
                    })
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
        }
        
        
        
        
        // 2: .childChanged observer
        //        self.observerChildChanged = self.ref.child("park").child(self.park.key).child(self.parkSection.path).observe(.childChanged, with: { (snapshot) -> Void in
        //            // ParkItem2 is updated; replace item in table array
        //            if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject] {
        //                for i in 0...self.items2.count-1 {
        //                    if let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self.park, type: self.parkSection.type), self.items2[i].key == item2.key {
        //                        self.items2[i]  = item2
        //                        let indexPath = IndexPath(item: i, section: 0)
        //                        self.collectionNode.reloadItems(at: [indexPath])
        //                    }
        //                }
        //            }
        //
        //        }) { (error) in
        //            print(error.localizedDescription)
        //        }
        
        
    }
    
    
    func removeObserver(){
        if self.observerChildAdded != nil {
            self._firebaseRef.removeObserver(withHandle: self.observerChildAdded!)
        }
        if self.observerChildChanged != nil {
            self._firebaseRef.removeObserver(withHandle: self.observerChildChanged!)
        }
    }
    
    /**
     * Preload Range. The furthest range out from being visible. This is where content is gathered from an external source, whether that’s some API or a local disk.
     */
    override func didEnterPreloadState() {
        super.didEnterPreloadState()
        if self._realmParkSection.name == "Community" {
            print("didEnterPreloadState")
        }
        
        /**
         * Firebase:
         * 1. Count the items in DB
         * 2. Only attach observer if items.count > 0
         * (only attach once an observer)
         */
        self.obseverCount = self._firebaseRef.child(self._firebasePath).child("count").observe(.value, with: { (snapshot) -> Void in
            if snapshot.exists(), let count: Int = snapshot.value as? Int, count > 0 {
                self.addObserver()
            }
        })
        //        self.ref.child("park").child(self.park.key).child(self.parkSection.path).child("count").observe(.childChanged, with: { (snapshot) -> Void in
        //            if let count: Int = snapshot.value as? Int, count > 0 {
        //                self.addObserver()
        //            } else {
        //                self.toggleErrorLabelNoItems(show: true)
        //            }
        //        })
        
    }
    override func didExitPreloadState() {
        super.didExitPreloadState()
        if self._realmParkSection.name == "Community" {
            print("didExitPreloadState")
        }
        
        self._firebaseRef.removeAllObservers()
        self.observerChildAdded = nil
        self.obseverCount = nil
    }
    
    /**
     * Visible Range: The node is onscreen by at least one pixel.
     */
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        if self._realmParkSection.name == "Community" {
            print("didEnterVisibleState")
        }
        if self.items2.count == 0 && self.observerChildAdded == nil {
            self.view.addSubview(self.errorLabelNoItems)
            self.view.addSubview(self.errorImageNoItems)
            self.errorImageNoItems.rotate360Degrees(duration: 2, completionDelegate: self)
        } else if self.items2.count == 0 && self.observerChildAdded != nil {
            self.errorLabelNoItems.removeFromSuperview()
            self.errorImageNoItems.removeFromSuperview()
            self.view.addSubview(self.loadingIndicatorView)
            self.loadingIndicatorView.startAnimating()
        } else if self.items2.count > 0 {
            self.loadingIndicatorView.removeFromSuperview()
        }
    }
    override func didExitVisibleState() {
        super.didExitVisibleState()
        if self._realmParkSection.name == "Community" {
            print("didExitVisibleState")
        }
        self.loadingIndicatorView.removeFromSuperview()
        self.errorImageNoItems.removeFromSuperview()
        self.errorLabelNoItems.removeFromSuperview()
    }
    
    /**
     * Display Range: Here, display tasks such as text rasterization and image decoding take place.
     */
    override func displayWillStart() {
        super.displayWillStart()
        if self._realmParkSection.name == "Community" {
            print("displayWillStart")
        }
    }
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        if self._realmParkSection.name == "Community" {
            print("didEnterDisplayState")
        }
    }
    override func didExitDisplayState() {
        super.didExitDisplayState()
        if self._realmParkSection.name == "Community" {
            print("didExitDisplayState")
        }
    }
    
    /**
     * didLoad: object is initialized (just once)
     */
    override func didLoad() {
        super.didLoad()
        
        // View
        self.view.backgroundColor = UIColor.white
        
        // TableNode
        self.tableNode.view.showsVerticalScrollIndicator    = true
        self.tableNode.allowsSelection                      = true
        self.tableNode.view.backgroundColor                 = UIColor.white
        self.tableNode.view.separatorColor                  = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00) // Bonjour
        self.addSubnode(self.tableNode)
        
        
        // Laodingindicator
        self.loadingIndicatorView.frame = CGRect(x: self.view.bounds.width / 2 - 22, y: self.view.bounds.height / 2  - 22, width: 44, height: 44)
        
        // Error label
        self.errorLabelNoItems.frame = self.view.frame
        self.errorLabelNoItems.text = "No items uploaded ..."
        self.errorLabelNoItems.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
        self.errorLabelNoItems.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.00)
        self.errorLabelNoItems.textAlignment = .center
        
        self.errorImageNoItems.frame = CGRect(x: self.view.bounds.width / 2 - 15, y: self.view.bounds.height / 2 + 22, width: 30, height: 30)
        self.errorImageNoItems.image = UIImage(named:"Turtle-66")
    }
    
    override func layout() {
        self.tableNode.frame = self.frame
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.tableNode.style.flexGrow      = 1
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.tableNode)
    }
    
}

extension PageASCellNode : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.items2.count
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
        let node = ListItemASCellNode(parkItem: self.items2[indexPath.row])
        node.selectionStyle = .blue
        // self.items2[indexPath.row].latitude)
        // self.items2[indexPath.row].longitude
        return node
    }
}

extension PageASCellNode: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 66), max: CGSize(width: 0, height: 66))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
        self.delegate?.didSelectPark(self.items2[indexPath.row])
    }
    
}

extension PageASCellNode: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.errorImageNoItems.rotate360Degrees(duration: CFTimeInterval(randomNumber(range: 1...6)), completionDelegate: self)
    }
}
