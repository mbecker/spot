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

let UPDATE_TIMEFRAME_MARKDOWN: Double   = 1 // 60 * 60 * 24 * 7
let UPDATE_TIMEFRAME_PARK: Double       = 1 // 60 * 60 * 24 * 7

class RealmTransactions {
    
    let realm = try! Realm()
    
    public func loadParkItemsFromRealm(parkKey: String, itemType: ItemType) -> [RealmEncyclopediaItem]? {
        if let results = self.realm.object(ofType: RealmPark.self, forPrimaryKey: parkKey)?.encyclopediaItems.filter("type = %@", itemType.rawValue) {
            return Array(results)
        }
        return nil
    }
    
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
    
    public func loadMarkdownFromFirebaseAndSaveToRealm(realmPark: RealmPark, completion: @escaping (_ result: RealmMarkdown?,_ error: MarkdownError?) -> Void) {
        
        func loadFirebase(firebaseLoaded: @escaping (_ result: String?, _ error: MarkdownError?) -> Void) {
            let ref = FIRDatabase.database().reference()
            ref.keepSynced(false)
            
            ref.child("markdown").child(realmPark.key).child("markdown").observe(.value, with: { (snapshot) in
                guard let markdown = snapshot.value as? String else {
                    return firebaseLoaded(nil, MarkdownError.MarkdownDoesNotExist)
                }
                return firebaseLoaded(markdown, nil)
            }) { (error) in
                print(error.localizedDescription)
                firebaseLoaded(nil, MarkdownError.FirebaseError)
            }
        }
        
        if let markdown = realmPark.markdown, markdown.updated + UPDATE_TIMEFRAME_MARKDOWN < NSDate().timeIntervalSince1970  {
            // RealmMarkdown object was updated latest older since UPDATE_TIMEFRAME_MARKDOWN; update object with firebase data
            
            loadFirebase(firebaseLoaded: { (returnMarkdown, error) in
                if let markdownString: String = returnMarkdown, error == nil {
                    try! self.realm.write {
                        markdown.updated    = NSDate().timeIntervalSince1970
                        markdown.markdown   = markdownString
                    }
                    completion(markdown, nil)
                } else if error != nil {
                    completion(markdown, nil)
                }
                
            })
            
        } else if let markdown = realmPark.markdown {
            // Markdown exists and was updated before UPDATE_TIMEFRAME_MARKDOWN
            
            completion(markdown, nil)
            
        } else {
            // Markdown does not exists
            
            loadFirebase(firebaseLoaded: { (returnMarkdown, error) in
                
                if let markdownString: String = returnMarkdown, error == nil {
                    let realmMarkdown       = RealmMarkdown()
                    realmMarkdown.updated   = NSDate().timeIntervalSince1970
                    realmMarkdown.key       = realmPark.key
                    realmMarkdown.markdown  = markdownString
                    
                    try! self.realm.write {
                        realmPark.markdown      = realmMarkdown
                    }
                    
                    completion(realmMarkdown, nil)
                } else {
                    completion(nil, error!)
                }
                
            })
        }
        
    }
    
