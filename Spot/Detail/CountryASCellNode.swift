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
    
    let _parkItem   :   ParkItem2!
    
    var _park       =   ASTextNode()
    var _country    =   ASTextNode()
    
    var _countryImage   = ASImageNode()
    var _parkImage      = ASImageNode()
    let _bottomSeparator = ASImageNode()
    let _topSeparator = ASImageNode()
    
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
    
    init(parkItem: ParkItem2){
        self._parkItem              = parkItem
        
        // Labels
        self._park.attributedText = NSAttributedString(
            string: self._parkItem.park.parkName,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        
        if parkItem.park.country != nil && !(parkItem.park.country?.isEmpty)! {
            self._country.attributedText = NSAttributedString(
                string: self._parkItem.park.country!,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
        }

        
        // Image
        let cache                               = KingfisherCache.sharedManager
        self._parkImage                         = ASNetworkImageNode(cache: cache, downloader: cache)
        self._parkImage.placeholderEnabled      = false
        self._parkImage.backgroundColor         = UIColor.clear
        self._parkImage.contentMode             = .scaleAspectFill
        
        self._countryImage                      = ASNetworkImageNode(cache: cache, downloader: cache)
        self._countryImage.placeholderEnabled   = false
        self._countryImage.backgroundColor      = UIColor.clear
        self._countryImage.contentMode          = .scaleAspectFill
        
        
        self._bottomSeparator.image = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: UIColor.clear, fill: UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00))  // Lilly White
        self._topSeparator.image = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: UIColor.clear, fill: UIColor.clear)
        
        super.init()
        // self.shouldRasterizeDescendants = true // This line will cause the entire node hierarchy from that point on to be rendered into one layer http://asyncdisplaykit.org/docs/subtree-rasterization.html
        
        self.addSubnode(self._park)
        self.addSubnode(self._country)
        self.addSubnode(self._countryImage)
        self.addSubnode(self._parkImage)
        self.addSubnode(self._bottomSeparator)
    }
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor        = UIColor.clear
        self._countryImage.imageModificationBlock = { image in
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
        self._parkImage.imageModificationBlock = { image in
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
        
        self._parkImage.style.width             = ASDimension(unit: .points, value: self._imageWidth)
        self._parkImage.style.height            = ASDimension(unit: .points, value: self._imageHeight)
        
        self._countryImage.style.width             = ASDimension(unit: .points, value: self._imageWidth)
        self._countryImage.style.height            = ASDimension(unit: .points, value: self._imageHeight)
        
        
        let textVerticalStack               = ASStackLayoutSpec.vertical()
        textVerticalStack.style.flexGrow    = 1.0
        textVerticalStack.style.flexShrink  = 1.0
        textVerticalStack.alignItems        = .stretch
        
        
        textVerticalStack.sizeRange        = ASRelativeSizeRangeMake(
            ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width), height: ASDimension(unit: .points, value: 0)), // min
            ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width), height: ASDimension(unit: .points, value: constrainedSize.max.height)) // max
        )
        if self._country.attributedText != nil {
            textVerticalStack.children = [self._park, self._country]
        } else {
            textVerticalStack.children = [self._park]
        }
        
        // Images
        self._countryImage.style.preferredSize = CGSize(width: self._imageWidth, height: self._imageHeight)
        self._countryImage.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        self._parkImage.style.preferredSize = CGSize(width: self._imageWidth, height: self._imageWidth)
        self._parkImage.style.layoutPosition = CGPoint(x: self._imageWidth / 2, y: 0)
        
        let imageAbsoluteSpec           = ASAbsoluteLayoutSpec(children: [self._countryImage, self._parkImage])
        imageAbsoluteSpec.style.height   = ASDimension(unit: .points, value: self._imageHeight)
        
        self._countryImage.image    = self._parkItem.park.countryIcon
        self._parkImage.image       = self._parkItem.park.parkIcon
        
        
        // Horizontal Stack
        let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                    spacing: 0,
                                                    justifyContent: .start,
                                                    alignItems: .center,
                                                    children: [textVerticalStack, imageAbsoluteSpec])
        horizontalStackSpec.style.alignSelf = .start
        horizontalStackSpec.style.flexGrow = 1.0
        
        
        
        // self._bottomSeparator.style.flexGrow    = 1.0
        self._bottomSeparator.style.height = ASDimension(unit: .points, value: 1.1)
        // self._topSeparator.style.flexGrow       = 1.0
        self._topSeparator.style.height = ASDimension(unit: .points, value: 1.0)
        
        let verticalSpec = ASStackLayoutSpec.vertical()
        verticalSpec.direction = .vertical
        verticalSpec.justifyContent = .center
        verticalSpec.alignItems = .stretch
        verticalSpec.children = [self._topSeparator, horizontalStackSpec, self._bottomSeparator]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: verticalSpec)
    }
    
    
    
}
