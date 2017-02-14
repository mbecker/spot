//
//  MainASTabBarController.swift
//  Spot
//
//  Created by Mats Becker on 12/7/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import NVActivityIndicatorView
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import RealmSwift
import SwiftMessages
import SwiftyJSON
import CoreLocation
import ImagePicker
import TOCropViewController

class MainASTabBarController: UITabBarController, NVActivityIndicatorViewable {
    
    let launchImageView         = UIImageView()
    let loadingIndicatorView    = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0)
    let loadingLabel            = UILabel()
    let realmTransactions       = RealmTransactions()
    var locationManager         : CLLocationManager!
    
    var _realmPark  : RealmPark?
    
    var parkController  : ParkASViewController?
    var listController  : ListASPagerNode?
    
    let cameraDummyView = UIViewController()
    let progressView = UIProgressView()
    
    var delegateSelectPark: SelectParkDelegate?
    
    let _user = User()
    var _firebaseUser: FIRUser?
    
    var _loadedRandom = false
    
//    init(realmPark: RealmPark, loadedRandom: Bool = false) {
//        self._realmPark = realmPark
//        self.parkController     = ParkASViewController(realmPark: realmPark)
//        self.listController     = ListASPagerNode(realmPark: realmPark)
//
//        super.init(nibName: nil, bundle: nil)
//        self.delegate = self // UITabBarControllerDelegate to identify CameraDummyView: tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController)
//        self.parkController.delegate    = self // SelectParkDelegate
//
//        initTabBar(rootParkNavgationController: self.parkController, rootListNavigationController: self.listController)
//        
//        self._loadedRandom = loadedRandom
//        
//    }
    
    
    init(){
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    
    func initRealmPark(realmPark: RealmPark, loadedRandom: Bool = false) {
        self._realmPark = realmPark
        
        self.parkController     = ParkASViewController(realmPark: realmPark)
        self.parkController?.delegate    = self // SelectParkDelegate
        
        self.listController     = ListASPagerNode(realmPark: realmPark)
        
        initTabBar(loadedRandom: loadedRandom)
    }
    
    func initTabBar(loadedRandom: Bool = false){
        
        if let rootParkNavgationController = self.parkController, let rootListNavigationController = self.listController {
            
            /*
             * Complete tabbar is (re-)initialzed to show new park with all it's data (park, list, map)
             * Pop to root
             */
            if let vc = self.listController?.parent as? ASNavigationController {
                vc.popToRootViewController(animated: false)
            }
            /*
             * Initialize TabBar
             */
            self.tabBar.unselectedItemTintColor = UIColor.flatBlack
            self.tabBar.tintColor = UIColor.crimson
            /*
             * Initialize Tabitems for TabBar
             */
            
            // TabBar Item: Park
            let parkNavgationController = ASNavigationController(rootViewController: rootParkNavgationController)
            parkNavgationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
            parkNavgationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "logoTabBar"), tag: 0)
            parkNavgationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
            // TabBar Item: List
            let listNavigationController = ASNavigationController(rootViewController: rootListNavigationController)
            listNavigationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
            listNavigationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "ic_list_36pt"), tag: 0)
            listNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
            // TabBar Item: Map
            let mapNavigationController = UIViewController()
            mapNavigationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "mapTabBar"), tag: 0)
            mapNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
            // TabBar Item: User
            let userNavigationController = ASNavigationController(rootViewController: UserSettingsASViewController(user: self._user))
            userNavigationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
            userNavigationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "user"), tag: 0)
            userNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
            // TabBar Item: Camera
            cameraDummyView.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "camera"), tag: 1)
            cameraDummyView.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
            // Set TabBar Items
            self.setViewControllers([parkNavgationController, listNavigationController, cameraDummyView, mapNavigationController, userNavigationController], animated: false)
            
            self.loadingIndicatorView.removeFromSuperview()
            self.launchImageView.removeFromSuperview()
            self.loadingLabel.removeFromSuperview()
            
            if loadedRandom {
                showAlert(title: "We just loaded a random park for you!")
            }
            
        }
        
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        // Navigationbar
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self._loadedRandom {
            showAlert(title: "We couldn't find any location. We just loaded a random park for you!")
            self._loadedRandom = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .fullScreen
        
        // TabBar
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor.white)
        
        // LaunchImage
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
        
        // Progressview
        self.progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        self.progressView.progressViewStyle = .default
        self.progressView.progressTintColor = UIColor(red:0.93, green:0.33, blue:0.39, alpha:1.00)
        self.progressView.trackTintColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.00) // Flat black
        self.progressView.progress = 0.0
        
        // Firebase Auth
        FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                self._firebaseUser = user
            } else {
                self._firebaseUser = nil
            }
        }
        
        self.loadPark()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadPark(){
        if let userDefaultPark = UserDefaults.standard.object(forKey: UserDefaultTypes.parkpath.rawValue) as? String, let realmPark: RealmPark = self.realmTransactions.realm.object(ofType: RealmPark.self, forPrimaryKey: userDefaultPark) {
            
            self.initRealmPark(realmPark: realmPark)
            
        } else {
            
            
            // Load parks from file and update with firebase data if possible
            if let _: [RealmPark] = loadParksJSONFromFile(file: "parks") {
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
    
    func showCameraAndUpload(){
        
        guard self._firebaseUser != nil else {
            showAlert(title: "Please login!")
            return
        }
        
        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1
        
        let spotTag = SpotPicker(picker: imagePicker, spotConfigurator: { image in
            let spotViewController = CameraSpotViewController(image: image)
            return spotViewController
        })
        
//        spotTag.show(from: self, completion: { result in
//            if case let .success(images) = result, let image = images.first {
//                let imageView = UIImageView(frame: CGRect(x: self.view.frame.width / 2 - image.size.width / 2, y: self.view.frame.height / 2 - image.size.height / 2, width: image.size.width, height: image.size.height))
//                imageView.image = image
//                self.view.addSubview(imageView)
//            }
//        })
        
//        let pickerCropper = ImagePickerCropper(picker: imagePicker, cropperConfigurator: { image in
//            let cropController = TOCropViewController(image: image)
//            cropController.aspectRatioLockEnabled = true
//            cropController.resetAspectRatioEnabled = false
//            cropController.rotateButtonsHidden = false
//            cropController.customAspectRatio = CGSize(width: 3, height: 2)
//            cropController.modalTransitionStyle = .crossDissolve
//            
//            return cropController
//        })
//        
        spotTag.show(from: self) { result in
            if case let .success(images) = result, let image = images.first {
                
                // Add Progressview to tabbar
                self.tabBar.addSubview(self.progressView)
                
                // Get data from JPEG
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                
                let ref: FIRDatabaseReference = FIRDatabase.database().reference()
                let storage = FIRStorage.storage()
                let storageRef = storage.reference()
                
                // Park unique string key and park full name
                // ToDo: Get park string key from photo / camera tags
                let parkKey         = self._realmPark!.key
                let parkFullName    = self._realmPark!.name
                let itemType        = ItemType.community.rawValue
                
                // Key for firebase push
                let itemKey = ref.child("items/\(parkKey)/\(itemType)").childByAutoId().key
                // Ref for storage
                let imageOriginalRef = storageRef.child("\(itemType)/\(itemKey).jpg")
                // Create metadata
                let metadataForImages = FIRStorageMetadata()
                metadataForImages.contentType = "image/jpeg"
                
                // Create upload task
                let imageOriginalUploadTask = imageOriginalRef.put(imageData!, metadata: metadataForImages)
                imageOriginalUploadTask.observe(.progress) { snapshot in
                    // Upload reported progress
                    if let progress = snapshot.progress {
                        let percentComplete: Float = 90 * Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                        print(":: Upload image - \(percentComplete)")
                        // Progress: 90%
                        self.progressView.setProgress(percentComplete / 100, animated: true)
                    }
                }
                
                imageOriginalUploadTask.observe(.failure) { error in
                    print(error.error)
                }
                
                imageOriginalUploadTask.observe(.success) { snapshot in
                    // Progress: 95%
                    self.progressView.setProgress(0.95, animated: true)
                    
                    // Firebase data
                    let item = [
                        "name": itemKey,
                        "timestamp": FIRServerValue.timestamp(),
                        "location": [
                            "latitude": -23.88065,
                            "longitude": 31.969589,
                            "parkName": parkFullName
                        ],
                        "spottedby": [
                            "123": [
                                "name": "Michi",
                                "profile": "https://storage.googleapis.com/safaridigitalapp.appspot.com/icons/lego6.jpg"
                            ]
                        ],
                        "tags": [
                            "Elephant": "Elephant"
                        ],
                        "images": [
                            "public": "https://storage.cloud.google.com/safaridigitalapp.appspot.com/\(itemType)/\(itemKey).jpg"
                        ]
                    ] as [String : Any]
                    
                    let childUpdates = ["/items/\(parkKey)/\(itemType)/\(itemKey)": item]
                    ref.updateChildValues(childUpdates, withCompletionBlock: { (error, reference) in
                        if (error != nil) {
                            // Progress: 100%
                            self.progressView.setProgress(1, animated: true)
                            print(":: ERROR - SAVING ITEM TO FIREBASE ::")
                            print(error!)
                        } else {
                            // Progress: 95%
                            self.progressView.setProgress(1, animated: true)
                            
                            // Create queue task
                            let queueRef = FIRDatabase.database().reference(withPath: "queue/tasks")
                            let queueKey = queueRef.childByAutoId().key;
                            let queueData = [
                                queueKey:
                                    [
                                        "ref": "/items/\(parkKey)/\(itemType)/\(itemKey)/images"
                                ]
                            ]
                            queueRef.setValue(queueData) { (error, ref) -> Void in
                                if(error != nil){
                                    // Progress: 100%
                                    self.progressView.setProgress(1, animated: true)
                                    print(":: ERROR - CREATING TASK IN QUEUE ::")
                                    print(error!)
                                } else {
                                    // Progress: 100%
                                    self.progressView.setProgress(1, animated: true)
                                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                                        self.progressView.removeFromSuperview()
                                        self.progressView.setProgress(0.00, animated: false)
                                    })
                                }
                            }
                        }
                    }) // End ref.updateChildValues
                    
                    
                }
                
                
            }
        }
        // End spotTag.show
        
        
    }
    
    
    // MARK: - Helpers
    
    // MARK: - Helpers
    
    func showAlert(title: String, showOK: Bool = true) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        if showOK {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showMessage(message: String) {
        self.stopAnimating()
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        self.dismiss(animated: false, completion: nil)
        
        let image = UIImage(named:"Dinosaur-66")?.withRenderingMode(.alwaysTemplate)
        let info = MessageView.viewFromNib(layout: .MessageView)
        info.configureTheme(.error)
        info.button?.isHidden = true
        info.iconLabel?.isHidden = true
        info.configureContent(title: "Error", body: message, iconImage: image!)
        info.iconImageView?.isHidden = false
        info.iconImageView?.tintColor = UIColor.white
        info.configureIcon(withSize: CGSize(width: 30, height: 30), contentMode: .scaleAspectFill)
        info.backgroundView.backgroundColor = UIColor(red:0.93, green:0.33, blue:0.39, alpha:1.00)
        var infoConfig = SwiftMessages.defaultConfig
        infoConfig.presentationStyle = .bottom
        infoConfig.duration = .seconds(seconds: 2)
        
        
        SwiftMessages.show(config: infoConfig, view: info)
    }
    
    
}

extension MainASTabBarController : UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.cameraDummyView {
            
            if FIRAuth.auth()?.currentUser != nil {
                showCameraAndUpload()
            } else {
                self.showAlert(title: "Please sign in")
            }
            
            
            return false
        }
        return true
    }
}

