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
    let parkController  : ParkASViewController!
    let listController  : ListASPagerNode!
    
    init() {
        /**
         * MOCKUP DATA
         */
        
        self.selectedPark       = UserDefaults.standard.object(forKey: UserDefaultTypes.parkpath.rawValue) as? String ?? "addo"
        self.selectedParkName   = UserDefaults.standard.object(forKey: UserDefaultTypes.parkname.rawValue) as? String ?? "Addo Elephant National Park"
        
        var parkSections = [ParkSection]()
        if self.selectedPark == "addo" {
            parkSections.append(ParkSection(name: "Attractions", path: "park/\(self.selectedPark)/attractions"))
        }
        parkSections.append(ParkSection(name: "Animals", path: "park/\(self.selectedPark)/animals"))
        
        
        /**
         * Initialize ViewControllers for TabBar
         */
        self.parkController             = ParkASViewController(park: self.selectedPark, parkName: self.selectedParkName, parkSections: parkSections)
        self.listController             = ListASPagerNode(park: self.selectedPark, parkName: self.selectedParkName, parkSections: parkSections)
        
        let parkNavgationController = ASNavigationController(rootViewController: self.parkController)
        parkNavgationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
        parkNavgationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "logoTabBar"), tag: 0)
        parkNavgationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        
        let listNavigationController = ASNavigationController(rootViewController: self.listController)
        listNavigationController.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: UIBarMetrics.default)
        listNavigationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "ic_list_36pt"), tag: 0)
        listNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        
        super.init(nibName: nil, bundle: nil)
        
        self.parkController.delegate    = self
        self.setViewControllers([parkNavgationController, listNavigationController], animated: false)
        
        self.tabBar.unselectedItemTintColor = UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00) // Jumbo
        self.tabBar.tintColor = UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00) // Alizarin Crimson
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor.white)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MainASTabBarController: SelectParkDelegate {
    func selectPark() {
        
    }
    
    func selectPark(park: String, name: String) {
        self.selectedPark       = park
        self.selectedParkName   = name
        UserDefaults.standard.set(park, forKey: UserDefaultTypes.parkpath.rawValue)
        UserDefaults.standard.set(name, forKey: UserDefaultTypes.parkname.rawValue)
        var parkSections = [ParkSection]()
        if park == "addo" {
            parkSections.append(ParkSection(name: "Attractions", path: "park/\(park)/attractions"))
            parkSections.append(ParkSection(name: "Animals", path: "park/\(park)/animals"))
        } else if park == "kruger" {
            parkSections.append(ParkSection(name: "Animals", path: "park/\(park)/animals"))
        }
        self.parkController.loadPark(park: selectedPark, parkName: selectedParkName, parkSections: parkSections)
        self.listController.updateParkSections(park: selectedPark, parkName: selectedParkName, parkSections: parkSections)
        if let vc = self.listController.parent as? ASNavigationController {
            vc.popToRootViewController(animated: false)
        }
    }
}
