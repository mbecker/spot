//
//  Park.swift
//  Spot
//
//  Created by Mats Becker on 08/11/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage

struct Park {
    let name: String
    let path: String
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}


struct ParkItem {
    let key:  String
    let ref:  FIRDatabaseReference
    let name: String
    let url:  String?
    let tags: [String]?
    let location: [String: Double]
    let images: [String: String]?
    var imagesRef = [String: URL]()
    let storage:            FIRStorage
    
    init(snapshot: FIRDataSnapshot) {
        self.storage      = FIRStorage.storage()
        self.key          = snapshot.key
        self.ref          = snapshot.ref
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name         = snapshotValue["name"] as! String
        self.url          = snapshotValue["url"] as? String
        self.images         = snapshotValue["images"] as? [String: String]
        
        self.tags           = snapshotValue["tags"] as? [String]
        self.location       = (snapshotValue["location"] as? [String: Double])!
        
        /*
         image375x300
         image337x218
         */
    }
    
}
