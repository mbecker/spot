//
//  FormCountriesTableViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/3/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation
import RealmSwift

protocol FormCountriesDelegate {
    func didSelect(parkKey: String)
}

class FormCountriesTableViewController: UITableViewController {
    
    let NO_PARKS_FOUND = "No Parks found ..."
    let LOADING_COUNTRIES = "Loading countries ..."
    
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    let _realm = try! Realm()
    
    var initialLoad = true
    var showNoParksFound = true
    var showGPSfetching = true
    var showGPSError = false
    
    let searchController = UISearchController(searchResultsController: nil)
    var _countriesFiltered  = [RealmCountry]()
    var _countriesAll       = [RealmCountry]()
    var _countriesClose     = [RealmCountry]()
    
    var locationManager: CLLocationManager!
    
    var formCountriesDelegate: FormCountriesDelegate?
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        _countriesFiltered.removeAll()
        _countriesFiltered = _countriesAll.filter { park in
            var stringToSearchIn: String
            if let detail: String = park.detail {
                stringToSearchIn = park.country + " " + park.name + " " + detail + " " + park.code
            } else {
                stringToSearchIn = park.country + " " + park.name + " " + park.code
            }
            stringToSearchIn = park.name
            // return stringToSearchIn.lowercased().contains(searchText.lowercased())
            
            print(stringToSearchIn.lowercased())
            print(searchText.lowercased())
            print(park.name)
            if stringToSearchIn.lowercased().range(of:searchText.lowercased()) != nil {
                return true
            }
            return false
        }
        if _countriesFiltered.count == 0 && searchText.characters.count > 0 {
            showNoParksFound = true
            tableView.reloadData()
        }
        if _countriesFiltered.count > 0 && searchText.characters.count > 0 {
            initialLoad = false
            showNoParksFound = false
            tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Park"
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        // self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        // self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        // self.searchController.searchBar.setValue("Back", forKey: "cancelButtonText")
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        //self.tableView.tableHeaderView = searchController.searchBar
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        // Preserve selection between presentations
        self.tableView.backgroundColor = UIColor.white
        self.clearsSelectionOnViewWillAppear = false
        
        self.tableView.separatorStyle = .none
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        /**
         * 1. Realm: load items from realm; then add items from firebase
         */
        for realmCountry in _realm.objects(RealmCountry.self) {
            addCountryAndReloadTable(realmCountry: realmCountry)
        }
        /**
         * 2. Firebase: After realm items are added, load firebase items (only if firebase item are not in realm)
         *    (firebase ref must load from online and not from cache)
         */
        self.ref.keepSynced(true)
        self.ref.child("parkcountries").observe(.value, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? [String: Any] {
                
                for (key, item) in snapshotValue {
                    if let itemValue = item as? [String : Any] {
                        guard let country: String = itemValue["country"] as? String else {
                            break
                        }
                        guard let name: String = itemValue["name"] as? String else {
                            break
                        }
                        guard let code: String = itemValue["code"] as? String else {
                            break
                        }
                        guard let longitude: Double = itemValue["longitude"] as? Double else {
                            break
                        }
                        guard let latitude: Double = itemValue["latitude"] as? Double else {
                            break
                        }
                        
                        /**
                         * Find realmCountry for given 'key'; only if the realmCountry does not exist then save it to realm
                         */
                        if self._realm.object(ofType: RealmCountry.self, forPrimaryKey: key) == nil {
                            let realmCountry        = RealmCountry()
                            realmCountry.key        = key
                            realmCountry.name       = name
                            realmCountry.country    = country
                            realmCountry.code       = code
                            realmCountry.latitude   = latitude
                            realmCountry.longitude  = longitude
                            
                            if let detail = itemValue["detail"] as? String {
                                realmCountry.detail = detail
                            }
                            
                            do {
                                try self._realm.write {
                                    self._realm.add(realmCountry)
                                }
                            } catch let error as NSError {
                                print(error)
                            }
                            
                            self.addCountryAndReloadTable(realmCountry: realmCountry)
                            
                        }
                        
                    }
                }
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        /**
         * GPS Location
         */
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.isActive = true
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            if _countriesClose.count == 0 {
                return 1
            }
            return _countriesClose.count
        default:
            if searchController.isActive && searchController.searchBar.text != "" && _countriesFiltered.count == 0 {
                return 1
            } else if searchController.isActive && searchController.searchBar.text != "" && _countriesFiltered.count > 0 {
                return _countriesFiltered.count
            } else if _countriesAll.count == 0 {
                return 1
            } else {
                return _countriesAll.count
            }
        }
    }
    
    /*
     * Cell
     */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        switch indexPath.section {
        case 0:
            if self._countriesClose.count == 0 {
                if showGPSError {
                    cell.textLabel?.text = "Error fetching parks at your location ..."
                } else if showGPSfetching {
                    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    activityIndicator.frame = CGRect(x: self.view.bounds.width / 2 - 12, y: 48 / 2 - 12, width: 24, height: 24)
                    activityIndicator.startAnimating()
                    cell.addSubview(activityIndicator)
                }
            } else {
                cell.textLabel!.text = _countriesClose[indexPath.row].name + ", " + _countriesClose[indexPath.row].country
            }
            
        default:
            
            if _countriesAll.count == 0 {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                activityIndicator.frame = CGRect(x: self.view.bounds.width / 2 - 12, y: 48 / 2 - 12, width: 24, height: 24)
                activityIndicator.startAnimating()
                cell.addSubview(activityIndicator)
            } else {
                if searchController.isActive && searchController.searchBar.text != "" {
                    if showNoParksFound {
                        cell.selectionStyle = .none
                        cell.textLabel!.text = NO_PARKS_FOUND
                    } else {
                        cell.textLabel!.text = _countriesFiltered[indexPath.row].name + ", " + _countriesFiltered[indexPath.row].country
                    }
                } else {
                    cell.textLabel!.text = _countriesAll[indexPath.row].name + ", " + _countriesAll[indexPath.row].country
                }
                
            }
            
        }
        // Bottom border
        let vw = UIView()
        vw.frame = CGRect(x: 20, y: 47, width: UIScreen.main.bounds.width - 40, height: 1)
        vw.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00).withAlphaComponent(0.6)
        cell.addSubview(vw)
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
        cell.textLabel?.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.00)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         // self.searchController.isActive = false
         tableView.becomeFirstResponder()
        switch indexPath.section {
        case 0:
            self.formCountriesDelegate?.didSelect(parkKey: self._countriesClose[indexPath.row].key)
            // self.formCountriesDelegate?.didSelect(country: parksClose[indexPath.row])
        default:
            if _countriesFiltered.count > 0 {
                self.formCountriesDelegate?.didSelect(parkKey: self._countriesFiltered[indexPath.row].key )
                // self.formCountriesDelegate?.didSelect(country: _parksFiltered[indexPath.row])
            } else {
                self.formCountriesDelegate?.didSelect(parkKey: self._countriesAll[indexPath.row].key)
                // self.formCountriesDelegate?.didSelect(country: parksAll[indexPath.row])
            }
        }
    }
    
    /*
     * Section
     */
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.white
        vw.borderWidth = 0
        vw.borderColor = UIColor.clear
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        vw.addSubview(title)
        title.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 12).isActive = true
        title.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
        
        switch section {
        case 0:
            title.text = "Parks close to you"
        default:
            title.text = "Parks"
        }
        
        return vw
    }
    
    // MARK: - Helpers
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func addCountryAndReloadTable(realmCountry: RealmCountry) {
        self._countriesAll.insert(realmCountry, at: 0)
        let indexPath = IndexPath(item: 0, section: 1)
        if self._countriesAll.count > 0 {
            // If the parksAll Array = 0 then we show an error; that's wy we can't add a new first row
            self.tableView.insertRows(at: [indexPath], with: .none)
        }
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .none)
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
}

