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
    let parkData: [Park] = [
        Park(name: "Attractions", path: "park/addo/attractions"),
        Park(name: "Animals", path: "park/addo/animals")
    ]
    
    init() {
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TableView
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.view.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
        self.tableNode.view.tableHeaderView = ParkTableHeaderUIView.init(park: "addo", parkTitle: "Addo Elephant National Park")
        self.tableNode.view.tableFooterView = tableFooterView
        
        self.view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        
        // Firebase Messaging
        print("-- FIREBASE -- subscribe toTopic topics/addo")
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var tableFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 240))
        view.backgroundColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        
        let buttonClearCache = UIButton(frame: CGRect(x: 20, y: 20, width: 150, height: 50))
        buttonClearCache.setBackgroundColor(color: UIColor(red:0.92, green:0.10, blue:0.22, alpha:1.00), forState: .normal)
        buttonClearCache.setBackgroundColor(color: UIColor(red:0.83, green:0.29, blue:0.31, alpha:1.00), forState: .highlighted)
        buttonClearCache.setTitle("Clear Cache", for: .normal)
        buttonClearCache.addTarget(self, action: #selector(didTapClearCache), for: .touchUpInside)
        
        view.addSubview(buttonClearCache)
        
        return view
    }()
    
    @objc fileprivate func didTapClearCache() {
        ImageCache.default.calculateDiskCacheSize { size in
            let alert = UIAlertController(title: "Cache", message: "Used disk size: \(size / 1024 / 1024) MB", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Clear cache", style: UIAlertActionStyle.destructive, handler: { action in
                // Clear memory cache right away.
                ImageCache.default.clearMemoryCache()
                
                // Clear disk cache. This is an async operation.
                ImageCache.default.clearDiskCache()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func sectionHeaderView(text: String) -> UIView {
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
        detailButton.setAttributedTitle(NSAttributedString(
            string: "See all",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:1.00, green:0.22, blue:0.22, alpha:1.00), // iOS Red
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
            ])
            , for: .normal)
        detailButton.setAttributedTitle(NSAttributedString(
            string: "See all",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:1.00, green:0.22, blue:0.22, alpha:1.00).withAlphaComponent(0.6), // iOS Red
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
            ])
            , for: .highlighted)
        
        detailButton.setImage(UIImage(named: "next48")?.withRenderingMode(.alwaysTemplate), for: .normal)
        detailButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        detailButton.tintColor = UIColor(red:1.00, green:0.22, blue:0.22, alpha:1.00)
        detailButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        detailButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        detailButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        if text == "Attractions" {
            detailButton.tag = 0
        } else if text == "Animals" {
            detailButton.tag = 1
        }
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
        print(sender.tag)
    }
    


}

extension ParkASViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return self.parkData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView(text: parkData[section].name)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // From header text to immage horizinta slider
        return 42
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.white
        if section < parkData.count - 1 {
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
        let node = ParkASCellNode(park: parkData[indexPath.section])
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
        let detailViewController = DetailViewController(parkItem: item)
        let detailTableViewConroller = DetailASViewController(parkItem: item)
        self.navigationController?.pushViewController(detailTableViewConroller, animated: true)
    }
}

/* FONTS
 UIFontWeightUltraLight,
 UIFontWeightThin,
 UIFontWeightLight,
 UIFontWeightRegular,
 UIFontWeightMedium,
 UIFontWeightSemibold,
 UIFontWeightBold,
 UIFontWeightHeavy,
 UIFontWeightBlack
*/
