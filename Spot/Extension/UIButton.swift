//
//  UIButton.swift
//  Spot
//
//  Created by Mats Becker on 11/30/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Foundation

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

func randomNumber(range: ClosedRange<Int> = 1...6) -> Int {
    let min = range.lowerBound
    let max = range.upperBound
    return Int(arc4random_uniform(UInt32(1 + max - min))) + min
}
