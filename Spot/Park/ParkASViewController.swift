//
//  ParkASViewController.swift
//  Spot
//
//  Created by Mats Becker on 11/6/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import Kingfisher

protocol SelectParkDelegate {
    func selectPark()
    func selectPark(park: String, name: String)
}
protocol SelectParkMapDelegate {
    func selectParkMap()
}

class ParkASViewController: ASViewController<ASDisplayNode> {
    
    /**
    * AsyncDisplayKit
    */
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    /**
     * Data
     */
    
    let parkInformtion = [
        "Park",
        "Animals",
        "Attractions"
    ]
    
    let _realmPark: RealmPark
    var delegate: SelectParkDelegate?
    
    var showConfig = false
    
    init(realmPark: RealmPark){
        self._realmPark = realmPark
        
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        self.view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        // TableView
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.view.backgroundColor = UIColor.white
        // self.tableNode.view.separatorColor = UIColor.clear
        self.tableNode.view.separatorStyle = .none
        loadPark()
        
        /**
         * SETUP DATA
         */
        subscribeMessaging(toTopic: "/topics/addo")
    }
    
    
    func loadPark(){
        let parkTableHeader                 = ParkTableHeaderUIView(realmPark: self._realmPark)
        parkTableHeader.delegate            = self
        parkTableHeader.delegateMap         = self
        parkTableHeader.backgroundColor = UIColor.white
        
        
        self.tableNode.view.tableHeaderView = parkTableHeader
        self.tableNode.view.tableFooterView = self.tableFooterView()
        
        if let mapImageString: String = self._realmPark.mapURL, let mapImageURL: URL = URL(string: mapImageString) {
            parkTableHeader.mapView?.stopAndRemoveLoadingIndicator()
            let processor = RoundCornerImageProcessor(cornerRadius: 10)
            parkTableHeader.mapView?.kf.indicatorType = .activity
            parkTableHeader.mapView?.kf.setImage(with: mapImageURL, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                if error != nil {
                    print(error!)
                    // ToDo: Map Image can't be download; show error?
                } else {
                    // We can not stora an image to realm; but the image is cached anyway
                }
            })
        }
        
    }
    
    func subscribeMessaging(toTopic: String){
        // Firebase Messaging
        print("-- FIREBASE -- subscribe toTopic \(toTopic)")
        // "/topics/addo"
        FIRMessaging.messaging().subscribe(toTopic: "/topics/addo")
    }
    
    func mapViewTouched(_ sender:UITapGestureRecognizer){
        // self.mapView touched
        let touch = sender.location(in: self.view)
        print(touch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        // self.navigationController?.isNavigationBarHidden = true
        
        //Status bar style and visibility
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        
        //Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: ASDisplayProperties.backgroundColor)) {
            statusBar.backgroundColor = UIColor.white
        }
        
        // User Settings: Change view based on settings
        self.showConfig = UserDefaults.standard.object(forKey: UserDefaultTypes.showConfig.rawValue) as? Bool ?? false
        self.tableNode.view.tableFooterView = self.tableFooterView()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableFooterView() -> UIView {
        return UIView(frame: CGRect.zero)
    }
    
    
    func sectionHeaderView(text: String, sectionId: Int = 99, additionalSpacingToTop: Bool = false) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.clear
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        let constraintLeftTitle = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 12)
        let constraintCenterYTitle = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: additionalSpacingToTop ? 8 : 0)
        view.addConstraint(constraintLeftTitle)
        view.addConstraint(constraintCenterYTitle)
        
        if sectionId != 99 {
            let detailButton = UIButton()
            detailButton.contentHorizontalAlignment = .right
            detailButton.setAttributedTitle(NSAttributedString(
                string: "See all",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight),
                    NSForegroundColorAttributeName: UIColor.scarlet,
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
                , for: .normal)
            detailButton.setAttributedTitle(NSAttributedString(
                string: "See all",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight),
                    NSForegroundColorAttributeName: UIColor.scarlet.withAlphaComponent(0.6),
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
                , for: .highlighted)
            // detailButton.setImage(UIImage(named: "next48")?.withRenderingMode(.alwaysTemplate), for: .normal)
            // detailButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
            detailButton.tintColor = UIColor.scarlet
            // detailButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            // detailButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            // detailButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            detailButton.tag = sectionId
            detailButton.addTarget(self, action: #selector(self.pushDetail(sender:)), for: UIControlEvents.touchUpInside)
            detailButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(detailButton)
            detailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            detailButton.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
            detailButton.heightAnchor.constraint(equalToConstant: 16.70703125 * 2).isActive = true
        }
        
        return view
    }
    
    @objc func pushDetail(sender: UIButton) {
        // self.tabBarController?.selectedIndex = 1
        print("-- TAGS --")
        print(sender.tag)
        
        if let vc = self.tabBarController!.viewControllers![1] as? ASNavigationController {
            vc.popToRootViewController(animated: false)
            if let view = vc.topViewController as? ChangePage {
                view.changePage(tab: sender.tag, showSelectedPage: true)
            }
        }
        
        
        self.tabBarController?.selectedIndex = 1
    }
    


}