extension MainASTabBarController: FormCountriesDelegate {
    
    func didSelect(parkKey: String) {
        // 1. Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        // 2. Start loading animation
        self.startAnimating(CGSize(width: self.view.bounds.height, height: 44), message: "Loading Park ...", type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0.0, displayTimeThreshold: 0, minimumDisplayTime: 2000)
        
        // 3. Load park
        self.realmTransactions.loadParkFromFirebaseAndSaveToRealm(key: parkKey, completion: { (realmPark, parkError) in
            if realmPark != nil {
                // loadingParkIndicator.removeFromSuperview()
                self.stopAnimating()
                //Status bar style and visibility
                UIApplication.shared.isStatusBarHidden = false
                self.initRealmPark(realmPark: realmPark!)
                self.dismiss(animated: false, completion: nil)
                
            } else if parkError != nil {
                switch (parkError!) {
                case .ParkDoesNotExist:
                    self.showMessage(message: "We couldn't load any park.")
                    break;
                case .UpdateError:
                    self.showMessage(message: "We couldn't update the park.")
                    break;
                default:
                    self.showMessage(message: "The park is not valid.")
                    break;
                }
                print("Error: Loading park")
                print(parkError!)
            }
        })
    }
    
}

extension MainASTabBarController: SelectParkDelegate {
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

extension MainASTabBarController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            let coordinate0 = CLLocation(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
            
            var distanceToClostesPark: Double = 123456789123456789.0
            var closestPark: RealmPark?
            for park in self.realmTransactions.realm.objects(RealmPark.self) {
                if let latitude: Double = park.country?.longitude, let longitude: Double = park.country?.longitude {
                    let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = coordinate0.distance(from: coordinate1)
                    if distance < distanceToClostesPark {
                        distanceToClostesPark = distance
                        closestPark = park
                    }
                }
            }
            
            if closestPark != nil {
                self.initRealmPark(realmPark: closestPark!)
            } else {
                showAlert(title: "We couldn't find any parks downloadded. Please restart the app.")
            }
            
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        
        if let realmPark = self.realmTransactions.realm.objects(RealmPark.self).first {
            self.initRealmPark(realmPark: realmPark, loadedRandom: true)
        } else {
            showAlert(title: "Now we couldn't load any parks. That shouldn't happen ...")
        }
    }
}

