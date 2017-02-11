//
//  MainNavigationController.swift
//  Spot
//
//  Created by Mats Becker on 2/4/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseAuth
import RealmSwift
import SwiftMessages
import SwiftyJSON
import CoreLocation

class MainNavigationController: UINavigationController, NVActivityIndicatorViewable {
    
    let launchImageView = UIImageView()
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0)
    let loadingLabel = UILabel()
    let realmTransactions = RealmTransactions()
    
    var alreadSignedinUser = false
    
    var locationManager: CLLocationManager!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        // Navigationbar
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.launchImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.launchImageView.image = #imageLiteral(resourceName: "SplahScreenAirBNB")
        
        self.loadingIndicatorView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 88 / 2, y: UIScreen.main.bounds.height / 2 + UIScreen.main.bounds.height / 4 - 44 / 2, width: 88, height: 44)
        self.loadingIndicatorView.startAnimating()
        
        self.loadingLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.height  - 44, width: self.view.bounds.width, height: 24)
        self.loadingLabel.textAlignment = .center
        self.loadingLabel.text = "Initializing parks ..."
        self.loadingLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        self.loadingLabel.textColor = UIColor.white
        
        self.view.addSubview(launchImageView)
        self.view.addSubview(loadingIndicatorView)
        self.view.addSubview(self.loadingLabel)
        
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .fullScreen
        
        FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if  user == nil {
                self.popToRootViewController(animated: true)
                self.launchImageView.removeFromSuperview()
                self.loadingIndicatorView.removeFromSuperview()
                self.loadingLabel.removeFromSuperview()
                self.alreadSignedinUser = false
            } else if user != nil && !self.alreadSignedinUser {
                
                if self.topViewController is MainASTabBarController {
                    // ToDO: Negative check? !(a is b) -> !! -> true
                } else {
                    self.alreadSignedinUser = true
                    self.loadPark()
                }
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showTabBarController(park: Park) {
        let mainASTabBarController = MainASTabBarController(park: park)
        mainASTabBarController.delegateSelectPark = self
        self.pushViewController(mainASTabBarController, animated: true)
        self.loadingIndicatorView.removeFromSuperview()
        self.launchImageView.removeFromSuperview()
        self.loadingLabel.removeFromSuperview()
    }
    
    func showTabBarController(park: RealmPark) {
        let park = Park(realmPark: park)
        self.showTabBarController(park: park)
    }
    
    func loadPark(){
        if let userDefaultPark = UserDefaults.standard.object(forKey: UserDefaultTypes.parkpath.rawValue) as? String, let realmPark: RealmPark = self.realmTransactions.realm.object(ofType: RealmPark.self, forPrimaryKey: userDefaultPark) {
            
            self.showTabBarController(park: realmPark)
            
        } else {
            
            
            // Load parks from file and update with firebase data if possible
            if let realmParks: [RealmPark] = loadParksJSONFromFile(file: "parks") {
                loadingLabel.text = "Parks loaded succesfully."
                loadAndShowParkBasedOnDistance()
                /**
                 * Load JSON object to realm at first start of app
                 */
                loadEncyclopediaItemsJSONFromFile(file: "parkanimals")
                loadParkMarkdownJSONFromFile(file: "parksmarkdown")
                
            } else {
                loadingLabel.text = "Something went wrong. Restart the ap and please contact us."
            }
        }
        
        /**
         * ToDo: Update realm object
         */
        // realmTransactions.updateRealmObject(park: park)
        
        
        
    }
    
    func loadAndShowParkBasedOnDistance() {
        self.loadingLabel.text = "Fetching your location to show you the closest park"
        /**
         * GPS Location
         */
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            showAlert(title: "Location services were previously denied. Please enable location services for this app in Settings.")
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.requestLocation()
        }
        
    }
    
    // MARK: - Helpers
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    

}

extension MainNavigationController {
    
    
    
    func getResizedPublicURL(key: String, json: [String: JSON]) -> String? {
        
        for (resizedIMageKey, resizedImageValue) : (String, JSON) in json {
            if resizedIMageKey == key, let resizedImageValueJSON = resizedImageValue.dictionary {
                for (resizedImageJSONKey, resizedImageJSONValue) : (String, JSON) in resizedImageValueJSON {
                    if resizedImageJSONKey == "public", let resizedImageJSONValuePublic = resizedImageJSONValue.rawString() {
                        return resizedImageJSONValuePublic
                    }
                }
            }
        }
        
        return nil
    }
    
