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

class MapViewController: UIViewController {
    
    let _firebaseReference = FIRDatabase.database().reference()
    var observerChildAdded      : FIRDatabaseHandle?
    var observers = [FIRDatabaseHandle]()
    
    var mapView: MGLMapView?
    var _realmPark: RealmPark?
    
    var items2: [ParkItem2] = [ParkItem2]()
    var layerIdentifiers: Set<String> = Set<String>()
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        self.mapView = nil
        self._realmPark = nil
        self.observerChildAdded = nil
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
        
        view.addSubview(mapView!)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView!.style else { return }
        
        // You can add custom UIImages to the map style.
        // These can be referenced by an MGLSymbolStyleLayer’s iconImage property.
        
        for (key, value) in icons {
            print(key.lowercased())
            let imageFromAsset = AssetManager.getImage(value)
            style.setImage(imageFromAsset, forName: key.lowercased())
        }
        
        
        if let parkKey: String = self._realmPark?.key, let sections = self._realmPark?.sections {
            for section: RealmParkSection in sections {
                print(section.path)
                let sectionObserver = self._firebaseReference.child("park").child(parkKey).child(section.path).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
                    
                    // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
                    if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark!, type: section.getType()), self.items2.first(where:{$0.key == item2.key}) == nil {
                        
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
                        }
                        
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                self.observers.append(sectionObserver)
                
            }
        }
        
        
//        if self.observerChildAdded == nil {
//            // 1: .childAdded observer
//            self.observerChildAdded = self._firebaseReference.child("park").child((self._realmPark?.key)!).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) -> Void in
//                
//                // Create ParkItem2 object from firebase snapshot, check tah object is not yet in array
//                if let snapshotValue: [String: AnyObject] = snapshot.value as? [String: AnyObject], let item2: ParkItem2 = ParkItem2(key: snapshot.key, snapshotValue: snapshotValue, park: self._realmPark!, type: ItemType.animals), self.items2.first(where:{$0.key == item2.key}) == nil {
//                    
//                    if let latitude: Double = item2.latitude, let longitude: Double = item2.longitude {
//                        self.items2.insert(item2, at: 0)
//                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                        let feature = MGLPointFeature()
//                        feature.coordinate = coordinate
//                        feature.title = item2.name
//                        // A feature’s attributes can used by runtime styling for things like text labels.
//                        feature.attributes = [
//                            "name": item2.name
//                        ]
//                        self.addItemsToMap(key: item2.key, features: feature)
//                    }
//                    
//                }
//                
//            }) { (error) in
//                print(error.localizedDescription)
//            }
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.clear
        }
        self.navigationController?.navigationBar.isHidden = true
        
        
    }
    
    func addItemsToMap(key: String, tag: String, type: ItemType, features: MGLPointFeature) {
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView!.style else { return }
        
        // Add the features to the map as a shape source.
        let source = MGLShapeSource(identifier: key, features: [features], options: nil)
        style.addSource(source)
        
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
        self.observerChildAdded = nil
        self.observers = [FIRDatabaseHandle]()
        self._firebaseReference.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        print("didSelect: \(annotation)")
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        mapView.removeAnnotations([annotation])
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout
        mapView.deselectAnnotation(annotation, animated: true)
    }
}

class CustomCalloutView: UIView, MGLCalloutView {
    var representedObject: MGLAnnotation
    
    // Lazy initialization of optional vars for protocols causes segmentation fault: 11s in Swift 3.0. https://bugs.swift.org/browse/SR-1825
    
    var leftAccessoryView = UIView() /* unused */
    var rightAccessoryView = UIView() /* unused */
    
    weak var delegate: MGLCalloutViewDelegate?
    
    let tipHeight: CGFloat = 10.0
    let tipWidth: CGFloat = 20.0
    
    let mainBody: UIButton
    
    required init(representedObject: MGLAnnotation) {
        self.representedObject = representedObject
        self.mainBody = UIButton(type: .system)
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        mainBody.backgroundColor = .darkGray
        mainBody.tintColor = .white
        mainBody.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        mainBody.layer.cornerRadius = 4.0
        
        addSubview(mainBody)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MGLCalloutView API
    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedView: UIView, animated: Bool) {
        if !representedObject.responds(to: Selector("title")) {
            return
        }
        
        view.addSubview(self)
        
        // Prepare title label
        mainBody.setTitle(representedObject.title!, for: .normal)
        mainBody.sizeToFit()
        
        if isCalloutTappable() {
            // Handle taps and eventually try to send them to the delegate (usually the map view)
            mainBody.addTarget(self, action: #selector(CustomCalloutView.calloutTapped), for: .touchUpInside)
        } else {
            // Disable tapping and highlighting
            mainBody.isUserInteractionEnabled = false
        }
        
        // Prepare our frame, adding extra space at the bottom for the tip
        let frameWidth = mainBody.bounds.size.width
        let frameHeight = mainBody.bounds.size.height + tipHeight
        let frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0)
        let frameOriginY = rect.origin.y - frameHeight
        frame = CGRect(x: frameOriginX, y: frameOriginY, width: frameWidth, height: frameHeight)
        
        if animated {
            alpha = 0
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = 1
            }
        }
    }
    
    func dismissCallout(animated: Bool) {
        if (superview != nil) {
            if animated {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.alpha = 0
                    }, completion: { [weak self] _ in
                        self?.removeFromSuperview()
                })
            } else {
                removeFromSuperview()
            }
        }
    }
    
    // MARK: - Callout interaction handlers
    
    func isCalloutTappable() -> Bool {
        if let delegate = delegate {
            if delegate.responds(to: #selector(MGLCalloutViewDelegate.calloutViewShouldHighlight)) {
                return delegate.calloutViewShouldHighlight!(self)
            }
        }
        return false
    }
    
    func calloutTapped() {
        if isCalloutTappable() && delegate!.responds(to: #selector(MGLCalloutViewDelegate.calloutViewTapped)) {
            delegate!.calloutViewTapped!(self)
        }
    }
    
    // MARK: - Custom view styling
    
    override func draw(_ rect: CGRect) {
        // Draw the pointed tip at the bottom
        let fillColor : UIColor = .darkGray
        
        let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
        let tipBottom = CGPoint(x: rect.origin.x + (rect.size.width / 2.0), y: rect.origin.y + rect.size.height)
        let heightWithoutTip = rect.size.height - tipHeight
        
        let currentContext = UIGraphicsGetCurrentContext()!
        
        let tipPath = CGMutablePath()
        tipPath.move(to: CGPoint(x: tipLeft, y: heightWithoutTip))
        tipPath.addLine(to: CGPoint(x: tipBottom.x, y: tipBottom.y))
        tipPath.addLine(to: CGPoint(x: tipLeft + tipWidth, y: heightWithoutTip))
        tipPath.closeSubpath()
        
        fillColor.setFill()
        currentContext.addPath(tipPath)
        currentContext.fillPath()
    }
}