extension FormCountriesTableViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    
}

extension FormCountriesTableViewController: UISearchDisplayDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}

extension FormCountriesTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FormCountriesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.characters.count == 0 {
            self._countriesFiltered.removeAll()
            self.tableView.reloadSections([1], with: .none)
        } else {
            filterContentForSearchText(searchText: searchController.searchBar.text!)
        }
    }
}

extension FormCountriesTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil && self._countriesClose.count == 0{
            let coordinate0 = CLLocation(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
            
            for country in self._countriesAll {
                let coordinate1 = CLLocation(latitude: country.latitude, longitude: country.longitude)
                let distance = coordinate0.distance(from: coordinate1)
                // print("Distance to \(park.name): \(distance)")
                let distance1: Double = Double(distance)
                if distance1 < 9000000 {
                    self.showGPSfetching = false
                    let parkToAdd: RealmCountry = country
                    OperationQueue.main.addOperation({
                        self._countriesClose.insert(parkToAdd, at: 0)
                        // ToDo: Relaod of seperated rows doesn't work; do not find the bug
                        // let indexPath = IndexPath(item: 0, section: 0)
                        // self.tableView.reloadRows(at: [indexPath], with: .none)
                        self.tableView.reloadSections([0], with: .none)
                    })
                }
            }
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
