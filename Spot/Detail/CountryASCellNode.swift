//
//  CountryASCellNode.swift
//  Spot
//
//  Created by Mats Becker on 16/12/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class CountryASCellNode: ASCellNode {
    
    let _park: Park
    
    var _parkTextNode           = ASTextNode()
    var _countryTextNode        = ASTextNode()
    var _countryImageNode       = ASImageNode()
    var _parkImageNode          = ASImageNode()
    let _bottomSeparatorNode    = ASImageNode()
    let _topSeparatorNode       = ASImageNode()
    
    let _height: CGFloat        = 86
    let _imageHeight: CGFloat   = 32
    let _imageWidth: CGFloat    = 32
    
    override var isSelected: Bool {
        get {
            return self.isSelected
        }
        set {
            if newValue {
                self.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00).withAlphaComponent(0.6) // Bonjour
            } else {
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    override var isHighlighted: Bool {
        get {
            return self.isHighlighted
        }
        set {
            if newValue {
                self.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00).withAlphaComponent(0.6) // Bonjour
            } else {
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.backgroundColor = UIColor.white
    }
    
    init(park: Park){
        self._park = park
        self._bottomSeparatorNode.image = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: UIColor.clear, fill: UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00))  // Lilly White
        self._topSeparatorNode.image    = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: UIColor.clear, fill: UIColor.clear)
        super.init()
        addNodes(name: park.name, country: park.country)

    }
    
    func addNodes(name: String, country: String?){
        self._parkTextNode.attributedText = NSAttributedString(
            string: name,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        
        if country != nil && !(country?.isEmpty)! {
            self._countryTextNode.attributedText = NSAttributedString(
                string: country!,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
        }
        
        // Image
        let cache                               = KingfisherCache.sharedManager
        self._parkImageNode                         = ASNetworkImageNode(cache: cache, downloader: cache)
        self._parkImageNode.placeholderEnabled      = false
        self._parkImageNode.backgroundColor         = UIColor.clear
        self._parkImageNode.contentMode             = .scaleAspectFill
        
        self._countryImageNode                      = ASNetworkImageNode(cache: cache, downloader: cache)
        self._countryImageNode.placeholderEnabled   = false
        self._countryImageNode.backgroundColor      = UIColor.clear
        self._countryImageNode.contentMode          = .scaleAspectFill
        
        self.addSubnode(self._parkTextNode)
        self.addSubnode(self._countryTextNode)
        self.addSubnode(self._countryImageNode)
        self.addSubnode(self._parkImageNode)
        self.addSubnode(self._bottomSeparatorNode)
    }
    
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor        = UIColor.clear
        self._countryImageNode.imageModificationBlock = { image in
            var modifiedImage: UIImage?
            let rect = CGRect(origin: CGPoint.zero, size: image.size)
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: self._imageWidth, height: self._imageHeight))
            maskPath.addClip()
            image.draw(in: rect)
            modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return modifiedImage
        }
        self._parkImageNode.imageModificationBlock = { image in
            var modifiedImage: UIImage?
            let rect = CGRect(origin: CGPoint.zero, size: image.size)
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: self._imageWidth, height: self._imageHeight))
            maskPath.addClip()
            image.draw(in: rect)
            modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return modifiedImage
        }

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self._parkImageNode.style.width             = ASDimension(unit: .points, value: self._imageWidth)
        self._parkImageNode.style.height            = ASDimension(unit: .points, value: self._imageHeight)
        
        self._countryImageNode.style.width             = ASDimension(unit: .points, value: self._imageWidth)
        self._countryImageNode.style.height            = ASDimension(unit: .points, value: self._imageHeight)
        
        
        let textVerticalStack               = ASStackLayoutSpec.vertical()
        textVerticalStack.style.flexGrow    = 1.0
        textVerticalStack.style.flexShrink  = 1.0
        textVerticalStack.alignItems        = .stretch
        
        
        textVerticalStack.sizeRange        = ASRelativeSizeRangeMake(
            ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width), height: ASDimension(unit: .points, value: 0)), // min
            ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width), height: ASDimension(unit: .points, value: constrainedSize.max.height)) // max
        )
        if self._countryTextNode.attributedText != nil {
            textVerticalStack.children = [self._parkTextNode, self._countryTextNode]
        } else {
            textVerticalStack.children = [self._parkTextNode]
        }
        
        // Images
        self._countryImageNode.style.preferredSize = CGSize(width: self._imageWidth, height: self._imageHeight)
        self._countryImageNode.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        self._parkImageNode.style.preferredSize = CGSize(width: self._imageWidth, height: self._imageWidth)
        self._parkImageNode.style.layoutPosition = CGPoint(x: self._imageWidth / 2, y: 0)
        
        let imageAbsoluteSpec           = ASAbsoluteLayoutSpec(children: [self._countryImageNode, self._parkImageNode])
        imageAbsoluteSpec.style.height   = ASDimension(unit: .points, value: self._imageHeight)
        
        if let countryIcon = self._park.countryIcon {
            self._countryImageNode.image = AssetManager.getImage(countryIcon)
        }
        if let parkIcon = self._park.parkIcon {
            self._parkImageNode.image = AssetManager.getImage(parkIcon)
        }
        
        // Horizontal Stack
        let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                    spacing: 0,
                                                    justifyContent: .start,
                                                    alignItems: .center,
                                                    children: [textVerticalStack, imageAbsoluteSpec])
        horizontalStackSpec.style.alignSelf = .start
        horizontalStackSpec.style.flexGrow = 1.0
        
        
        
        // self._bottomSeparatorNode.style.flexGrow    = 1.0
        self._bottomSeparatorNode.style.height = ASDimension(unit: .points, value: 1.1)
        // self._topSeparatorNode.style.flexGrow       = 1.0
        self._topSeparatorNode.style.height = ASDimension(unit: .points, value: 1.0)
        
        let verticalSpec = ASStackLayoutSpec.vertical()
        verticalSpec.direction = .vertical
        verticalSpec.justifyContent = .center
        verticalSpec.alignItems = .stretch
        verticalSpec.children = [self._topSeparatorNode, horizontalStackSpec, self._bottomSeparatorNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: verticalSpec)
    }
    
    
    
}
