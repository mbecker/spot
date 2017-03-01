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
    var item2: ParkItem2?
    
    let _imageHeight: CGFloat   = 140 // 96
    let _imageWidth: CGFloat    = 186 // 103.55417528 // 142
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor    = UIColor.white
        self.borderColor        = UIColor(red:0.85, green:0.84, blue:0.81, alpha:1.00) // Timberwolf
        self.borderWidth        = 1.0
        self.layer.shadowColor           = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset     = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity    = 0.6
        self.layer.shadowRadius     = 1.0
        self.layer.masksToBounds    = false
        
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: _imageWidth, height: 184 - 18)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        
//        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
//        self.collectionView.backgroundColor = UIColor.white
//        self.collectionView.allowsMultipleSelection = true
//        self.collectionView.delegate    = self
//        self.collectionView.dataSource  = self
//        self.collectionView.allowsMultipleSelection = false
//        self.collectionView.register(PresentCell.self, forCellWithReuseIdentifier: "collectionViewCell")
//        self.addSubview(collectionView)
        
        self.swipeView.delegate = self
        self.swipeView.dataSource = self
        self.swipeView.alignment = .center
        self.swipeView.isPagingEnabled = true
        self.addSubview(swipeView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
//        self.collectionView.frame = CGRect(x: 12, y: self.bounds.height / 2 - (184 - 18) / 2, width: self.bounds.width - 24, height: 184 - 18)
//        self.collectionView.reloadData()
//        if self.item2 != nil {
//            self.collectionView.selectItem(at: [0, 0], animated: false, scrollPosition: .left)
//        }
//        self.collectionView.scrollToItem(at: [0, 0], at: .left, animated: false)
        self.swipeView.frame = CGRect(x: 12, y: self.bounds.height / 2 - (184 - 18) / 2, width: self.bounds.width - 24, height: 184 - 18)
    }
    
}

extension PresentView: SwipeViewDataSource, SwipeViewDelegate {
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        if self.item2 != nil && self.items2 != nil {
            return 1 + self.items2!.count
        }
        if self.item2 != nil {
            return 1
        }
        return 0
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        var label: UILabel! = nil
        var imageView = UIImageView()
        
        //create new view if no view is available for recycling
        var newView = view
        
        if newView == nil
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be		             //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later		             //recycled and used with other index values later
            newView = UIView()
            newView!.autoresizingMask = .flexibleWidth
            
            
            imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self._imageHeight)
            newView!.addSubview(imageView)
            
            label = UILabel(frame: newView!.bounds)
            label.autoresizingMask = .flexibleWidth
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.center
            label.font = label.font.withSize(50)
            label.tag = 1
            newView!.addSubview(label)
        }
        else
        {
            //get a reference to the label in the recycled view
            label = newView!.viewWithTag(1) as! UILabel!
        }
        var red:CGFloat = CGFloat(Float(arc4random()) / Float(INT_MAX))
        var green:CGFloat = CGFloat(Float(arc4random()) / Float(INT_MAX))
        var blue:CGFloat = CGFloat(Float(arc4random()) / Float(INT_MAX))
        newView!.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        switch index {
        case 0:
            label.text = self.item2?.name
        default:
            var title: String!
            if let name: String = items2?[index - 1].name {
                title = name
            } else {
                title = "\(index)"
            }
            label.attributedText = NSAttributedString(
                string: title,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
                    NSForegroundColorAttributeName: UIColor.flatBlack,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            
            let labelSize = NSAttributedString(
                string: title,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
                    NSKernAttributeName: 0.0,
                    ]).size()
            label.frame = CGRect(x: 0, y: self._imageHeight + 4, width: self.bounds.width, height: labelSize.height)
            let url: URL!
            if let imageURL: URL = items2?[index - 1].image?.resized["375x300"]?.publicURL {
                url = imageURL
            } else if let imageURL: URL = items2?[index - 1].image?.original?.publicURL {
                url = imageURL
            } else {
                // ToDo: Show error
                url = URL(fileURLWithPath: "https://test.com")
            }
            let processor = RoundCornerImageProcessor(cornerRadius: 10)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                if error != nil {
                    print(error)
                } else {
                    
                }
            })
        }
        
        return newView
    }
    
    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        return self.swipeView.bounds.size
    }
}

extension PresentView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.item2 != nil && self.items2 != nil {
            return 1 + self.items2!.count
        }
        if self.item2 != nil {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! PresentCell
        switch indexPath.row {
        case 0:
            cell.item2 = self.item2
        default:
            cell.item2 = self.items2?[indexPath.row - 1]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) deselected index path \(indexPath)")
    }
}
