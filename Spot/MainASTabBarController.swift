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
import PMAlertController
import FirebaseDatabase
import FirebaseStorage

class MainASTabBarController: ASTabBarController {
    
    var selectedPark    : String
    var selectedParkName: String
    var park: Park
    var parkController  : ParkASViewController!
    var listController  : ListASPagerNode!
    
    var parkNavgationController: ASNavigationController
    var listNavigationController: ASNavigationController
    
    init() {
        /**
         * MOCKUP DATA
         */
        
        self.selectedPark       = UserDefaults.standard.object(forKey: UserDefaultTypes.parkpath.rawValue) as? String ?? "addo"
        self.selectedParkName   = UserDefaults.standard.object(forKey: UserDefaultTypes.parkname.rawValue) as? String ?? "Addo Elephant National Park"
        
        var parkSections = [ParkSection]()
        if self.selectedPark == "addo" {
            parkSections.append(ParkSection(name: "Attractions", type: ItemType.attractions, path: "park/\(self.selectedPark)/attractions"))
        }
        parkSections.append(ParkSection(name: "Animals", type: ItemType.animals, path: "park/\(self.selectedPark)/animals"))
        
        self.park = Park(park: self.selectedPark, parkName: self.selectedParkName, sections: parkSections)
        
        /**
         * Initialize ViewControllers for TabBar
         */
        self.parkController             = ParkASViewController(park: self.park)
        self.listController             = ListASPagerNode(park: self.park)
        
        self.parkNavgationController = ASNavigationController(rootViewController: self.parkController)
        self.parkNavgationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
        self.parkNavgationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "logoTabBar"), tag: 0)
        self.parkNavgationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        
        self.listNavigationController = ASNavigationController(rootViewController: self.listController)
        self.listNavigationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
        self.listNavigationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "ic_list_36pt"), tag: 0)
        self.listNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        print(":: TABBARITEM SIZE \(self.listNavigationController.tabBarItem.image?.size)")
        
        super.init(nibName: nil, bundle: nil)
        
        self.parkController.delegate    = self
        self.setViewControllers([self.parkNavgationController, self.listNavigationController], animated: false)
        
        self.tabBar.unselectedItemTintColor = UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00) // Jumbo
        self.tabBar.tintColor = UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00) // Alizarin Crimson
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor.white)
        
        // Camera Button
        let itemWidth: CGFloat  = 48
        let itemHeight: CGFloat = 48
        let cameraButton = UIButton(frame: CGRect(x: self.view.frame.size.width / 2 - itemWidth / 2, y: self.view.frame.size.height - self.tabBar.frame.size.height + self.tabBar.frame.size.height / 2 - itemHeight / 2, width: itemWidth, height: itemHeight))
        cameraButton.setBackgroundImage(UIImage(named: "Google Bilder-64"), for: .normal)
        cameraButton.adjustsImageWhenHighlighted = false
        cameraButton.addTarget(self, action: #selector(upload), for: .touchUpInside)
        self.view.addSubview(cameraButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func upload(sender: UIButton){
        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1
        let pickerCropper = ImagePickerCropper(picker: imagePicker, cropperConfigurator: { image in
            let cropController = TOCropViewController(image: image)
            cropController.aspectRatioLockEnabled = true
            cropController.resetAspectRatioEnabled = false
            cropController.rotateButtonsHidden = true
            cropController.customAspectRatio = CGSize(width: 3, height: 2)
            cropController.modalTransitionStyle = .crossDissolve
            
            return cropController
        })
        
        pickerCropper.show(from: self) { result in
            if case let .success(images) = result, let image = images.first {
                // Get data from JPEG
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                
                let ref: FIRDatabaseReference = FIRDatabase.database().reference()
                let storage = FIRStorage.storage()
                let storageRef = storage.reference()
                
                // Key for firebase push
                let key = ref.child("items/addo/animals").childByAutoId().key
                // Ref for storage
                let imageOriginalRef = storageRef.child("animals/\(key).jpg")
                // Create metadata
                let metadataForImages = FIRStorageMetadata()
                metadataForImages.contentType = "image/jpeg"
                
                // Create upload task
                let imageOriginalUploadTask = imageOriginalRef.put(imageData!, metadata: metadataForImages)
                imageOriginalUploadTask.observe(.progress) { snapshot in
                    // Upload reported progress
                    if let progress = snapshot.progress {
                        let percentComplete: Float = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                        print(":: Upload image - \(percentComplete)")
                    }
                }
                imageOriginalUploadTask.observe(.success) { snapshot in
                    
                    let item = [
                        "name": key,
                        "timestamp": FIRServerValue.timestamp(),
                        "location": [
                            "latitude": -23.88065,
                            "longitude": 31.969589,
                            "parkName": "Addo National Elephant Park"
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
                            "public": "https://storage.cloud.google.com/safaridigitalapp.appspot.com/animals/\(key).jpg"
                        ]
                    ] as [String : Any]
                    
                    let childUpdates = ["/items/addo/animals/\(key)": item]
                    ref.updateChildValues(childUpdates, withCompletionBlock: { (error, reference) in
                        if (error != nil) {
                            print(":: ERROR - SAVING ITEM TO FIREBASE ::")
                            print(error)
                        } else {
                            // Create queue task
                            let queueRef = FIRDatabase.database().reference(withPath: "queue/tasks")
                            let queueKey = queueRef.childByAutoId().key;
                            let queueData = [
                                queueKey:
                                    [
                                        "ref": "/items/addo/animals/\(key)/images"
                                ]
                            ]
                            queueRef.setValue(queueData)
                        }
                    })
                    
                }
                
                
            }
        }
    }
    
}

extension MainASTabBarController: SelectParkDelegate {
    func selectPark() {
        
    }
    
    func selectPark(park: String, name: String) {
        
        /**
         * ToDo: Change "Select Park"
         */
        
        self.selectedPark       = park
        self.selectedParkName   = name
        UserDefaults.standard.set(park, forKey: UserDefaultTypes.parkpath.rawValue)
        UserDefaults.standard.set(name, forKey: UserDefaultTypes.parkname.rawValue)
        var parkSections = [ParkSection]()
        if park == "addo" {
            parkSections.append(ParkSection(name: "Attractions", type: ItemType.attractions, path: "park/\(park)/attractions"))
            parkSections.append(ParkSection(name: "Animals", type: ItemType.animals, path: "park/\(park)/animals"))
        } else if park == "kruger" {
            parkSections.append(ParkSection(name: "Animals", type: ItemType.animals, path: "park/\(park)/animals"))
        }
        
        let park = Park(park: self.selectedPark, parkName: self.selectedParkName, sections: parkSections)
        
        self.parkController = ParkASViewController(park: park)
        self.listController = ListASPagerNode(park: park)
        
        self.parkNavgationController = ASNavigationController(rootViewController: self.parkController)
        self.listNavigationController = ASNavigationController(rootViewController: self.listController)
        
        if let vc = self.listController.parent as? ASNavigationController {
            vc.popToRootViewController(animated: false)
        }
        
        self.parkNavgationController = ASNavigationController(rootViewController: self.parkController)
        self.parkNavgationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
        self.parkNavgationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "logoTabBar"), tag: 0)
        self.parkNavgationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        
        self.listNavigationController = ASNavigationController(rootViewController: self.listController)
        self.listNavigationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
        self.listNavigationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "ic_list_36pt"), tag: 0)
        self.listNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        
        self.parkController.delegate    = self
        self.setViewControllers([self.parkNavgationController, self.listNavigationController], animated: false)
        
        self.tabBar.unselectedItemTintColor = UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00) // Jumbo
        self.tabBar.tintColor = UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00) // Alizarin Crimson
    }
}
