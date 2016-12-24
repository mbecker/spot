//
//  Park.swift
//  Spot
//
//  Created by Mats Becker on 08/11/2016.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage
import UIKit

enum UserDefaultTypes: String {
    case parkpath   = "parkpath"
    case parkname   = "parkname"
}

enum Databasepaths: String {
    case attractions    = "attractions"
    case animals        = "animals"
}

enum ItemType: String {
    case attractions    = "attractions"
    case animals        = "animals"
}

class Park {
    let ref         :   FIRDatabaseReference
    let park        :   String!
    var parkName        :   String!
    let path        :   String!
    let sections    :   [ParkSection]!
    var country     :   String?
    var countryIcon :   UIImage?
    var parkIcon    :   UIImage?
    var mapImage    :   String?
    var info        :   String?
    
    init(park: String, parkName: String, sections: [ParkSection]) {
        self.ref        = FIRDatabase.database().reference()
        self.park       = park
        self.parkName   = parkName
        self.path       = "parkinfo/\(park)"
        self.sections   = sections
        
        self.country        = nil
        self.countryIcon    = nil
        self.parkIcon       = nil
        self.mapImage       = nil
        self.info           = nil
    }
    
    init(park: String, parkName: String, sections: [ParkSection], completion: @escaping (_ result: Bool) -> Void) {
        self.ref        = FIRDatabase.database().reference()
        self.park       = park
        self.parkName   = parkName
        self.path       = "parkinfo/\(park)"
        self.sections   = sections
        
        self.country        = nil
        self.countryIcon    = nil
        self.parkIcon       = nil
        self.mapImage       = nil
        self.info           = nil
        
        loadDB(path: path) { (loaded) in
            if loaded {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func load(completion: @escaping (_ result: Bool) -> Void) {
        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.country            =   value?["country"]       as? String ?? nil
            self.mapImage           =   value?["mapimage"]      as? String ?? nil
            self.parkName           =   value?["name"]          as? String ?? nil
            self.info               =   value?["info"]          as? String ?? nil
            
            if let countryIconValue =   value?["countryicon"]   as? String, let countryIconName: String = countries[countryIconValue] {
                self.countryIcon    =   AssetManager.getImage(countryIconName)
            } else {
                self.countryIcon    =   nil
            }
            if let parkIconValue    =   value?["parkicon"]      as? String, let parkIconName: String = parks[parkIconValue] {
                self.parkIcon       =   AssetManager.getImage(parkIconName)
            } else {
                self.parkIcon       = nil
            }
            
            completion(true)
            
        }) { (error) in
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func loadDB(path: String, completion: @escaping (_ result: Bool) -> Void) {
        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get park value
            let value = snapshot.value as? NSDictionary
            
            self.country            =   value?["country"]       as? String ?? nil
            self.mapImage           =   value?["mapimage"]      as? String ?? nil
            self.parkName           =   value?["name"]          as? String ?? nil
            self.info               =   value?["info"]          as? String ?? nil
            
            if let countryIconValue =   value?["countryicon"]   as? String, let countryIconName: String = countries[countryIconValue] {
                self.countryIcon    =   AssetManager.getImage(countryIconName)
            } else {
                self.countryIcon    =   nil
            }
            if let parkIconValue    =   value?["parkicon"]      as? String, let parkIconName: String = parks[parkIconValue] {
                self.parkIcon       =   AssetManager.getImage(parkIconName)
            } else {
                self.parkIcon       = nil
            }
            
            completion(true)
            
        }) { (error) in
            print(error.localizedDescription)
            completion(false)
        }

    }
    
    func loadDB(path: String){
        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get park value
            let value = snapshot.value as? NSDictionary
            
            self.country            =   value?["country"]       as? String ?? nil
            self.mapImage           =   value?["mapimage"]      as? String ?? nil
            self.parkName           =   value?["name"]          as? String ?? nil
            self.info               =   value?["info"]          as? String ?? nil
            
            if let countryIconValue =   value?["countryicon"]   as? String, let countryIconName: String = countries[countryIconValue] {
                self.countryIcon    =   AssetManager.getImage(countryIconName)
            } else {
                self.countryIcon    =   nil
            }
            if let parkIconValue    =   value?["parkicon"]      as? String, let parkIconName: String = parks[parkIconValue] {
                self.parkIcon       =   AssetManager.getImage(parkIconName)
            } else {
                self.parkIcon       = nil
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadDB(value: NSDictionary){
        self.country            =   value["country"]       as? String ?? nil
        self.mapImage           =   value["mapimage"]      as? String ?? nil
        self.parkName           =   value["name"]          as? String ?? nil
        self.info               =   value["info"]          as? String ?? nil
        
        if let countryIconValue =   value["countryicon"]   as? String, let countryIconName: String = countries[countryIconValue] {
            self.countryIcon    =   AssetManager.getImage(countryIconName)
        } else {
            self.countryIcon    =   nil
        }
        if let parkIconValue    =   value["parkicon"]      as? String, let parkIconName: String = parks[parkIconValue] {
            self.parkIcon       =   AssetManager.getImage(parkIconName)
        } else {
            self.parkIcon       = nil
        }
    }

}

class ParkSection {
    let name: String
    let path: String
    let type: ItemType
    init(name: String, type: ItemType, path: String) {
        self.name   = name
        self.type   = type
        self.path   = path
    }
}

struct Image {
    let publicURL: URL
    let gcloud: String
    
    init(publicURL: String, glcoud: String){
        self.publicURL = URL(string: publicURL)!
        self.gcloud = glcoud
    }
}

struct Images {
    let original: Image
    let resized: [String: Image]
    
    init(original: Image, resizedSize: String, resizedImage: Image) {
        self.original = original
        self.resized = [resizedSize: resizedImage]
    }
}

class ParkItem2 {
    
    let ref         :   FIRDatabaseReference
    let storage     :   FIRStorage
    
    let key         :   String
    let name        :   String
    
    let image: Images?
    var images: [Images]?
    
    
    let location    :   [String: Double]?
    let latitude    :   Double?
    let longitude   :   Double?
    
    let type        :   ItemType
    
    
    
    var tags        =   [String]()
    var spottedBy   =   [[String: String]]()
    
    
    
    
    
    
    /**
     * Park informatio
     */
    var park        :   Park!
    
    init?(snapshot: FIRDataSnapshot, type: ItemType, park: Park) {
        
        self.storage      = FIRStorage.storage()
        self.type         = type
        self.key          = snapshot.key
        self.ref          = snapshot.ref
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        
        if let name: String = snapshotValue["name"] as? String {
            self.name = name
        } else {
            return nil
        }
        
        self.park         = park
        
        
        
        
        
        
        /**
         * Tags
         */
        if let tags: [String:String] = snapshotValue["tags"] as? [String:String] {
            for (_, tag) in tags {
                self.tags.append(tag)
            }
        }
        
        /**
         * Sotted By
         */
        
        if let spotted: [String: AnyObject] = snapshotValue["spottedby"] as? [String: AnyObject] {
            for (key, user) in spotted {
                var spot = [String: String]()
                spot["id"] = key
                
                if let name: String = user["name"] as? String {
                    spot["name"] = name
                }
                
                if let profile: String = user["profile"] as? String {
                    spot["profile"] = profile
                }
                self.spottedBy.append(spot)
            }
        }
        
        /**
         * Location
         */
        if let location = snapshotValue["location"] as? [String: Any] {
            self.latitude = location["latitude"] as? Double
            self.longitude = location["longitude"] as? Double
            self.location = [String: Double]()
            self.location!["latitude"]  = self.latitude
            self.location!["longitude"] = self.longitude
        } else {
            self.location = nil
            self.latitude = nil
            self.longitude = nil
        }
        
        /**
         * 1. Load original image + resized
         */
        if let imagesFromSnaphsot = snapshotValue["images"] as? [String: Any] {
            print(":: IMAGES ::")
            print(imagesFromSnaphsot)
            let publicImage = imagesFromSnaphsot["public"] as! String;
            let glcoudIMage = imagesFromSnaphsot["gcloud"] as! String;
            print(":: PUBLIC IMAGE ::")
            print(publicImage)
            print(":: GCLOUD IMAGE ::")
            print(glcoudIMage)
            let originalImage = Image(publicURL: imagesFromSnaphsot["public"] as! String, glcoud: imagesFromSnaphsot["gcloud"] as! String)
            let resized: [String: Any] = imagesFromSnaphsot["resized"] as! [String : Any]
            let resized375: [String: String] = resized["375x300"] as! [String : String]
            let resizedImage = Image(publicURL: resized375["public"]!, glcoud: resized375["gcloud"]!)
            self.image = Images(original: originalImage, resizedSize: "375x300", resizedImage: resizedImage)
            
            self.images = [Images]()
            for (key, value) in imagesFromSnaphsot {
                if key != "public" && key != "gcloud" && key != "resized" {
                    let imageInArray: [String: Any] = value as! [String : Any]
                    let originalImage = Image(publicURL: imageInArray["public"] as! String, glcoud: imageInArray["gcloud"] as! String)
                    let resized: [String: Any] = imageInArray["resized"] as! [String : Any]
                    let resized375: [String: String] = resized["375x300"] as! [String : String]
                    let resizedImage = Image(publicURL: resized375["public"]!, glcoud: resized375["gcloud"]!)
                    self.images?.append(Images(original: originalImage, resizedSize: "375x300", resizedImage: resizedImage))
                }
            }
            
        } else {
            self.image = nil
            self.images = nil
        }
        
        
        /*
        self.url        = snapshotValue["url"] as? String ?? nil
        if let urlPublicString = snapshotValue["urlPublic"] as? String {
            self.urlPublic  = URL(string: urlPublicString)!
        }
        if let images = snapshotValue["imagesPublic"] as? [String: String] {
            for (name, url) in images {
                self.imagesPublic[name] = URL(string: url)!
            }
        }
        */
        
        /*
         * Images: Load google storage and public images reference
         *
        if let images =  snapshotValue["images"] as? [String: String] {
            self.images = images
            for (name, url) in images {
                let imgStorageReference = self.storage.reference(forURL: url)
                imgStorageReference.downloadURL(completion: { (storageURL, error) -> Void in
                    if error == nil {
                        self.setImagePublic(name: name, url: storageURL!, overwrite: true)
                    }
                })
            }
        } else {
            self.images = nil
        }
        
        if let url: String = self.url, url.characters.count > 0 {
            let imgStorageReference: FIRStorageReference = self.storage.reference(forURL: url)
            imgStorageReference.downloadURL(completion: { (storageURL, error) -> Void in
                if error == nil {
                    self.setUrlPublic(url: storageURL!, overwrite: true)
                } else {
                    print(":: PARK - init - set self.url")
                    print(error!.localizedDescription)
                }
            })
        }
        
        
         * Offline: Store images as public url
         */
        
        
    }
    
    /**
     *  Only save url pubic if it's not already set; see information flow for public storage image:
            1.) ParkItem is loaded
            2.) Loadined into Parktabel
            3.) Parktable cell loads public storage url
            4.) Save to self.urlPublic and firebase
            5.) NOW the ParkItem loads public storage url
        General assumption: firebase["url"] doesn't change during app's lifecycle
 
    func setUrlPublic(url: URL, overwrite: Bool = false){
        if overwrite {
            self.urlPublic = url
            self.ref.child("urlPublic").setValue(url.absoluteString)
        } else {
            if self.urlPublic == nil {
                self.urlPublic = url
                self.ref.child("urlPublic").setValue(url.absoluteString)
            }
        }
    }
    
    func setImagePublic(name: String, url: URL, overwrite: Bool = false){
        if overwrite {
            self.imagesPublic[name] = url
            self.ref.child("imagesPublic").child(name).setValue(url.absoluteString)
        } else {
            if !self.imagesPublic.contains(where: { _,_ in key == name }) {
                self.imagesPublic[name] = url
                self.ref.child("imagesPublic").child(name).setValue(url.absoluteString)
            }
        }
    }
    */
}

let parks = [
    "sanparks" : "sanparks.png"
]

let countries = [
    "ad" : "ad.png",
    "ae" : "ae.png",
    "af" : "af.png",
    "ag" : "ag.png",
    "al" : "al.png",
    "am" : "am.png",
    "ao" : "ao.png",
    "ar" : "ar.png",
    "at" : "at.png",
    "au" : "au.png",
    "az" : "az.png",
    "ba" : "ba.png",
    "bb" : "bb.png",
    "bd" : "bd.png",
    "be" : "be.png",
    "bf" : "bf.png",
    "bg" : "bg.png",
    "bh" : "bh.png",
    "bi" : "bi.png",
    "bj" : "bj.png",
    "bn" : "bn.png",
    "bo" : "bo.png",
    "br" : "br.png",
    "bs" : "bs.png",
    "bt" : "bt.png",
    "bw" : "bw.png",
    "by" : "by.png",
    "bz" : "bz.png",
    "ca" : "ca.png",
    "cd" : "cd.png",
    "cf" : "cf.png",
    "cg" : "cg.png",
    "ch" : "ch.png",
    "ci" : "ci.png",
    "cl" : "cl.png",
    "cm" : "cm.png",
    "cn" : "cn.png",
    "co" : "co.png",
    "cr" : "cr.png",
    "cu" : "cu.png",
    "cv" : "cv.png",
    "cy" : "cy.png",
    "cz" : "cz.png",
    "de" : "de.png",
    "dj" : "dj.png",
    "dk" : "dk.png",
    "dm" : "dm.png",
    "do" : "do.png",
    "dz" : "dz.png",
    "ec" : "ec.png",
    "ee" : "ee.png",
    "eg" : "eg.png",
    "eh" : "eh.png",
    "er" : "er.png",
    "es" : "es.png",
    "et" : "et.png",
    "fi" : "fi.png",
    "fj" : "fj.png",
    "fm" : "fm.png",
    "fr" : "fr.png",
    "ga" : "ga.png",
    "gb" : "gb.png",
    "gd" : "gd.png",
    "ge" : "ge.png",
    "gh" : "gh.png",
    "gm" : "gm.png",
    "gn" : "gn.png",
    "gq" : "gq.png",
    "gr" : "gr.png",
    "gt" : "gt.png",
    "gw" : "gw.png",
    "gy" : "gy.png",
    "hn" : "hn.png",
    "hr" : "hr.png",
    "ht" : "ht.png",
    "hu" : "hu.png",
    "id" : "id.png",
    "ie" : "ie.png",
    "il" : "il.png",
    "in" : "in.png",
    "iq" : "iq.png",
    "ir" : "ir.png",
    "is" : "is.png",
    "it" : "it.png",
    "jm" : "jm.png",
    "jo" : "jo.png",
    "jp" : "jp.png",
    "ke" : "ke.png",
    "kg" : "kg.png",
    "kh" : "kh.png",
    "ki" : "ki.png",
    "km" : "km.png",
    "kn" : "kn.png",
    "kp" : "kp.png",
    "kr" : "kr.png",
    "ks" : "ks.png",
    "kw" : "kw.png",
    "kz" : "kz.png",
    "la" : "la.png",
    "lb" : "lb.png",
    "lc" : "lc.png",
    "li" : "li.png",
    "lk" : "lk.png",
    "lr" : "lr.png",
    "ls" : "ls.png",
    "lt" : "lt.png",
    "lu" : "lu.png",
    "lv" : "lv.png",
    "ly" : "ly.png",
    "ma" : "ma.png",
    "mc" : "mc.png",
    "md" : "md.png",
    "me" : "me.png",
    "mg" : "mg.png",
    "mh" : "mh.png",
    "mk" : "mk.png",
    "ml" : "ml.png",
    "mm" : "mm.png",
    "mn" : "mn.png",
    "mr" : "mr.png",
    "mt" : "mt.png",
    "mu" : "mu.png",
    "mv" : "mv.png",
    "mw" : "mw.png",
    "mx" : "mx.png",
    "my" : "my.png",
    "mz" : "mz.png",
    "na" : "na.png",
    "ne" : "ne.png",
    "ng" : "ng.png",
    "ni" : "ni.png",
    "nl" : "nl.png",
    "no" : "no.png",
    "np" : "np.png",
    "nr" : "nr.png",
    "nz" : "nz.png",
    "om" : "om.png",
    "pa" : "pa.png",
    "pe" : "pe.png",
    "pg" : "pg.png",
    "ph" : "ph.png",
    "pk" : "pk.png",
    "pl" : "pl.png",
    "pt" : "pt.png",
    "pw" : "pw.png",
    "py" : "py.png",
    "qa" : "qa.png",
    "ro" : "ro.png",
    "rs" : "rs.png",
    "ru" : "ru.png",
    "rw" : "rw.png",
    "sa" : "sa.png",
    "sb" : "sb.png",
    "sc" : "sc.png",
    "sd" : "sd.png",
    "se" : "se.png",
    "sg" : "sg.png",
    "si" : "si.png",
    "sk" : "sk.png",
    "sl" : "sl.png",
    "sm" : "sm.png",
    "sn" : "sn.png",
    "so" : "so.png",
    "sr" : "sr.png",
    "st" : "st.png",
    "sv" : "sv.png",
    "sy" : "sy.png",
    "sz" : "sz.png",
    "td" : "td.png",
    "tg" : "tg.png",
    "th" : "th.png",
    "tj" : "tj.png",
    "tl" : "tl.png",
    "tm" : "tm.png",
    "tn" : "tn.png",
    "to" : "to.png",
    "tr" : "tr.png",
    "tt" : "tt.png",
    "tv" : "tv.png",
    "tw" : "tw.png",
    "tz" : "tz.png",
    "ua" : "ua.png",
    "ug" : "ug.png",
    "us" : "us.png",
    "uy" : "uy.png",
    "uz" : "uz.png",
    "va" : "va.png",
    "vc" : "vc.png",
    "ve" : "ve.png",
    "vn" : "vn.png",
    "vu" : "vu.png",
    "ws" : "ws.png",
    "ye" : "ye.png",
    "za" : "za.png",
    "zm" : "zm.png",
    "zw" : "zw.png"
]

let icons = [
    "Alligator" :   "Alligator-66.png",
    "Bat"       :   "Bat-66.png",
    "Bear"      :   "Bear-66.png",
    "Chicken"   :   "Chicken-66.png",
    "Deer"      :   "Deer-66.png",
    "Dinosaur"  :   "Dinosaur-66.png",
    "Dolphin"   :   "Dolphin-66.png",
    "Duck"      :   "Duck-66.png",
    "Elephant"  :   "Elephant_64.png",
    "Falcon"    :   "Falcon-66.png",
    "Flamingo"  :   "Flamingo-66.png",
    "Frog"      :   "Frog-66.png",
    "Giraffe"   :   "Giraffe-66.png",
    "Gorilla"   :   "Gorilla-66.png",
    "Hummingbird" : "Hummingbird-66.png",
    "Ladybird"  :   "Ladybird-66.png",
    "Lion"      :   "Lion-66.png",
    "Owl"       :   "Owl-66.png",
    "Pelican"   :   "Pelican-66.png",
    "Pinguin"   :   "Pinguin-66.png",
    "Rhinoceros":   "Rhinoceros-66.png",
    "Rabbit"    :   "Running Rabbit-66.png",
    "Stork"     :   "Stork-66.png",
    "Turtle"    :   "Turtle-66.png",
    "Bird"      :   "Twitter-66.png",
    "Tiger"     :   "Year of Tiger-66.png",
    "Bufallo"   :   "buffalo.png",
    "Butterfly" :   "butterfly-with-a-heart-on-frontal-wing-on-side-view.png",
    "Goat"      :   "goat.png",
    "Sheep"     :   "sheep.png",
    "Snake"     :   "snake66.png",
    "Unicorn"   :   "unicorn.png",
    "Creek"     :   "Creek-66.png",
    "Forest"    :   "Forest-66.png",
    "Fountain"  :   "Fountain-66.png",
    "ParkBench" :   "Park Bench-66.png",
    "Parking"   :   "Parking-66.png",
    "Treehouse" :   "Treehouse-66.png",
    "Hiking"    :   "backpacker.png",
    "Bicyle Parking"    :   "bicycle-parking.png",
    "Campfire"  :   "bonfire.png",
    "Church"    :   "church.png",
    "Cutlery"   :   "cutlery.png",
    "Panels"    :   "panel.png",
    "Tent"      :   "tent.png"
]

class FirebaseModel {
    
    var ref: FIRDatabaseReference!
    
    init(){
        ref = FIRDatabase.database().reference()
    }
    
    /**
     * Firebase Model
     "-1234abcd" : {
        "name" : "Kruger Lions 1",
        
        "url" : "gs://safaridigitalapp.appspot.com/animals/maxresdefault.jpg",
        "images" : {
            "lion" : "gs://safaridigitalapp.appspot.com/animals/-KVMEIvvabbpUCXJzOYd.jpg"
        },
     
        "location" : {
            "latitude" : -23.888061,
            "longitude" : 31.969467
        },
     
        "spottedby" : {
            "1234abcd" : {
                "name" : "Mike",
                "profile" : "https://storage.googleapis.com/safaridigitalapp.appspot.com/icons/lego3.jpg"
            },
            "123efsdf" : {
                "name" : "Mikki",
                "profile" : "https://storage.googleapis.com/safaridigitalapp.appspot.com/icons/lego9.jpg"
            }
        },
     
        "tags" : {
            "a1" : "Lion"
        },
     
     },
     */
    
    let animals = [
        "silver fox",
        "baboon",
        "dromedary",
        "kangaroo",
        "elk",
        "woodchuck",
        "walrus",
        "capybara",
        "giraffe",
        "eagle owl",
        "wildcat",
        "armadillo",
        "parakeet",
        "seal",
        "mynah bird",
        "octopus"
    ]
    
    let urls = [
        "gs://safaridigitalapp.appspot.com/animals/-KVS55WPWeluyuQtk4dQ.jpg",
        "gs://safaridigitalapp.appspot.com/animals/15_a_KrugerNational.jpg",
        "gs://safaridigitalapp.appspot.com/animals/African_elephant_warning_raised_trunk.jpg",
        "gs://safaridigitalapp.appspot.com/animals/Bison1.jpg",
        "gs://safaridigitalapp.appspot.com/animals/Elephant1.jpg",
        "gs://safaridigitalapp.appspot.com/animals/Giraffe1.JPG",
        "gs://safaridigitalapp.appspot.com/animals/maxresdefault.jpg",
        "gs://safaridigitalapp.appspot.com/animals/maxresdefault2.jpg",
        "gs://safaridigitalapp.appspot.com/animals/p1120770.jpg",
        "gs://safaridigitalapp.appspot.com/animals/coati.jpg",
        "gs://safaridigitalapp.appspot.com/animals/coyote.jpg",
        "gs://safaridigitalapp.appspot.com/animals/mandrill.jpg",
        "gs://safaridigitalapp.appspot.com/animals/ocelot.jpg"
    ]
    
    
    public func addAnimals(count: Int, parkName: String){
        for _ in 0...count {
            addAnimal(parkName: parkName)
        }
    }
    
    public func addAnimal(parkName: String){
        
        var images = [String: String]()
        for i in 0...randomNumber() {
            images["image" + String(i)] = urls[randomNumber(range: 0...urls.count - 1)]
        }
        
        var location = [String: Double]()
        location["latitude"] = -23.888061
        location["longitude"] = 31.969589
        
        
        
        let post =
            [
                "timestamp": FIRServerValue.timestamp(),
                "name": animals[randomNumber(range: 0...animals.count - 1)],
                "url":  urls[randomNumber(range: 0...urls.count - 1)],
                "images": images,
                "location": location,
                "spottedby": [
                    "123abv": [
                        "name" : "Mike",
                        "profile" : "https://storage.googleapis.com/safaridigitalapp.appspot.com/icons/lego3.jpg"
                    ],
                    "121asdy23abv": [
                        "name" : "Michael",
                        "profile" : "https://storage.googleapis.com/safaridigitalapp.appspot.com/icons/lego6.jpg"
                    ]
                ],
                "tags": [
                    "Dinosaur"  :   "Dinosaur",
                    "Dolphin"   :   "Dolphin",
                    "Duck"      :   "Duck",
                    "Elephant"  :   "Elephant",
                    "Creek"     :   "Creek",
                    "Forest"    :   "Forest",
                    "Fountain"  :   "Fountain",
                ]
            ] as [String : Any]
        
        let key = ref.child("park/\(parkName)/animals").childByAutoId().key
        let childUpdates = ["/park/\(parkName)/animals//\(key)": post]
        ref.updateChildValues(childUpdates, withCompletionBlock: { (error:Error?, dbref: FIRDatabaseReference) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(":: DB :: Added ANIMAL")
            }
        })
        
    }
    
    func deleteItems(parkName: String){
        self.ref.child("park").child(parkName).child("animals").removeValue(completionBlock: { (error:Error?, dbref: FIRDatabaseReference) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(":: DB :: \(parkName) :: Deleted ANIMALS")
            }
        })
    }
    
    func randomNumber(range: ClosedRange<Int> = 1...6) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
    
}

