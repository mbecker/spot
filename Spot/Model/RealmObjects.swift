//
//  RealmObjects.swift
//  Spot
//
//  Created by Mats Becker on 2/4/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

/*
 * ParkSection
 */

class RealmParkSection: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    dynamic var key = ""
    dynamic var name = ""
    dynamic var path = ""
    dynamic var type: ItemType.RawValue = ""
    dynamic var updated: Double = 0
    let park = LinkingObjects(fromType: RealmPark.self, property: "sections")
    
    override static func indexedProperties() -> [String] {
        return ["key"]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    public func getType() -> ItemType {
        if self.type == ItemType.ad.rawValue {
            return ItemType.ad
        } else if self.type == ItemType.animals.rawValue {
            return ItemType.animals
        } else if self.type == ItemType.attractions.rawValue {
            return ItemType.attractions
        } else if self.type == ItemType.community.rawValue {
            return ItemType.community
        }
        return ItemType.item
    }
}

class ParkSection {
    let key: String
    let name: String
    let path: String
    let type: ItemType
    init(realmParkSection: RealmParkSection) {
        self.key = realmParkSection.key
        self.name = realmParkSection.name
        self.path = realmParkSection.path
        self.type = realmParkSection.getType()
    }
}

/*
 * Park
 */

class RealmPark: Object {
    
    func configure(key: String, name: String, country: String, path: String){
        self.key = key
        self.name = name
        self.country = country
        self.path = path
    }
    
    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
    dynamic var updated: Double = 0
    dynamic var key = ""
    dynamic var name = ""
    dynamic var path = ""
    dynamic var country = ""
    let sections = List<RealmParkSection>()
    
    dynamic var markdown: RealmMarkdown?
    
    // Images
    dynamic var mapURL      : String?
    dynamic var countryIcon : String?
    dynamic var parkIcon    : String?
    
    override static func indexedProperties() -> [String] {
        return ["key"]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}

class RealmMarkdown: Object {
    dynamic var updated: Double = 0
    dynamic var key = ""
    dynamic var markdown: String?
    let park = LinkingObjects(fromType: RealmPark.self, property: "markdown")
    
    override static func indexedProperties() -> [String] {
        return ["key"]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

class Markdown {
    let key: String
    let markdown: String?
    
    init(realmMarkdown: RealmMarkdown){
        self.key = realmMarkdown.key
        if let markdown = realmMarkdown.markdown {
            self.markdown = markdown
        } else {
            self.markdown = nil
        }
    }
}

class Park {
    let key: String
    var name: String
    let path: String
    let country: String
    
    var sections = [ParkSection]()
    
    var markdown: Markdown?
    
    var mapURL: String?
    var mapImage: UIImage?
    var countryIcon: String?
    var countryImage: UIImage?
    var parkIcon: String?
    var parkImage: UIImage?
    
    init(realmPark: RealmPark){
        self.key = realmPark.key
        self.name = realmPark.name
        self.path = "parkinfo/\(realmPark.key)"
        self.country = realmPark.country
        
        for section in realmPark.sections {
            let parkSection = ParkSection(realmParkSection: section)
            self.sections.append(parkSection)
        }
        // ToDo: hack to have the ItemTypes in the 'correct' order
        self.sections.reverse()
        
        self.mapURL         = (realmPark.mapURL ?? "").isEmpty ? nil : realmPark.mapURL!
        self.countryIcon    = (realmPark.countryIcon ?? "").isEmpty ? nil : realmPark.countryIcon!
        self.parkIcon       = (realmPark.parkIcon ?? "").isEmpty ? nil : realmPark.parkIcon!
        
        self.mapImage = nil
        self.countryImage = nil
        self.parkImage = nil
        
        if let realmMarkdown = realmPark.markdown, let markdown: Markdown = Markdown(realmMarkdown: realmMarkdown) {
            self.markdown = markdown
        } else {
            self.markdown = nil
        }
        
    }
    
}

/**
 * Country
 */
class Country {
    let key: String
    let name: String
    let country: String
    let code: String
    let latitude: Double
    let longitude: Double
    var detail: String?
    
    init(key: String, name: String, country: String, code: String, latitude: Double, longitude: Double){
        self.key = key
        self.name = name
        self.country = country
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
    }
}
