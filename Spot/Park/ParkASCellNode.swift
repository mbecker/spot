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
import FirebaseStorage
import NVActivityIndicatorView

let airBnbImageFooterHeight: CGFloat = 58
let airBnbHeight: CGFloat = 218 + airBnbImageFooterHeight
let airBnbInset = UIEdgeInsetsMake(0, 24, 0, 24)
let airbnbSpacing = 12

protocol ParkASCellNodeDelegate: class {
    func didSelectPark(_ item: ParkItem2)
}
class ParkASCellNode: ASCellNode {
    
    var collectionNode: ASCollectionNode!
    let parkSection: ParkSection!
    let park: Park!
    var items2: [ParkItem2] = [ParkItem2]()
    var nodes = [ItemASCellNode]()
    let type: ItemType
    weak var delegate:ParkASCellNodeDelegate?
    
    var observerChildAdded: FIRDatabaseHandle?
    var observerChildChanged: FIRDatabaseHandle?
    let errorLabelNoItems = UILabel()
    var errorImageNoItems: UIImageView!
    
    /**
     * Firebase
     */
    var ref: FIRDatabaseReference = FIRDatabaseReference()
    var storage: FIRStorage!
    
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 88, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
    
    init(park: Park, section: Int, type: ItemType) {
        self.parkSection    = park.sections[section]
        self.park           = park
        self.type           = type
        self.ref            = FIRDatabase.database().reference()
        self.storage        = FIRStorage.storage()
        
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
        self.toggleErrorLabelNoItems(show: false)
        // 1: .childAdded observer
        self.observerChildAdded = self.ref.child("park").child(self.park.key).child(self.parkSection.path).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
            // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
            if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, type: self.type, park: self.park), self.items2.contains(where: {$0.key == item2.key}) == false {
                if self.loadingIndicatorView.animating {
                    self.loadingIndicatorView.stopAnimating()
                }
                self.items2.insert(item2, at: 0)
                let indexPath = IndexPath(item: 0, section: 0)
                self.collectionNode.insertItems(at: [indexPath])
                self.collectionNode.reloadItems(at: [indexPath])
            }
            
        })
        
        // 2: .childChanged observer
        self.observerChildChanged = self.ref.child("park").child(self.park.key).child(self.parkSection.path).observe(.childChanged, with: { (snapshot) -> Void in
            // ParkItem2 is updated; replace item in table array
            if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject] {
                for i in 0...self.items2.count-1 {
                    if let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, type: self.type, park: self.park), self.items2[i].key == item2.key {
                        self.items2[i]  = item2
                        let indexPath = IndexPath(item: i, section: 0)
                        self.collectionNode.reloadItems(at: [indexPath])
                    }
                }
            }
            
        })
        
        
    }
    
    func toggleErrorLabelNoItems(show: Bool) {
        if show {
            self.loadingIndicatorView.stopAnimating()
            self.view.addSubview(self.errorLabelNoItems)
            self.view.addSubview(self.errorImageNoItems)
            self.errorImageNoItems.rotate360Degrees(duration: 2, completionDelegate: self)
            removeObserver()
        } else {
            self.errorLabelNoItems.removeFromSuperview()
            self.errorImageNoItems.removeFromSuperview()
            self.loadingIndicatorView.startAnimating()
        }
        
    }
    
    func removeObserver(){
        if self.observerChildAdded != nil {
            self.ref.removeObserver(withHandle: self.observerChildAdded!)
        }
        if self.observerChildAdded != nil {
            self.ref.removeObserver(withHandle: self.observerChildChanged!)
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
        self.loadingIndicatorView.startAnimating()
        self.collectionNode.view.addSubview(self.loadingIndicatorView)
        
        // Error label
        self.errorLabelNoItems.frame = self.view.frame
        self.errorLabelNoItems.text = "No items uploaded ..."
        self.errorLabelNoItems.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
        self.errorLabelNoItems.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.00)
        self.errorLabelNoItems.textAlignment = .center
        
        self.errorImageNoItems = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - 15, y: self.view.bounds.height / 2 + 22, width: 30, height: 30))
        self.errorImageNoItems.image = UIImage(named:"Turtle-66")
        
        /**
         * Firebase:
         * 1. Count the items in DB
         * 2. Only attach observer if items.count > 0
         * (only attach once an observer)
         */
        self.ref.child("park").child(self.park.key).child(self.parkSection.path).child("count").observe(.value, with: { (snapshot) -> Void in
            if snapshot.exists(), let count: Int = snapshot.value as? Int, count > 0 {
                self.addObserver()
            } else {
                self.toggleErrorLabelNoItems(show: true)
            }
        })
        self.ref.child("park").child(self.park.key).child(self.parkSection.path).child("count").observe(.childChanged, with: { (snapshot) -> Void in
            if let count: Int = snapshot.value as? Int, count > 0 {
                self.addObserver()
            } else {
                self.toggleErrorLabelNoItems(show: true)
            }
        })
        
    }
    
    override func layout() {
        self.collectionNode.frame = self.frame
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.collectionNode.style.flexGrow      = 1
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.collectionNode)
    }

}

extension ParkASCellNode: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.errorImageNoItems.rotate360Degrees(duration: CFTimeInterval(randomNumber(range: 1...6)), completionDelegate: self)
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
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                    NSForegroundColorAttributeName: UIColor.black,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            node._detail.attributedText = NSAttributedString(
                string: "Latitude: \(self.items2[indexPath.row].latitude) - Longitude \(self.items2[indexPath.row].longitude)",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight), // UIFont(name: "Avenir-Book", size: 12)!,
                    NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00), // grey
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            self.nodes.append(node)
            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let parkItem = self.items2[indexPath.row]
        self.delegate?.didSelectPark(parkItem)
    }

}
