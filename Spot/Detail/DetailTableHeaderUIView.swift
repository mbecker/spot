//
//  DetailTableHeaderUIView.swift
//  Spot
//
//  Created by Mats Becker on 12/1/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import ImageSlideshow

class DetailTableHeaderUIView: UIView {

    let _title: String
    let _urls: [URL]
    let _slideShow: ImageSlideshow
    let _viewController: DetailASViewController
    
    init(title: String, urls: [URL], viewController: DetailASViewController) {
        self._title = title
        self._urls = urls
        self._viewController = viewController
        self._slideShow = ImageSlideshow()
        
        
        if(urls.count > 0){
            super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 82 + 82 + 82))
            
            addSlideShow()
        } else {
            super.init(frame: CGRect.zero)
            // addHeadline(text: "No images uploaded.")
        }
        backgroundColor = UIColor.white
        
        
//        let borderLine = UIView(frame: CGRect(x: 20, y: self.bounds.height, width: self.bounds.width - 20, height: 1))
//        borderLine.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00) // Lavender grey
//        self.addSubview(borderLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addHeadline(text: String){
        let headline = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        headline.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                NSForegroundColorAttributeName: UIColor.black,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                NSParagraphStyleAttributeName: paragraph,
                ])
        let size = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
                NSForegroundColorAttributeName: UIColor.black,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                NSParagraphStyleAttributeName: paragraph,
                ]).size()
        print("SIZE :: \(size)")
        self.addSubview(headline)
    }
    
    func addSlideShow() -> () {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self._slideShow.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self._slideShow.addGestureRecognizer(gestureRecognizer)
        self._slideShow.backgroundColor = UIColor.white
        self._slideShow.cornerRadius = 0
        self._slideShow.slideshowInterval = 5.0
        self._slideShow.pageControlPosition = PageControlPosition.insideScrollView
        self._slideShow.pageControl.currentPageIndicatorTintColor = UIColor.white
        self._slideShow.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self._slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        var imageSource: [KingfisherSource] = []
        for url in self._urls {
            imageSource.append(KingfisherSource(url: url))
        }
        self._slideShow.setImageInputs(imageSource)
        
        self.addSubview(self._slideShow)

            // ToDO: Like Button for image?
//        let like = UIButton(frame: CGRect(x: self._slideShow.bounds.width - 12 - 48, y: self._slideShow.bounds.height - 12 - 48, width: 64, height: 64))
//        like.setImage(#imageLiteral(resourceName: "like98"), for: .normal)
//        like.setImage(#imageLiteral(resourceName: "likefilledredlight98"), for: .highlighted)
//        self._slideShow.addSubview(like)
        
        let download = UIButton(frame: CGRect(x: self._slideShow.bounds.width - 12 - 48, y: self._slideShow.bounds.height - 12 - 48, width: 64, height: 64))
        download.setImage(#imageLiteral(resourceName: "DownloadWhite98"), for: .normal)
        download.setImage(#imageLiteral(resourceName: "DownloadFilledWhite98"), for: .highlighted)
        download.addTarget(self._viewController, action: #selector(self._viewController.saveImage), for: UIControlEvents.touchUpInside)
        self._slideShow.addSubview(download)
        
    }
    
    func getImages() -> [UIImage] {
        var images = [UIImage]()
        for item in self._slideShow.slideshowItems {
            images.append(item.imageView.image!)
        }
        return images
    }
    
    func getImage() -> UIImage {
        return (self._slideShow.currentSlideshowItem?.imageView.image)!
    }
    
    func getFirstImage() -> UIImage {
        // ToDo: BUG
        // If the self._slideShow.slideshowItems.count > 1 the element[0] is not the image; it's [1]
        if self._slideShow.slideshowItems.count > 1 {
            return self._slideShow.slideshowItems[1].imageView.image!
        } else {
            return self._slideShow.slideshowItems[0].imageView.image!
        }
    }
    
    func getImage(pos: Int) -> UIImage? {
        print(self._slideShow.slideshowItems.count)
        if let image: UIImage = self._slideShow.slideshowItems[pos].imageView.image {
            return image
        }
        return nil
    }
    
    func didTap() {
        self._slideShow.presentFullScreenController(from: self._viewController)
    }
    
}
