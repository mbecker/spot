//
//  UserSettingsASViewController.swift
//  Spot
//
//  Created by Mats Becker on 1/24/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class UserSettingsASViewController: ASViewController<ASDisplayNode> {
    //AsyncDisplayKit
    var _tableNode: ASTableNode {
        return node as! ASTableNode
    }
    let _user: User
    private var shadowImageView: UIImageView?
    
    init(user: User){
        self._user = user
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        self._tableNode.delegate      = self
        self._tableNode.dataSource    = self
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
        
        self.navigationController!.navigationBar.topItem?.title = "Profile"
        // Hide text "Back"
        let backImage = UIImage(named: "back64")?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        
        
    }
    
    func changeStatusbarColor(color: UIColor){
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: ASDisplayProperties.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        self.view.backgroundColor = UIColor.green
        // TableView
        self._tableNode.view.showsVerticalScrollIndicator = true
        self._tableNode.view.backgroundColor = UIColor.white
        self._tableNode.view.separatorColor = UIColor.clear
        self._tableNode.view.tableFooterView = tableFooterView
        self._tableNode.view.allowsSelection = true
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

extension UserSettingsASViewController : ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return CONFIGITEMS.count
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView(text: self._user.name)
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
        node = ASCellNode { () -> UIView in
            
            switch row {
            case 0:
                return SettingsNode.init(user: self._user, configItem: CONFIGITEMS[0])
            case 1:
                return SettingsNode.init(user: self._user, configItem: CONFIGITEMS[1])
            default:
                let view = UIView()
                view.backgroundColor = UIColor.white
                return view
            }
            
        }
        node.selectionStyle = .none
        node.backgroundColor = UIColor.white
        node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 64)
        return node
    }
}

extension UserSettingsASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 20), max: CGSize(width: 0, height: 86 + UIScreen.main.bounds.width * 2 / 3))
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

class SettingsNode: UIView {
    
    let _user: User
    let _configItem: configItem
    
    init(user: User, configItem: configItem) {
        self._user = user
        self._configItem = configItem
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        let height: CGFloat = 64
        let view = UIView(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width - 20 - 32 - 20, height: height))
        addSubview(view)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 19.09375))
        label.attributedText = NSAttributedString(
            string: _configItem.rawValue,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        let switchControl = UISwitch()
        switchControl.center = view.center
        switchControl.setOn(_user.getConfig(_configItem: _configItem), animated: false)
        // switchControl.tintColor = UIColor.blue
        switchControl.onTintColor = UIColor.crimson
        // switchControl.thumbTintColor = UIColor.crimson
        // switchControl.backgroundColor = UIColor.white
        switchControl.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControlEvents.valueChanged)
        view.addSubview(switchControl)
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let borderBottomView = UIView(frame: CGRect(x: 20, y: height, width: UIScreen.main.bounds.width - 40, height: 1))
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        addSubview(borderBottomView)
        
    }
    
    func switchChanged(sender: UISwitch!) {
        print("\(self._configItem.rawValue) to: \(sender.isOn)")
        switch self._configItem {
        case .showConfig:
            self._user.setShowConfig(showConfig: sender.isOn)
        case .shownavbar:
            self._user.setShowNavBar(showNavBar: sender.isOn)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

