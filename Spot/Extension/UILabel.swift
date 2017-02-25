//
//  UILabel.swift
//  Spot
//
//  Created by Mats Becker on 2/25/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//
import UIKit

extension UILabel {
    func setTextWhileKeepingAttributes(string: String) {
        if let newAttributedText = self.attributedText {
            let mutableAttributedText = newAttributedText.mutableCopy()
            
            (mutableAttributedText as AnyObject).mutableString.setString(string)
            
            self.attributedText = mutableAttributedText as? NSAttributedString
        }
    }
}
