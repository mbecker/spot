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


enum ParkError: Error {
    case ParkDoesNotExist
    case ParkNameDoesNotExist
    case ParkSectionDoesNotExist
    case ParkError
    case ParkCountryError
    case UpdateParkDoesNotExists
    case UpdateError
    case UpdateCountryError
}

enum MarkdownError: Error {
    case MarkdownDoesNotExist
    case MarkdownError
    case FirebaseError
}

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
    
//    func configure(key: String, name: String, country: String, path: String){
//        self.key = key
//        self.name = name
//        self.country = country
//        self.path = path
//    }
    
    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
    dynamic var updated: Double = 0
    dynamic var key = ""
    dynamic var name = ""
    dynamic var path = ""
    dynamic var country: RealmCountry?
    let sections = List<RealmParkSection>()
    
    dynamic var markdown: RealmMarkdown?
    
    let encyclopediaItems = List<RealmEncyclopediaItem>()
    
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
    let country: Country?
    
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
        self.country = Country(realmCountry: realmPark.country!)
        
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
        
        if let realmMarkdown = realmPark.markdown {
            self.markdown = Markdown(realmMarkdown: realmMarkdown)
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
    
    init(realmCountry: RealmCountry){
        self.key = realmCountry.key
        self.name = realmCountry.name
        self.country = realmCountry.country
        self.code = realmCountry.code
        self.detail = realmCountry.detail
        self.latitude = realmCountry.latitude
        self.longitude = realmCountry.longitude
    }
}

class RealmCountry: Object {
    dynamic var updated: Double = 0
    dynamic var key = ""
    dynamic var name: String = ""
    dynamic var country: String = ""
    dynamic var code: String = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    var detail: String?
    let park = LinkingObjects(fromType: RealmPark.self, property: "country")
    
    override static func indexedProperties() -> [String] {
        return ["key"]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

/**
 * EncyclopediaItem
 */
class RealmImage: Object {
    dynamic var key = ""
    dynamic var type = "" // "original", "375x300", etc.
    dynamic var publicURL = ""
    let original   = LinkingObjects(fromType: RealmImages.self, property: "original")
    let resizedOriginal   = LinkingObjects(fromType: RealmImages.self, property: "resized")
    
    override static func indexedProperties() -> [String] {
        return ["key", "type"]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}

class RealmImages: Object {
    dynamic var key = ""
    var original: RealmImage?
    let resized = List<RealmImage>()
    let realmEncyclopediaItemImage   = LinkingObjects(fromType: RealmEncyclopediaItem.self, property: "image")
    let realmEncyclopediaItemImages   = LinkingObjects(fromType: RealmEncyclopediaItem.self, property: "images")
    
    
    override static func indexedProperties() -> [String] {
        return ["key"]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}

class RealmEncyclopediaItem: Object {
    dynamic var updated: Double = 0
    dynamic var key     = ""
    dynamic var type    = ""
    dynamic var name    = ""
    dynamic var latitude: Double    = 0.0
    dynamic var longitude: Double   = 0.0
    dynamic var markdown    = ""
    dynamic var image       : RealmImages?
    let images              = List<RealmImages>()
    let parks               = LinkingObjects(fromType: RealmPark.self, property: "encyclopediaItems")
    
    override static func indexedProperties() -> [String] {
        return ["key"]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
