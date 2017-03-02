//
//  UIColor.swift
//  Spot
//
//  Created by Mats Becker on 12/20/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit

extension UIColor {
    public class var bunker: UIColor {
        return UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00)
    }
    
    public class var mandy: UIColor {
        return UIColor(red:0.93, green:0.33, blue:0.39, alpha:1.00)
    }
    
    public class var amaranth: UIColor {
        return UIColor(red:0.92, green:0.20, blue:0.29, alpha:1.00)
    }
    
    public class var linkWater: UIColor {
        return UIColor(red:0.80, green:0.82, blue:0.85, alpha:1.00)
    }
    
    public class var lavenderGey: UIColor {
        return UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00) // Lavender Grey
    }
    
    public class var crimson: UIColor {
        return UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00) // Alizarin Crimson
        // Hex: #EB1938
    }
    
    public class var flatBlack: UIColor {
        return UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.00) // Flat black
    }
    
    public class var scarlet: UIColor {
        return UIColor(red:1.00, green:0.15, blue:0.29, alpha:1.00) // scarlet
    }
    
    public class var radicalRed: UIColor {
        return UIColor(red:1.00, green:0.18, blue:0.33, alpha:1.00) // selected cell background color
    }
    
    public class var cellHighlightColor: UIColor {
        return UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00) // Filter Background View Color
    }
}

extension UIColor {
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}
