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
    
    
    var _realmPark: RealmPark?
    var _realmParkSections = [RealmParkSection]()
    
    /**
     * MapView
     */
    var mapView: MGLMapView?
    var layerIdentifiers: Set<String> = Set<String>()
    var _sources = [MGLShapeSource]()
    var _symbols = [MGLSymbolStyleLayer]()
    var _annotations = [MGLAnnotation]()
    let buttonFilter        = UIButton(type: .roundedRect)
    let buttonFilterLabel   = UILabel()
    
    let liveIcon = UIView()
    
    /**
     * Tags
     */
    var isLoading       = false {
        willSet(newValue) {
            if newValue {
                buttonFilter.loadingIndicator(true)
                self.buttonShowText(false)
            } else {
                buttonFilter.loadingIndicator(false)
                self.buttonShowText(true)
            }
        }
    }
    var isMapLoaded     = false
    var filterLoaded    = false
    var isLive          = false {
        didSet {
            if isLive {
                self.view.addSubview(self.liveIcon)
            } else {
                self.liveIcon.removeFromSuperview()
            }
        }
    }
    let _tags           = Tags()
    var _weightedTags    = [ItemType : [String: Int]]()
    var _selectedTags    = [String]()
    var _lowerDate      : DateInRegion?
    var _upperDate      : DateInRegion?
    
    /**
     * Data
     */
    var items2: [ParkItem2] = [ParkItem2]()
    
    
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
        
        /**
         * Data
         */
        if let realmPark: RealmPark = self._realmPark {
            for section in realmPark.sections {
                self._realmParkSections.append(section)
            }
        }
        self._lowerDate = DateInRegion() - 4.days // Set default dates; ToDo: If user is logged in or user has subscription enable more days
        self._upperDate = DateInRegion() - 1.months
        
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
        buttonFilter.backgroundColor        = UIColor.white
        buttonFilter.cornerRadius           = 16
        // Shadow and Radius
        buttonFilter.layer.shadowColor      = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonFilter.layer.shadowOffset     = CGSize(width: 0.0, height: 2.0)
        buttonFilter.layer.shadowOpacity    = 0.6
        buttonFilter.layer.shadowRadius     = 1.0
        buttonFilter.layer.masksToBounds    = false
        buttonFilter.addTarget(self, action: #selector(showFilter(sender:)), for: UIControlEvents.touchUpInside)
        
        /**
         * View "Live"
         */
        let liveIconImage = UIImageView()
        let scale: CGFloat = 0.5
        liveIconImage.frame = CGRect(x: 0, y: 0, width: 18 * scale, height: 32 *  scale)
        liveIconImage.image = StyleKitName.imageOfBolt
        liveIconImage.tintColor = UIColor.radicalRed
        liveIconImage.contentMode = .scaleAspectFit
        
        let liveIconLabel = UILabel()
        liveIconLabel.attributedText = NSAttributedString(
            string: "Live",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor.radicalRed,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        let liveIconLabelSize = NSAttributedString(
            string: "Live",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
                NSKernAttributeName: 0.6,
                ]).size()
        
        liveIcon.frame = CGRect(x: 8, y: UIApplication.shared.statusBarFrame.height + 8, width: liveIconImage.bounds.width + 8 + liveIconLabelSize.width, height: liveIconImage.bounds.height)
        liveIconLabel.frame = CGRect(x: liveIconImage.bounds.width + 8, y: liveIcon.bounds.height / 2 - liveIconLabelSize.height / 2, width: liveIconLabelSize.width, height: liveIconLabelSize.height)
        
        
        liveIcon.addSubview(liveIconImage)
        liveIcon.addSubview(liveIconLabel)
        
        self.view.addSubview(mapView!)
        self.view.addSubview(buttonFilter)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    /**
     * Weighted Tags
     * tags: all tags which should added and weighted
     * counTag: which value should be added to weight (the filter tells to save some tags which are not in the DB)
     */
    func saveWeightedTags(tags: [String], countTag: Int = 1){
        
        func addTagsToWeightedTags(itemType: ItemType, tag: String) {
            if let weightedTag: [String: Int] = self._weightedTags[itemType] {
                if let _: Int = weightedTag[tag] {
                    self._weightedTags[itemType]![tag] = self._weightedTags[itemType]![tag]! + countTag
                } else {
                    self._weightedTags[itemType]![tag] = countTag
                }
            } else {
                self._weightedTags[itemType] = [String: Int]()
                self._weightedTags[itemType]![tag] = countTag
            }
        }
        
        // 1. Loop through all tags and look if tag is in App Tags
        for tag in tags {
            if let tagsForItemType: [String] = self._tags.getKeys(type: .animals), tagsForItemType.contains(tag) {
                addTagsToWeightedTags(itemType: .animals, tag: tag)
                //                addTagsToSelectedTags(tag: tag)
            } else if let tagsForItemType: [String] = self._tags.getKeys(type: .attractions), tagsForItemType.contains(tag) {
                addTagsToWeightedTags(itemType: .attractions, tag: tag)
                //                addTagsToSelectedTags(tag: tag)
            }
        }
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView!.style else { return }
        
        // You can add custom UIImages to the map style.
        // These can be referenced by an MGLSymbolStyleLayer’s iconImage property.
        
        for (key, value) in self._tags.getTags() {
            let imageFromAsset = AssetManager.getImage(value)
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
        buttonFilter.frame = CGRect(x: self.view.bounds.width / 2 - 82 / 2, y: self.view.bounds.height - 20 - 32, width: 82, height: 32)
        self.isLoading = true
        
        /**
         * Firebase observer
         */
        createFirebaseObserver()
        
    }
    
    func buttonShowText(_ show: Bool){
        let tag = 91234
        if let label = buttonFilter.viewWithTag(tag) as? UILabel {
            label.removeFromSuperview()
        }
        
        if show {
            buttonFilter.loadingIndicator(false)
            
            
            // Label
            buttonFilter.frame = CGRect(x: self.view.bounds.width / 2 - 96 / 2, y: self.view.bounds.height - 20 - 32, width: 96, height: 32)
            buttonFilter.setAttributedTitle(NSAttributedString(
                string: "Filter",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
                    NSForegroundColorAttributeName: UIColor.flatBlack,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ]), for: .normal)
            
            // Count
            var countFilter = 0
            if self._lowerDate != nil && self._upperDate != nil {
                countFilter = countFilter + 1
            }
            if self._selectedTags != nil {
                countFilter = countFilter + 1
            }
            for section in self._realmParkSections {
                switch section.getType() {
                case .animals, .attractions, .live:
                    break
                default:
                    countFilter = countFilter + 1
                }
            }
            
            buttonFilterLabel.backgroundColor   = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00) // Persian green
            buttonFilterLabel.tag               = tag
            let style       = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            buttonFilterLabel.attributedText    = NSAttributedString(
                string: "\(countFilter)",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 10, weight: UIFontWeightBold),
                    NSForegroundColorAttributeName: UIColor.white,
                    NSBackgroundColorAttributeName: UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00),
                    NSKernAttributeName: 0.6,
                    NSParagraphStyleAttributeName: style
                ])
            let buttonFilterLabelSize           = NSAttributedString(
                string: "\(countFilter)",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 10, weight: UIFontWeightBold),
                    NSForegroundColorAttributeName: UIColor.white,
                    NSBackgroundColorAttributeName: UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00),
                    NSKernAttributeName: 0.6,
                    ]).size()
            let buttonFilterLabelLongerSize     = buttonFilterLabelSize.width > buttonFilterLabelSize.height ? buttonFilterLabelSize.width : buttonFilterLabelSize.height // To have a rounded cirlce both width and heigt must be same
            let buttonFilterLabelSizePadding    = 4 + buttonFilterLabelLongerSize
            buttonFilterLabel.frame             = CGRect(x: buttonFilter.bounds.width - buttonFilterLabelSizePadding - 8, y: buttonFilter.bounds.height / 2 - buttonFilterLabelSizePadding / 2, width: buttonFilterLabelSizePadding, height: buttonFilterLabelSizePadding)
            buttonFilterLabel.layer.cornerRadius = buttonFilterLabelSizePadding / 2
            buttonFilterLabel.cornerRadius = buttonFilterLabelSizePadding / 2
            buttonFilter.addSubview(buttonFilterLabel)
        } else {
            buttonFilter.frame = CGRect(x: self.view.bounds.width / 2 - 82 / 2, y: self.view.bounds.height - 20 - 32, width: 82, height: 32)
            buttonFilter.setAttributedTitle(NSAttributedString(
                string: "",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
                    NSForegroundColorAttributeName: UIColor.clear,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ]), for: .normal)
        }
        
    }
    
    /**
     * Firebase
     */
    func createFirebaseObserver() {
        
        func addItemToMap(item2: ParkItem2, tags: [String]){
            if let latitude: Double = item2.latitude, let longitude: Double = item2.longitude {
                self.items2.insert(item2, at: 0)
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let feature = MGLPointFeature()
                feature.coordinate = coordinate
                feature.title = item2.name
                // A feature’s attributes can used by runtime styling for things like text labels.
                feature.attributes = [
                    "name": item2.name
                ]
                self.addItemsToMap(key: item2.key, tag: item2.tags[0].lowercased(), type: item2.type, features: feature)
                
                self.saveWeightedTags(tags: tags)
            }
        }
        
        func checkTagsForItem(item2: ParkItem2){
            for tag in item2.tags {
                if self._selectedTags.contains(tag) {
                    addItemToMap(item2: item2, tags: [tag])
                    break
                }
            }
        }
        
        func checkFilter(item2: ParkItem2, type: ItemType, checkTags: Bool){
            // 1. Check timerange: Item should be in timerage
            // 2.   Is Filer set? Then check that item has at least one tag of selected tags; is Filter not set then add item to map (first load of mapview)
            //      (.community items are not checked because these items shoudl not have valid tags)
            if let lowerDate: DateInRegion = self._lowerDate, let upperDate: DateInRegion = self._upperDate, item2.timestamp != nil, upperDate <= item2.timestamp!, item2.timestamp! <= lowerDate, checkTags && type != .community {
                checkTagsForItem(item2: item2)
            } else if let lowerDate: DateInRegion = self._lowerDate, self._upperDate == nil, item2.timestamp != nil, item2.timestamp! <= lowerDate, checkTags && type != .community {
                checkTagsForItem(item2: item2)
            } else if self._lowerDate == nil, let upperDate: DateInRegion = self._upperDate, item2.timestamp != nil, upperDate <= item2.timestamp!, checkTags && type != .community {
                checkTagsForItem(item2: item2)
            } else if self._lowerDate == nil, self._upperDate == nil, item2.timestamp != nil, checkTags, type != .community {
                // Timerange is not set (in filter the lower date value = 0 && upper date value = 1
                checkTagsForItem(item2: item2)
            } else if let lowerDate: DateInRegion = self._lowerDate, let upperDate: DateInRegion = self._upperDate, item2.timestamp != nil, upperDate <= item2.timestamp!, item2.timestamp! <= lowerDate, !checkTags && type != .community {
                addItemToMap(item2: item2, tags: item2.tags)
            } else if type == .community {
                addItemToMap(item2: item2, tags: item2.tags)
            }
        }
        
        func createObserver(parkKey: String, section: RealmParkSection, checkTags: Bool) {
            let sectionObserver = self._firebaseReference.child("park").child(parkKey).child(section.path).queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) -> Void in
                
                if self.isLoading {
                    self.isLoading = false
                }
                
                for item in snapshot.children {
                    let go = item as! FIRDataSnapshot
                    if let snapshotValue = go.value as? NSDictionary, let item2: ParkItem2 = ParkItem2(key: go.key, snapshotValue: snapshotValue, park: self._realmPark!, type: section.getType()), !self.items2.contains(item2) {
                        checkFilter(item2: item2, type: section.getType(), checkTags: checkTags)
                    }
                }
                
                // Create ParkItem2 object from firebase snapshot, check that object is not yet in array
                if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark!, type: section.getType()), !self.items2.contains(item2) {
                    checkFilter(item2: item2, type: section.getType(), checkTags: checkTags)
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            self.observers[section.key] = sectionObserver
        }
        
        
        
        if let parkKey: String = self._realmPark?.key {
            if self.isMapLoaded {
                for section in self._realmParkSections {
                    createObserver(parkKey: parkKey, section: section, checkTags: self.filterLoaded)
                }
            }
        }
        
    }
    
    func addItemsToMap(key: String, tag: String, type: ItemType, features: MGLPointFeature) {
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
        symbols.iconColor       = MGLStyleValue(rawValue: UIColor.flatBlack)
        
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
        symbols.iconHaloColor   = MGLStyleValue(rawValue: UIColor.white.withAlphaComponent(0.5))
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
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.observers.removeAll()
        self._firebaseReference.removeAllObservers()
        
        // MapView: Remove all data from map
        self.items2 = [ParkItem2]()
        self.isLoading = true
        
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
        
        // Remove annotations from mapview
        if self._annotations.count > 0 {
            for annotation in self._annotations {
                self.mapView?.deselectAnnotation(annotation, animated: true)
                self.mapView?.removeAnnotation(annotation)
            }
            self._annotations = [MGLAnnotation]()
        }
        
        
        // Preperata data:section for Filter
        var sections = [RealmParkSection]()
        var sectionsEnabled = [String: Bool]()
        if let realmPark: RealmPark = self._realmPark {
            for section in realmPark.sections {
                switch section.getType() {
                case .community: // ToDo: Hack to show community at first position; mapviewcontroller should pass the correct sort of array
                    sections.insert(section, at: 0)
                    if self._realmParkSections.contains(section){
                        sectionsEnabled[section.key] = true
                    }
                default:
                    sections.append(section)
                }
            }
        }
        
        // Remove not selected tags from weightedTags
        if self.filterLoaded {
            for (key, value) in self._weightedTags {
                for (tag, _) in value {
                    if !self._selectedTags.contains(tag) {
                        self._weightedTags[key]?.removeValue(forKey: tag)
                    }
                }
            }
        }
        
        let liveSection     = RealmParkSection()
        liveSection.key     = "live"
        liveSection.name    = "Live"
        liveSection.type    = ItemType.live.rawValue
        sections.insert(liveSection, at: 0)
        sectionsEnabled[liveSection.key] = self.isLive
        
        let filterViewController = FilterViewController()
        // filterViewController._realmPark = self._realmPark!
        filterViewController._realmParkSections = sections
        filterViewController._enabledSections = sectionsEnabled
        filterViewController._weightedTags = self._weightedTags
        filterViewController._dataLowerDate = self._lowerDate
        filterViewController._dataUpperDate = self._upperDate
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
        self.createFirebaseObserver()
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveFiler(tags: [String]?, sections: [RealmParkSection : Bool]?, lowerDate: DateInRegion?, upperDate: DateInRegion?) {
        
        
        
        // 1. Tags
        self._selectedTags = tags != nil ? tags! : [String]()
        self._weightedTags = [ItemType : [String: Int]]()
        self.saveWeightedTags(tags: self._selectedTags, countTag: 0)
        
        // 2. Sections
        self._realmParkSections = [RealmParkSection]()
        if let sectionsEnabled: [RealmParkSection: Bool] = sections {
            for (section, enabled) in sectionsEnabled {
                if section.getType() == .live {
                    self.isLive = enabled
                } else if section.getType() != .live && enabled {
                    self._realmParkSections.append(section)
                }
            }
        }
        
        // 3. Date
        self._lowerDate = lowerDate
        self._upperDate = upperDate
        
        
        self.filterLoaded = true
        
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

