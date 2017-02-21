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
