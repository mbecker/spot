//
//  FormFilterTableViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/21/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import DLRadioButton

class FormFilterTableViewController: UITableViewController {
    
    private var shadowImageView: UIImageView?
    var _realmPark: RealmPark?
    var _sectionsForTags: [RealmParkSection?] = [RealmParkSection?]()
    let _tags = Tags()
    
    var _tagsKey = [ItemType: [String]]()
    
    var _sectionsChecked = [String: DLRadioButton]()
    
    var _sectionsForTagsChecked = [ItemType: [String: DLRadioButton]]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Filter Spots"
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.tableView.allowsSelection = true
        
        self.tableView.separatorStyle = .none
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //self.tableView.register(UINib(nibName: "CheckboxTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        
        // Button
        let buttonHeight: CGFloat = 48
        let buttonPadding: CGFloat = 16
        let buttonPaddingRight: CGFloat = 46
        let buttonwView = UIView()
        buttonwView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - buttonHeight - buttonPadding * 2, width: self.view.bounds.width, height: buttonHeight + buttonPadding * 2)
        buttonwView.backgroundColor = UIColor.white
        buttonwView.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
        buttonwView.borderWidth = 1.0
        
        let buttonShow = UIButton()
        buttonShow.frame = CGRect(x: buttonPaddingRight, y: buttonPadding, width: self.view.bounds.width - buttonPaddingRight * 2, height: buttonHeight)
        buttonShow.setBackgroundColor(color: UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00), forState: .normal)
        buttonShow.setBackgroundColor(color: UIColor(red:0.08, green:0.59, blue:0.48, alpha:1.00), forState: .highlighted)
        buttonShow.setAttributedTitle(NSAttributedString(
            string: "Show more than 20 spots",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor.white,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ]), for: .normal)
        buttonShow.cornerRadius = 12
        
        buttonwView.addSubview(buttonShow)
        self.navigationController?.view.addSubview(buttonwView)
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonHeight + buttonPadding * 2, right: 0)
        // Sections
        if let sections = self._realmPark?.sections {
            
            for section in sections {
                
                self._sectionsChecked[section.key] = createCheckbox(isSelected: true)
                
                switch section.getType() {
                case .animals:
                    self._sectionsForTags.append(section)
                    self._tagsKey[.animals] = Array(self._tags.getTags(type: .animals)!.keys)
                    for item in self._tagsKey[.animals]! {
                        self._sectionsChecked[item] = createCheckbox(isSelected: false)
                    }
                case .attractions:
                    self._sectionsForTags.append(section)
                    self._tagsKey[.attractions] = Array(self._tags.getTags(type: .attractions)!.keys)
                    for item in self._tagsKey[.attractions]! {
                        self._sectionsChecked[item] = createCheckbox(isSelected: false)
                    }
                default:
                    break
                }
            }
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Navigationbar
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
//        shadowImageView?.backgroundColor = UIColor.purple
//        shadowImageView?.tintColor = UIColor.green
//        shadowImageView?.borderColor = UIColor.scarlet
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00), height: 1)
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        let size = CGSize(width: 18, height: 18)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        
        //// cross.svg Group
        //// Group 2
        //// cross
        //// Group 4
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 18, y: 0.63))
        bezierPath.addLine(to: CGPoint(x: 16.96, y: -0.4))
        bezierPath.addLine(to: CGPoint(x: 9, y: 7.47))
        bezierPath.addLine(to: CGPoint(x: 1.04, y: -0.4))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0.63))
        bezierPath.addLine(to: CGPoint(x: 7.96, y: 8.5))
        bezierPath.addLine(to: CGPoint(x: 0, y: 16.37))
        bezierPath.addLine(to: CGPoint(x: 1.04, y: 17.4))
        bezierPath.addLine(to: CGPoint(x: 9, y: 9.53))
        bezierPath.addLine(to: CGPoint(x: 16.96, y: 17.4))
        bezierPath.addLine(to: CGPoint(x: 18, y: 16.37))
        bezierPath.addLine(to: CGPoint(x: 10.04, y: 8.5))
        bezierPath.addLine(to: CGPoint(x: 18, y: 0.63))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cancelButton = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(dismiss(sender:)))
        let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpace.width = 12.0
        self.navigationItem.leftBarButtonItems = [negativeSpace, cancelButton]
        self.navigationItem.title = "Filter"
        
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
            NSForegroundColorAttributeName: UIColor.black,
            NSBackgroundColorAttributeName: UIColor.clear,
            NSKernAttributeName: 0.0,
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sectionsCount: Int = self._sectionsForTags.count {
            return 1 + sectionsCount
        }
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self._sectionsForTags.count > 0 {
            switch section {
            case 0:
                if let allSectionsCount = self._realmPark?.sections.count {
                    return allSectionsCount
                }
            default:
                return 3
            }
        }
        return 0
        
    }
    
    /*
     * Section
     */
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.white
        vw.borderWidth = 0
        vw.borderColor = UIColor.clear
        
        var titleText = ""
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
        title.textColor = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00) // Charcoal
        title.translatesAutoresizingMaskIntoConstraints = false
        
        vw.addSubview(title)
        title.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 16).isActive = true
        title.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
        
        switch section {
        case 0:
            titleText = "Spot Types"
        default:
            if let realmParkSection: RealmParkSection = self._sectionsForTags[section - 1] {
                titleText = realmParkSection.getType().rawValue.firstCharacterUpperCase()
                let moreButton = MoreButtonUIButton(title: "More")
                moreButton.translatesAutoresizingMaskIntoConstraints = false
//                moreButton.tag = sectionId
//                moreButton.addTarget(self, action: #selector(self.pushDetail(sender:)), for: UIControlEvents.touchUpInside)
                
                vw.addSubview(moreButton)
                moreButton.centerYAnchor.constraint(equalTo: title.centerYAnchor, constant: 0).isActive = true
                moreButton.trailingAnchor.constraint(equalTo: vw.trailingAnchor, constant: -20).isActive = true
                moreButton.heightAnchor.constraint(equalTo: title.heightAnchor, constant: 8).isActive = true
                moreButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
            }
            
        }
        
        title.attributedText = NSAttributedString(
            string: "Spot types",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00), // Charcoal //UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 1.2,
                ])
        
        return vw
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self._sectionsForTags.count == section {
            return 0
        } else {
            return 24
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self._sectionsForTags.count == section {
            return nil
        }
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        
        let view = UIView(frame: CGRect(x: 16, y: 12, width: self.view.bounds.width - 32, height: 1))
        view.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
        footer.addSubview(view)
        
        return footer
    }

    /**
     * Row cell
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let section: RealmParkSection = self._realmPark?.sections[indexPath.row], let sectionKey: String = section.key, let checkBox: DLRadioButton = self._sectionsChecked[sectionKey] {
                checkBox.isSelected = !checkBox.isSelected
            }
        default:
            if let cell: UITableViewCell = tableView.cellForRow(at: indexPath), let tagName: String = cell.textLabel?.text, let checkBox: DLRadioButton = self._sectionsChecked[tagName] {
                checkBox.isSelected = !checkBox.isSelected
            }
            
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 49
        
    }
    
    func createCheckbox(isSelected: Bool) -> DLRadioButton {
        let checkBox = DLRadioButton()
        checkBox.backgroundColor = UIColor.clear
        checkBox.iconStrokeWidth = 1.0
        checkBox.iconSize = 24
        checkBox.isIconSquare = true
        checkBox.isSelected = isSelected
        checkBox.isMultipleSelectionEnabled = true
        checkBox.iconColor = UIColor.lightGray
        checkBox.indicatorColor = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00);
        checkBox.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center;
        return checkBox
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var title = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        let accView = UIView()
        accView.backgroundColor = UIColor.clear
        let checkBoxHeight: CGFloat = 42
        
        
        
        switch indexPath.section {
        case 0:
            if let section: RealmParkSection = self._realmPark?.sections[indexPath.row] {
                
               title = section.name
                
                if let checkBox: DLRadioButton = self._sectionsChecked[section.key] {
                    checkBox.frame = CGRect(x: 0, y: cell.bounds.height / 2 - checkBoxHeight / 2, width: checkBoxHeight, height: checkBoxHeight)
                    accView.addSubview(checkBox)
                }
                
            }
        default:
            if let section: RealmParkSection = self._sectionsForTags[indexPath.section - 1], let sectionTitlte: String = self._tagsKey[section.getType()]?[indexPath.row] {
                title = sectionTitlte
                if let checkBox: DLRadioButton = self._sectionsChecked[sectionTitlte] {
                    checkBox.frame = CGRect(x: 0, y: cell.bounds.height / 2 - checkBoxHeight / 2, width: checkBoxHeight, height: checkBoxHeight)
                    accView.addSubview(checkBox)
                }
            }
        }
        
        cell.textLabel?.attributedText = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00), // Charcoal //UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        
        cell.accessoryView = accView
        cell.accessoryView?.frame = CGRect(x: cell.bounds.height, y: cell.bounds.width - checkBoxHeight, width: checkBoxHeight, height: cell.bounds.height)
        
        return cell
    }
    
    
    // mark: Helpers
    func dismiss(sender: UITabBarItem){
        if self.presentingViewController != nil{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

   

}
