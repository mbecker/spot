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
    let ref         :   FIRDatabaseReference
    let storage     :   FIRStorage
    
    let key         :   String
    let name        :   String
    let url         :   String
    var urlPublic   :   URL?
    let tags        :   [String]?
    let location    :   [String: Double]?
    let latitude    :   Double?
    let longitude   :   Double?
    let images      :   [String: String]?
    var imagesPublic:[String: URL] =   [String: URL]()
    
    
    init(snapshot: FIRDataSnapshot) {
        self.storage      = FIRStorage.storage()
        self.key          = snapshot.key
        self.ref          = snapshot.ref
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name         = snapshotValue["name"] as! String
        
        self.tags           =   snapshotValue["tags"] as? [String]
        
        if let location = snapshotValue["location"] as? [String: Double] {
            self.location = location
            self.latitude = location["latitude"]
            self.longitude = location["longitude"]
        } else {
            self.location = nil
            self.latitude = nil
            self.longitude = nil
        }
        
        self.url            = snapshotValue["url"] as! String
        self.urlPublic      = nil
        
        /*
         * Images: Load google storage and public images reference
         */
        if let images =  snapshotValue["images"] as? [String: String] {
            self.images = images
            for (name, url) in images {
                let imgStorageReference = self.storage.reference(forURL: url)
                loadPublicImage(name: name, imgStorageReference: imgStorageReference)
            }
        } else {
            self.images = nil
        }
        
        loadPublicUrl(url: self.url)
        
    }
    
    mutating func loadPublicImage(name: String, imgStorageReference: FIRStorageReference){
        var copy = self
        imgStorageReference.downloadURL(completion: { (storageURL, error) -> Void in
            if error == nil {
                copy.imagesPublic[name] = storageURL!
            }
        })
    }
    
    mutating func loadPublicUrl(url: String) {
        let imgStorageReference = self.storage.reference(forURL: url)
        var copy = self
        imgStorageReference.downloadURL(completion: { (storageURL, error) -> Void in
            if error == nil {
                copy.urlPublic = storageURL!
            }
        })
        self = copy
    }
}

class ParkItem2 {
    
    let ref         :   FIRDatabaseReference
    let storage     :   FIRStorage
    
    let key         :   String
    let name        :   String
    let url         :   String
    var urlPublic   :   URL?
    let tags        :   [String]?
    let location    :   [String: Double]?
    let latitude    :   Double?
    let longitude   :   Double?
    let images      :   [String: String]?
    var imagesPublic:[String: URL] =   [String: URL]()
    
    init(snapshot: FIRDataSnapshot) {
        self.storage      = FIRStorage.storage()
        self.key          = snapshot.key
        self.ref          = snapshot.ref
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name         = snapshotValue["name"] as! String
        
        self.tags           =   snapshotValue["tags"] as? [String]
        
        if let location = snapshotValue["location"] as? [String: Double] {
            self.location = location
            self.latitude = location["latitude"]
            self.longitude = location["longitude"]
        } else {
            self.location = nil
            self.latitude = nil
            self.longitude = nil
        }
        
        self.url        = snapshotValue["url"] as! String
        self.urlPublic  = nil
        
        /*
         * Images: Load google storage and public images reference
         */
        if let images =  snapshotValue["images"] as? [String: String] {
            self.images = images
            for (name, url) in images {
                let imgStorageReference = self.storage.reference(forURL: url)
                loadPublicImage(name: name, imgStorageReference: imgStorageReference)
            }
        } else {
            self.images = nil
        }
        
        
        let imgStorageReference = self.storage.reference(forURL: url)
        imgStorageReference.downloadURL(completion: { (storageURL, error) -> Void in
            if error == nil {
                self.urlPublic = storageURL!
            } else {
                self.urlPublic = nil
            }
        })
        
    }
    
    func loadPublicImage(name: String, imgStorageReference: FIRStorageReference){
        imgStorageReference.downloadURL(completion: { (storageURL, error) -> Void in
            if error == nil {
                self.imagesPublic[name] = storageURL!
            }
        })
    }
    
}


