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

class ItemASCellNode: ASCellNode {
    
    let _parkItem   :   ParkItem!
    var storage     :   FIRStorage
    var _image      :   ASNetworkImageNode
    
    var _title              =   ASTextNode()
    var _detail             =   ASTextNode()
    var _loadingIndicator   =   BallPulse()
    
    
    init(parkItem: ParkItem){
        self._parkItem = parkItem
        self.storage                    = FIRStorage.storage()
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
        self.addSubnode(self._detail)
        self.addSubnode(self._title)
        self.addSubnode(self._loadingIndicator)
        loadImage()
    }
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor = UIColor.clear
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
        
        let loadingIndicatorInsetSpec       = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 140 / 2 - 22, left: 156 / 2 - 22, bottom: 0, right: 0), child: self._loadingIndicator)
        
        self._image.style.width             = ASDimension(unit: .points, value: 186)
        self._image.style.height            = ASDimension(unit: .points, value: 140)
        
        let loadingIndicatorOverlaySpec     = ASOverlayLayoutSpec(child: self._image, overlay: loadingIndicatorInsetSpec)
        
        self._title.style.flexGrow          = 1 // 	If the sum of childrens' stack dimensions is less than the minimum size, should this object grow?
        self._detail.style.flexGrow         = 1
        
        let verticalTextStackSpec           = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [self._title, self._detail])
        let insetSpec                       = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0), child: verticalTextStackSpec)
        
        let verticalStackSpec               = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [loadingIndicatorOverlaySpec, insetSpec])
        verticalStackSpec.style.flexGrow    = 1
        
        return verticalStackSpec
    }
    
    func loadImage() {
        if let imageURL: String = self._parkItem.url as String!, imageURL.characters.count > 0 {
            // cellData.url is resized image 3750x300
            let imgRef = self.storage.reference(forURL: imageURL)
            loadImageURL(imgRef: imgRef)
        } else if let imageURL: String = self._parkItem.images?["original"], imageURL.characters.count > 0 {
            // resized image doesn't exist -> Load "original" image
            let imgRef = self.storage.reference(forURL: imageURL)
            loadImageURL(imgRef: imgRef)
        } else {
            // Show error
            self._image.url = URL(string: "https://error.com")
        }
        
        
    }
    
    func loadImageURL(imgRef: FIRStorageReference){
        imgRef.downloadURL(completion: { (storageURL, error) -> Void in
            if error != nil {
                self._image.url = URL(string: "https://error.com")
            } else {
                self._image.url = storageURL
            }
        })
    }
    
    
}


extension ItemASCellNode: ASNetworkImageNodeDelegate {
    
    func imageNodeDidFinishDecoding(_ imageNode: ASNetworkImageNode) {
        self._loadingIndicator.removeFromSupernode()
    }
    
    func imageNode(_ imageNode: ASNetworkImageNode, didFailWithError error: Error) {
        // ToDo: Show error text
        print(":: IMAGE DID FAIL WITH ERROR ::")
        print(error)
        
        self._loadingIndicator.removeFromSupernode()
    }
    
}
