//
//  DetailASViewController.swift
//  Spot
//
//  Created by Mats Becker on 12/1/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher
import Mapbox
import MapboxStatic

class DetailASViewController: ASViewController<ASDisplayNode> {
    
    private var shadowImageView: UIImageView?
    
    /**
     * AsyncDisplayKit
     */
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    let _parkItem       : ParkItem2
    let _realmPark      : RealmPark
    let _park           : Park
    var _tableHeader    : DetailTableHeaderUIView?
    let _mapNode        : MapNode!
    
    init(realmPark: RealmPark, parkItem: ParkItem2) {
        self._realmPark     = realmPark
        self._park          = Park(realmPark: realmPark)
        self._parkItem      = parkItem
        self._mapNode       = MapNode(parkItem: self._parkItem)
        
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        // Navigationbar
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = false
        
        // Navigationcontroller back image, tint color, text attributes
        let backImage = UIImage(named: "back64")?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
            NSForegroundColorAttributeName: UIColor.black,
            NSBackgroundColorAttributeName: UIColor.clear,
            NSKernAttributeName: 0.0,
        ]
        
    }
    
    func changeStatusbarColor(color: UIColor){
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: ASDisplayProperties.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
    
    func share() {
        
        if let image: UIImage = self._tableHeader?.getFirstImage() {
            self._tableHeader?._slideShow.pauseTimerIfNeeded()
            
            let text: NSString = NSString(string: "Spotted \(self._parkItem.name) at \(self._realmPark.name)")
            let url = getSafariDigitalSpotURL(park: self._realmPark.key, type: self._parkItem.type.rawValue, key: self._parkItem.key)
            let size = image.size
            var map: UIImage = UIImage()
            
            if let mapImage = self._mapNode.view.image {
                map = (mapImage.circle?.resizeImage(newWidth: size.width / 3))!
            }
            
            // Start drawing image
            UIGraphicsBeginImageContext(size)
            
            let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            image.draw(in: areaSize)
            
            map.draw(in: CGRect(x: size.width - map.size.width - 12, y: size.height - map.size.height - 12, width: map.size.width, height: map.size.height), blendMode: .normal, alpha: 1.0)
            
            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            // End drawing image
            
            let objectsToShare = [newImage, text, url] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.openInIBooks, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.print, UIActivityType.saveToCameraRoll]
            self.changeStatusbarColor(color: UIColor.clear)
            self.present(activityVC, animated: true, completion: nil)
            
            activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
                self.changeStatusbarColor(color: UIColor.white)
                self._tableHeader?._slideShow.unpauseTimerIfNeeded()
                
                if let error = activityError {
                    print(":: ERROR UIActivityViewController ::")
                    print(error)
                }
            }
            
        }
        
    }
    
    func saveImage() {
        if let image: UIImage = self._tableHeader?.getImage() {
            self._tableHeader?._slideShow.pauseTimerIfNeeded()
            
            let objectsToShare = [image]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.openInIBooks, UIActivityType.addToReadingList, UIActivityType.postToFacebook, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.postToTencentWeibo]
            self.changeStatusbarColor(color: UIColor.clear)
            self.present(activityVC, animated: true, completion: nil)
            
            activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
                self.changeStatusbarColor(color: UIColor.white)
                self._tableHeader?._slideShow.unpauseTimerIfNeeded()
                
                if let error = activityError {
                    print(":: ERROR UIActivityViewController ::")
                    print(error)
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigationcontroller
        self.navigationController?.visibleViewController?.title = self._parkItem.name
        
        
//        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
//        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: nil)
//        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: nil)
//        let tag = UIBarButtonItem(image: #imageLiteral(resourceName: "pricetag66"), style: .plain, target: self, action: nil)
        let social = UIBarButtonItem(image: #imageLiteral(resourceName: "ShareFilledBlack66"), style: .plain, target: self, action: #selector(self.share))
        
        self.navigationItem.rightBarButtonItems = [social, camera]
        
        var urls = [URL]()
        if let imageURL: URL = self._parkItem.image?.resized["375x300"]?.publicURL {
            urls.append(imageURL)
        } else if let imageURL: URL = self._parkItem.image?.original?.publicURL {
            urls.append(imageURL)
        }
        
        if let images: [Images] = self._parkItem.images, images.count > 0 {
            for image in images {
                if let imageURL: URL = image.resized["375x300"]?.publicURL {
                    urls.append(imageURL)
                } else if let imageURL: URL = image.original?.publicURL {
                    urls.append(imageURL)
                }
            }
        }
        
        // View
        self.view.backgroundColor = UIColor.green
        
        // TableView
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.view.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
        self.tableNode.view.tableFooterView = tableFooterView
        self.tableNode.view.allowsSelection = true
        if(urls.count > 0){
            self._tableHeader = DetailTableHeaderUIView.init(title: self._parkItem.name, urls: urls, viewController: self)
            self.tableNode.view.tableHeaderView = self._tableHeader
        } else {
            self.tableNode.view.tableHeaderView = tableFooterView
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shadowImageView?.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
    
    lazy var tableFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.00000000000000000000000001))
        return view
    }()
    
    func sectionHeaderView(text: String) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 26, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor.black,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        title.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        
        let constraintLeftTitle = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let constraintCenterYTitle = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        view.addConstraint(constraintLeftTitle)
        view.addConstraint(constraintCenterYTitle)
        
        return view
    }
}

