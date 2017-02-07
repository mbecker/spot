//
//  RealmTransactions.swift
//  Spot
//
//  Created by Mats Becker on 2/5/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseDatabase

class RealmTransactions {
    
    public func loadCountriesFromFirebase(completion: @escaping (_ result: [Country]?) -> Void) {
        let ref = FIRDatabase.database().reference()
        ref.child("parkcountries").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? [String: Any] {
                var countries = [Country]()
                for (key, item) in snapshotValue {
                    if let itemValue = item as? [String : Any] {
                        guard let country: String = itemValue["country"] as? String else {
                            break
                        }
                        guard let name: String = itemValue["name"] as? String else {
                            break
                        }
                        guard let code: String = itemValue["code"] as? String else {
                            break
                        }
                        guard let longitude: Double = itemValue["longitude"] as? Double else {
                            break
                        }
                        guard let latitude: Double = itemValue["latitude"] as? Double else {
                            break
                        }
                        let countryObject = Country(key: key, name: name, country: country, code: code, latitude: latitude, longitude: longitude)
                        if let detail = itemValue["detail"] as? String {
                            countryObject.detail = detail
                        }
                        countries.append(countryObject)
                        
                    } else {
                        break
                    }
                }
                completion(countries)
            } else {
                completion(nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    public func loadMarkdownFromFirebaseAndSaveToRealm(park: Park, completion: @escaping (_ result: Markdown?) -> Void) {
        
        func loadFirebase(firebaseLoaded: @escaping (_ result: String?) -> Void) {
            let ref = FIRDatabase.database().reference()
            ref.child("markdown").child(park.key).child("markdown").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let markdown = snapshot.value as? String else {
                    return firebaseLoaded(nil)
                }
                return firebaseLoaded(markdown)
            }) { (error) in
                print(error.localizedDescription)
                firebaseLoaded(nil)
            }
        }
        
        let realm = try! Realm()
        // Check if realmMarkdown Object exists; and if yes when was it last updated?
        if let currentObject = realm.object(ofType: RealmMarkdown.self, forPrimaryKey: park.key) {
            // RealmMarkdown object exists in database
            if currentObject.updated > NSDate.timeIntervalSinceReferenceDate + 60 * 60 * 24 * 2 {
                // RealmMarkdown object was updated latest older since 2 days; update object with firebase data
                loadFirebase(firebaseLoaded: { (markdown) in
                    try! realm.write {
                        currentObject.updated = NSDate.timeIntervalSinceReferenceDate
                        currentObject.markdown = markdown
                    }
                    if let markdownObject: Markdown = Markdown(realmMarkdown: currentObject){
                        park.markdown = markdownObject
                        completion(markdownObject)
                    } else {
                        completion(nil)
                    }
                })
            } else {
                // RealmMarkdown object exists in database and was not longer than 2 days
                if let markdownObject: Markdown = Markdown(realmMarkdown: currentObject){
                    park.markdown = markdownObject
                    completion(markdownObject)
                } else {
                    completion(nil)
                }
            }
        } else {
            loadFirebase(firebaseLoaded: { (markdown) in
                let markdownRealm = RealmMarkdown()
                markdownRealm.updated = NSDate.timeIntervalSinceReferenceDate
                markdownRealm.key = park.key
                markdownRealm.markdown = markdown
                
                try! realm.write {
                    realm.add(markdownRealm)
                    // link markdown to park
                    if let parkObject = realm.object(ofType: RealmPark.self, forPrimaryKey: park.key) {
                        parkObject.markdown = markdownRealm
                        realm.add(parkObject)
                    }
                }
                
                if let markdownObject: Markdown = Markdown(realmMarkdown: markdownRealm){
                    park.markdown = markdownObject
                    completion(markdownObject)
                } else {
                    completion(nil)
                }
                
            })
        }
        
    }
    
    func updateRealmObject(park: Park) {
        let realm = try! Realm()
        let objects = realm.objects(RealmPark.self).filter("key = '\(park.key)'")
        let timeInterval: Double = 0
        for object in objects {
            if NSDate.timeIntervalSinceReferenceDate > object.updated + timeInterval {
                print("...time to update")
            }
        }
    }
    
    
    func loadParkFromFirebaseAndSaveToRealm(key: String, completion: @escaping (_ result: Park?) -> Void) {
        let ref = FIRDatabase.database().reference()
        ref.keepSynced(true)
        ref.child("parkinfo/\(key)").observe(.value, with: { (snapshot) in
            // Get park value
            let value = snapshot.value as? NSDictionary
            
            guard let parkName = value?["name"] as? String else {
                return completion(nil)
            }
            
            guard let parkCountry = value?["country"] as? String else {
                return completion(nil)
            }
            
            guard let parkCountryIconCode = value?["countryicon"] as? String else {
                return completion(nil)
            }
            
            guard let parkIconCode = value?["parkicon"] as? String else {
                return completion(nil)
            }
            
            guard let parkSections = value?["section"] as? [String: Any] else {
                return completion(nil)
            }
            
            let park = RealmPark()
            park.configure(key: key, name: parkName, country: parkCountry, path: "parkinfo/\(key)")
            park.updated = NSDate.timeIntervalSinceReferenceDate
            
            if let parkCountryIconFilePath: String = countries[parkCountryIconCode] {
                park.countryIcon = parkCountryIconFilePath
            }
            
            if let parkIconFilePath: String = parks[parkIconCode] {
                park.parkIcon = parkIconFilePath
            }
            
            if let parkMapURL = value?["mapimage"] as? String {
                park.mapURL = parkMapURL
            }
            
            /*
             * Sections
             */
            // var realmSections = [RealmSection]()
            for (key, section) in parkSections {
                if let sectionValue = section as? [String : Any], let sectionName = sectionValue["name"] as? String, let sectionType = sectionValue["type"] as? String {
                    let realmSection = RealmParkSection()
                    realmSection.key = key
                    realmSection.name = sectionName
                    if(sectionType == "ad") {
                        realmSection.type = ItemType.ad.rawValue
                    } else if (sectionType == ItemType.animals.rawValue) {
                        realmSection.type = ItemType.animals.rawValue
                    } else if (sectionType == ItemType.attractions.rawValue) {
                        realmSection.type = ItemType.attractions.rawValue
                    } else {
                        realmSection.type = ItemType.item.rawValue
                    }
                    
                    if let sectionPath = sectionValue["path"] as? String {
                        realmSection.path = sectionPath
                    }
                    park.sections.append(realmSection)
                    
                    park.updated = NSDate.timeIntervalSinceReferenceDate
                }
            }
            
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(park, update: true)
            }
            
            let parkObject = Park(realmPark: park)
            
            completion(parkObject)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil)
        }
        
    }

}

