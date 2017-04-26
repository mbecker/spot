//
//  ParkASCellNode.swift
//  Spot
//
//  Created by Mats Becker on 08/11/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import NVActivityIndicatorView
import SwiftDate

let airBnbImageFooterHeight: CGFloat = 58
let airBnbHeight: CGFloat = 218 + airBnbImageFooterHeight
let airBnbInset = UIEdgeInsetsMake(0, 24, 0, 24)
let airbnbSpacing = 12

protocol ParkASCellNodeDelegate: class {
    func didSelectPark(_ item: ParkItem2)
}
class ParkASCellNode: ASCellNode {
    
    let _realmPark          : RealmPark
    let _realmParkSection   : RealmParkSection
    
    var collectionNode      : ASCollectionNode!
    
    var items2: [ParkItem2]     = [ParkItem2]()
    var nodes: [ItemASCellNode] = [ItemASCellNode]()
    
    weak var delegate:ParkASCellNodeDelegate?
    
    var observerChildAdded      : FIRDatabaseHandle?
    var observerChildChanged    : FIRDatabaseHandle?
    var obseverCount            : FIRDatabaseHandle?
    let errorLabelNoItems = UILabel()
    let errorImageNoItems = UIImageView()
    
    /**
     * Firebase
     */
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 88, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
    
    init(realmPark: RealmPark, parkSectionNumber: Int) {
        self._realmPark           = realmPark
        self._realmParkSection    = realmPark.sections[parkSectionNumber]
        
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat(16) // The minimum spacing to use between items in the same row (here: spacing after all items)
        layout.minimumLineSpacing = CGFloat(16) // The minimum spacing to use between lines of items in the grid (here: spacing between items)
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 186/2)
        layout.itemSize = CGSize(width: 186, height: 188)
        layout.estimatedItemSize = CGSize(width: 186, height: 188)
        
        // Ccollection view node: ASCollectionDelegate, ASCollectionDataSource
        self.collectionNode = ASCollectionNode(collectionViewLayout: layout)
        // self.collectionNode!.frame = self.frame
        self.collectionNode.allowsSelection = true
        self.collectionNode.view.showsHorizontalScrollIndicator = false
        self.collectionNode.borderWidth = 0.0
        
        super.init()
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
    }
    
    func addObserver(){
        removeObserver()
        
        
        // 0. At least 1 x item is in DB; remove error image & label; add loadingindicator
        if self.obseverCount != nil {
            self.errorLabelNoItems.removeFromSuperview()
            self.errorImageNoItems.removeFromSuperview()
            self.view.addSubview(self.loadingIndicatorView)
            
            // 1: .childAdded observer
            self.observerChildAdded = self.ref.child("park").child(self._realmPark.key).child(self._realmParkSection.path).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
                // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
                if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark, type: self._realmParkSection.getType()), self.items2.first(where:{$0.key == item2.key}) == nil {
                    
                    
                    
                    self.items2.insert(item2, at: 0)
                    
                    self.collectionNode.performBatchUpdates({
                        self.collectionNode.insertItems(at: [[0,0]])
                    }, completion: { (inserted) in
                        
                        if inserted {
                            // self.collectionNode.reloadItems(at: [[0,0]])
                            if self.loadingIndicatorView.animating {
                                self.loadingIndicatorView.stopAnimating()
                            }
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
            self.ref.removeObserver(withHandle: self.observerChildAdded!)
        }
        if self.observerChildChanged != nil {
            self.ref.removeObserver(withHandle: self.observerChildChanged!)
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
        self.obseverCount = self.ref.child("park").child(self._realmPark.key).child(self._realmParkSection.path).child("count").observe(.value, with: { (snapshot) -> Void in
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
        
        self.ref.removeAllObservers()
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
    
    
    
    
    override func didLoad() {
        super.didLoad()
        
        // View
        self.view.backgroundColor = UIColor.white
        
        // CollectionNode
        self.collectionNode.backgroundColor = UIColor.white
        self.addSubnode(self.collectionNode)
        
        // Laodingindicator
        self.loadingIndicatorView.frame = CGRect(x: self.view.bounds.width / 2 - 22, y: 188 / 2 - 22, width: 44, height: 44)
        
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
        self.collectionNode.frame = self.frame
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.collectionNode.style.flexGrow      = 1
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.collectionNode)
    }

}

extension ParkASCellNode : ASCollectionDelegate, ASCollectionDataSource {
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        if self.items2.count > 0 {
            self.loadingIndicatorView.removeFromSuperview()
        }
        return self.items2.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        // Use the node block that the collection node is able to prepare and display all of it's cell concurrently
        return {
            let parkitem = self.items2[indexPath.row]
            let node = ItemASCellNode(parkItem: parkitem)
            node._title.attributedText = NSAttributedString(
                string: self.items2[indexPath.row].name,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                    NSForegroundColorAttributeName: UIColor.black,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            /*
            node._detail.attributedText = NSAttributedString(
                string: "Latitude: \(self.items2[indexPath.row].latitude) - Longitude \(self.items2[indexPath.row].longitude)",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight), // UIFont(name: "Avenir-Book", size: 12)!,
                    NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00), // grey
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            */
            if self.items2[indexPath.row].timestamp != nil {
                // Define current region tegt correct date/time
                // let region = Region(tz: TimeZone.current, cal: Calendar.current, loc: Locale.current)
                // let date = self.items2[indexPath.row].timestamp!.toRegion(region).string(format: .custom("HH:mm dd.MM.yyyy"))
                // Format the date to get the string "%d days ago"
                let formatter = DateInRegionFormatter()
                formatter.allowedComponents = [.year, .month, .day, .hour]
                
                do {
                    let result = try formatter.colloquial(from: self.items2[indexPath.row].timestamp!, to: DateInRegion(absoluteDate: Date()))
                    node._detail.attributedText = NSAttributedString(
                        string: "\(result.colloquial) \(result.time ?? "")",
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight), // UIFont(name: "Avenir-Book", size: 12)!,
                            NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00), // grey
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.0,
                            ])
                } catch {
                    debugPrint(error.localizedDescription, error)
                }
                
            }
            
            self.nodes.append(node)
            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let parkItem = self.items2[indexPath.row]
        self.delegate?.didSelectPark(parkItem)
    }

}

extension ParkASCellNode: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.errorImageNoItems.rotate360Degrees(duration: CFTimeInterval(randomNumber(range: 1...6)), completionDelegate: self)
    }
}
