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
                let modificationBlock = { (originalImage: UIImage) -> UIImage? in
                    return ASImageNodeTintColorModificationBlock(self._imageColorSelected)(originalImage)
                }
                self.chevron.imageModificationBlock = modificationBlock
            } else {
                self.backgroundColor = UIColor.clear
                self.textAttributes = self._titleAttributes
                self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
            }
        }
    }
    
    override func __setSelected(fromUIKit selected: Bool) {
        if selected {
            self.textAttributes = self._titleAttributesSelected
            self.backgroundColor = UIColor.radicalRed
            let modificationBlock = { (originalImage: UIImage) -> UIImage? in
                return ASImageNodeTintColorModificationBlock(self._imageColorSelected)(originalImage)
            }
            self.chevron.imageModificationBlock = modificationBlock
        } else {
            self.backgroundColor = UIColor.clear
            self.textAttributes = self._titleAttributes
            self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
        }
    }
    
    override func __setHighlighted(fromUIKit highlighted: Bool) {
        if highlighted {
            self.textAttributes = self._titleAttributesSelected
            self.backgroundColor = UIColor.radicalRed
            let modificationBlock = { (originalImage: UIImage) -> UIImage? in
                return ASImageNodeTintColorModificationBlock(self._imageColorSelected)(originalImage)
            }
            self.chevron.imageModificationBlock = modificationBlock
        } else {
            self.textAttributes = self._titleAttributes
            self.backgroundColor = UIColor.clear            
            self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
        }
    }
    
    let _titleAttributes:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.scarlet,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
        ]
    let _titleAttributesSelected:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.white,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
        ]
    
    let chevron = ASImageNode()
    let _imageColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:0.60)
    let _imageColorSelected = UIColor.white
    
    convenience init(title: String) {
        self.init()
        self.text = title
        self.textAttributes = self._titleAttributes
        let chevronImage = UIImage(named: "chevronright_32x17")?.withRenderingMode(.alwaysTemplate)
        self.chevron.image = chevronImage
        
        
    }
    
    override func didLoad() {
        let modificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeTintColorModificationBlock(UIColor(red:0.78, green:0.78, blue:0.80, alpha:0.60))(originalImage)
        }
        self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
        self.chevron.frame = CGRect(x: self.frame.width - 20 - 8.5, y: self.frame.height / 2 - 16 / 2, width: 8.5, height: 16)
        self.addSubnode(self.chevron)
    }

}
