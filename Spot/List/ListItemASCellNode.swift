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
    
    let _height: CGFloat        = 112
    let _imageHeight: CGFloat   = 96
    let _imageWidth: CGFloat    = 142
    
    override var isSelected: Bool {
        get {
            return self.isSelected
        }
        set {
            if newValue {
                self.backgroundColor = UIColor.clear
            } else {
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    override var isHighlighted: Bool {
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
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.backgroundColor = UIColor.clear
    }
    
    /**
     * Height: 108 (188)
     */
    
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
        self.backgroundColor = UIColor.clear
//        self._image.imageModificationBlock = { image in
//            var modifiedImage: UIImage?
//            let rect = CGRect(origin: CGPoint.zero, size: image.size)
//            
//            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
//            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 10, height: 10))
//            maskPath.addClip()
//            image.draw(in: rect)
//            modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            return modifiedImage
//        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self._loadingIndicator.style.width  = ASDimension(unit: .points, value: 44)
        self._loadingIndicator.style.height = ASDimension(unit: .points, value: 44)
        
        let loadingIndicatorInsetSpec       = ASInsetLayoutSpec(insets: UIEdgeInsets(top: self._imageHeight / 2 - 22, left: self._imageWidth / 2 - 22, bottom: 0, right: 0), child: self._loadingIndicator)
        
        self._image.style.width             = ASDimension(unit: .points, value: self._imageWidth)
        self._image.style.height            = ASDimension(unit: .points, value: self._imageHeight)
        
        self._errorText.style.alignSelf     = .center
        self._errorText.style.width         = ASDimension(unit: .points, value: self._imageHeight * 2 / 3)
        self._errorText.style.height        = ASDimension(unit: .points, value: 28.640625)
        self._errorText.backgroundColor     = UIColor.clear
        
        let errorCenterLayout               = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self._errorText)
        errorCenterLayout.style.width       = ASDimension(unit: .points, value: self._imageWidth / 2)
        errorCenterLayout.style.height      = ASDimension(unit: .points, value: self._imageHeight)
        
        let errorTextOverlaySpec            = ASOverlayLayoutSpec(child: self._image, overlay: errorCenterLayout)
        
        let loadingIndicatorOverlaySpec     = ASOverlayLayoutSpec(child: errorTextOverlaySpec, overlay: loadingIndicatorInsetSpec)
        let imageInsetSpec                  = ASInsetLayoutSpec(insets: UIEdgeInsets(top: self._height - self._imageHeight, left: 20, bottom: 0, right: 0), child: loadingIndicatorOverlaySpec)
        
        let verticalTextStackSpec           = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [self._title, self._detail])
        let textInsetSpec                   = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), child: verticalTextStackSpec)
        textInsetSpec.style.flexShrink      = 1
        
        let verticalStackSpec               = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .start, children: [loadingIndicatorOverlaySpec, textInsetSpec])
        verticalStackSpec.style.flexShrink  = 0
        
        let insetSpec                       = ASInsetLayoutSpec(insets: UIEdgeInsets(top: (self._height - self._imageHeight) / 2, left: 20, bottom: 0, right: 0), child: verticalStackSpec)
        
        
        return insetSpec
    }
    
    func loadImage() {
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
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            self._errorText.attributedText = NSAttributedString(
                string: "No image uploaded.",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                    NSForegroundColorAttributeName: UIColor.black,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    NSParagraphStyleAttributeName: paragraph,
                    ])
            
        }
        
        
    }
    
    func loadImageURL(imgRef: FIRStorageReference){
        imgRef.downloadURL(completion: { (storageURL, error) -> Void in
            if error != nil {
                self._loadingIndicator.removeFromSupernode()
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center
                self._errorText.attributedText = NSAttributedString(
                    string: (error?.localizedDescription)!,
                    attributes: [
                        NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                        NSForegroundColorAttributeName: UIColor.black,
                        NSBackgroundColorAttributeName: UIColor.clear,
                        NSKernAttributeName: 0.0,
                        NSParagraphStyleAttributeName: paragraph,
                        ])
            } else {
                self._image.url = storageURL
                self._parkItem.setUrlPublic(url: storageURL!)
            }
        })
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
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        self._errorText.attributedText = NSAttributedString(
            string: error.localizedDescription,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                NSForegroundColorAttributeName: UIColor.black,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                NSParagraphStyleAttributeName: paragraph,
                ])
        
        self._loadingIndicator.removeFromSupernode()
    }
    
}
