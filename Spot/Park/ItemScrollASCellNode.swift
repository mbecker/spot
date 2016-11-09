//
//  ItemScrollASCellNode.swift
//  Spot
//
//  Created by Mats Becker on 11/9/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ItemScrollASCellNode: ASCellNode {
    
    var _number: Int!
    var _parkItem: ParkItem!
    
    /**
     * AsyncDisplayKit
     */
    var _tableNode: ASTableNode!
    
    init(number: Int, parkItem: ParkItem) {
        self._number = number
        self._parkItem = parkItem
        self._tableNode = ASTableNode(style: UITableViewStyle.grouped)
        super.init()
        self._tableNode.delegate    = self
        self._tableNode.dataSource  = self
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.backgroundColor = UIColor.clear
        self._tableNode.backgroundColor = UIColor.clear
        self._tableNode.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self._tableNode.view.contentOffset = CGPoint(x: 0, y: 0)
        self._tableNode.view.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubnode(self._tableNode)
    }
    
    override func layout() {
        self._tableNode.frame = self.frame
    }
    

}

extension ItemScrollASCellNode : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let node = ASTextCellNode()
        node.text = "Row: \(indexPath.row)"
        return node
    }
}

extension ItemScrollASCellNode : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 188), max: CGSize(width: 0, height: 188))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}