    func getRealmImages(imageJSON: [String:JSON], itemKey: String, suffix: String, resizedKeyInJSON: String) -> RealmImages? {
        // 1. Original images (original + additional)
        let realmImages     = RealmImages()
        realmImages.key     = "\(itemKey)"
        
        // 2. Original public image
        let realmImage      = RealmImage()
        realmImage.key      = "\(itemKey)-\(suffix)-original"
        realmImage.type     = "original"
        
        // 3. original resized image
        let realmResized    = RealmImage()
        realmResized.key    = "\(itemKey)-\(suffix)-resized-\(resizedKeyInJSON)"
        realmResized.type   = resizedKeyInJSON
        
        for(JSONimageKey, JSONimageValue) : (String, JSON) in imageJSON {
            if JSONimageKey == "public", let originalImagePublicURL = JSONimageValue.rawString() {
                
                // Add original image public url to realm "realm original image public" -> Save to "realm original image"
                realmImage.publicURL    = originalImagePublicURL
                realmImages.original    = realmImage
                
            } else if JSONimageKey == "resized", let resizedImageJSON = JSONimageValue.dictionary {
                
                if let originalImageResizedPublicURL: String = getResizedPublicURL(key: resizedKeyInJSON, json: resizedImageJSON) {
                    
                    // Add original resized image
                    realmResized.publicURL = originalImageResizedPublicURL
                    realmImages.resized.append(realmResized)
                    
                }
                
            }
        }
        
        if realmImages.original != nil && !realmImages.resized.isEmpty {
            return realmImages
        }
        return nil
    }
    
    func loadParksJSONFromFile(file: String) -> [RealmPark]? {
        var jsonData: Data?
        
        guard let file = Bundle.main.path(forResource: file, ofType: "json") else {
            print("JOSN failed reading file")
            return nil
        }
        
        jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
        let json = JSON(data: jsonData!)
        
        var realmParks = [RealmPark]()
        
        for(id, park) : (String, JSON) in json {
            
            let key = id
            let path = "parkinfo/\(key)"
            
            guard let updated = park["updated"].double else {
                print("JSON updated was not defined for park: \(id)")
                return nil
            }
            
            guard let name = park["name"].string else {
                print("JSON name was not defined for park: \(id)")
                return nil
            }
            
            
            guard let countryicon = park["countryicon"].string else {
                print("JSON countryicon was not defined for park: \(id)")
                return nil
            }
            
            guard let parkicon = park["parkicon"].string else {
                print("JSON parkicon was not defined for park: \(id)")
                return nil
            }
            
            guard let mapimage = park["mapimage"].string else {
                print("JSON parkicon was not defined for park: \(id)")
                return nil
            }
            
            /**
             * Country
             */
            guard let countryName = park["country"]["name"].string else {
                print("JSON country:name was not defined for park: \(id)")
                return nil
            }
            
            guard let countryCode = park["country"]["code"].string else {
                print("JSON country:code was not defined for park: \(id)")
                return nil
            }
            
            guard let countryCountry = park["country"]["country"].string else {
                print("JSON country:country was not defined for park: \(id)")
                return nil
            }
            
            guard let countryDetail = park["country"]["detail"].string else {
                print("JSON country:detail was not defined for park: \(id)")
                return nil
            }
            
            guard let countryLatitude = park["country"]["latitude"].double else {
                print("JSON country:longitude was not defined for park: \(id)")
                return nil
            }
            
            guard let countryLongitude = park["country"]["longitude"].double else {
                print("JSON country:longitude was not defined for park: \(id)")
                return nil
            }
            
            /**
             * Sections
             */
            guard let sections = park["section"].dictionary else {
                print("JSON sections was not defined for park: \(id)")
                return nil
            }
            
            /**
             * Create RealmPark
             */
            let realmPark = RealmPark()
            
            for (sectionKey, sectionValue) : (String, JSON) in sections {
                guard let sectionName = sectionValue["name"].string else{
                    print("JSON section:name was not defined for park: \(id)")
                    break
                }
                guard let sectionPath = sectionValue["path"].string else{
                    print("JSON section:path was not defined for park: \(id)")
                    break
                }
                guard let sectionType = sectionValue["type"].string else{
                    print("JSON section:type was not defined for park: \(id)")
                    break
                }
                
                let realmSection = RealmParkSection()
                realmSection.key = sectionKey
                realmSection.name = sectionName
                realmSection.path = sectionPath
                realmSection.type = sectionType
                realmSection.updated = updated
                
                realmPark.sections.append(realmSection)
            }
            
            let realmCountry = RealmCountry()
            realmCountry.key        = key
            realmCountry.name       = countryName
            realmCountry.code       = countryCode
            realmCountry.country    = countryCountry
            realmCountry.detail     = countryDetail
            realmCountry.latitude   = countryLatitude
            realmCountry.longitude  = countryLongitude
            
            
            realmPark.key           = key
            realmPark.path          = "parkinfo/\(key)"
            realmPark.updated       = updated
            realmPark.name          = name
            realmPark.countryIcon   = countryicon
            realmPark.parkIcon      = parkicon
            realmPark.mapURL        = mapimage
            realmPark.country       = realmCountry
            
            try! self.realmTransactions.realm.write {
                self.realmTransactions.realm.add(realmPark, update: true)
            }
            
            realmParks.append(realmPark)
        }
        
        return realmParks
    }
    
