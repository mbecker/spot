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
     * Firebase
     */
    var ref: FIRDatabaseReference!
    var refs: [FIRDatabaseReference] = [FIRDatabaseReference]()
    
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
        Park(name: "Attraction", path: "park/addo/attractions"),
        Park(name: "Animals", path: "park/addo/animals")
    ]
    
    let mapView = UIImageView(frame: CGRect.zero)
    
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
        self.tableNode.view.tableHeaderView = tableHeaderView
        
        self.view.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        
        // Firebase Messaging
        print("-- FIREBASE -- subscribe toTopic topics/addo")
        FIRMessaging.messaging().subscribe(toTopic: "/topics/addo")
        
        // Firebase Databse: Set park image from firebase database
        ref = FIRDatabase.database().reference()
        ref.child("park/addo/image").observeSingleEvent(of: .value, with: { (snapshot) in
            if let image = snapshot.value as? String {
             print(image)
                let url = URL(string: image)!
                let processor = RoundCornerImageProcessor(cornerRadius: 10)
                self.mapView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var tableHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 82))
        view.backgroundColor = UIColor.clear
        
        let parkTitle = UILabel()
        parkTitle.attributedText = NSAttributedString(
            string: "Addo Elephant Park",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 26, weight: UIFontWeightBlack),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        parkTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let borderLine = UIView(frame: CGRect(x: 20, y: 82, width: self.view.bounds.width, height: 1))
        borderLine.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00) // iron
        
        view.addSubview(parkTitle)
        view.addSubview(borderLine)
        
        parkTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        parkTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 82 + 82 + 82 + 82))
        headerView.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        
        
        
        self.mapView.contentMode = .scaleAspectFill
        self.mapView.backgroundColor = UIColor.clear
        self.mapView.cornerRadius = 0
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.kf.indicatorType = .activity
        
        
        
        headerView.addSubview(view)
        headerView.addSubview(self.mapView)
        
        self.mapView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        self.mapView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        self.mapView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20).isActive = true
        self.mapView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
            
        return headerView
    }()
    
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
        
        let detailButton = UIButton()
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
        
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        view.addSubview(detailButton)
        
        let constraintLeftTitle = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let constraintCenterYTitle = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        view.addConstraint(constraintLeftTitle)
        view.addConstraint(constraintCenterYTitle)
        
        detailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        detailButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
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
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let node = ParkASCellNode(park: parkData[indexPath.section])
        node.delegate = self
        return node
    }
}

extension ParkASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 144), max: CGSize(width: 0, height: 144))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

extension ParkASViewController : ParkASCellNodeDelegate {
    func didSelectPark(_ item: ParkItem) {
        let itemViewController = ItemViewController(parkItem: item)
        self.navigationController?.pushViewController(itemViewController, animated: true)
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
