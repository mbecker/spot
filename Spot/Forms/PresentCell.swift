//
//  PresentCell.swift
//  Spot
//
//  Created by Mats Becker on 2/28/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import Kingfisher

class PresentCell: UICollectionViewCell {
    
    let _imageHeight: CGFloat   = 140 // 96
    let _imageWidth: CGFloat    = 186 // 103.55417528 // 142
    
    var textLabel = UILabel()
    let imageView = UIImageView(frame: CGRect.zero)
    let borderView = UIView(frame: CGRect.zero)
    var textLabelSize: CGSize?
    
    var item2: ParkItem2?
    var url: URL?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.borderView.frame = CGRect(x: 0, y: self._imageHeight - 4, width: self.bounds.width, height: 4)
                self.contentView.addSubview(self.borderView)
            } else {
                self.borderView.removeFromSuperview()
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.borderView.backgroundColor = UIColor.radicalRed
        
        self.contentView.addSubview(self.textLabel)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.borderView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self._imageHeight)
        if let item: ParkItem2 = self.item2 {
            
            if self.url == nil {
                if let imageURL: URL = item.image?.resized["375x300"]?.publicURL {
                    self.url = imageURL
                } else if let imageURL: URL = item.image?.original?.publicURL {
                    self.url = imageURL
                } else {
                    // ToDo: Show error
                    
                }
            }
            
            if let url: URL = self.url {
                let processor = RoundCornerImageProcessor(cornerRadius: 10)
                self.imageView.kf.indicatorType = .activity
                self.imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                    if error != nil {
                        print(error)
                    } else {
                        
                    }
                })
            }
            
            self.textLabel.attributedText = NSAttributedString(
                string: item.name,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
                    NSForegroundColorAttributeName: UIColor.flatBlack,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            
            let textLabelSize = NSAttributedString(
                string: item.name,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
                    NSKernAttributeName: 0.0,
                    ]).size()
            
            self.textLabel.frame = CGRect(x: 0, y: self._imageHeight + 4, width: self.bounds.width, height: textLabelSize.height)
            
        }
    }
    
    
    
}
