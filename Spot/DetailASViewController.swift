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
        self._tableData.append("Addo Elephant National Park")
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
//        let barButton = UIBarButtonItem(image: backImage, style: .plain, target: nil, action: nil)
//        barButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        barButton.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
//        self.navigationItem.leftBarButtonItem = barButton
//        self.navigationController?.navigationBar.backItem?.backBarButtonItem = barButton
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        self.navigationController!.navigationBar.topItem?.title = "Park"
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
        return 18
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let item = self._tableData[indexPath.row]
        let row = indexPath.row
        let node = ASCellNode { () -> UIView in
            switch row {
            case 0:
                return CountryNode.init(_item: self._parkItem)
            case 1:
                return ItemsNode.init(parkItem: self._parkItem)
            case 2:
                return SpootedByNode.init(parkItem: self._parkItem)
            default:
                let view = UIView()
                view.backgroundColor = UIColor.white
                return view
            }
            
        }
        if item == "mbecker" {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86)
        } else {
            node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 86)
        }
        
        return node
    }
}

extension DetailASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 20), max: CGSize(width: 0, height: 86))
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

class CountryNode: UIView {
    init(_item: ParkItem2) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: "Addo Elephant National Park",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        
        let info = UILabel()
        info.attributedText = NSAttributedString(
            string: "Cape Town, South Africa • 2km away",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        info.translatesAutoresizingMaskIntoConstraints = false
        addSubview(info)
        info.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4).isActive = true
        info.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        
        /**
         * Images
         */
        let countryLogo = UIImageView()
        countryLogo.image = #imageLiteral(resourceName: "southafrica")
        countryLogo.layer.cornerRadius = 16
        countryLogo.clipsToBounds = true
        countryLogo.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countryLogo)
        countryLogo.widthAnchor.constraint(equalToConstant: 32).isActive = true
        countryLogo.heightAnchor.constraint(equalToConstant: 32).isActive = true
        countryLogo.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -36).isActive = true
        countryLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let parkLogo = UIImageView()
        parkLogo.image = #imageLiteral(resourceName: "southafricannationalparks")
        parkLogo.layer.cornerRadius = 16
        parkLogo.clipsToBounds = true
        parkLogo.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parkLogo)
        parkLogo.widthAnchor.constraint(equalToConstant: 32).isActive = true
        parkLogo.heightAnchor.constraint(equalToConstant: 32).isActive = true
        parkLogo.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        parkLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        let borderBottomView = UIView()
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        borderBottomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderBottomView)
        
        borderBottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        borderBottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        borderBottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        borderBottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ItemsNode: UIView {
    init(parkItem: ParkItem2){
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        if parkItem.tags.count == 0 {
            let info = UILabel()
            info.attributedText = NSAttributedString(
                string: "No tags",
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
            var i = 0
            for tag in parkItem.tags {
                let tagImageView = UIImageView(frame: CGRect(x: 20 + i, y: 86 / 2 - 24, width: 48, height: 48))
                tagImageView.cornerRadius = 24
                tagImageView.clipsToBounds = true
                tagImageView.borderColor = UIColor.black
                tagImageView.borderWidth = 1.0
                tagImageView.contentMode = .center
                var imageTag : UIImage = UIImage()
                if tag == "Elephant" {
                    imageTag = #imageLiteral(resourceName: "elephant64")
                } else if tag == "Ape" {
                    imageTag = #imageLiteral(resourceName: "gorilla64")
                } else {
                    imageTag = #imageLiteral(resourceName: "giraffe64")
                }
                
                tagImageView.image = imageTag.resizedImage(newSize: CGSize(width: 32, height: 32))
                
                addSubview(tagImageView)
                i = i + 48 + 14
            }
        }
        
        
        let borderBottomView = UIView()
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        borderBottomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderBottomView)
        
        borderBottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        borderBottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        borderBottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        borderBottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpootedByNode: UIView {
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
            
            var count = 4
            if parkItem.spottedBy.count < 4 {
                count = parkItem.spottedBy.count
            }
            
            for i in 0...count {
                let tagImageView = UIImageView(frame: CGRect(x: 20 + (i * 32), y: 86 / 2 - 24, width: 48, height: 48))
                tagImageView.cornerRadius = 24
                tagImageView.clipsToBounds = true
                tagImageView.borderColor = UIColor.black
                tagImageView.borderWidth = 1.0
                tagImageView.image = UIImage(named: "lego" + String(arc4random_uniform(9) + 1))
                
                addSubview(tagImageView)
                self.sendSubview(toBack: tagImageView)
            }
            
            let info = UILabel()
            info.attributedText = NSAttributedString(
                string: "+ \(parkItem.spottedBy.count) user",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00), // Charcoal
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.6,
                    ])
            info.translatesAutoresizingMaskIntoConstraints = false
            addSubview(info)
            let leadingConstant: Int = Int(32) * (Int(count) + 1) + 20 + 24
            info.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            info.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: CGFloat(leadingConstant)).isActive = true
            
        }
        
        let borderBottomView = UIView()
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        borderBottomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderBottomView)
        
        borderBottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        borderBottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        borderBottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        borderBottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
