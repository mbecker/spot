//
//  FormCountriesTableViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/3/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

protocol FormCountriesDelegate {
    func didSelect(country: Country)
}

class FormCountriesTableViewController: UITableViewController {
    
    let NO_PARKS_FOUND = "No Parks found ..."
    let LOADING_COUNTRIES = "Loading countries ..."
    
    var showNoParksFound = false
    var showGPSfetching = true
    var showGPSError = false
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCountries = [Country]()
    private var parksAll = [Country]()
    private let parksClose = [Country]()
    
    var formCountriesDelegate: FormCountriesDelegate?
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCountries = parksAll.filter { park in
            let stringToSearchIn: String
            if let detail: String = park.detail {
                stringToSearchIn = park.country + park.name + detail + park.code
            } else {
                stringToSearchIn = park.country + park.name + park.code
            }
            
            return stringToSearchIn.lowercased().contains(searchText.lowercased())
        }
        if filteredCountries.count == 0 {
            showNoParksFound = true
        } else {
            showNoParksFound = false
        }
        if searchText.characters.count > 0 {
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
        
        let realmTransactions = RealmTransactions()
        realmTransactions.loadCountriesFromFirebase { (result) in
            if let countries: [Country] = result {
                self.parksAll = countries
                self.tableView.reloadData()
            }
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.isActive = true
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
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
            if parksClose.count == 0 {
                return 1
            }
            return parksClose.count
        default:
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredCountries.count
            }
            if parksAll.count == 0 {
                return 1
            }
            return parksAll.count
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
            if showGPSError {
                cell.textLabel?.text = "Error fetching parks at your location ..."
            } else if showGPSfetching {
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
                        cell.textLabel!.text = parksAll[indexPath.row].name + ", " + parksAll[indexPath.row].country
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
        switch indexPath.section {
        case 0:
            self.formCountriesDelegate?.didSelect(country: parksClose[indexPath.row])
        default:
            self.formCountriesDelegate?.didSelect(country: parksAll[indexPath.row])
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
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
