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
    
    init(title: String, urls: [URL]) {
        self._title = title
        self._urls = urls
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 82 + 82 + 82))
        backgroundColor = UIColor.white
        
        // addTitleView()
        addSlideShow()
        
//        let borderLine = UIView(frame: CGRect(x: 20, y: self.bounds.height, width: self.bounds.width - 20, height: 1))
//        borderLine.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00) // Lavender grey
//        self.addSubview(borderLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSlideShow() -> () {
        let slideShow: ImageSlideshow = ImageSlideshow(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        slideShow.backgroundColor = UIColor.white
        slideShow.cornerRadius = 0
        slideShow.slideshowInterval = 5.0
        slideShow.pageControlPosition = PageControlPosition.insideScrollView
        slideShow.pageControl.currentPageIndicatorTintColor = UIColor.white
        slideShow.pageControl.pageIndicatorTintColor = UIColor.lightGray
        slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        var imageSource: [KingfisherSource] = []
        for url in self._urls {
            imageSource.append(KingfisherSource(url: url))
        }
        slideShow.setImageInputs(imageSource)
        
        self.addSubview(slideShow)
    }
    
}