    // Load Markdown from JSON; save to realm
    func loadParkMarkdownJSONFromFile(file: String){
        var jsonData: Data?
        guard let file = Bundle.main.path(forResource: file, ofType: "json") else {
            return print("Fail")
        }
        jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
        let json = JSON(data: jsonData!)
        
        /**
         *  {
         *      "addo" : {
         *          "updated": 1486719547,
         *          "markdown" : "markdown"
         *      },
         *      "kruger" : {
         *          "updated": 1486719547,
         *          "markdown" : "markdown"
         *      }
         *  }
         */
        
        for(park, item) : (String, JSON) in json {
            guard let markdown = item["markdown"].string else {
                print("JSON markdown was not defined for item: \(park)")
                break
            }
            
            var updated: Double = 0.0
            if let updatedJSON: Double = item["updated"].double {
                updated = updatedJSON
            } else {
                updated = NSDate.timeIntervalSinceReferenceDate
            }
            
            let realmMarkdown = RealmMarkdown()
            realmMarkdown.key       = park
            realmMarkdown.markdown  = markdown
            realmMarkdown.updated   = updated
            
            do {
                try self.realmTransactions.realm.write {
                    self.realmTransactions.realm.create(RealmPark.self, value: ["key": park, "markdown": realmMarkdown], update: true)
                }
            } catch let error as NSError {
                print(error)
            }
            
        }
    }
    
