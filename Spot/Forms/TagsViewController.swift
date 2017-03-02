//
//  TagsViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/23/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import DLRadioButton

class TagsViewController: UIViewController {
    
    private var shadowImageView: UIImageView?
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    let model = generateRandomData()
    var storedOffsets = [Int: CGFloat]()
    
    var _sectionTitles: [ItemType]?
    var _checkboxes = [String: DLRadioButton]()
    var _typeTags: [ItemType: [String]]?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.title = "Filter Spots"
        self.view.backgroundColor = UIColor.white
        
        /**
         * Data
         */
        if let sections: [ItemType] = self._sectionTitles {
            for section in sections {
                self._checkboxes[section.rawValue] = createCheckbox(isSelected: true)
            }
        }
        
        /**
         * Button
         */
        let buttonHeight: CGFloat = 48
        let buttonPadding: CGFloat = 16
        let buttonPaddingRight: CGFloat = 46
        let buttonwView = UIView()
        buttonwView.frame = CGRect(x: 0, y: self.view.bounds.height - buttonHeight - buttonPadding * 2, width: self.view.bounds.width, height: buttonHeight + buttonPadding * 2)
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
        
        
        /**
         * Tableview
         */
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonHeight + buttonPadding * 2, right: 0)
        self.tableView.backgroundColor = UIColor.white
        self.tableView.frame = self.view.bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TagsTableCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sectionCell")
        /**
         * Add subviews
         */
        self.view.addSubview(self.tableView)
        self.view.addSubview(buttonwView)
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
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00), height: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), // UIFont(name: "Avenir-Heavy", size: 12)!,
            NSForegroundColorAttributeName: UIColor.black,
            NSBackgroundColorAttributeName: UIColor.clear,
            NSKernAttributeName: 0.0,
        ]
        
        // Cancel bar button item
        let cancelImage: UIImage = StyleKitName.imageOfCancel
        let cancelButton = UIBarButtonItem(image: cancelImage, style: .plain, target: self, action: #selector(dismiss(sender:)))
        let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpace.width = 12.0
        self.navigationItem.leftBarButtonItems = [negativeSpace, cancelButton]
        self.navigationItem.title = "Filter"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helpers
    func dismiss(sender: UITabBarItem){
        self.dismiss(animated: true, completion: nil)
    }

}

extension TagsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
}
extension TagsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sectionsCount: Int = self._sectionTitles?.count {
            return sectionsCount
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let sectionsCount: Int = self._sectionTitles?.count {
                return sectionsCount
            }
        default:
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            // Show section names: Animals, Attractions, Community, ...
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath)
            cell.selectionStyle = .default
            let accView = UIView()
            accView.backgroundColor = UIColor.clear
            let checkBoxHeight: CGFloat = 42
            let title = self._sectionTitles?[indexPath.row].rawValue
            if let checkBox: DLRadioButton = self._checkboxes[title!] {
                checkBox.frame = CGRect(x: 0, y: cell.bounds.height / 2 - checkBoxHeight / 2, width: checkBoxHeight, height: checkBoxHeight)
                accView.addSubview(checkBox)
            }
            cell.textLabel?.attributedText = NSAttributedString(
                string: (title?.firstCharacterUpperCase())!,
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName: UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00), // Charcoal //UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            
            cell.accessoryView = accView
            cell.accessoryView?.frame = CGRect(x: cell.bounds.height, y: cell.bounds.width - checkBoxHeight, width: checkBoxHeight, height: cell.bounds.height)
            
            return cell
        default:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TagsTableCell
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? TagsTableCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? TagsTableCell else { return }
        storedOffsets[indexPath.section] = tableViewCell.collectionViewOffset
    }
}

/**
 * CollectionView
 */
extension TagsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let itemType: ItemType = self._sectionTitles?[section], let tags: [String] = self._typeTags?[itemType] {
            return tags.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
        
        if let itemType: ItemType = self._sectionTitles?[indexPath.section], let tags: [String] = self._typeTags?[itemType] {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 49, height: 49))
            label.text = tags[indexPath.row]
            cell.contentView.addSubview(label)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}

/**
 * SAMPLE DATA
 */
func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 15
    let numberOfItemsPerRow = 20
    
    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

extension UIColor {
    
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}
