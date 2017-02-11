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
    
    let realm = try! Realm()
    
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
        
        // Check if realmMarkdown Object exists; and if yes when was it last updated?
        if let currentObject = self.realm.object(ofType: RealmMarkdown.self, forPrimaryKey: park.key) {
            // RealmMarkdown object exists in database
            if currentObject.updated > NSDate.timeIntervalSinceReferenceDate + 60 * 60 * 24 * 2 {
                // RealmMarkdown object was updated latest older since 2 days; update object with firebase data
                loadFirebase(firebaseLoaded: { (markdown) in
                    try! self.realm.write {
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
                
                try! self.realm.write {
                    self.realm.add(markdownRealm)
                    // link markdown to park
                    if let parkObject = self.realm.object(ofType: RealmPark.self, forPrimaryKey: park.key) {
                        parkObject.markdown = markdownRealm
                        self.realm.add(parkObject)
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
        let objects = self.realm.objects(RealmPark.self).filter("key = '\(park.key)'")
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
            
            guard let parkCountryIconCode = value?["countryicon"] as? String else {
                return completion(nil)
            }
            
            guard let parkIconCode = value?["parkicon"] as? String else {
                return completion(nil)
            }
            
            guard let parkSections = value?["section"] as? [String: Any] else {
                return completion(nil)
            }
            
            guard let parkCountry = value?["country"] as? [String: Any] else {
                return completion(nil)
            }
            
            let realmPark = RealmPark()
            realmPark.updated = NSDate.timeIntervalSinceReferenceDate
            
            if let parkCountryIconFilePath: String = countries[parkCountryIconCode] {
                realmPark.countryIcon = parkCountryIconFilePath
            }
            
            if let parkIconFilePath: String = parks[parkIconCode] {
                realmPark.parkIcon = parkIconFilePath
            }
            
            if let parkMapURL = value?["mapimage"] as? String {
                realmPark.mapURL = parkMapURL
            }
            
            /**
             * country
             */
            guard let countryCode = parkCountry["code"] as? String else {
                return completion(nil)
            }
            
            guard let countryCountry = parkCountry["country"] as? String else {
                return completion(nil)
            }
            
            guard let countryDetail = parkCountry["detail"] as? String else {
                return completion(nil)
            }
            
            guard let countryLatitude = parkCountry["latitude"] as? Double else {
                return completion(nil)
            }
            
            guard let countryLongitude = parkCountry["longitude"] as? Double else {
                return completion(nil)
            }
            
            let realmCountry = RealmCountry()
            realmCountry.updated = NSDate.timeIntervalSinceReferenceDate
            realmCountry.key = snapshot.key
            realmCountry.code = countryCode
            realmCountry.name = parkName
            realmCountry.country = countryCountry
            realmCountry.detail = countryDetail
            realmCountry.latitude = countryLatitude
            realmCountry.longitude = countryLongitude
            
            // -> RealmCountry -> RealmPark
            realmPark.country = realmCountry
            
            
            /*
             * Sections
             */
            for (key, section) in parkSections {
                if let sectionValue = section as? [String : Any], let sectionName = sectionValue["name"] as? String, let sectionType = sectionValue["type"] as? String {
                    
                    let realmSection = RealmParkSection()
                    realmSection.updated = NSDate.timeIntervalSinceReferenceDate
                    realmSection.key = key
                    realmSection.name = sectionName
                    realmSection.type = sectionType
                    
                    if let sectionPath = sectionValue["path"] as? String {
                        realmSection.path = sectionPath
                    }
                    
                    // -> Sections -> RealmPark
                    realmPark.sections.append(realmSection)
                    
                }
            }
            
            try! self.realm.write {
                self.realm.add(realmPark, update: true)
            }
            
            let parkObject = Park(realmPark: realmPark)
            
            completion(parkObject)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil)
        }
        
    }

}

