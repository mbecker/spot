//
//  MoreButtonUIButton.swift
//  Spot
//
//  Created by Mats Becker on 2/23/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

class MoreButtonUIButton: UIButton {

    //let label = UILabel()
    var title: String!
    let image: UIImage = StyleKitName.imageOfChevronRight.withRenderingMode(.alwaysTemplate)
    let chevronImageView: UIImageView = UIImageView(frame: CGRect.zero)
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                self.imageView?.tintColor = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00).withAlphaComponent(0.6)
            }
            else {
                self.imageView?.tintColor = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00)
            }
            super.isHighlighted = newValue
        }
    }
    
    init(title: String){
        self.title = title
        super.init(frame: CGRect.zero)
        self.setAttributedTitle(NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00), // Charcoal // UIColor.scarlet,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
            , for: .normal)
        self.setAttributedTitle(NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00).withAlphaComponent(0.6),
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
            , for: .highlighted)
    }
    
    override public func layoutSubviews() {
        let size = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00), // Charcoal // UIColor.scarlet,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ]).size()
        let buttonHeight: CGFloat = 10
        self.imageView?.frame = CGRect(x: self.bounds.width - buttonHeight / 2, y: self.bounds.height / 2 - buttonHeight / 2 + 1, width: buttonHeight / 2, height: buttonHeight)
        self.imageView?.image = self.image
        self.imageView?.tintColor = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00)
        
        
        self.titleLabel?.frame = CGRect(x: self.bounds.width - buttonHeight / 2 - size.width - 4, y: self.bounds.height / 2 - size.height / 2, width: size.width, height: size.height)
//        
//        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
//        // self.addSubview(self.label)
//        self.titleLabel?.trailingAnchor.constraint(equalTo: (imageView?.leadingAnchor)!, constant: -4).isActive = true
//        self.titleLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        self.titleLabel?.heightAnchor.constraint(equalToConstant: height).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
