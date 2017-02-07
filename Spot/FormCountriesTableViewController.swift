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

protocol FormCountriesDelegate {
    func didSelect(country: Country)
}

class FormCountriesTableViewController: UITableViewController {
    
    let NO_PARKS_FOUND = "No Parks found ..."
    let LOADING_COUNTRIES = "Loading countries ..."
    
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    var initialLoad = true
    var showNoParksFound = true
    var showGPSfetching = true
    var showGPSError = false
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCountries = [Country]()
    var parksAll = [Country]()
    var parksClose = [Country]()
    
    var locationManager: CLLocationManager!
    
    var formCountriesDelegate: FormCountriesDelegate?
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCountries.removeAll()
        filteredCountries = parksAll.filter { park in
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
        if filteredCountries.count == 0 && searchText.characters.count > 0 {
            showNoParksFound = true
            tableView.reloadData()
        }
        if filteredCountries.count > 0 && searchText.characters.count > 0 {
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
        
//        let realmTransactions = RealmTransactions()
//        realmTransactions.loadCountriesFromFirebase { (result) in
//            if let countries: [Country] = result {
//                self.parksAll = countries
//                self.tableView.reloadData()
//            }
//        }
        
        self.ref.child("parkcountries").observeSingleEvent(of: .value, with: { (snapshot) in
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
                        let countryObject = Country(key: key, name: name, country: country, code: code, latitude: latitude, longitude: longitude)
                        if let detail = itemValue["detail"] as? String {
                            countryObject.detail = detail
                        }
                        self.parksAll.insert(countryObject, at: 0)
                        let indexPath = IndexPath(item: 0, section: 1)
                        if self.parksAll.count > 1 {
                            // If the parksAll Array = 0 then we show an error; that's wy we can't add a new first row
                            self.tableView.insertRows(at: [indexPath], with: .none)
                        }
                        UIView.setAnimationsEnabled(false)
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                    } else {
                        break
                    }
                }
                
            } else {
                self.parksAll.removeAll()
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
            self.locationManager.requestAlwaysAuthorization()
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
    
    // MARK: - Helpers
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
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
            if parksClose.count == 0 {
                return 1
            }
            return parksClose.count
        default:
            if searchController.isActive && searchController.searchBar.text != "" && filteredCountries.count == 0 {
                return 1
            } else if searchController.isActive && searchController.searchBar.text != "" && filteredCountries.count > 0 {
                return filteredCountries.count
            } else if parksAll.count == 0 {
                return 1
            } else {
                return parksAll.count
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
            if showGPSError && parksClose.count == 0 {
                cell.textLabel?.text = "Error fetching parks at your location ..."
            } else if showGPSfetching && parksClose.count == 0 {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                activityIndicator.frame = CGRect(x: self.view.bounds.width / 2 - 12, y: 48 / 2 - 12, width: 24, height: 24)
                activityIndicator.startAnimating()
                cell.addSubview(activityIndicator)
            } else {
                cell.textLabel!.text = parksClose[indexPath.row].name + ", " + parksClose[indexPath.row].country
            }
            
            if parksClose.count > 1 {
                // Bottom border
                let vw = UIView()
                vw.frame = CGRect(x: 20, y: 47, width: UIScreen.main.bounds.width - 40, height: 1)
                vw.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00).withAlphaComponent(0.6)
                cell.addSubview(vw)
            }
            
        default:
            
            if parksAll.count == 0 {
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
                        cell.textLabel!.text = filteredCountries[indexPath.row].name + ", " + filteredCountries[indexPath.row].country
                    }
                } else {
                    cell.textLabel!.text = parksAll[indexPath.row].name + ", " + parksAll[indexPath.row].country
                }
                // Bottom border
                let vw = UIView()
                vw.frame = CGRect(x: 20, y: 47, width: UIScreen.main.bounds.width - 40, height: 1)
                vw.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00).withAlphaComponent(0.6)
                cell.addSubview(vw)
            }
            
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
        cell.textLabel?.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.00)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         // self.searchController.isActive = false
         tableView.becomeFirstResponder()
        switch indexPath.section {
        case 0:
            self.formCountriesDelegate?.didSelect(country: parksClose[indexPath.row])
        default:
            if filteredCountries.count > 0 {
                self.formCountriesDelegate?.didSelect(country: filteredCountries[indexPath.row])
            } else {
                self.formCountriesDelegate?.didSelect(country: parksAll[indexPath.row])
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
            self.filteredCountries.removeAll()
            self.tableView.reloadSections([1], with: .none)
        } else {
            filterContentForSearchText(searchText: searchController.searchBar.text!)
        }
    }
}

extension FormCountriesTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil && self.parksClose.count == 0{
            print("Found user's location: \(locations.first)")
            self.showGPSfetching = false
            let country = Country(key: "addo", name: "\(locations.first)", country: "DE", code: "DE", latitude: (locations.first?.coordinate.longitude)!, longitude: (locations.first?.coordinate.longitude)!)
            self.parksClose.insert(country, at: 0)
            let indexPath = IndexPath(item: 0, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
