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
        if self._number == 1 {
            self.view.backgroundColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00)
        } else {
            self.view.backgroundColor = UIColor(red:0.19, green:0.26, blue:0.35, alpha:1.00)
        }
        
        self._tableNode.backgroundColor = UIColor.clear
        
        
        
        self.addSubnode(self._tableNode)
    }
    
    override func layout() {
        self._tableNode.frame = self.frame
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self._tableNode.style.flexGrow      = 1
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self._tableNode)
    }
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow
        
        return view
    }()

}

extension ItemScrollASCellNode : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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
