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
    let _park: Park
    let _user: User
    var delegate: SelectParkDelegate?
    
    var showConfig = false
    
    init(park: Park, user: User){
        self._park = park
        self._user = user
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
        self.tableNode.view.separatorColor = UIColor.clear
        
        loadPark()
        
        /**
         * SETUP DATA
         */
        subscribeMessaging(toTopic: "/topics/addo")
    }
    
    
    func loadPark(){
        let parkTableHeader                 = ParkTableHeaderUIView(park: self._park)
        parkTableHeader.delegate            = self
        parkTableHeader.delegateMap         = self
        if self._user.getConfig(configItem: .showWhiteHeader) {
            parkTableHeader.backgroundColor = UIColor.white
        }
        
        
        self.tableNode.view.tableHeaderView = parkTableHeader
        self.tableNode.view.tableFooterView = self.tableFooterView()
        
        if let mapImageString: String = self._park.mapURL, let mapImageURL: URL = URL(string: mapImageString) {
            parkTableHeader.mapView?.stopAndRemoveLoadingIndicator()
            let processor = RoundCornerImageProcessor(cornerRadius: 10)
            parkTableHeader.mapView?.kf.indicatorType = .activity
            parkTableHeader.mapView?.kf.setImage(with: mapImageURL, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                if error != nil {
                    print(error!)
                    // ToDo: Map Image can't be download; show error?
                } else {
                    
                    self._park.mapImage = image
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
    
    
    func sectionHeaderView(text: String, sectionId: Int = 0) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let detailButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 20 - 42.5947265625 - 20 - 20, y: 42 / 2 - 16.70703125, width: 20 + 42.5947265625 + 20, height: 16.70703125 * 2))
        detailButton.contentHorizontalAlignment = .right
        detailButton.setAttributedTitle(NSAttributedString(
            string: "See all",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor.scarlet,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
            ])
            , for: .normal)
        detailButton.setAttributedTitle(NSAttributedString(
            string: "See all",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular),
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
        
        view.addSubview(title)
        view.addSubview(detailButton)
        
        let constraintLeftTitle = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let constraintCenterYTitle = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        view.addConstraint(constraintLeftTitle)
        view.addConstraint(constraintCenterYTitle)
        
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
        return self._park.sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self._park.sections.indices.contains(section) {
            return sectionHeaderView(text: self._park.sections[section].name, sectionId: section)
        }
        return sectionHeaderView(text: "Section: \(section)")
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.white
        if section < self._park.sections.count - 1 {
            // Show not border line for last section
            let borderLine = UIView(frame: CGRect(x: 20, y: 14, width: self.view.bounds.width - 40, height: 1))
            borderLine.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00) // Bonjour
            footer.addSubview(borderLine)
        }
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let node = ParkASCellNode(park: self._park, section: indexPath.section, type: self._park.sections[indexPath.section].type)
        node.delegate = self
        return node
    }
}

extension ParkASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 144), max: CGSize(width: 0, height: 188))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

extension ParkASViewController : ParkASCellNodeDelegate {
    func didSelectPark(_ item: ParkItem2) {
        let detailTableViewConroller = DetailASViewController(park: self._park, parkItem: item)
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
        let parkDetailUIViewController = ParkDetailViewController(park: self._park)
        self.navigationController?.pushViewController(parkDetailUIViewController, animated: true)
    }
}