extension DetailASViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView(text: self._parkItem.name)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // From header text to immage horizinta slider
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.white
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0000000000000000001
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let row = indexPath.row
        var node: ASCellNode
        
        switch row {
        case 0:
            node = CountryASCellNode(park: self._park)
        case 1:
            node = ASCellNode{ () -> UIView in
                    return TagsNode(parkItem: self._parkItem)
            }
        case 2:
            node = ASCellNode{ () -> UIView in
                return SpottedByNode(parkItem: self._parkItem)
            }
        case 3:
            node = ASCellNode{ () -> UIView in
                return self._mapNode
            }
        default:
            let textCellNode = ASTextCellNode()
            textCellNode.text = "Not found"
            return textCellNode
        }
    
        node.selectionStyle = .default
        node.backgroundColor = UIColor.white
        
        if row == 3 && self._parkItem.latitude != nil && self._parkItem.longitude != nil {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86 + UIScreen.main.bounds.width * 2 / 3)
        } else {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86)
        }
        
        return node
    }
}

extension DetailASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 20), max: CGSize(width: 0, height: 86 + UIScreen.main.bounds.width * 2 / 3))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

class TagsNode: UIView {
    init(parkItem: ParkItem2){
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        if parkItem.tags.count == 0 {
            let noTags = UILabel()
            noTags.attributedText = NSAttributedString(
                string: "Not yet tagged ...",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
            noTags.translatesAutoresizingMaskIntoConstraints = false
            addSubview(noTags)
            noTags.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            noTags.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        } else {
            
            let height: CGFloat = 48
            let view = UIView(frame: CGRect(x: 20, y: 86 / 2 - height / 2, width: UIScreen.main.bounds.width - 20, height: height))
            
            let label = UILabel(frame: CGRect(x: 0, y: view.bounds.height / 2 - 19.09375 / 2, width: 100, height: 19.09375))
            label.attributedText = NSAttributedString(
                string: "Tags",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
            view.addSubview(label)
            
            var count = 4 // == 5 icon images
            if parkItem.tags.count < count {
                count = parkItem.tags.count - 1
            } else {
                count = count - 1
            }
            
            
            for i in 0...count {
                if let iconName: String = icons[parkItem.tags[i]] {
                    // Load icon from asset
                    let tagImageView = UIImageView(frame: CGRect(x: CGFloat(100) + (CGFloat(i) * CGFloat(32)), y: 0, width: CGFloat(48), height: CGFloat(48)))
                    tagImageView.backgroundColor = UIColor.white
                    tagImageView.cornerRadius = 24
                    tagImageView.clipsToBounds = true
                    tagImageView.borderColor = UIColor.black
                    tagImageView.borderWidth = 1.0
                    tagImageView.contentMode = .center
                    tagImageView.image = AssetManager.getImage(iconName).resizedImage(newSize: CGSize(width: 32, height: 32))
                    view.addSubview(tagImageView)
                    view.sendSubview(toBack: tagImageView)
                } else {
                    // ToDo: Load icons from URL?
                    print("ICON NOT FOUND :: \(tag)")
                }
            }
            
            addSubview(view)
        }
        
        
        let borderBottomView = UIView(frame: CGRect(x: 20, y: 85, width: UIScreen.main.bounds.width - 40, height: 1))
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        addSubview(borderBottomView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpottedByNode: UIView {
    init(parkItem: ParkItem2){
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        if parkItem.spottedBy.count == 0 {
            let info = UILabel()
            info.attributedText = NSAttributedString(
                string: "Not yet spotted ...",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
            info.translatesAutoresizingMaskIntoConstraints = false
            addSubview(info)
            info.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            info.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        } else {
            
            let height: CGFloat = 48
            let view = UIView(frame: CGRect(x: 20, y: 86 / 2 - height / 2, width: UIScreen.main.bounds.width - 20, height: height))
            
            let label = UILabel(frame: CGRect(x: 0, y: view.bounds.height / 2 - 19.09375 * 2 / 2, width: 85.4687499999999, height: 19.09375 * 2))
            label.numberOfLines = 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            label.attributedText = NSAttributedString(
                string: "Spotted by\n\(parkItem.spottedBy.count) user",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    NSParagraphStyleAttributeName: paragraphStyle
                    ])
            view.addSubview(label)
            
            var count = 4 // == 5 user profile images
            if parkItem.spottedBy.count < count {
                count = parkItem.spottedBy.count - 1
            } else {
                count = count - 1
            }
            
            for i in 0...count {
                let tagImageView = UIImageView(frame: CGRect(x: CGFloat(100) + (CGFloat(i) * CGFloat(32)), y: 0, width: CGFloat(48), height: CGFloat(48)))

                let processor = RoundCornerImageProcessor(cornerRadius: 24)
                let imageURL: URL = URL(string: parkItem.spottedBy[i]["profile"]!)!
                
                tagImageView.kf.setImage(with: imageURL, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    if image != nil {
                        tagImageView.cornerRadius = 24
                        tagImageView.clipsToBounds = true
                        tagImageView.borderColor = UIColor.black
                        tagImageView.borderWidth = 1.0
                    }
                })
                
                view.addSubview(tagImageView)
                view.sendSubview(toBack: tagImageView)
            }
            
            addSubview(view)
        }
        
        let borderBottomView = UIView(frame: CGRect(x: 20, y: 85, width: UIScreen.main.bounds.width - 40, height: 1))
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        addSubview(borderBottomView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MapNode: UIView {
    
    let view: UIImageView
    
    init(parkItem: ParkItem2){
        view = UIImageView(frame: CGRect(x: 0, y: 86, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 2 / 3))
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        setupView(latitude: parkItem.latitude, longitude: parkItem.longitude)
    }
    
    init(latitude: Double?, longitude: Double?){
        view = UIImageView(frame: CGRect(x: 0, y: 86, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 2 / 3))
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        setupView(latitude: latitude, longitude: longitude)
    }
    
    func setupView(latitude: Double?, longitude: Double?) {
        if latitude != nil, longitude != nil {
            let label = UILabel(frame: CGRect(x: 20, y: 86 / 2 - 19.09375 / 2, width: 100, height: 19.09375))
            label.attributedText = NSAttributedString(
                string: "Spotted at",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
            addSubview(label)
            
            
            view.backgroundColor = UIColor.white
            addSubview(view)
            
            let options = SnapshotOptions(
                mapIdentifiers: ["mapbox.streets"],
                centerCoordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                zoomLevel: 9,
                size: view.bounds.size)
            let customMarker = CustomMarker(
                coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                url: URL(string: "https://www.mapbox.com/help/img/screenshots/rocket.png")!
            )
            let markerOverlay = Marker(
                coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                size: .medium,
                iconName: "marker"
            )
            markerOverlay.color = UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00)
            options.overlays = [markerOverlay]
            let snapshot = Snapshot(
                options: options,
                accessToken: "pk.eyJ1IjoibWJlY2tlciIsImEiOiJjaWt2MDZxbDkwMDFzd3ptNXF3djVhYW42In0.9Lavn2fn_0tg-QVrPhwEzA")
            
            let imageURL = snapshot.url
            
            let i = BallPulseIndicator(frame: CGRect(x: view.bounds.width / 2 - 88 / 2, y: view.bounds.height / 2 - CGFloat(44 / 2), width: CGFloat(88), height: CGFloat(44)))
            view.kf.indicatorType = .custom(indicator: i)
            view.kf.setImage(with: imageURL)
        } else {
            let info = UILabel()
            info.attributedText = NSAttributedString(
                string: "Not yet located ...",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
            info.translatesAutoresizingMaskIntoConstraints = false
            addSubview(info)
            info.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            info.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        }
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
