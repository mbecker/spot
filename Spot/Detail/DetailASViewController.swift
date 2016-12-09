//
//  DetailASViewController.swift
//  Spot
//
//  Created by Mats Becker on 12/1/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
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
    
    let _parkItem: ParkItem2
    
    init(parkItem: ParkItem2) {
        self._parkItem = parkItem
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = false
        
        // Hide text "Back"
        let backImage = UIImage(named: "back64")?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        // self.navigationController!.navigationBar.topItem?.title = "Park"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: nil)
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: nil)
        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: nil)
        let tag = UIBarButtonItem(image: #imageLiteral(resourceName: "pricetag66"), style: .plain, target: self, action: nil)
        let like = UIBarButtonItem(image: #imageLiteral(resourceName: "like66"), style: .plain, target: self, action: nil)
        
        self.navigationItem.rightBarButtonItems = [share, camera]
        
        var urls = [URL]()
        if let publicURL: URL = self._parkItem.urlPublic as URL! {
            urls.append(publicURL)
        }
        
        if self._parkItem.imagesPublic.count > 0 {
            for (_, url) in self._parkItem.imagesPublic {
                urls.append(url)
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
            self.tableNode.view.tableHeaderView = DetailTableHeaderUIView.init(title: self._parkItem.name, urls: urls, viewController: self)
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
        let node = ASCellNode { () -> UIView in
            
            switch row {
            case 0:
                return CountryNode.init(_parkItem: self._parkItem)
            case 1:
                return TagsNode.init(parkItem: self._parkItem)
            case 2:
                return SpottedByNode.init(parkItem: self._parkItem)
            case 3:
                return MapNode.init(parkItem: self._parkItem)
            default:
                let view = UIView()
                view.backgroundColor = UIColor.white
                return view
            }
            
        }
        
        if row == 3 && self._parkItem.latitude != nil && self._parkItem.longitude != nil {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86 + UIScreen.main.bounds.width * 2 / 3)
            node.selectionStyle = .blue
        } else {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86)
            node.selectionStyle = .gray
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

class CountryNode: UIView {
    init(_parkItem: ParkItem2) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        let height: CGFloat = 19.09375 + 4 + 14.3203125
        let view = UIView(frame: CGRect(x: 20, y: 86 / 2 - height / 2, width: UIScreen.main.bounds.width - 20 - 32 - 20, height: height))
        addSubview(view)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 19.09375))
        label.attributedText = NSAttributedString(
            string: _parkItem.park.name,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        
        view.addSubview(label)
        
        let info = UILabel(frame: CGRect(x: 0, y: label.bounds.height + 4, width: view.bounds.width, height: 14.3203125))
        if _parkItem.park.country != nil {
            info.attributedText = NSAttributedString(
                string: (_parkItem.park.country ?? "").isEmpty ? "No country defined" : _parkItem.park.country!,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
        }
        view.addSubview(info)
        
        /**
         * Images for country and park
         */
        if _parkItem.park.countryIcon != nil {
            let countryIconView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 20 - 32 - 16, y: 86 / 2 - 32 / 2, width: 32, height: 32))
            countryIconView.image = _parkItem.park.countryIcon
            countryIconView.layer.cornerRadius = 16
            countryIconView.clipsToBounds = true
            addSubview(countryIconView)
        }
        
        if _parkItem.park.parkIcon != nil {
            let parkLogo = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 20 - 32, y: 86 / 2 - 32 / 2, width: 32, height: 32))
            parkLogo.image = _parkItem.park.parkIcon
            parkLogo.layer.cornerRadius = 16
            parkLogo.clipsToBounds = true
            addSubview(parkLogo)
        }
        
        let borderBottomView = UIView(frame: CGRect(x: 20, y: 85, width: UIScreen.main.bounds.width - 40, height: 1))
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        addSubview(borderBottomView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    init(parkItem: ParkItem2){
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        if parkItem.latitude != nil, parkItem.longitude != nil {
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
            
            let view = UIImageView(frame: CGRect(x: 0, y: 86, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 2 / 3))
            view.backgroundColor = UIColor.white
            addSubview(view)
            
            let options = SnapshotOptions(
                mapIdentifiers: ["mapbox.streets"],
                centerCoordinate: CLLocationCoordinate2D(latitude: parkItem.latitude!, longitude: parkItem.longitude!),
                zoomLevel: 11,
                size: view.bounds.size)
            let customMarker = CustomMarker(
                coordinate: CLLocationCoordinate2D(latitude: parkItem.latitude!, longitude: parkItem.longitude!),
                url: URL(string: "https://www.mapbox.com/help/img/screenshots/rocket.png")!
            )
            let markerOverlay = Marker(
                coordinate: CLLocationCoordinate2D(latitude: parkItem.latitude!, longitude: parkItem.longitude!),
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
