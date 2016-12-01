//
//  DB.swift
//  Spot
//
//  Created by Mats Becker on 11/30/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Firebase

class DatabaseModels: AnyObject {
    
    struct dbData {
        let name: NSString
        let url:  NSString
        
        init(name: NSString, url: NSString) {
            self.name = name
            self.url  = url
        }
        
        init?(name: NSString){
            self.name = name
            self.url = ""
        }
    }
    
    var ref: FIRDatabaseReference!
    var animals: [dbData] = [dbData]()
    var attractions: [dbData] = [dbData]()
    
    init() {
        ref = FIRDatabase.database().reference()
        
        
        
        self.animals.append(
            dbData.init(
                name: "Bison",
                url: "gs://safaridigitalapp.appspot.com/animals/Bison1.jpg"
        ))
        
        self.animals.append(
            dbData.init(
                name: "Elephant",
                url: "gs://safaridigitalapp.appspot.com/animals/Elephant1.jpg"
        ))
        
        self.animals.append(
            dbData.init(
                name: "Turtle",
                url: "gs://safaridigitalapp.appspot.com/animals/Turtle.jpg"
        ))
        
        self.animals.append(
            dbData.init(
                name: "Giraffe",
                url: "gs://safaridigitalapp.appspot.com/animals/Giraffe1.JPG"
        ))
        
        self.animals.append(
            dbData.init(name: "Zebra", url: "gs://safaridigitalapp.appspot.com/animals/Zebra1.jpg")
        )
        
        
        
        /* Attractions */
        
        
        self.attractions.append(
            dbData.init(
                name: "Main Camp",
                url: "gs://safaridigitalapp.appspot.com/attractions/MainCamp1.jpg"
        ))
        
        self.attractions.append(
            dbData.init(
                name: "Criss Cross",
                url: "gs://safaridigitalapp.appspot.com/attractions/CrissCross1.jpg"
        ))
        
        self.attractions.append(
            dbData.init(
                name: "Shamrock Chapel",
                url: "gs://safaridigitalapp.appspot.com/attractions/ShamrockChapel1.jpg"
        ))
        
        self.attractions.append(
            dbData.init(name: "No image URL")!
        )
        
        self.attractions.append(
            dbData.init(
                name: "Image URL wron",
                url: "gs://safaridigitalapp.appspot.com/parks/QuestionMark222.jpg"
        ))
        
    }
    
    public func insertBatch(count: Int){
        for _ in 0...count {
            insertBatch()
        }
    }
    
    public func insertBatch(){
        
        for item in self.animals {
            let key = ref.child("park/addo/animals").childByAutoId().key
            let post = ["name": item.name,
                        "url":  item.url]
            let childUpdates = ["/park/addo/animals//\(key)": post]
            ref.updateChildValues(childUpdates)
            print(":: DB :: ANIMAL · name: \(item.name)")
        }
        
        for item in self.attractions {
            let key = ref.child("park/addo/attractions").childByAutoId().key
            let post = ["name": item.name,
                        "url":  item.url ]
            let childUpdates = ["/park/addo/attractions//\(key)": post]
            ref.updateChildValues(childUpdates)
            print(":: DB :: ATTRACTION · name: \(item.name)")
        }
    }
    
    public func deleteBatch() {
        self.ref.child("park").removeValue()
    }
    
    public func deleteItem(ref: FIRDatabaseReference){
        ref.removeValue()
    }
    
    public func addAnimal(animal: String){
        
        for item in self.animals {
            if item.name as String == animal {
                let key = ref.child("park/addo/animals").childByAutoId().key
                let post = ["name": item.name,
                            "url":  item.url]
                let childUpdates = ["/park/addo/animals//\(key)": post]
                ref.updateChildValues(childUpdates)
                print(":: DB :: ANIMAL · name: \(item.name)")
            }
        }
    }
    
    public func addAnimal(name: String, url: String, resizedURL: String){
        let key = ref.child("park/addo/animals").childByAutoId().key
        let post = ["name": name,
                    "url":  url,
                    "images": [
                        "image375x300": resizedURL]
            ] as [String : Any]
        let childUpdates = ["/park/addo/animals//\(key)": post]
        ref.updateChildValues(childUpdates)
        print(":: DB :: ANIMAL added · name: \(name)")
    }
    
}

