//
//  MainASTabBarController.swift
//  Spot
//
//  Created by Mats Becker on 12/7/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import ImagePicker
import TOCropViewController
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class MainASTabBarController: UITabBarController {
    
    var _realmPark  : RealmPark
    
    var parkController  : ParkASViewController
    var listController  : ListASPagerNode
    
    let cameraDummyView = UIViewController()
    let progressView = UIProgressView()
    
    var delegateSelectPark: SelectParkDelegate?
    
    let _user = User()
    var _firebaseUser: FIRUser?
    
    var _loadedRandom = false
    
    init(realmPark: RealmPark, loadedRandom: Bool = false) {
        self._realmPark = realmPark
        self.parkController     = ParkASViewController(realmPark: realmPark)
        self.listController     = ListASPagerNode(realmPark: realmPark)
        
        super.init(nibName: nil, bundle: nil)
        self.delegate = self // UITabBarControllerDelegate to identify CameraDummyView: tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController)
        self.parkController.delegate    = self // SelectParkDelegate
        
        initTabBar(rootParkNavgationController: self.parkController, rootListNavigationController: self.listController)
        
        self._loadedRandom = loadedRandom
        
    }
    
    
    func initTabBar(rootParkNavgationController: ASViewController<ASDisplayNode>, rootListNavigationController: ASViewController<ASDisplayNode>){
        /*
         * Complete tabbar is (re-)initialzed to show new park with all it's data (park, list, map)
         * Pop to root
         */
        if let vc = self.listController.parent as? ASNavigationController {
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
        
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor.white)
        
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                let parkKey         = self._realmPark.key
                let parkFullName    = self._realmPark.name
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
    
    
}

extension MainASTabBarController : UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.cameraDummyView {
            showCameraAndUpload()
            return false
        }
        return true
    }
}

extension MainASTabBarController: SelectParkDelegate {
    func selectPark() {
        delegateSelectPark?.selectPark()
    }
    
    func selectPark(park: String, name: String) {
        
        /**
         * ToDo: Change "Select Park"
         */
//        
//        self.selectedPark       = park
//        self.selectedParkName   = name
//        UserDefaults.standard.set(park, forKey: UserDefaultTypes.parkpath.rawValue)
//        UserDefaults.standard.set(name, forKey: UserDefaultTypes.parkname.rawValue)
//        var parkSections = [ParkSection]()
//        if park == "addo" {
//            parkSections.append(ParkSection(name: "Attractions", type: ItemType.attractions, path: "park/\(park)/attractions"))
//            parkSections.append(ParkSection(name: "Animals", type: ItemType.animals, path: "park/\(park)/animals"))
//        } else if park == "kruger" {
//            parkSections.append(ParkSection(name: "Animals", type: ItemType.animals, path: "park/\(park)/animals"))
//        }
//        
//        self.park = Park(park: self.selectedPark!, parkName: self.selectedParkName!, sections: parkSections)
//        self.parkController = ParkASViewController(park: self.park!, user: self._user!)
//        self.listController = ListASPagerNode(park: self.park!)
//        initTabBar(rootParkNavgationController: self.parkController!, rootListNavigationController: self.listController!)
    }
}
