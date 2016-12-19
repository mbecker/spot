//
//  SeparatorASCellNode.swift
//  Spot
//
//  Created by Mats Becker on 16/12/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SeparatorASCellNode: ASCellNode {
    
    let _topSeparator = ASImageNode()
    let _bottomSeparator = ASImageNode()
    let _textNode = ASTextNode()
    
    override init(){
        super.init()
        self.backgroundColor = UIColor.cyan
        self._topSeparator.image = UIImage.as_resizableRoundedImage(withCornerRadius: 1.0, cornerColor: UIColor.red, fill: UIColor.red)
        self._bottomSeparator.image = UIImage.as_resizableRoundedImage(withCornerRadius: 1.0, cornerColor: UIColor.red, fill: UIColor.red)
        self._textNode.attributedText = NSAttributedString(
        string: "Country country country",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        self.addSubnode(self._topSeparator)
        self.addSubnode(self._bottomSeparator)
        self.addSubnode(self._textNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self._topSeparator.style.flexGrow = 1.0
        self._bottomSeparator.style.flexGrow = 1.0
        
        let insets = UIEdgeInsetsMake(10, 10, 10, 10)
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: self._textNode)
        
        let verticalSpec = ASStackLayoutSpec.vertical()
        verticalSpec.direction = .vertical
        verticalSpec.justifyContent = .center
        verticalSpec.alignItems = .stretch
        verticalSpec.children = [self._topSeparator, insetSpec, self._bottomSeparator]
        
        return verticalSpec
        
        
    }

}
