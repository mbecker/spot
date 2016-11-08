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

let airBnbImageFooterHeight: CGFloat = 58
let airBnbHeight: CGFloat = 218 + airBnbImageFooterHeight
let airBnbInset = UIEdgeInsetsMake(0, 24, 0, 24)
let airbnbSpacing = 12

class ParkASCellNode: ASCellNode {
    
    var collectionNode: ASCollectionNode!
    let park: Park!
    var items: [ParkItem] = [ParkItem]()
    
    /**
     * Firebase
     */
    var ref: FIRDatabaseReference = FIRDatabaseReference()
    var storage: FIRStorage!
    
    init(park: Park) {
        self.park = park
        self.ref           = FIRDatabase.database().reference()
        self.storage       = FIRStorage.storage()
        
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat(12) // The minimum spacing to use between items in the same row (here: spacing after all items)
        layout.minimumLineSpacing = CGFloat(12) // The minimum spacing to use between lines of items in the grid (here: spacing between items)
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 0)
        layout.itemSize = CGSize(width: 210, height: 290/1.61803398875)
        layout.estimatedItemSize = CGSize(width: 210, height: 290/1.61803398875)
        
        // Ccollection view node: ASCollectionDelegate, ASCollectionDataSource
        self.collectionNode = ASCollectionNode(collectionViewLayout: layout)
        // self.collectionNode!.frame = self.frame
        self.collectionNode.allowsSelection = false
        self.collectionNode.view.showsHorizontalScrollIndicator = false
        self.collectionNode.backgroundColor = UIColor.white
        self.collectionNode.borderWidth = 0.0
        
        super.init()
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.view.backgroundColor = UIColor.yellow
        self.collectionNode.backgroundColor = UIColor.orange
        
        self.addSubnode(self.collectionNode)
        
        // Listen for added snapshots
        self.ref.child(self.park.path).observe(.childAdded, with: { (snapshot) -> Void in
            let item = ParkItem(snapshot: snapshot)
            OperationQueue.main.addOperation({
                self.items.insert(item, at: 0)
                let indexPath = IndexPath(item: 0, section: 0)
                self.collectionNode.insertItems(at: [indexPath])
                self.collectionNode.reloadItems(at: [indexPath])
            })
        })
    }
    
    override func layout() {
        self.collectionNode.frame = self.frame
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.collectionNode.style.flexGrow      = 1
        self.collectionNode.style.flexShrink    = 1
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.collectionNode)
    }

}

extension ParkASCellNode : ASCollectionDelegate, ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        // Use the node block that the collection node is able to prepare and display all of it's cell concurrently
        return {
            let node = ItemASCellNode(parkItem: self.items[indexPath.row])
            node._title.attributedText = NSAttributedString(
                string: self.items[indexPath.row].name,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                    NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])

            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        print("Selected item: \(indexPath.row)")
    }

}
