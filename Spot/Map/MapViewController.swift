//
//  MapViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/16/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//
import Foundation
import UIKit
import Mapbox
import FirebaseDatabase
import SwiftDate


class MapViewController: UIViewController {
    
    let _firebaseReference = FIRDatabase.database().reference()
    var observers = [String: FIRDatabaseHandle]()
    
    
    var _realmPark: RealmPark!
//    var _realmParkSections = [RealmParkSection]()
    var _filterStruct: FilterStruct! {
        didSet {
            if _filterStruct.isLive {
                self.view.addSubview(self.liveIcon)
                
                let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
                connectedRef.observe(.value, with: { snapshot in
                    if let connected = snapshot.value as? Bool, connected {
                        self.liveIcon.showStrikethrough(show: false)
                    } else {
                        self.liveIcon.showStrikethrough(show: true)
                    }
                })
                
                
            } else {
                self.liveIcon.removeFromSuperview()
            }
        }
    }
    
    /**
     * MapView
     */
    var mapView: MGLMapView?
    var layerIdentifiers: Set<String> = Set<String>()
    var _sources = [MGLShapeSource]()
    var _symbols = [MGLSymbolStyleLayer]()
    var _annotations = [MGLAnnotation]()
    let buttonFilter            = FilterButton(frame: CGRect.zero)
    
    let liveIcon = LiveView(frame: CGRect.zero)
    
    /**
     * Tags
     */
    var isLoading       = false {
        willSet(newValue) {
            if newValue {
                buttonFilter.loadingIndicator(true)
            } else {
                var countFilter = 0
                if self._filterStruct.timerange.isSet() {
                    countFilter = countFilter + 1
                }
                for filterSection: FilterSection in self._filterStruct.filterSections {
                    switch filterSection.realmParkSection.getType() {
                    case .community:
                        if filterSection.isEnabled {
                            countFilter = countFilter + 1
                        }
                    default:
                        if !filterSection.isAllTagsSelected() {
                            countFilter = countFilter + 1
                        }
                    }
                }
                buttonFilter.setTitleAndCount(title: "Filter", count: countFilter)
            }
        }
    }
    var isMapLoaded     = false
//    var filterLoaded    = false
//    var isLive          = false {
//        didSet {
//            if isLive {
//                self.view.addSubview(self.liveIcon)
//            } else {
//                self.liveIcon.removeFromSuperview()
//            }
//        }
//    }
    let _tags           = Tags().getKeys()
    let now = DateInRegion()
//    var _weightedTags    = [ItemType : [String: Int]]()
//    var _selectedTags    = [String]()
//    var _lowerDate      : DateInRegion?
//    var _upperDate      : DateInRegion?
    
