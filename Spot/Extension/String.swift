//
//  String.swift
//  Spot
//
//  Created by Mats Becker on 2/9/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import Foundation

extension String {
    func firstCharacterUpperCase() -> String {
        let lowercaseString = self.lowercased()
        
        let start = lowercaseString.index(lowercaseString.startIndex, offsetBy: 0)
        let end = lowercaseString.index(lowercaseString.startIndex, offsetBy: 1)
        let myRange = start..<end
        
        return lowercaseString.replacingCharacters(in: myRange, with: String(lowercaseString[lowercaseString.startIndex]).uppercased())
    }
}
