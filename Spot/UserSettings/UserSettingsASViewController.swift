//
//  UserSettingsASViewController.swift
//  Spot
//
//  Created by Mats Becker on 1/24/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseAuth
import FacebookLogin
import FacebookCore

class UserSettingsASViewController: ASViewController<ASDisplayNode> {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationctroller title
        self.navigationController!.navigationBar.topItem?.title = "Profile"
        // View
        self.view.backgroundColor = UIColor.green
        // TableView
        
        self._tableNode.view.allowsSelection = true
        self._tableNode.view.showsVerticalScrollIndicator = true
        self._tableNode.view.backgroundColor = UIColor.white
        self._tableNode.view.separatorColor = UIColor.clear
        self._tableNode.view.tableFooterView = tableFooterView
        if let text: String = self._user.name {
            self._tableNode.view.tableHeaderView = tableHeaderView(text: text)
        } else {
            self._tableNode.view.tableHeaderView = tableHeaderView(text: "Please login")
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
    
    /**
     * Footer
     */
    lazy var tableFooterView: UIView = {
        let logutView = LogoutNode()
        logutView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 96)
        return logutView
    }()
    
    /**
     * Header
     */
    func tableHeaderView(text: String) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 84))
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
        
        switch section {
        case 0:
            return 1
        default:
            return CONFIGITEMS.count + 2
        }
        
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let vw = UIView()
            vw.backgroundColor = UIColor.white
            vw.borderWidth = 0
            vw.borderColor = UIColor.clear
            
            let title = UILabel()
            title.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
            title.translatesAutoresizingMaskIntoConstraints = false
            
            vw.addSubview(title)
            title.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 20).isActive = true
            title.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
            
            switch section {
            case 0:
                title.text = "Offline packs"
            default:
                title.text = "Settings"
            }
            
            return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
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
        
        if indexPath.section == 0 {
            let textNode = ASTextCellNode()
            textNode.text = "Parks"
            return UserSettingsASTextCellNode(title: "Parks")
        }
        
        let row = indexPath.row
        var node: ASCellNode
        node = ASCellNode { () -> UIView in
            
            switch row {
            case 0:
                return SettingsNode.init(user: self._user, configItem: CONFIGITEMS[0])
            case 1:
                return SettingsNode.init(user: self._user, configItem: CONFIGITEMS[1])
            case 2:
                return SettingsNode.init(user: self._user, configItem: CONFIGITEMS[2])
            case 3:
                return SettingsNode.init(user: self._user, configItem: CONFIGITEMS[2])
            case 4:
                return SettingsNode.init(user: self._user, configItem: CONFIGITEMS[2])
            default:
                let view = UIView()
                view.backgroundColor = UIColor.white
                return view
            }
            
        }
        node.selectionStyle = .none
        node.backgroundColor = UIColor.white
        node.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 48)
        return node
    }
}

extension UserSettingsASViewController : ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange.init(min: CGSize(width: 0, height: 48), max: CGSize(width: 0, height: 48))
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at: \(indexPath)")
    }
}

class LogoutNode: UIView {
    
