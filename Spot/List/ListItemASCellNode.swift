//
//  ItemASCellNode.swift
//  Spot
//
//  Created by Mats Becker on 08/11/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseStorage

class ListItemASCellNode: ASCellNode {
    
    var _parkItem    : ParkItem2
    var _storage            : FIRStorage
    var _image              : ASNetworkImageNode
    
    var _title              =   ASTextNode()
    var _detail             =   ASTextNode()
    var _errorText          =   ASTextNode()
    var _loadingIndicator   =   BallPulse()
    
    let _titleAttributes:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.black, // UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
    ]
    let _titleAttributesSelected:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.white,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
        ]
    let _detailAttributes:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight), // UIFont(name: "Avenir-Book", size: 12)!,
        NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00), // grey
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
    ]
    let _detailAttributesSelected:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight), // UIFont(name: "Avenir-Book", size: 12)!,
        NSForegroundColorAttributeName: UIColor.white,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
        ]
    
    
    override var isSelected: Bool {
        get {
            return self.isSelected
        }
        set {
            if newValue {
                self.backgroundColor = UIColor.radicalRed // UIColor(red:0.93, green:0.23, blue:0.33, alpha:0.20) // UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00).withAlphaComponent(0.6) // Bonjour
                self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string, attributes: self._titleAttributesSelected)
                self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string, attributes: self._detailAttributesSelected)
            } else {
                self.backgroundColor = UIColor.clear
                self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string, attributes: self._titleAttributes)
                self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string, attributes: self._detailAttributes)
            }
        }
    }
    
    override func __setSelected(fromUIKit selected: Bool) {
        if selected {
            self.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00) // very light grey
        } else {
            self.backgroundColor = UIColor.clear
            self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string, attributes: self._titleAttributes)
            self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string, attributes: self._detailAttributes)
        }
    }
    
    override func __setHighlighted(fromUIKit highlighted: Bool) {
        if highlighted {
            self.backgroundColor = UIColor.radicalRed // UIColor(red:0.93, green:0.23, blue:0.33, alpha:0.20) // UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00).withAlphaComponent(0.6) // Bonjour
            self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string, attributes: self._titleAttributesSelected)
            self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string, attributes: self._detailAttributesSelected)
        } else {
            self.backgroundColor = UIColor.clear
            self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string, attributes: self._titleAttributes)
            self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string, attributes: self._detailAttributes)
        }
    }
    
    init(parkItem: ParkItem2){
        self._parkItem                  = parkItem
        self._storage                   = FIRStorage.storage()
        let cache                       = KingfisherCache.sharedManager
        self._image                     = ASNetworkImageNode(cache: cache, downloader: cache)
        
        self._image.placeholderEnabled  = true
        // self._image.defaultImage        = UIImage(named: "imagebackgrounddefault")
        self._image.backgroundColor     = UIColor(red:0.89, green:0.89, blue:0.89, alpha:0.30)
        self._image.contentMode         = .scaleAspectFill
        
        super.init()
        
        // self.shouldRasterizeDescendants = true // This line will cause the entire node hierarchy from that point on to be rendered into one layer http://asyncdisplaykit.org/docs/subtree-rasterization.html
        
        self._image.delegate            = self
        
        self.addSubnode(self._image)
        self.addSubnode(self._errorText)
        self.addSubnode(self._detail)
        self.addSubnode(self._title)
        self.addSubnode(self._loadingIndicator)
        loadImage()
    }
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor = UIColor.white
        self._image.imageModificationBlock = { image in
            var modifiedImage: UIImage?
            let rect = CGRect(origin: CGPoint.zero, size: image.size)
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 10, height: 10))
            maskPath.addClip()
            image.draw(in: rect)
            modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return modifiedImage
        }
        self.setNeedsLayout()
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let imageWidth = (constrainedSize.max.height - 16) * 4 / 3
        let imageHeight = (constrainedSize.max.height - 16)
        
        self._image.style.width             = ASDimension(unit: .points, value: imageWidth)
        self._image.style.height            = ASDimension(unit: .points, value: imageHeight)
        
        self._loadingIndicator.style.width  = ASDimension(unit: .points, value: 44)
        self._loadingIndicator.style.height = ASDimension(unit: .points, value: 44)
        
        let loadingIndicatorInsetSpec       = ASInsetLayoutSpec(insets: UIEdgeInsets(top: imageHeight / 2 - 22, left: imageWidth / 2 - 22, bottom: 0, right: 0), child: self._loadingIndicator)
        
        
        self._errorText.style.alignSelf     = .center
        // self._errorText.style.width         = ASDimension(unit: .points, value: self._imageHeight * 2 / 3)
        // self._errorText.style.height        = ASDimension(unit: .points, value: 28.640625)
        self._errorText.backgroundColor     = UIColor.clear
        self._errorText.style.flexGrow      = 1.0
        
        let errorCenterLayout               = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self._errorText)
        errorCenterLayout.style.width       = ASDimension(unit: .points, value: imageWidth - 8)
        errorCenterLayout.style.height      = ASDimension(unit: .points, value: imageHeight - 8)
        
        let errorTextOverlaySpec            = ASOverlayLayoutSpec(child: self._image, overlay: errorCenterLayout)
        
        let loadingIndicatorOverlaySpec     = ASOverlayLayoutSpec(child: errorTextOverlaySpec, overlay: loadingIndicatorInsetSpec)
        
        self._title.attributedText          = NSAttributedString(string: self._parkItem.name, attributes: self._titleAttributes)
        
        //self._title.style.height            = ASDimension(unit: .points, value: (constrainedSize.max.height - 16) / 2)
        self._title.style.width             = ASDimension(unit: .points, value: constrainedSize.max.width - 16 - imageWidth - 16 - 16)
        
        self._detail.attributedText         = NSAttributedString(string: "12mins ago • 5.1km away", attributes: self._detailAttributes)
        // self._detail.style.height            = ASDimension(unit: .points, value: constrainedSize.max.height / 2)
        self._detail.style.width            = ASDimension(unit: .points, value: constrainedSize.max.width - 16 - imageWidth - 16 - 16)
        
        // self._title.backgroundColor = UIColor.linkWater
        // self._detail.backgroundColor = UIColor.lightGray
        
        let verticalTextStackSpec           = ASStackLayoutSpec(direction: .vertical, spacing: 2, justifyContent: .start, alignItems: .start, children: [self._title, self._detail])
        verticalTextStackSpec.style.height  = ASDimension(unit: .points, value: constrainedSize.max.height)
        verticalTextStackSpec.style.alignSelf = .start
        
        let horizontalStackSpec               = ASStackLayoutSpec(direction: .horizontal, spacing: 16, justifyContent: .start, alignItems: .start, children: [loadingIndicatorOverlaySpec, verticalTextStackSpec])
        horizontalStackSpec.style.flexGrow    = 1.0
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: (constrainedSize.max.height - imageHeight) / 2, left: 16, bottom: 0, right: 16), child: horizontalStackSpec)
    }
    
    func loadImage() {
        if let imageURL: URL = self._parkItem.image?.resized["375x300"]?.publicURL {
            self._image.url = imageURL
        } else if let imageURL: URL = self._parkItem.image?.original?.publicURL {
            self._image.url = imageURL
        } else {
            // Show error
            // self._image.url = URL(string: "https://error.com")
            self._loadingIndicator.removeFromSupernode()
            self.showError(text: "Error:\nNo image uploaded")
        }
    }
    
    func showError(text: String){
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        self._errorText.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 9, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                NSForegroundColorAttributeName: UIColor.black,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                NSParagraphStyleAttributeName: paragraph,
                ])
        self.setNeedsLayout()
    }
    
    
}


extension ListItemASCellNode: ASNetworkImageNodeDelegate {
    
    func imageNodeDidFinishDecoding(_ imageNode: ASNetworkImageNode) {
        self._loadingIndicator.removeFromSupernode()
    }
    
    func imageNode(_ imageNode: ASNetworkImageNode, didFailWithError error: Error) {
        // ToDo: Show error text
        print(":: IMAGE DID FAIL WITH ERROR ::")
        print(error)
        self._loadingIndicator.removeFromSupernode()
        self.showError(text: "Error:\nLoading did fail")
    }
    
}
