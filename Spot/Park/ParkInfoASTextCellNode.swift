//
//  ParkInfoASTextCellNode.swift
//  Spot
//
//  Created by Mats Becker on 2/9/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ParkInfoASTextCellNode: ASTextCellNode {
    
    override var isSelected: Bool {
        get {
            return self.isSelected
        }
        set {
            if newValue {
                self.textAttributes = self._titleAttributesSelected
                self.backgroundColor = UIColor.radicalRed
                node.removeFromSupernode()
                self.addSubnode(nodeSelected)
                self.setNeedsDisplay()
            } else {
                self.backgroundColor = UIColor.clear
                self.textAttributes = self._titleAttributes
                nodeSelected.removeFromSupernode()
                self.addSubnode(node)
                self.setNeedsDisplay()
            }
        }
    }
    
    override func __setSelected(fromUIKit selected: Bool) {
        if selected {
            self.textAttributes = self._titleAttributesSelected
            self.backgroundColor = UIColor.radicalRed
            self.addSubnode(nodeSelected)
            node.removeFromSupernode()
            self.addSubnode(nodeSelected)
            self.setNeedsDisplay()
        } else {
            self.backgroundColor = UIColor.clear
            self.textAttributes = self._titleAttributes
            nodeSelected.removeFromSupernode()
            self.addSubnode(node)
            self.setNeedsDisplay()
        }
    }
    
    override func __setHighlighted(fromUIKit highlighted: Bool) {
        if highlighted {
            self.textAttributes = self._titleAttributesSelected
            self.backgroundColor = UIColor.radicalRed
            node.removeFromSupernode()
            self.addSubnode(nodeSelected)
            self.setNeedsDisplay()
        } else {
            self.textAttributes = self._titleAttributes
            self.backgroundColor = UIColor.clear
            nodeSelected.removeFromSupernode()
            self.addSubnode(node)
            self.setNeedsDisplay()
        }
    }
    
    let _titleAttributes:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.scarlet,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.6,
        ]
    let _titleAttributesSelected:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.white,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.6,
        ]
    
    
    let _imageColor = UIColor.green // UIColor(red:0.78, green:0.78, blue:0.80, alpha:0.60)
    let _imageColorSelected = UIColor.white
    
    let node = ASDisplayNode(viewBlock: { () -> UIView in
        let chevronImage = UIImage(named: "chevronright_32x17")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: chevronImage?.withRenderingMode(.alwaysTemplate))
        imageView.alpha = 1.0
        imageView.tintColor = UIColor.scarlet
        return imageView
    })
    let nodeSelected = ASDisplayNode(viewBlock: { () -> UIView in
        let chevronImage = UIImage(named: "chevronright_32x17")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: chevronImage?.withRenderingMode(.alwaysTemplate))
        imageView.alpha = 1.0
        imageView.tintColor = UIColor.white
        return imageView
    })
    
    convenience init(title: String) {
        self.init()
        self.text = title
        self.textAttributes = self._titleAttributes
    }
    
    override func didLoad() {
        nodeSelected.frame = CGRect(x: self.frame.width - 20 - 8.5, y: self.frame.height / 2 - 16 / 2, width: 8.5, height: 16)
        node.frame = CGRect(x: self.frame.width - 20 - 8.5, y: self.frame.height / 2 - 16 / 2, width: 8.5, height: 16)
        self.addSubnode(node)
    }

}
