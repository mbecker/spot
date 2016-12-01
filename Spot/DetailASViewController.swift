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

class DetailASViewController: ASViewController<ASDisplayNode> {
    
    private var shadowImageView: UIImageView?
    
    /**
     * AsyncDisplayKit
     */
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    let _parkItem: ParkItem2
    
    var _tableData: [String] = []
    
    init(parkItem: ParkItem2) {
        self._parkItem = parkItem
        self._tableData.append("Addo Elephant national Park")
        self._tableData.append("2km away")
        self._tableData.append("10mins ago")
        self._tableData.append("mbecker")
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.title = "Detail"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
        
        // Hide text "Back"
        let backImage = UIImage(named: "back64")?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        self.navigationController!.navigationBar.topItem?.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var urls = [URL]()
        if let publicURL: URL = self._parkItem.urlPublic {
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
        self.tableNode.view.tableHeaderView = DetailTableHeaderUIView.init(title: self._parkItem.name, urls: urls)
        self.tableNode.view.tableFooterView = tableFooterView
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
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 240))
        view.backgroundColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        return view
    }()
    
    func sectionHeaderView(text: String) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
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
        return self._tableData.count
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView(text: self._parkItem.name)
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
        return 18
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let item = self._tableData[indexPath.row]
        let node = ASCellNode { () -> UIView in
            let view = UIView()
            view.backgroundColor = UIColor.white
            let label = UILabel(frame: CGRect(x: 20, y: 2, width: UIScreen.main.bounds.width - 20, height: 20))
            label.textColor = UIColor(red:0.16, green:0.20, blue:0.32, alpha:1.00)
            label.attributedText = NSAttributedString(
                string: item,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])

            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            return view
        }
        if item == "mbecker" {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 32)
        } else {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 32)
        }
        
        return node
    }
}

extension DetailASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 20), max: CGSize(width: 0, height: 32))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}
