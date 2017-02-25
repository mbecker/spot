//
//  SaveCancelButton.swift
//  ImagePicker
//
//  Created by Mats Becker on 10/29/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

enum SaveCancelButtonPosition {
    case Right
    case Left
    case None
}

enum SaveCancelButtonColorType {
    case Normal
    case Reverted
}

class SaveCancelButton: UIButton {
    
    let darkmint = UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00) // Dark Mint
    let aztecblack = UIColor(red:0.09, green:0.10, blue:0.12, alpha:1.00) // Aztec black
    let background = UIColor.white
    let lightgrey = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
    let gallery = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
    
    init(title: String, position: SaveCancelButtonPosition, type: SaveCancelButtonColorType, showimage: Bool) {
        
        var textColor: UIColor
        var selectedTextColor: UIColor
        var backgroundColor: UIColor
        
        switch type {
        case .Reverted:
            textColor = background
            selectedTextColor = gallery
            backgroundColor = darkmint
        default:
            textColor = darkmint
            selectedTextColor = UIColor.yellow
            backgroundColor = background
        }
        
        
        super.init(frame: CGRect.zero)
        let attribues = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: textColor,
                NSKernAttributeName: 0.6,
                ])
        let attribuesSelected = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: selectedTextColor,
                NSKernAttributeName: 0.6,
                ])
        //set image for button
        self.setAttributedTitle(attribues, for: .normal)
        self.setAttributedTitle(attribuesSelected, for: .highlighted)
        self.backgroundColor = backgroundColor
        
        self.layer.borderWidth = 1
        self.layer.borderColor = backgroundColor.cgColor
        
        let buttonwidth = CGFloat(108)
        let buttonheight = CGFloat(46.135)
        self.layer.cornerRadius = buttonheight / 2
        
        let posy = UIScreen.main.bounds.size.height - buttonheight - 16
        
        switch position {
        case .Left:
            self.frame = CGRect(x: 32, y: posy, width: buttonwidth, height: buttonheight)
        default:
            // Right
            if showimage {
                let chevronRightImage = UIImage(named: "ic_chevron_right_36pt")?.withRenderingMode(.alwaysTemplate)
                self.setImage(chevronRightImage, for: UIControlState())
                self.imageView?.tintColor = textColor
                self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
            self.frame = CGRect(x: UIScreen.main.bounds.size.width - buttonwidth - 32, y: UIScreen.main.bounds.size.height - buttonheight - 16, width: buttonwidth, height: buttonheight)
            break
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MapButton: UIButton {
    
    let darkmint = UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00) // Dark Mint
    let aztecblack = UIColor(red:0.09, green:0.10, blue:0.12, alpha:1.00) // Aztec black
    let background = UIColor.white
    
    
    init(position: SaveCancelButtonPosition) {
        
        var textColor: UIColor
        var selectedTextColor: UIColor
        var backgroundColor: UIColor
        
        textColor = darkmint
        selectedTextColor = UIColor(red:0.83, green:0.29, blue:0.31, alpha:1.00) // Dark Red
        backgroundColor = background
        
        
        super.init(frame: CGRect.zero)
                //set image for button
        
        self.backgroundColor = backgroundColor
        self.setImage(UIImage(named: "my_location")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = textColor
        self.setTitleColor(selectedTextColor, for: .selected)
        self.layer.borderWidth = 1
        self.layer.borderColor = backgroundColor.cgColor
        self.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let buttonwidth = CGFloat(46.135)
        let buttonheight = CGFloat(46.135)
        self.layer.cornerRadius = buttonheight / 2
        
        let posy = UIScreen.main.bounds.size.height - buttonheight - 16
        
        switch position {
        case .Left:
            self.frame = CGRect(x: 32, y: posy, width: buttonwidth, height: buttonheight)
        default:
            self.frame = CGRect(x: UIScreen.main.bounds.size.width - buttonwidth - 32, y: UIScreen.main.bounds.size.height - buttonheight - 16, width: buttonwidth, height: buttonheight)
            break
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