    func loadEncyclopediaItemsJSONFromFile(file: String){
        var jsonData: Data?
        
        guard let file = Bundle.main.path(forResource: file, ofType: "json") else {
            return print("Fail")
        }
        
        jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
        let json = JSON(data: jsonData!)
        
        //If json is .Array
        //The `index` is 0..<json.count's string value
        for (index, items):(String, JSON) in json {
            for(itemKey, item) : (String, JSON) in items {
                
                let type = index
                
                guard let updated = item["updated"].double else {
                    print("JSON updated was not defined for item: \(itemKey)")
                    break
                }
                
                guard let name = item["name"].string else {
                    print("JSON name was not defined for item: \(itemKey)")
                    break
                }
                
                guard let markdown = item["markdown"].string else {
                    print("JSON markdown was not defined for item: \(itemKey)")
                    break
                }
                
                guard let parksJSON = item["parks"].dictionary else {
                    print("JSON parks was not defined for item: \(itemKey)")
                    break
                }
                
                guard let images = item["images"].dictionary else {
                    print("JSON images was not defined for item: \(itemKey)")
                    break
                }
                
                var parks = [String]()
                for(_, park) : (String, JSON) in parksJSON {
                    if let parkName = park.string {
                        parks.append(parkName)
                    }
                }
                
                
                /**
                 * RealmImages:
                 *  - key: String
                 *  - original: RealmImage
                 *  - resized: List<RealmImage>
                 *
                 * RealImage:
                 *  - key: String
                 *  - type: String
                 *  - publicURL: String
                 */
                let resizedKeyinJSON = "375x300"
                
                
                // 1. Original images (original + resized)
                var realmOriginalImage = RealmImages()
                if let realmOriginalImageFromJSON: RealmImages = getRealmImages(imageJSON: images, itemKey: itemKey, suffix: "original", resizedKeyInJSON: resizedKeyinJSON) {
                    realmOriginalImage      = realmOriginalImageFromJSON
                }
                
                // 2. Additional images (each item has origina + resized)
                var realmAdditionalImages = [RealmImages]()
                for(_, JSONimageValue) : (String, JSON) in images {
                    var i = 0
                    if let additionalImages = JSONimageValue.dictionary, let realmAdditionalImage: RealmImages = getRealmImages(imageJSON: additionalImages, itemKey: itemKey, suffix: "additional_\(i)", resizedKeyInJSON: resizedKeyinJSON) {
                        realmAdditionalImages.append(realmAdditionalImage)
                        i = i + 1
                    }
                }
                
                /**
                 * Create RealmEncyclopediaItem
                 */
                let realmEncyclopediaitem       = RealmEncyclopediaItem()
                realmEncyclopediaitem.key       = itemKey // "Elephant", "Lion", ... (unique identifier)
                realmEncyclopediaitem.updated   = updated
                realmEncyclopediaitem.name      = name
                realmEncyclopediaitem.type      = type
                realmEncyclopediaitem.markdown  = markdown
                
                if realmOriginalImage.original != nil {
                    realmEncyclopediaitem.image = realmOriginalImage
                }
                
                for resizedImages in realmAdditionalImages {
                    realmEncyclopediaitem.images.append(resizedImages)
                }
                
                /**
                 * Loop through all parks in JSON; add the RealmEncyclopediaItem to each park
                 */
                for park in parks {
                    if let realmPark: RealmPark = self.realmTransactions.realm.object(ofType: RealmPark.self, forPrimaryKey: park) {
                        // Bug: Get all encyclopedia items from park, add the current one and update park
                        let realmParkEncylopediaItems = realmPark.encyclopediaItems
                        let realmParkEncyclopediaList = List<RealmEncyclopediaItem>()
                        for rEncyclopediaItem in realmParkEncylopediaItems {
                            realmParkEncyclopediaList.append(rEncyclopediaItem)
                        }
                        realmParkEncyclopediaList.append(realmEncyclopediaitem)
                        
                        
                        do {
                            try self.realmTransactions.realm.write {
                                self.realmTransactions.realm.create(RealmPark.self, value: ["key": park, "encyclopediaItems": realmParkEncyclopediaList], update: true)
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    } else {
                        let realmPark = RealmPark()
                        realmPark.key = park
                        realmPark.encyclopediaItems.append(realmEncyclopediaitem)
                        try! self.realmTransactions.realm.write {
                            self.realmTransactions.realm.add(realmPark)
                        }
                    }
                }
                
                
                
                
                
            }
        }
        
    }

    
}

extension MainNavigationController: FormCountriesDelegate {
    func didSelect(country: Country) {
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        
        self.startAnimating(CGSize(width: self.view.bounds.height, height: 44), message: "Loading Park ...", type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0.0, displayTimeThreshold: 0, minimumDisplayTime: 2000)

        self.realmTransactions.loadParkFromFirebaseAndSaveToRealm(key: country.key, completion: { (park) in
            if park != nil {
                // loadingParkIndicator.removeFromSuperview()
                self.stopAnimating()
                //Status bar style and visibility
                UIApplication.shared.isStatusBarHidden = false
                // self.showTabBarController(park: park!)
                self.dismiss(animated: false, completion: nil)
            } else {
                self.stopAnimating()
                //Status bar style and visibility
                UIApplication.shared.isStatusBarHidden = false
                self.dismiss(animated: false, completion: nil)
                
                let image = UIImage(named:"Dinosaur-66")?.withRenderingMode(.alwaysTemplate)
                let info = MessageView.viewFromNib(layout: .MessageView)
                info.configureTheme(.error)
                info.button?.isHidden = true
                info.iconLabel?.isHidden = true
                info.configureContent(title: "Error", body: "We couldn't load the park ...", iconImage: image!)
                info.iconImageView?.isHidden = false
                info.iconImageView?.tintColor = UIColor.white
                info.configureIcon(withSize: CGSize(width: 30, height: 30), contentMode: .scaleAspectFill)
                info.backgroundView.backgroundColor = UIColor(red:0.93, green:0.33, blue:0.39, alpha:1.00)
                var infoConfig = SwiftMessages.defaultConfig
                infoConfig.presentationStyle = .bottom
                infoConfig.duration = .seconds(seconds: 2)
                
                
                SwiftMessages.show(config: infoConfig, view: info)
            }
        })
        
    }
}

extension MainNavigationController: SelectParkDelegate {
    func selectPark() {
        let formCountriesTableViewController = FormCountriesTableViewController(style: .grouped)
        formCountriesTableViewController.formCountriesDelegate = self
        let formNavigationController = UINavigationController(rootViewController: formCountriesTableViewController)
        formNavigationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
        
        self.present(formNavigationController, animated: true, completion: nil)
    }
    
    func selectPark(park: String, name: String) {
        
    }
}

extension MainNavigationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            let coordinate0 = CLLocation(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
            
            var distanceToClostesPark: Double = 123456789123456789.0
            var closestPark = RealmPark()
            for park in self.realmTransactions.realm.objects(RealmPark.self) {
                closestPark = park
                if let latitude: Double = park.country?.longitude, let longitude: Double = park.country?.longitude {
                    let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = coordinate0.distance(from: coordinate1)
                    if distance < distanceToClostesPark {
                        distanceToClostesPark = distance
                        closestPark = park
                    }
                }
            }
            
            if closestPark.key != nil {
                self.showTabBarController(park: closestPark)
            } else {
                showAlert(title: "We couldn't find any parks downloadded. Please restart the app.")
            }
            
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        showAlert(title: "We couldn't find any location. Please restart the app and enable GPS.")
    }
}
