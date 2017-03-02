//
//  PresentView.swift
//  Spot
//
//  Created by Mats Becker on 2/28/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import Kingfisher

class PresentView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let swipeView = SwipeView()
    var collectionView: UICollectionView!
    let layout = UICollectionViewFlowLayout()
    var items2: [ParkItem2]?
    var item: Int?
    
    let _imageHeight: CGFloat   = 140 // 96
    let _imageWidth: CGFloat    = 186 // 103.55417528 // 142
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor    = UIColor.clear
        // self.borderColor        = UIColor(red:0.85, green:0.84, blue:0.81, alpha:1.00) // Timberwolf
        // self.borderWidth        = 1.0
        self.layer.shadowColor           = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset     = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity    = 0.6
        self.layer.shadowRadius     = 1.0
        self.layer.masksToBounds    = false
        self.cornerRadius = 16
        self.layer.cornerRadius = 16
        
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: _imageWidth, height: 184 - 18)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        
        self.swipeView.delegate = self
        self.swipeView.dataSource = self
        self.swipeView.alignment = .center
        self.swipeView.isPagingEnabled = true
        self.swipeView.backgroundColor = UIColor.clear
        self.addSubview(swipeView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.swipeView.frame = CGRect(x: 12, y: self.bounds.height / 2 - (184 - 18) / 2, width: self.bounds.width - 24, height: 184 - 18)
        if let i: Int = self.item {
            self.swipeView.currentPage = i
        }
    }
    
}

extension PresentView: SwipeViewDataSource, SwipeViewDelegate {
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        if self.items2 != nil {
            return self.items2!.count
        }
        return 0
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        var label: UILabel! = nil
        let imageView = UIImageView()
        
        //create new view if no view is available for recycling
        var newView = view
        
        if newView == nil
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be		             //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later		             //recycled and used with other index values later
            newView = UIView()
            newView!.autoresizingMask = .flexibleWidth
            
            
            imageView.frame = CGRect(x: self.bounds.width / 2 - (self.bounds.width - 12) / 2, y: 0, width: 168, height: 168)
            imageView.layer.cornerRadius = 168 / 2
            newView!.addSubview(imageView)
            
            label = UILabel(frame: CGRect(x: 0, y: self._imageHeight + 4, width: self._imageWidth, height: self.bounds.height - newView!.bounds.height))
            label.autoresizingMask = .flexibleWidth
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.left
            label.font = label.font.withSize(50)
            label.tag = 1
            newView!.addSubview(label)
        }
        else
        {
            //get a reference to the label in the recycled view
            label = newView!.viewWithTag(1) as! UILabel!
        }
        
        newView!.backgroundColor = UIColor.clear
        
        var title: String!
        if let item2: ParkItem2 = self.items2?[safe: index] {
            title = item2.name
        } else {
            title = "\(index)"
        }
        var selectedColor: UIColor!
        if index == self.item {
            selectedColor = UIColor.radicalRed
        } else {
            selectedColor = UIColor.flatBlack
        }
        
        label.attributedText = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
                NSForegroundColorAttributeName: selectedColor,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        
        let labelSize = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
                NSKernAttributeName: 0.0,
                ]).size()
        label.frame = CGRect(x: 0, y: self._imageHeight + 4, width: self._imageWidth, height: labelSize.height)
        let url: URL!
        if let item2 = self.items2?[safe: index], let imageURL: URL = item2.image?.resized["375x300"]?.publicURL {
            url = imageURL
        } else if let imageURL: URL = items2?[index - 1].image?.original?.publicURL {
            url = imageURL
        } else {
            // ToDo: Show error
            url = URL(fileURLWithPath: "https://test.com")
        }
        let processor = RoundCornerImageProcessor(cornerRadius: 168 / 2)
        imageView.kf.indicatorType = .custom(indicator: BallPulseIndicator(frame: CGRect(x: view.bounds.width / 2 - 88 / 2, y: view.bounds.height / 2 - CGFloat(44 / 2), width: CGFloat(88), height: CGFloat(44))))
        imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
            if error != nil {
                print(error!)
            } else {
                
            }
        })
        
        return newView
    }
    
    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        return CGSize(width: self.bounds.width, height: self.bounds.height)
    }
}
