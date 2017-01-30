//
//  UIImage.swift
//  Spot
//
//  Created by Mats Becker on 12/20/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//
import UIKit
extension UIImage {
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/4, size.width/4)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()        
        return newImage!
    }
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width / resizeFactor, height: size.height / resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return textToImage(drawText: "\(newSize.width)x\(newSize.height)" as NSString, inImage: resized, atPoint: CGPoint(x: 20, y: 20))
    }
    
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

}

func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
    
    // Setup the font specific variables
    let font = UIFont.boldSystemFont(ofSize: 16)
    
    // Setup the image context using the passed image
    UIGraphicsBeginImageContextWithOptions(inImage.size, false, 0.0)
    
    // Setup the font attributes that will be later used to dictate how the text should be drawn
    
    let attr = [NSFontAttributeName: font, NSForegroundColorAttributeName:UIColor.white]
    
    // Put the image into a rectangle as large as the original image
    inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
    
    // Create a point within the space that is as bit as the image
    let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
    
    // Draw the text into an image
    drawText.draw(in: rect, withAttributes: attr)
    drawText.draw(at: CGPoint(x: 20, y: 20), withAttributes: attr)
    
    // Create a new image out of the images we have created
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    
    // End the context now that we have the image we need
    UIGraphicsEndImageContext()
    
    //Pass the image back up to the caller
    return newImage
    
}
