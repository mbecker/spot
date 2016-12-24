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
    
    let _parkItem   :   ParkItem2!
    var _storage     :   FIRStorage
    var _image      :   ASNetworkImageNode
    
    var _title              =   ASTextNode()
    var _detail             =   ASTextNode()
    var _errorText          =   ASTextNode()
    var _loadingIndicator   =   BallPulse()
    
    let _height: CGFloat        = 80 // 112
    let _imageHeight: CGFloat   = 64 // 96
    let _imageWidth: CGFloat    = 64 // 103.55417528 // 142
    
    override var isSelected: Bool {
        get {
            return self.isSelected
        }
        set {
            if newValue {
                self.backgroundColor = UIColor(red:0.93, green:0.23, blue:0.33, alpha:1.00) // UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00).withAlphaComponent(0.6) // Bonjour
                self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string,
                                                                 attributes: [
                                                                    NSForegroundColorAttributeName: UIColor.white
                    ])
                self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string,
                                                                attributes: [
                                                                    NSForegroundColorAttributeName: UIColor.black
                    ])
            } else {
                self.backgroundColor = UIColor.clear
                self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string,
                                                                 attributes: [
                                                                    NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00), // grey
                    ])
                self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string,
                                                                attributes: [
                                                                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00) // Bunker
                    ])
            }
        }
    }
    
    override func __setHighlighted(fromUIKit highlighted: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(red:0.93, green:0.23, blue:0.33, alpha:1.00) // UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00).withAlphaComponent(0.6) // Bonjour
            self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string,
                                                             attributes: [
                                                                NSForegroundColorAttributeName: UIColor.white
                ])
            self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string,
                                                             attributes: [
                                                                NSForegroundColorAttributeName: UIColor.black
                ])
            
        } else {
            self.backgroundColor = UIColor.white
            self._detail.attributedText = NSAttributedString(string: self._detail.attributedText!.string,
                                                             attributes: [
                                                                NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00), // grey
                ])
            self._title.attributedText = NSAttributedString(string: self._title.attributedText!.string,
                                                            attributes: [
                                                                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00) // Bunker
                ])

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
        
        self._title.attributedText = NSAttributedString(
            string: parkItem.name,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        self._detail.attributedText = NSAttributedString(
            string: "12mins ago • 5.1km away",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight), // UIFont(name: "Avenir-Book", size: 12)!,
                NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00), // grey
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])

        
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
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self._loadingIndicator.style.width  = ASDimension(unit: .points, value: 44)
        self._loadingIndicator.style.height = ASDimension(unit: .points, value: 44)
        
        let loadingIndicatorInsetSpec       = ASInsetLayoutSpec(insets: UIEdgeInsets(top: self._imageHeight / 2 - 22, left: self._imageWidth / 2 - 22, bottom: 0, right: 0), child: self._loadingIndicator)
        
        self._image.style.width             = ASDimension(unit: .points, value: self._imageWidth)
        self._image.style.height            = ASDimension(unit: .points, value: self._imageHeight)
        
        self._errorText.style.alignSelf     = .center
        // self._errorText.style.width         = ASDimension(unit: .points, value: self._imageHeight * 2 / 3)
        // self._errorText.style.height        = ASDimension(unit: .points, value: 28.640625)
        self._errorText.backgroundColor     = UIColor.clear
        self._errorText.style.flexGrow = 1.0
        
        let errorCenterLayout               = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self._errorText)
        errorCenterLayout.style.width       = ASDimension(unit: .points, value: self._imageWidth - 8)
        errorCenterLayout.style.height      = ASDimension(unit: .points, value: self._imageHeight - 8)
        
        let errorTextOverlaySpec            = ASOverlayLayoutSpec(child: self._image, overlay: errorCenterLayout)
        
        let loadingIndicatorOverlaySpec     = ASOverlayLayoutSpec(child: errorTextOverlaySpec, overlay: loadingIndicatorInsetSpec)
        
        let verticalTextStackSpec           = ASStackLayoutSpec(direction: .vertical, spacing: 2, justifyContent: .center, alignItems: .start, children: [self._title, self._detail])
        verticalTextStackSpec.style.flexGrow = 1.0
        verticalTextStackSpec.style.alignSelf = .center
        
        let horizontalStackSpec               = ASStackLayoutSpec(direction: .horizontal, spacing: 16, justifyContent: .start, alignItems: .start, children: [loadingIndicatorOverlaySpec, verticalTextStackSpec])
        horizontalStackSpec.style.flexGrow  = 1.0
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: (self._height - self._imageHeight) / 2, left: 16, bottom: 0, right: 16), child: horizontalStackSpec)
    }
    
    func loadImage() {
        if let imageURL: URL = self._parkItem.image?.resized["375x300"]?.publicURL {
            self._image.url = imageURL
        } else if let imageURL: URL = self._parkItem.image?.original.publicURL {
            self._image.url = imageURL
        } else {
            // Show error
            // self._image.url = URL(string: "https://error.com")
            self._loadingIndicator.removeFromSupernode()
            self.showError(text: "Error:\nNo image uploaded")
        }
        /*
        if let imageURL: URL = self._parkItem.urlPublic as URL! {
            self._image.url = imageURL
        } else if let imageURL: String = self._parkItem.url as String!, imageURL.characters.count > 0 {
            // cellData.url is resized image 3750x300
            let imgRef = self._storage.reference(forURL: imageURL)
            loadImageURL(imgRef: imgRef)
        } else if let imageURL: String = self._parkItem.images?["original"], imageURL.characters.count > 0 {
            // resized image doesn't exist -> Load "original" image
            let imgRef = self._storage.reference(forURL: imageURL)
            loadImageURL(imgRef: imgRef)
        } else {
            // Show error
            // self._image.url = URL(string: "https://error.com")
            self._loadingIndicator.removeFromSupernode()
            self.showError(text: "Error:\nNo image uploaded")
        }
         */
    }
    
    /*
    func loadImageURL(imgRef: FIRStorageReference){
        imgRef.downloadURL(completion: { (storageURL, error) -> Void in
            if error != nil {
                self._loadingIndicator.removeFromSupernode()
                self.showError(text: "Error:\nLoading image")
            } else {
                self._image.url = storageURL
                self._parkItem.setUrlPublic(url: storageURL!)
            }
        })
    }
     */
    
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