    func updateRealmObject(park: Park) {
        let objects = self.realm.objects(RealmPark.self).filter("key = '\(park.key)'")
        let timeInterval: Double = 0
        for object in objects {
            if NSDate().timeIntervalSince1970 > object.updated + timeInterval {
                print("...time to update")
            }
        }
    }
    
    
    func loadParkFromFirebaseAndSaveToRealm(key: String, completion: @escaping (_ result: RealmPark?, _ error: ParkError?) -> Void) {
        
        func loadParkFromFirebase(firebaseLoaded: @escaping (_ result: RealmPark?) -> Void) {
            let ref = FIRDatabase.database().reference()
            ref.keepSynced(true)
            
            ref.child("parkinfo").child(key).observe(.value, with: { (snapshot) in
                
                guard snapshot.exists() else {
                    return completion(nil, ParkError.ParkDoesNotExist)
                }
                
                // Get park value
                let value = snapshot.value as? NSDictionary
                
                guard let parkName = value?["name"] as? String else {
                    return completion(nil, ParkError.ParkNameDoesNotExist)
                }
                
                guard let parkCountryIconCode = value?["countryicon"] as? String else {
                    return completion(nil, ParkError.ParkError)
                }
                
                guard let parkIconCode = value?["parkicon"] as? String else {
                    return completion(nil, ParkError.ParkError)
                }
                
                guard let parkSections = value?["section"] as? [String: Any] else {
                    return completion(nil, ParkError.ParkSectionDoesNotExist)
                }
                
                guard let parkCountry = value?["country"] as? [String: Any] else {
                    return completion(nil, ParkError.ParkError)
                }
                
                
                let realmPark = RealmPark()
                realmPark.updated       = NSDate().timeIntervalSince1970
                realmPark.key           = snapshot.key
                realmPark.name          = parkName
                realmPark.path          = "parkinfo/\(snapshot.key)"
                realmPark.countryIcon   = parkCountryIconCode
                realmPark.parkIcon      = parkIconCode
                
                if let parkMapURL = value?["mapimage"] as? String {
                    realmPark.mapURL = parkMapURL
                }
                
                /**
                 * country
                 */
                guard let countryCode = parkCountry["code"] as? String else {
                    return completion(nil, ParkError.ParkCountryError)
                }
                
                guard let countryCountry = parkCountry["country"] as? String else {
                    return completion(nil, ParkError.ParkCountryError)
                }
                
                guard let countryLatitude = parkCountry["latitude"] as? Double else {
                    return completion(nil, ParkError.ParkCountryError)
                }
                
                guard let countryLongitude = parkCountry["longitude"] as? Double else {
                    return completion(nil, ParkError.ParkCountryError)
                }
                
                guard let countryZoomLevel = parkCountry["zoomlevel"] as? Double else {
                    return completion(nil, ParkError.ParkCountryError)
                }
                
                let realmCountry = RealmCountry()
                realmCountry.updated    = NSDate().timeIntervalSince1970
                realmCountry.key        = snapshot.key
                realmCountry.code       = countryCode
                realmCountry.name       = parkName
                realmCountry.country    = countryCountry
                realmCountry.latitude   = countryLatitude
                realmCountry.longitude  = countryLongitude
                realmCountry.zoomlevel  = countryZoomLevel
                
                if let countryDetail = parkCountry["detail"] as? String {
                    realmCountry.detail     = countryDetail
                }
                
                // -> RealmCountry -> RealmPark
                realmPark.country = realmCountry
                
                
                /*
                 * Sections
                 */
                for (key, section) in parkSections {
                    if let sectionValue = section as? [String : Any], let sectionName = sectionValue["name"] as? String, let sectionType = sectionValue["type"] as? String {
                        
                        let realmSection        = RealmParkSection()
                        realmSection.updated    = NSDate().timeIntervalSince1970
                        realmSection.key        = key
                        realmSection.name       = sectionName
                        realmSection.type       = sectionType
                        
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
                
                firebaseLoaded(realmPark)
                
                
                
            }) { (error) in
                print(error.localizedDescription)
                firebaseLoaded(nil)
            }
        }
        
        func updateParkFromFirebase(realmPark: RealmPark, firebaseLoaded: @escaping (_ result: RealmPark?) -> Void) {
            let ref = FIRDatabase.database().reference()
            ref.keepSynced(true)
            
            ref.child("parkinfo").child(key).observe(.value, with: { (snapshot) in
                
                guard snapshot.exists() else {
                    return completion(nil, ParkError.UpdateParkDoesNotExists)
                }
                
                // Get park value
                let value = snapshot.value as? NSDictionary
                
                guard let parkName = value?["name"] as? String else {
                    return completion(nil, ParkError.UpdateError)
                }
                
                guard let parkCountryIconCode = value?["countryicon"] as? String else {
                    return completion(nil, ParkError.UpdateError)
                }
                
                guard let parkIconCode = value?["parkicon"] as? String else {
                    return completion(nil, ParkError.UpdateError)
                }
                
                guard let parkSections = value?["section"] as? [String: Any] else {
                    return completion(nil, ParkError.UpdateError)
                }
                
                guard let parkCountry = value?["country"] as? [String: Any] else {
                    return completion(nil, ParkError.UpdateError)
                }
                
                
                /**
                 * country
                 */
                guard let countryCode = parkCountry["code"] as? String else {
                    return completion(nil, ParkError.UpdateCountryError)
                }
                
                guard let countryCountry = parkCountry["country"] as? String else {
                    return completion(nil, ParkError.UpdateCountryError)
                }
                
                guard let countryLatitude = parkCountry["latitude"] as? Double else {
                    return completion(nil, ParkError.UpdateCountryError)
                }
                
                guard let countryLongitude = parkCountry["longitude"] as? Double else {
                    return completion(nil, ParkError.UpdateCountryError)
                }
                
                try! self.realm.write {
                    realmPark.updated       = NSDate().timeIntervalSince1970
                    realmPark.name          = parkName
                    realmPark.path          = "parkinfo/\(snapshot.key)"
                    realmPark.countryIcon   = parkCountryIconCode
                    realmPark.parkIcon      = parkIconCode
                    
                    if let parkMapURL = value?["mapimage"] as? String {
                        realmPark.mapURL = parkMapURL
                    }
                    
                    if let realmCountry = realmPark.country {
                        realmCountry.updated = NSDate().timeIntervalSince1970
                        realmCountry.code = countryCode
                        realmCountry.name = parkName
                        realmCountry.country = countryCountry
                        realmCountry.latitude = countryLatitude
                        realmCountry.longitude = countryLongitude
                        
                        if let countryDetail = parkCountry["detail"] as? String {
                            realmCountry.detail     = countryDetail
                        }
                    }
                    
                    
                    /*
                     * Sections
                     */
                    for (key, section) in parkSections {
                        if let sectionValue = section as? [String : Any], let sectionName = sectionValue["name"] as? String, let sectionType = sectionValue["type"] as? String {
                            
                            if let realmSection: RealmParkSection = self.realm.object(ofType: RealmParkSection.self, forPrimaryKey: key) {
                                // the section is already in realm and linked to the park
                                realmSection.updated = NSDate().timeIntervalSince1970
                                realmSection.name = sectionName
                                realmSection.type = sectionType
                                
                                if let sectionPath = sectionValue["path"] as? String {
                                    realmSection.path = sectionPath
                                }
                            } else {
                                // Section is new; save to realm and link to park
                                let realmSection = RealmParkSection()
                                realmSection.updated = NSDate().timeIntervalSince1970
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
                    }
                }
                
                firebaseLoaded(realmPark)
                
                
                
            }) { (error) in
                print(error.localizedDescription)
                firebaseLoaded(nil)
            }
        }
        
        
        /**
         * Check if realmPark object is in realm; if not load from firebase
         */
        if let realmPark = self.realm.object(ofType: RealmPark.self, forPrimaryKey: key) {
            // realPark exsist in realm
            if NSDate().timeIntervalSince1970 > realmPark.updated + UPDATE_TIMEFRAME_PARK {
                // realmPark object needs to be updated
                updateParkFromFirebase(realmPark: realmPark, firebaseLoaded: { (realmPark) in
                    completion(realmPark, nil)
                })
            } else {
                // realmPark object does not to be updated
                completion(realmPark, nil)
            }
        } else {
            // The park is not in realm; usee selcted "country" which was loaded from firebase and not yet in realm
            loadParkFromFirebase(firebaseLoaded: { (realmPark) in
                completion(realmPark, nil)
            })
        }
        
        
        
    }

}

