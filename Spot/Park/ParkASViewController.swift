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
        self.tableNode.view.tableHeaderView = tableHeaderView
        
        // Firebase
        ref = FIRDatabase.database().reference()
        ref.child("sections").observeSingleEvent(of: .value, with: { (snapshot) in
            let snaps = snapshot.value as! [String : NSDictionary]
            for snap in snaps {
                print(snap)
            }
            // self.tableNode.view.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView = navHeaderView(park: "Addo Elephant Park")
        
        // TableView
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var tableHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 28))
        view.backgroundColor = UIColor.red
        return view
    }()
    
    func navHeaderView(park: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.navigationController?.navigationBar.frame.size.height)!))
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: park,
            attributes: [
                NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16)!,
                NSForegroundColorAttributeName: UIColor.black
                ])
        title.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }
    
    func sectionHeaderView(text: String) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.00)
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 21),
                NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
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
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let node = ParkASCellNode(park: parkData[indexPath.section])
        return node
    }
}

extension ParkASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 180), max: CGSize(width: 0, height: 180))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}
