//
//  ItemASCellNode.swift
//  Spot
//
//  Created by Mats Becker on 08/11/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ItemASCellNode: ASCellNode {
    
    let _parkItem: ParkItem!
    var _title = ASTextNode()
    
    init(parkItem: ParkItem){
        self._parkItem = parkItem
        super.init()
        self.addSubnode(self._title)
    }
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor = UIColor.green
        self.view.layer.cornerRadius = 5
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self._title.style.flexShrink    = 1
        self._title.style.flexGrow      = 1
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self._title)
    }
    
    
}
