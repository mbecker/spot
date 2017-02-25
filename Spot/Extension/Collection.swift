//
//  Dictionary.swift
//  Spot
//
//  Created by Mats Becker on 2/21/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func unionInPlace(
        dictionary: Dictionary<Key, Value>) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
    
    // Thanks Airspeed Velocity
    mutating func unionInPlace<S: Sequence>(sequence: S) where
        S.Iterator.Element == (Key,Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