extension MainASTabBarController {
    
    
    
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
        realmImages.key     = "\(itemKey)-\(suffix)-images"
        
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
                updated = NSDate().timeIntervalSince1970
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
                 * Create RealmEncyclopediaItem
                 */
                let realmEncyclopediaitem       = RealmEncyclopediaItem()
                realmEncyclopediaitem.key       = itemKey // "Elephant", "Lion", ... (unique identifier)
                realmEncyclopediaitem.updated   = updated
                realmEncyclopediaitem.name      = name
                realmEncyclopediaitem.type      = type
                realmEncyclopediaitem.markdown  = markdown
                
                // Location: latitude && longitude
                if let latitude: Double = item["location"]["latitude"].double, let longitude = item["location"]["longitude"].double {
                    realmEncyclopediaitem.latitude  = latitude
                    realmEncyclopediaitem.longitude = longitude
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
                
                // 1. Original images
                
                if let realmOriginalImageFromJSON: RealmImages = getRealmImages(imageJSON: images, itemKey: itemKey, suffix: "original", resizedKeyInJSON: resizedKeyinJSON) {
                    realmEncyclopediaitem.image = realmOriginalImageFromJSON
                }
                    
                
                
                // 2. Additional images (each item has origina + resized)
                var i = 0
                for(_, JSONimageValue) : (String, JSON) in images {
                    i = i + 1
                    if let additionalImages = JSONimageValue.dictionary, let realmAdditionalImage: RealmImages = getRealmImages(imageJSON: additionalImages, itemKey: itemKey, suffix: "additional_\(i)", resizedKeyInJSON: resizedKeyinJSON) {
                        realmEncyclopediaitem.images.append(realmAdditionalImage)
                        
                    }
                }
                
                /*
                 * Loop through all parks in JSON; add the RealmEncyclopediaItem to each park
                 */
                for park in parks {
                    if let realmPark: RealmPark = self.realmTransactions.realm.object(ofType: RealmPark.self, forPrimaryKey: park) {
                        // Bug: Get all encyclopedia items from park, add the current one and update park
                        let realmParkEncyclopediaList = List<RealmEncyclopediaItem>()
                        realmParkEncyclopediaList.append(realmEncyclopediaitem)
                        for rEncyclopediaItem in realmPark.encyclopediaItems {
                            realmParkEncyclopediaList.append(rEncyclopediaItem)
                        }
                        
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
