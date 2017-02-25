//
//  TagCell
//  ImagePicker
//
//  Created by Mats Becker on 10/27/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    var textLabel = UILabel()
    let imageView = UIImageView(frame: CGRect.zero)
    let borderView = UIView(frame: CGRect.zero)
    var textLabelSize: CGSize?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.contentView.addSubview(self.textLabel)
        self.borderView.addSubview(self.imageView)
        self.contentView.addSubview(self.borderView)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        
        self.borderView.frame = CGRect(x: self.frame.size.width / 2 - (self.bounds.width * 2 / 3) / 2, y: 0, width: self.bounds.width * 2 / 3, height: self.bounds.height * 2 / 3)
        self.imageView.frame = CGRect(x: borderView.bounds.width / 2 - (borderView.bounds.width * 2 / 3) / 2, y: borderView.bounds.height / 2 - (borderView.bounds.height * 2 / 3) / 2, width: borderView.bounds.width * 2 / 3, height: borderView.bounds.height * 2 / 3)
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00) // Black...
        self.borderView.layer.cornerRadius = self.bounds.width * 2 / 3 / 2
        self.borderView.layer.borderColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).cgColor // Black...
        self.borderView.layer.borderWidth = 1.0
        
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.borderView.backgroundColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00) // green ...
                self.borderView.layer.borderColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00).cgColor // green ...
                self.imageView.tintColor = UIColor.white
                self.textLabel.textColor = UIColor.black
            } else {
                self.borderView.backgroundColor = UIColor.clear
                self.borderView.layer.borderColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6).cgColor
                self.imageView.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
                self.textLabel.textColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.borderView.backgroundColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00) // green ...
                self.borderView.layer.borderColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00).cgColor // green ...
                self.imageView.tintColor = UIColor.white
                self.textLabel.textColor = UIColor.black
            } else {
                self.borderView.backgroundColor = UIColor.clear
                self.borderView.layer.borderColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6).cgColor
                self.imageView.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
                self.textLabel.textColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
            }
        }
    }
    
}