    let errorLabel = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        let loginButton = LoginButton(frame: CGRect.zero, readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.delegate = self
        self.addSubview(loginButton)
        loginButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 164).isActive = true
        
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let infoAttributedText = NSAttributedString(
            string: "We use Facebook as a login provider and would never post anything without your permission.",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightLight),
                NSForegroundColorAttributeName: UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.00),
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                NSParagraphStyleAttributeName: paragraph
            ])
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.numberOfLines = 0
        errorLabel.attributedText = infoAttributedText
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(errorLabel)
        errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        errorLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 64).isActive = true

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LogoutNode: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print(":: FACEBOOK LOGOUT ::")
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print(":: FIREBASE LOGOUT ::")
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        switch result {
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    self.errorLabel.attributedText = NSAttributedString(
                        string: error.localizedDescription,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium),
                            NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.0,
                            NSParagraphStyleAttributeName: paragraph
                        ])
                    return
                }
                print(":: FIREBASE :: LOGGED IN ")
                print("displayname: \(user!.displayName)")
                print("email: \(user!.email)")
                print("image: \(user!.photoURL)")
                // self.navigationController?.pushViewController(MainASTabBarController(), animated: true)
                
            }
            break
        case .cancelled:
            print(":: FACEBOOK LOGIN CANCELLED ::")
            self.errorLabel.attributedText = NSAttributedString(
                string: "Facebook Login cancelled",
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    NSParagraphStyleAttributeName: paragraph
                ])
            break
        case .failed(let error):
            print(":: FACEBOOK LOGIN ERROR ::")
            print(error)
            self.errorLabel.attributedText = NSAttributedString(
                string: error.localizedDescription,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium),
                    NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    NSParagraphStyleAttributeName: paragraph
                ])
            break
        }
        
        
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
//        let height: CGFloat = 48
//        let view = UIView(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width - 20 - 32 - 20, height: height))
//        addSubview(view)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 19.09375))
        label.attributedText = NSAttributedString(
            string: _configItem.rawValue,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        
        let switchControl = UISwitch()
        switchControl.setOn(_user.getConfig(configItem: self._configItem), animated: false)
        // switchControl.tintColor = UIColor.blue
        switchControl.onTintColor = UIColor.radicalRed
        // switchControl.thumbTintColor = UIColor.crimson
        // switchControl.backgroundColor = UIColor.white
        switchControl.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControlEvents.valueChanged)
        self.addSubview(switchControl)
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        
        let borderBottomView = UIView(frame: CGRect.zero)
        borderBottomView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00) // Lilly White
        addSubview(borderBottomView)
        borderBottomView.translatesAutoresizingMaskIntoConstraints = false
        borderBottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        borderBottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20).isActive = true
        borderBottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        borderBottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        
    }
    
    func switchChanged(sender: UISwitch!) {
        print("\(self._configItem.rawValue) to: \(sender.isOn)")
        switch self._configItem {
        case .showConfig:
            self._user.setShowConfig(showConfig: sender.isOn)
        case .shownavbar:
            self._user.setShowNavBar(showNavBar: sender.isOn)
        case .showWhiteHeader:
            self._user.setConfig(configItem: self._configItem, set: sender.isOn)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserSettingsASTextCellNode: ASTextCellNode {
    
    override var isSelected: Bool {
        get {
            return self.isSelected
        }
        set {
            if newValue {
                self.textAttributes = self._titleAttributesSelected
                self.backgroundColor = UIColor.radicalRed
                let modificationBlock = { (originalImage: UIImage) -> UIImage? in
                    return ASImageNodeTintColorModificationBlock(self._imageColorSelected)(originalImage)
                }
                self.chevron.imageModificationBlock = modificationBlock
                self.setNeedsDisplay()
            } else {
                self.backgroundColor = UIColor.clear
                self.textAttributes = self._titleAttributes
                self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
                self.setNeedsDisplay()
            }
        }
    }
    
    override func __setSelected(fromUIKit selected: Bool) {
        if selected {
            self.textAttributes = self._titleAttributesSelected
            self.backgroundColor = UIColor.radicalRed
            let modificationBlock = { (originalImage: UIImage) -> UIImage? in
                return ASImageNodeTintColorModificationBlock(self._imageColorSelected)(originalImage)
            }
            self.chevron.imageModificationBlock = modificationBlock
            self.setNeedsDisplay()
        } else {
            self.backgroundColor = UIColor.clear
            self.textAttributes = self._titleAttributes
            self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
            self.setNeedsDisplay()
        }
    }
    
    override func __setHighlighted(fromUIKit highlighted: Bool) {
        if highlighted {
            self.textAttributes = self._titleAttributesSelected
            self.backgroundColor = UIColor.radicalRed
            let modificationBlock = { (originalImage: UIImage) -> UIImage? in
                return ASImageNodeTintColorModificationBlock(self._imageColorSelected)(originalImage)
            }
            self.chevron.imageModificationBlock = modificationBlock
            self.setNeedsDisplay()
        } else {
            self.textAttributes = self._titleAttributes
            self.backgroundColor = UIColor.clear
            self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
            self.setNeedsDisplay()
        }
    }
    
    let _titleAttributes:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.scarlet,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
        ]
    let _titleAttributesSelected:[String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
        NSForegroundColorAttributeName: UIColor.white,
        NSBackgroundColorAttributeName: UIColor.clear,
        NSKernAttributeName: 0.0,
        ]
    
    let chevron = ASImageNode()
    let _imageColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:0.60)
    let _imageColorSelected = UIColor.white
    
    convenience init(title: String) {
        self.init()
        self.text = title
        self.textAttributes = self._titleAttributes
        let chevronImage = UIImage(named: "chevronright_32x17")?.withRenderingMode(.alwaysTemplate)
        self.chevron.image = chevronImage
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), child: self.textNode)
    }
    
    override func didLoad() {
        let modificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeTintColorModificationBlock(UIColor(red:0.78, green:0.78, blue:0.80, alpha:0.60))(originalImage)
        }
        self.chevron.imageModificationBlock = ASImageNodeTintColorModificationBlock(self._imageColor)
        self.chevron.frame = CGRect(x: self.frame.width - 20 - 8.5, y: self.frame.height / 2 - 16 / 2, width: 8.5, height: 16)
        self.addSubnode(self.chevron)
    }
    
}