    /**
     * Data
     */
    var items2: [ParkItem2] = [ParkItem2]()
    var filteredItems2: [ParkItem2] = [ParkItem2]()
    
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        self.mapView    = nil
        self._realmPark = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(realmPark: RealmPark) {
        self.init(nibName: nil, bundle: nil)
        self._realmPark = realmPark
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterDate = FilterDate(lowerDate: DateInRegion() - 2.days, upperDate: DateInRegion() - 6.days)
        var filterSections = [FilterSection]()
        
        var sectionsPlaceHolder = [FilterSection]()
        
        for section in self._realmPark.sections {
            let filterSection = FilterSection(realmParkSection: section, isEnabled: true)
            print(section.getType().rawValue)
            switch section.getType() {
            case .community:
                sectionsPlaceHolder.append(filterSection)
            default:
                filterSections.append(filterSection)
            }
        }
        for section in sectionsPlaceHolder {
            filterSections.insert(section, at: 0)
        }
        
        self._filterStruct = FilterStruct(filterSections: filterSections, isActive: false, timerange: filterDate, isLive: false)
        
        
        /**
         * Data
         */
//        if let realmPark: RealmPark = self._realmPark {
//            for section in realmPark.sections {
//                self._realmParkSections.append(section)
//            }
//        }
//        self._lowerDate = DateInRegion() - 4.days // Set default dates; ToDo: If user is logged in or user has subscription enable more days
//        self._upperDate = DateInRegion() - 1.months
        
        /**
         * Mapview
         */
        // Fill in the next line with your style URL from Mapbox Studio.
        let styleURL = NSURL(string: "mapbox://styles/mbecker/ciw7woa4z00232pnqx8300j67")
        //mapView = MGLMapView(frame: view.bounds, styleURL: styleURL as URL?)
        mapView = MGLMapView(frame: view.bounds,
                             styleURL: MGLStyle.outdoorsStyleURL(withVersion: 9))
        
        // Tint the ℹ️ button and the user location annotation.
        mapView!.tintColor = .darkGray
        mapView!.delegate = self
        mapView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Set the map’s center coordinate and zoom level.
        if let latitude: Double = self._realmPark?.country?.latitude, let longitde: Double = self._realmPark?.country?.longitude {
            mapView!.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitde), zoomLevel: 9, animated: false)
        }
        if let zoomLevel: Double = self._realmPark?.country?.zoomlevel {
            mapView!.zoomLevel = zoomLevel
        }
        
        // Add our own gesture recognizer to handle taps on our custom map features.
        mapView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:))))
        
        /**
         * Button Filter
         */
        buttonFilter.addTarget(self, action: #selector(showFilter(sender:)), for: UIControlEvents.touchUpInside)
        
        /**
         * View "Live"
         */
        self.liveIcon.frame = CGRect(x: self.liveIcon.frame.minX, y: UIApplication.shared.statusBarFrame.height + 12, width: self.liveIcon.bounds.width, height: self.liveIcon.bounds.height)
        
        
        self.view.addSubview(mapView!)
        self.view.addSubview(buttonFilter)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView!.style else { return }
        
        // Add custom UIImage to the map style; these images can be referenced by an MGLSymbolStyleLayer’s iconImage property
        for (key, value) in Tags().getTags() {
            let imageFromAsset = AssetManager.getImage(value).withRenderingMode(.alwaysTemplate)
            style.setImage(imageFromAsset, forName: key.lowercased())
        }
        
        /**
         * Firebase observer
         */
        self.isMapLoaded = true
        createFirebaseObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.clear
        }
        self.navigationController?.navigationBar.isHidden = true
        
        /**
         * View
         */
        buttonFilter.frame = CGRect(x: self.view.bounds.width / 2 - 82 / 2, y: self.view.bounds.height - 20 - 32, width: 96, height: 32)
        self.isLoading = true
        
        
        /**
         * Firebase observer
         */
        createFirebaseObserver()
        
    }
    
    
    /**
     * Firebase
     */
    func createFirebaseObserver() {
        
        func addItemToMap(item2: ParkItem2, filterSectionIndex: Int?, isLive: Bool){
            if var latitude: Double = item2.latitude, var longitude: Double = item2.longitude {
                
                // Check that no item2 is at the same location
                for parkItem2 in self.items2 {
                    if parkItem2.latitude == latitude, parkItem2.longitude == longitude {
                        let random = Double(Int(arc4random_uniform(10)))
                        latitude    = latitude  - 0.00015 * random
                        longitude   = longitude - 0.00015 * random
                    }
                }
                
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let feature = MGLPointFeature()
                feature.coordinate = coordinate
                feature.title = item2.name
                // A feature’s attributes can used by runtime styling for things like text labels.
                feature.attributes = [
                    "key": item2.key,
                    "name": item2.name
                ]
                
                self.addItemsToMap(key: item2.key, tag: item2.tags[0].lowercased(), type: item2.type, features: feature, isLive: isLive)
                self.items2.insert(item2, at: 0)
                
                // If FilterSection is set then populate the selected tags (olny at the first load of the view)
                if let index: Int = filterSectionIndex, let filterSection: FilterSection = self._filterStruct.filterSections[safe: index] {
                    for tag in item2.tags {
                        // Check that the given tag for an item is in the default tags for that section
                        if let allTagsForSection: [String] = filterSection.typeTags, allTagsForSection.contains(tag) {
                            self._filterStruct.filterSections[index].addTag(tag: tag, count: 1)
                        }
                    }
                }
                
            }
        }
        
        
        func checkFilter(filterSectionIndex: Int, item2: ParkItem2, isLive: Bool = false){
            
            guard let timestamp: DateInRegion = item2.timestamp else {
                return
            }
            
            /* Live: No filter for live tags */
            if isLive {
                return addItemToMap(item2: item2, filterSectionIndex: nil, isLive: isLive)
            }
                
            /* Live Filter - Sort all items spotted within 6hours to have these items as live spots */
            if timestamp >= self.now - 6.hours {
                return
            }
            
            switch self._filterStruct.timerange.getAction() {
            case .lowerDate: // lowerDate is nil
                if !(timestamp >= self._filterStruct.timerange.upperDate!) {
                    self.filteredItems2.append(item2)
                    return
                }
            case .upperDate: // upperDate is nil
                if  !(timestamp <= self._filterStruct.timerange.lowerDate!) {
                    self.filteredItems2.append(item2)
                    return
                }
            case .none: // none of both dates are nil; that means both dates has a value
                if !(self._filterStruct.timerange.upperDate! <= timestamp && timestamp <= self._filterStruct.timerange.lowerDate!) {
                    self.filteredItems2.append(item2)
                    return
                }
            default: // .both: Both values are nil; no timerange is set
                break
            }
            
            
            // Is filter active? Yes: Filter item; No: Add item to map (for the first load of the map the filter is not active; only timerange should be checked!)
            if self._filterStruct.isActive == false {
                return addItemToMap(item2: item2, filterSectionIndex: filterSectionIndex, isLive: isLive)
            }
            
            // .community
            // All communiy items should be added without checking the tags
            if let filterSection: FilterSection = self._filterStruct.filterSections[safe: filterSectionIndex], filterSection.realmParkSection.getType() == .community {
                return addItemToMap(item2: item2, filterSectionIndex: nil, isLive: isLive)
            }
            
            // Tags: .animals, .attractions
            // - ItemType .community already filtered above; only .animals or .attractions
            for filterSection: FilterSection in self._filterStruct.filterSections {
                if filterSection.realmParkSection.getType() != .community {
                    let selectedTags = filterSection.getSelectedTags()
                    for tag in item2.tags {
                        if selectedTags.contains(tag) {
                            return addItemToMap(item2: item2, filterSectionIndex: nil, isLive: isLive)
                        }
                    }
                }
            }
            
            return self.filteredItems2.append(item2)
            
        }
        
        func createObserver(parkKey: String, filterSection: FilterSection, filterSectionIndex: Int) {
            
            self._firebaseReference.child("park").child(parkKey).child(filterSection.realmParkSection.path).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if self.isLoading {
                    self.isLoading = false
                }
                
                for item in snapshot.children {
                    let snapshotChildren = item as! FIRDataSnapshot
                    if let snapshotValue = snapshotChildren.value as? NSDictionary, let item2: ParkItem2 = ParkItem2(key: snapshotChildren.key, snapshotValue: snapshotValue, park: self._realmPark!, type: filterSection.realmParkSection.getType()), !self.items2.contains(item2) {
                        checkFilter(filterSectionIndex: filterSectionIndex, item2: item2)
                    }
                }
                
            }) { (error) in
                print(error)
            }
            
            /* isLive */
            if self._filterStruct.isLive {
                let sectionObserver = self._firebaseReference.child("park").child(parkKey).child(filterSection.realmParkSection.path).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
                    
                    // Create ParkItem2 object from firebase snapshot, check that object is not yet in array
                    if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject] {
                        if let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark!, type: filterSection.realmParkSection.getType()) {
                            if !self.items2.contains(item2) {
                                if !self.filteredItems2.contains(item2) {
                                    checkFilter(filterSectionIndex: filterSectionIndex, item2: item2, isLive: true)
                                }
                            }
                        }
                    }
                    
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                self.observers[filterSection.realmParkSection.key] = sectionObserver
            }
            
        }
        
        
        if self.isMapLoaded {
            for (index, filterSection) in self._filterStruct.filterSections.enumerated() {
                createObserver(parkKey: self._realmPark.key, filterSection: filterSection, filterSectionIndex: index)
            }
        }
        
    }
    
    func addItemsToMap(key: String, tag: String, type: ItemType, features: MGLPointFeature, isLive: Bool = false) {
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView!.style else { return }
        
        // Add the features to the map as a shape source.
        let source = MGLShapeSource(identifier: key, features: [features], options: nil)
        style.addSource(source)
        self._sources.append(source)
        
        // Use MGLCircleStyleLayer to represent the points with simple circles.
        // In this case, we can use style functions to gradually change properties between zoom level 2 and 7: the circle opacity from 50% to 100% and the circle radius from 2pt to 3pt.
        let circlesIdentifier = "\(key)-circles"
        self.layerIdentifiers.insert(circlesIdentifier)
        let circles             = MGLCircleStyleLayer(identifier: circlesIdentifier, source: source)
        var typeColor: UIColor = UIColor.white
        switch type {
        case .animals:
            typeColor = UIColor.yellow
        case .community:
            typeColor = UIColor.green
        case .attractions:
            typeColor = UIColor.brown
        default:
            typeColor = UIColor.white
        }
        
        circles.circleColor     = MGLStyleValue(rawValue: typeColor)
        circles.circleOpacity   = MGLStyleValue(stops: [
            2: MGLStyleValue(rawValue: 0.2),
            4: MGLStyleValue(rawValue: 0.4),
            8: MGLStyleValue(rawValue: 0.6),
            9: MGLStyleValue(rawValue: 0.4),
            ])
        circles.circleRadius    = MGLStyleValue(stops: [
            2: MGLStyleValue(rawValue: 10),
            4: MGLStyleValue(rawValue: 10),
            8: MGLStyleValue(rawValue: 10)
            ])
        
        // Use MGLSymbolStyleLayer for more complex styling of points including custom icons and text rendering.
        let iconIdentifiers = "\(key)-symbols"
        self.layerIdentifiers.insert(iconIdentifiers)
        let symbols             = MGLSymbolStyleLayer(identifier: iconIdentifiers, source: source)
        symbols.iconImageName   = MGLStyleValue(rawValue: NSString(string: tag))
        if isLive {
            symbols.iconColor       = MGLStyleValue(rawValue: UIColor.radicalRed)
            symbols.iconHaloColor   = MGLStyleValue(rawValue: UIColor.radicalRed.withAlphaComponent(1.0))
        } else {
            symbols.iconColor       = MGLStyleValue(rawValue: UIColor.flatBlack)
            symbols.iconHaloColor   = MGLStyleValue(rawValue: UIColor.flatBlack.withAlphaComponent(1.0))
        }
        
        
        symbols.iconScale       = MGLStyleValue(stops: [
            5.9: MGLStyleValue(rawValue: 0.2),
            6.9: MGLStyleValue(rawValue: 0.3),
            7.9: MGLStyleValue(rawValue: 0.4),
            8.9: MGLStyleValue(rawValue: 0.5),
            10.9: MGLStyleValue(rawValue: 0.6),
            ])
        
        symbols.iconOpacity     = MGLStyleValue(stops: [
            3.9: MGLStyleValue(rawValue: 0.4),
            7.9: MGLStyleValue(rawValue: 1),
            12: MGLStyleValue(rawValue: 1)
            ])
        
        symbols.iconHaloWidth   = MGLStyleValue(rawValue: 1)
        
        //        symbols.text            = MGLStyleValue(rawValue: "{name}") // {name} references the "name" key in an MGLPointFeature’s attributes dictionary.
        //        symbols.textColor       = MGLStyleValue(rawValue: UIColor.flatBlack)
        //        symbols.textFontSize    = MGLStyleValue(stops: [
        //                                        10: MGLStyleValue(rawValue: 10),
        //                                        16: MGLStyleValue(rawValue: 16)
        //                                    ])
        //        symbols.textTranslation = MGLStyleValue(rawValue: NSValue(cgVector: CGVector(dx: 10, dy: 0)))
        //        symbols.textOpacity     = symbols.iconOpacity
        //        // symbols.textHaloColor   = symbols.iconHaloColor
        //        symbols.textHaloWidth   = symbols.iconHaloWidth
        //        symbols.textJustification = MGLStyleValue(rawValue: NSValue(mglTextJustification: .left))
        //        symbols.textAnchor      = MGLStyleValue(rawValue: NSValue(mglTextAnchor: .left))
        
        //        style.addLayer(circles)
        style.addLayer(symbols)
        self._symbols.append(symbols)
        
    }
    
    // MARK: - Feature interaction
    func handleMapTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // Try matching the exact point first.
            let point = sender.location(in: sender.view!)
            for f in self.mapView!.visibleFeatures(at: point, styleLayerIdentifiers: self.layerIdentifiers)
                where f is MGLPointFeature {
                    showCallout(feature: f as! MGLPointFeature)
                    return
            }
            
            let touchCoordinate = self.mapView!.convert(point, toCoordinateFrom: sender.view!)
            let touchLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            
            // Otherwise, get all features within a rect the size of a touch (44x44).
            let touchRect = CGRect(origin: point, size: .zero).insetBy(dx: -22.0, dy: -22.0)
            let possibleFeatures = self.mapView!.visibleFeatures(in: touchRect, styleLayerIdentifiers: Set(layerIdentifiers)).filter { $0 is MGLPointFeature }
            
            // Select the closest feature to the touch center.
            let closestFeatures = possibleFeatures.sorted(by: {
                return CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude).distance(from: touchLocation) < CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude).distance(from: touchLocation)
            })
            if let f = closestFeatures.first {
                showCallout(feature: f as! MGLPointFeature)
                return
            }
            
            // If no features were found, deselect the selected annotation, if any.
            self.mapView!.deselectAnnotation(self.mapView!.selectedAnnotations.first, animated: true)
        }
    }
    
    func showCallout(feature: MGLPointFeature) {
        let point = MGLPointFeature()
        point.title = feature.attributes["name"] as? String
        point.coordinate = feature.coordinate
        
        
        // Selecting an feature that doesn’t already exist on the map will add a new annotation view.
        // We’ll need to use the map’s delegate methods to add an empty annotation view and remove it when we’re done selecting it.
        self.mapView!.selectAnnotation(point, animated: true)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.observers.removeAll()
        self._firebaseReference.removeAllObservers()
        
        // MapView: Remove annotations from mapview
        if self._annotations.count > 0 {
            for annotation in self._annotations {
                self.mapView?.deselectAnnotation(annotation, animated: true)
                self.mapView?.removeAnnotation(annotation)
            }
            self._annotations = [MGLAnnotation]()
        }
        
        // MapView: Remove all data from map
        self.items2         = [ParkItem2]()
        self.filteredItems2 = [ParkItem2]()
        self.isLoading      = true
        
        if let style = self.mapView!.style {
            for symbol in self._symbols {
                style.removeLayer(symbol)
            }
            self._symbols = [MGLSymbolStyleLayer]()
            
            for source in self._sources {
                style.removeSource(source)
            }
            self._sources = [MGLShapeSource]()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /**
     * Show Filter
     */
    func showFilter(sender: UIButton){
        let filterViewController = FilterViewController()
        filterViewController._filterStruct = self._filterStruct
        filterViewController.delegate = self
        let formNavigationController = UINavigationController(rootViewController: filterViewController)
        self.navigationController?.present(formNavigationController, animated: true, completion: nil)
    }
    
    
}

extension MapViewController: FilterProtocol {
    
    func dismiss() {
        
        /**
         * Firebase observer
         */
        //self.createFirebaseObserver()
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveFilter(filterStruct: FilterStruct) {
        self._filterStruct = filterStruct
        self.dismiss()
    }
    
    func saveFiler(tags: [String]?, sections: [RealmParkSection : Bool]?, lowerDate: DateInRegion?, upperDate: DateInRegion?) {
        
        
        
//        // 1. Tags
//        self._selectedTags = tags != nil ? tags! : [String]()
//        self._weightedTags = [ItemType : [String: Int]]()
//        self.saveWeightedTags(tags: self._selectedTags, countTag: 0)
//        
//        // 2. Sections
//        self._realmParkSections = [RealmParkSection]()
//        if let sectionsEnabled: [RealmParkSection: Bool] = sections {
//            for (section, enabled) in sectionsEnabled {
//                if section.getType() == .live {
//                    self.isLive = enabled
//                } else if section.getType() != .live && enabled {
//                    self._realmParkSections.append(section)
//                }
//            }
//        }
//        
//        // 3. Date
//        self._lowerDate = lowerDate
//        self._upperDate = upperDate
//        
//        
//        self.filterLoaded = true
        
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension MapViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return .white
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped
        return true
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // Create an empty view annotation. Set a frame to offset the callout.
        return MGLAnnotationView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        self._annotations.append(annotation)
        print("didSelect: \(annotation)")
        
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        if self._annotations.count > 0 {
            self._annotations.remove(at: 0)
        }
        mapView.removeAnnotations([annotation])
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout
        if self._annotations.count > 0 {
            self._annotations.remove(at: 0)
        }
        mapView.deselectAnnotation(annotation, animated: true)
    }
}

