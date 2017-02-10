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

class MainNavigationController: UINavigationController, NVActivityIndicatorViewable {
    
    var launchImageView: UIImageView!
    var loadingIndicatorView: NVActivityIndicatorView!
    let realmTransactions = RealmTransactions()
    
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
        
        self.launchImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.launchImageView.image = #imageLiteral(resourceName: "SplahScreenAirBNB")
        
        self.loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 88 / 2, y: UIScreen.main.bounds.height / 2 + UIScreen.main.bounds.height / 4 - 44 / 2, width: 88, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0)
        self.loadingIndicatorView.startAnimating()
        
        self.view.addSubview(launchImageView)
        self.view.addSubview(loadingIndicatorView)
        
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .fullScreen
        
        FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if  user == nil {
                self.popToRootViewController(animated: true)
                self.launchImageView.removeFromSuperview()
                self.loadingIndicatorView.removeFromSuperview()
            } else {
                if !(self.topViewController is MainASTabBarController) {
                    self.loadPark()
                }
            }
        }
        
        /**
         * Load JOSN object to realm
         */
        loadAnimalsJSON()
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
    }
    
    func loadPark(){
        let realm = try! Realm()
        if let userDefaultPark = UserDefaults.standard.object(forKey: UserDefaultTypes.parkpath.rawValue) as? String {
            let parks = realm.objects(RealmPark.self).filter("key = '\(userDefaultPark)'")
            if parks.count == 1 {
                let realmPark = parks[0]
                /*
                 * Park is in local database; show ParkASViewController
                 */
                let park = Park(realmPark: realmPark)
                self.showTabBarController(park: park)
                realmTransactions.updateRealmObject(park: park)
                
            } else {
                /*
                 * Park is whyever not in local database; fetch park details
                 */
                realmTransactions.loadParkFromFirebaseAndSaveToRealm(key: userDefaultPark, completion: { (park) in
                    if park != nil {
                        self.showTabBarController(park: park!)
                    } else {
                        // Error in fecthing park details from firebae; show "park form list"
                        // showParkFormList()
                    }
                })
            }
        } else {
            /*
             * User has not yet set a park; show "park form list"
             */
            // showParkFormList()
        }
        
    }
    

}

extension MainNavigationController {
    func loadAnimalsJSON(){
        var jsonData: Data?
        
        
        
        guard let file = Bundle.main.path(forResource: "parkanimals", ofType: "json") else {
            return print("Fail")
        }
        
        jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
        let json = JSON(data: jsonData!)
        
        //If json is .Array
        //The `index` is 0..<json.count's string value
        for (index, items):(String, JSON) in json {
            for(id, item) : (String, JSON) in items {
                print(id)
                guard let name = item["name"].string else {
                    print("JSON name was not defined for item: \(id)")
                    break
                }
                print(name)
                
                guard let markdown = item["markdown"].string else {
                    print("JSON markdown was not defined for item: \(id)")
                    break
                }
                print(markdown)
                
                guard let parks = item["parks"] as? JSON else {
                    print("JSON parks was not defined for item: \(id)")
                    break
                }
                
                guard let images = item["images"] as? JSON else {
                    print("JSON images was not defined for item: \(id)")
                    break
                }
                
                for(parkid, park) : (String, JSON) in parks {
                    if let parkName = park.string {
                        print(parkName)
                    }
                }
                
                var imageObject = Image()
                var imagesObject = Images()
                for(imageKey, imageValue) : (String, JSON) in images {
                    
                    if imageKey == "public", let imageValuePublic = imageValue.rawString(), let imageValuePublicURL = URL(string: imageValuePublic) {
                        imageObject.publicURL = imageValuePublicURL
                        imagesObject.original = imageObject
                    } else if imageKey == "resized", let resizedImageJSON = imageValue.dictionary {
                        for (resizedIMageKey, resizedImageValue) : (String, JSON) in resizedImageJSON {
                            if resizedIMageKey == "375x300", let resizedImageValueJSON = resizedImageValue.dictionary {
                                for (resizedImageJSONKey, resizedImageJSONValue) : (String, JSON) in resizedImageValueJSON {
                                    if resizedImageJSONKey == "public", let resizedImageJSONValuePublic = resizedImageJSONValue.rawString() {
                                        let resizedImageObject = Image(publicURL: resizedImageJSONValuePublic)
                                        imagesObject.addImage(key: "375x300", image: resizedImageObject)
                                    }
                                }
                            }
                        }
                    } else {
                        if let additionalImage = imageValue.dictionary {
                            for(additionalImageKey, additionalImageValue) : (String, JSON) in additionalImage {
                                if additionalImageKey == "public", let additionalImagePublic = additionalImageValue.rawString() {
                                    print(additionalImagePublic)
                                }
                            }
                        }
                    }
                    
                }
                
                print(imagesObject)
                
                
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
                self.showTabBarController(park: park!)
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
