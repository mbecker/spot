//
//  Float.swift
//  Spot
//
//  Created by Mats Becker on 2/24/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import Foundation

extension Float {
    func roundToInt() -> Int{
        let value = Int(self)
        let f = self - Float(value)
        if f < 0.5{
            return value
        } else {
            return value + 1
        }
    }
}
