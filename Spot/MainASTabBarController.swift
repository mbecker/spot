//
//  MainASTabBarController.swift
//  Spot
//
//  Created by Mats Becker on 12/7/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
