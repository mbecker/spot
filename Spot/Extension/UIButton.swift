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
import NVActivityIndicatorView
extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if let indicator = self.viewWithTag(tag) as? NVActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
        if show {
            self.isEnabled = true
            let loadingIndicatorView    = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor.radicalRed, padding: 0.0)
            loadingIndicatorView.isUserInteractionEnabled = false
            let loadingIndicatorViewWidth = self.bounds.width * 2 / 3
            let loadingIndicatorViewHeight = self.bounds.height * 2 / 3
            loadingIndicatorView.frame = CGRect(x: self.bounds.width / 2 - loadingIndicatorViewWidth / 2, y: self.bounds.height / 2 - loadingIndicatorViewHeight / 2, width: loadingIndicatorViewWidth, height: loadingIndicatorViewHeight)
            loadingIndicatorView.tag = tag
            self.addSubview(loadingIndicatorView)
            loadingIndicatorView.startAnimating()
        }
    }
}

func randomNumber(range: ClosedRange<Int> = 1...6) -> Int {
    let min = range.lowerBound
    let max = range.upperBound
    return Int(arc4random_uniform(UInt32(1 + max - min))) + min
}