extension ParkASViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return self._realmPark.sections.count + parkInformtion.count
    }
    
    /**
     * Section
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            return sectionHeaderView(text: "Encyclopedia")
        case _ where section < parkInformtion.count:
            return UIView()
        case parkInformtion.count:
            // The header is between last row of "Encyclopedia" and the first section
            return sectionHeaderView(text: self._realmPark.sections[section - parkInformtion.count].name, sectionId: section - parkInformtion.count, additionalSpacingToTop: true)
        default:
            return sectionHeaderView(text: self._realmPark.sections[section - parkInformtion.count].name, sectionId: section - parkInformtion.count)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 42
        case _ where section < parkInformtion.count:
            return 0.0000000000001
        case parkInformtion.count:
            // The header is between last row of "Encyclopedia" and the first section
            return 52
        default:
            return 42
        }
    }
    
    /**
     * Footer
     */
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        
        switch section {
        case _ where section == self._realmPark.sections.count + parkInformtion.count - 1:
            // Show not border line for last section
            return footer
        default:
            let borderLine = UIView(frame: CGRect(x: 20, y: 14, width: self.view.bounds.width - 40, height: 1))
            borderLine.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:0.60) // Lavender grey (standard cell border color?) UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00) // Bonjour
            borderLine.translatesAutoresizingMaskIntoConstraints = false
            footer.addSubview(borderLine)
            borderLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            borderLine.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 20).isActive = true
            borderLine.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20).isActive = true
            borderLine.centerYAnchor.constraint(equalTo: footer.centerYAnchor).isActive = true
            return footer
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case _ where section < self.parkInformtion.count:
            return 0.0000000000001
        default:
            return 18
        }
    }
    
    /**
     * Cellnode
     */
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let section = indexPath.section
        
        switch section {
        case _ where section < parkInformtion.count:
            let node = ParkInfoASTextCellNode(title: self.parkInformtion[section])
            return node
        default:
            let node = ParkASCellNode(realmPark: self._realmPark, parkSectionNumber: (section - parkInformtion.count))
            node.delegate = self
            return node
        }
        
    }
}

extension ParkASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let section = indexPath.section
        
        switch section {
        case _ where section < parkInformtion.count:
            return ASSizeRange.init(min: CGSize(width: 0, height: 44), max: CGSize(width: 0, height: 44))
        default:
            return ASSizeRange.init(min: CGSize(width: 0, height: 188), max: CGSize(width: 0, height: 188))
        }
        
        
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
        switch indexPath.section {
        case 0:
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
            let parkDetailUIViewController = ParkDetailViewController(realmPark: self._realmPark)
            self.navigationController?.pushViewController(parkDetailUIViewController, animated: true)
        case 1:
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
            let parkDetailUIViewController = ParkItemsASViewController(realmPark: self._realmPark, type: .animals)
            self.navigationController?.pushViewController(parkDetailUIViewController, animated: true)
        default:
            return
        }
        
    }
}

extension ParkASViewController : ParkASCellNodeDelegate {
    func didSelectPark(_ item: ParkItem2) {
        let detailTableViewConroller = DetailASViewController(realmPark: self._realmPark, parkItem: item)
        self.navigationController?.pushViewController(detailTableViewConroller, animated: true)
    }
}

extension ParkASViewController: SelectParkDelegate {
    func selectPark() {
            self.delegate?.selectPark()
    }
    
    func selectPark(park: String, name: String) {
        
    }
}

extension ParkASViewController: SelectParkMapDelegate {
    func selectParkMap() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        let parkDetailUIViewController = ParkDetailViewController(realmPark: self._realmPark)
        self.navigationController?.pushViewController(parkDetailUIViewController, animated: true)
    }
}
