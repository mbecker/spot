//
//  NavigationBar.swift
//  Spot
//
//  Created by Mats Becker on 2/15/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

func findShadowImage(under view: UIView) -> UIImageView? {
    if view is UIImageView && view.bounds.size.height <= 1 {
        return (view as! UIImageView)
    }
    
    for subview in view.subviews {
        if let imageView = findShadowImage(under: subview) {
            return imageView
        }
    }
    return nil
}

extension UINavigationBar {
    
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        
        let bottomBorderView = UIView()
        bottomBorderView.backgroundColor = color
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorderView)
        
        bottomBorderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        bottomBorderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        bottomBorderView.centerYAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomBorderView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
    }
}
