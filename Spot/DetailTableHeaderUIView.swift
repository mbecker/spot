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
        
        let borderLine = UIView(frame: CGRect(x: 20, y: self.bounds.height, width: self.bounds.width - 20, height: 1))
        borderLine.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00) // Lavender grey
        self.addSubview(borderLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTitleView() -> () {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 82))
        titleView.backgroundColor = UIColor.clear
        
        let parkTitle = UILabel()
        parkTitle.attributedText = NSAttributedString(
            string: self._title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBlack),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        
        parkTitle.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(parkTitle)
        
        self.addSubview(titleView)
        
        
        parkTitle.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 20).isActive = true
        parkTitle.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        let borderLine = UIView(frame: CGRect(x: 20, y: 82, width: self.bounds.width - 20, height: 1))
        borderLine.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00) // iron
        
        self.addSubview(borderLine)
    }
    
    func addSlideShow() -> () {
        let slideShow: ImageSlideshow = ImageSlideshow(frame: CGRect(x: 20, y: 20, width: self.bounds.width - 40, height: self.bounds.height - 20 - 20))
        slideShow.backgroundColor = UIColor.white
        slideShow.cornerRadius = 10
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
