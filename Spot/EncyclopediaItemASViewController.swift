//
//  EncyclopediaItemASViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/12/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher
import Mapbox
import MapboxStatic
import RealmSwift

class EncyclopediaItemASViewController: ASViewController<ASDisplayNode> {
    
    private var shadowImageView: UIImageView?
    
    /**
     * AsyncDisplayKit
     */
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    let _realm                      = try! Realm()
    let _realmEnyclopediaItemKey    : String
    let _realmEnyclopediaItem       : RealmEncyclopediaItem
    let _realmPark                  : RealmPark?
    var _tableHeader                : DetailTableHeaderUIView?
    let _mapNode                    : MapNode!
    
    init(realmEnyclopediaItemKey: String, realmParkKey: String) {
        self._realmEnyclopediaItemKey   = realmEnyclopediaItemKey
        self._realmEnyclopediaItem      = self._realm.object(ofType: RealmEncyclopediaItem.self, forPrimaryKey: realmEnyclopediaItemKey)!
        self._realmPark                 = self._realm.object(ofType: RealmPark.self, forPrimaryKey: realmParkKey)!
        self._mapNode                   = MapNode(latitude: self._realmPark?.country?.latitude, longitude: self._realmPark?.country?.longitude)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigationcontroller
        self.navigationController?.visibleViewController?.title = self._realmEnyclopediaItem.name
        
        
        /**
         * URLs for Slideshow
         */
        var urls = [URL]()
        // 01. Original image
        if let results = self._realmEnyclopediaItem.image?.resized.filter("type = %@", "375x300"), let image: RealmImageOriginal = results.first, let imageURL: URL = URL(string: image.publicURL) {
            // 1. resized 375x300
            urls.append(imageURL)
        } else if let results = self._realmEnyclopediaItem.image?.resized, let image: RealmImageOriginal = results.first, let imageURL: URL = URL(string: image.publicURL) {
            // 2. any resized image (first image; better than public image)
            urls.append(imageURL)
        } else if let image: String = self._realmEnyclopediaItem.image?.original, let imageURL: URL = URL(string: image) {
            // 3. public image
            urls.append(imageURL)
        }
        // 02. Resized Images
        for image in self._realmEnyclopediaItem.images {
            if let resizedIMage: RealmImage = image.resized.filter("type = '375x300'").first, let imageURL: URL = URL(string: resizedIMage.publicURL) {
                // 1. resized 375x300
                urls.append(imageURL)
            } else if let resizedIMage: RealmImage = image.resized.first, let imageURL: URL = URL(string: resizedIMage.publicURL) {
                // 2. any resized image (first image; better than public image)
                urls.append(imageURL)
            } else if let image: String = image.original?.publicURL, let imageURL: URL = URL(string: image) {
                // 3. public image
                urls.append(imageURL)
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
            self._tableHeader = DetailTableHeaderUIView.init(title: self._realmEnyclopediaItem.name, urls: urls, viewController: self)
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

extension EncyclopediaItemASViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView(text: self._realmEnyclopediaItem.name)
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
//        case 0:
//            node = CountryASCellNode(park: self._park)
//        case 1:
//            node = ASCellNode{ () -> UIView in
//                return TagsNode(parkItem: self._parkItem)
//            }
//        case 2:
//            node = ASCellNode{ () -> UIView in
//                return SpottedByNode(parkItem: self._parkItem)
//            }
        case 0:
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
        
        if row == 0 && self._realmPark?.country?.latitude != nil && self._realmPark?.country?.longitude != nil {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86 + UIScreen.main.bounds.width * 2 / 3)
        } else {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86)
        }
        
        return node
    }
}

extension EncyclopediaItemASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 20), max: CGSize(width: 0, height: 86 + UIScreen.main.bounds.width * 2 / 3))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

