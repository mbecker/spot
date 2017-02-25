//
//  FilterViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/23/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import RealmSwift
import DLRadioButton
import SwiftDate

protocol FilterProtocol {
    func saveFiler(tags: [String]?, sections: [RealmParkSection: Bool]?, lowerDate: DateInRegion?, upperDate: DateInRegion?)
}

class FilterViewController: UIViewController, ExpandingTransitionPresentingViewController {
    // Create a new DateInRegion which represent the current moment (Date()) in current device's local settings
    
    let colorSectionHeadline = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00) // Black ...
    let colorSectionSubHeadline = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
    let colorSectionAccessoryLabel = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00) // Persian Green
    let colorBackgroundView = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
    
    
    // Data public
    // var _realmPark: RealmPark?
    var _realmParkSections: [RealmParkSection]?
    var _weightedTags: [ItemType :[String: Int]]?
    var delegate: FilterProtocol?
    
    // Data private
    fileprivate let _dataAllTags                = Tags()
    fileprivate var _dataAllTagsForSection      = [Int : [String]]()
    fileprivate var _dataSelectedTagsForSection = [Int : [String]]()
    fileprivate var _dataShowAllTagsForSection  = [Int: Bool]()
    fileprivate var _dataCheckboxes             = [Int: DLRadioButton]()
    fileprivate var _dataRangeSliders           = [Int: RangeSlider]()
    fileprivate var _dataTimeTextForSection     = [Int : String]()
    fileprivate var _dataDateNow                = DateInRegion()
    fileprivate var _dataLowerDate: DateInRegion?
    fileprivate var _dataUpperDate: DateInRegion?
    
    // Tableview
    let tableView   = UITableView(frame: CGRect.zero, style: .grouped)
    let doneButton  = SaveCancelButton(title: "Save", position: .Right, type: .Reverted, showimage: false)
    var storedOffsets = [Int: CGFloat]()
    
    // View & Transition
    let transition = ExpandingCellTransition(type: .Presenting)
    var selectedIndexPath: IndexPath?
    private var shadowImageView: UIImageView?
    
    
    
    func createCheckbox(isSelected: Bool) -> DLRadioButton {
        let checkBox = DLRadioButton()
        checkBox.backgroundColor = UIColor.clear
        checkBox.iconStrokeWidth = 1.0
        checkBox.iconSize = 24
        checkBox.isIconSquare = true
        checkBox.isSelected = isSelected
        checkBox.isMultipleSelectionEnabled = true
        checkBox.iconColor = UIColor.lightGray
        checkBox.indicatorColor = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00)  // Perian green
        checkBox.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        return checkBox
    }
    
    func createRangeSlider(lowerValue: Double, upperValue: Double) -> RangeSlider {
        let rangeSlider = RangeSlider(frame: CGRect.zero)
        rangeSlider.trackTintColor          = self.colorBackgroundView
        rangeSlider.trackHighlightTintColor = self.colorSectionAccessoryLabel
        rangeSlider.thumbTintColor      = UIColor.white
        rangeSlider.thumbBorderColor    = self.colorSectionAccessoryLabel
        rangeSlider.thumbBorderWidth    = 1.0
        rangeSlider.curvaceousness = 1.0
        rangeSlider.lowerValue = lowerValue
        rangeSlider.upperValue = upperValue
        return rangeSlider
        /*
         minimumValue : The minimum possible value of the range
         maximumValue : The maximum possible value of the range
         lowerValue : The value corresponding to the left thumb current position
         upperValue : The value corresponding to the right thumb current position
         trackTintColor : The track color
         trackHighlightTintColor : The color of the section of the track located between the two thumbs
         thumbTintColor: The thumb color
         thumbBorderColor: The thumb border color
         thumbBorderWidth: The width of the thumb border
         curvaceousness : From 0.0 for square thumbs to 1.0 for circle thumbs
        */
    }
    
    func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        var lowerDate: DateInRegion!
        var upperDate: DateInRegion!
        var lowerValue: String = "todays"
        var upperValue: String = ""
        switch rangeSlider.lowerValue {
        case 0.0..<0.1:
            lowerValue = "today"
            lowerDate = self._dataDateNow
        case 0.1..<0.2:
            lowerValue = "yesterday"
            lowerDate = self._dataDateNow - 1.days
        case 0.2..<0.3:
            lowerValue = "2 days ago"
            lowerDate = self._dataDateNow - 2.days
        case 0.3..<0.4:
            lowerValue = "3 days ago"
            lowerDate = self._dataDateNow - 4.days
        case 0.4..<0.5:
            lowerValue = "4 days ago"
            lowerDate = self._dataDateNow - 4.days
        case 0.5..<0.6:
            lowerValue = "5 days ago"
            lowerDate = self._dataDateNow - 5.days
        case 0.6..<0.7:
            lowerValue = "6 days ago"
            lowerDate = self._dataDateNow - 6.days
        case 0.7..<0.8:
            lowerValue = "1 week ago"
            lowerDate = self._dataDateNow - 1.weeks
        case 0.8..<0.9:
            lowerValue = "2 weeks ago"
            lowerDate = self._dataDateNow - 2.weeks
        case 0.9...1.0:
            lowerValue = "1 month"
            lowerDate = self._dataDateNow - 1.months
        default:
            lowerValue = "today"
            lowerDate = self._dataDateNow
        }
        
        switch rangeSlider.upperValue {
        case 0.0..<0.1:
            upperValue = "yesterday"
            upperDate = self._dataDateNow - 1.days
        case 0.1..<0.2:
            upperValue = "2 days ago"
            upperDate = self._dataDateNow - 2.days
        case 0.2..<0.3:
            upperValue = "3 days ago"
            upperDate = self._dataDateNow - 3.days
        case 0.3..<0.4:
            upperValue = "4 days ago"
            upperDate = self._dataDateNow - 4.days
        case 0.4..<0.5:
            upperValue = "5 days ago"
            upperDate = self._dataDateNow - 5.days
        case 0.5..<0.6:
            upperValue = "6 days ago"
            upperDate = self._dataDateNow - 6.days
        case 0.6..<0.7:
            upperValue = "1 week ago"
            upperDate = self._dataDateNow - 1.weeks
        case 0.7..<0.8:
            upperValue = "2 week ago"
            upperDate = self._dataDateNow - 2.weeks
        case 0.8..<0.9:
            upperValue = "1 month ago"
            upperDate = self._dataDateNow - 1.months
        case 0.9...1.0:
            upperValue = "all"
            upperDate = self._dataDateNow - 10.years
        default:
            upperValue = "yesterday"
            upperDate = self._dataDateNow - 1.days
        }
        self._dataLowerDate = lowerDate
        self._dataUpperDate = upperDate
        self._dataTimeTextForSection[rangeSlider.tag] = "between \(lowerValue) and \(upperValue)"
    }
    
    func saveFilter() {
        var tags: [String]?
        if let selectedTagsForSections: [Int: [String]] = self._dataSelectedTagsForSection {
            for (key, selectedTags) in selectedTagsForSections {
                for selectedTag in selectedTags {
                    if tags == nil {
                        tags = [String]()
                    }
                    tags!.append(selectedTag)
                }
            }
        }
        
        var sections =  [RealmParkSection: Bool]()
        if let realmParkSection: [RealmParkSection] = self._realmParkSections {
            var i = 0
            for section in realmParkSection {
                switch section.getType() {
                case .live, .community:
                    if let checkBox: DLRadioButton = self._dataCheckboxes[i] {
                        if checkBox.isSelected {
                            sections[section] = true
                        } else {
                            sections[section] = false
                        }
                        
                    }
                    
                default:
                    sections[section] = true
                }
                i = i + 1
            }
        }
        
        self.delegate?.saveFiler(tags: tags, sections: sections, lowerDate: self._dataLowerDate, upperDate: self._dataUpperDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        
        self.view.backgroundColor = UIColor.white
        
        /**
         * Data model
         */
        print(self._weightedTags)
        if let sections: [RealmParkSection] = self._realmParkSections {
            for section in sections {
                
                if let i = sections.index(of: section) {
                    switch section.getType() {
                    case .live:
                        self._dataCheckboxes[i]         = createCheckbox(isSelected: false)
                        self._dataRangeSliders[i]       = createRangeSlider(lowerValue: 0.00, upperValue: 0.35)
                        self._dataTimeTextForSection[i] = "between today and 3 days ago"
                        self._dataLowerDate             = self._dataDateNow
                        self._dataUpperDate             = self._dataDateNow - 3.days
                    case .community:
                        self._dataCheckboxes[i]         = createCheckbox(isSelected: true)
                    default:
                        self._dataShowAllTagsForSection[i]  = false
                        self._dataAllTagsForSection[i]      = self._dataAllTags.getKeys(type: section.getType())
                        self._dataSelectedTagsForSection[i] = [String]()
                        print(section.getType())
                        print(self._weightedTags?[section.getType()])
                        if let weightedSelectedTags: [String: Int] = self._weightedTags?[section.getType()] {
                            for (tag, _) in weightedSelectedTags {
                                self._dataSelectedTagsForSection[i]?.append(tag)
                            }
                        }
                    }
                }
                
            }
        }
        
        
        
        
        
        
        /**
         * Tableview
         */
        self.tableView.frame            = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.tableView.tableHeaderView  = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.01))
        self.tableView.contentInset     = UIEdgeInsets(top: 0, left: 0, bottom: doneButton.bounds.height, right: 0)
        self.tableView.backgroundColor  = UIColor.white
        self.tableView.allowsSelection  = true
        self.tableView.separatorStyle   = .none
        self.tableView.sectionFooterHeight = 0.0
        self.tableView.sectionHeaderHeight = 0.0
        self.tableView.delegate     = self
        self.tableView.dataSource   = self
        self.tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(CheckboxCell.self, forCellReuseIdentifier: "checkboxCell")
        self.tableView.register(RangeSliderCell.self, forCellReuseIdentifier: "rangesliderCell")
        self.tableView.register(TagsTableCell.self, forCellReuseIdentifier: "collectionViewCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        
        self.doneButton.addTarget(self, action: #selector(self.saveFilter), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.doneButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigationbar
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor    = UIColor.white
        self.navigationController?.navigationBar.barTintColor       = UIColor.white
        self.navigationController?.navigationBar.tintColor          = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00) // Charcoal
        self.navigationController?.navigationBar.titleTextAttributes = [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium), // UIFont(name: "Avenir-Heavy", size: 12)!,
                NSForegroundColorAttributeName: UIColor.black,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 2.8,
            ]
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor.white, height: 0)
        
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
        if self.presentingViewController != nil{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: ExpandingTransitionPresentingViewController
    public func expandingTransitionTargetViewForTransition(transition: ExpandingCellTransition) -> UIView! {
        if let indexPath = self.selectedIndexPath {
            return self.tableView.cellForRow(at: indexPath)
        }
        else {
            return nil
        }
    }

}

/**
 * Transition
 */
extension FilterViewController : UINavigationControllerDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transition
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transition
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is FilterViewController {
            transition.type = .Presenting
        } else {
            transition.type = .Dismissing
        }
        return self.transition
    }
    
}
/**
 * AnimalFormCollectionDelegate
 */
extension FilterViewController : AnimalFormCollectionDelegate {
    
    public func saveItems(index: [IndexPath], items: [String]) {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

/**
 * TableView
 */
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 49 * 1.5
        default:
            if let section: RealmParkSection = self._realmParkSections?[safe: indexPath.section], section.getType() != .community {
                
                switch section.getType() {
                case .live:
                    return 49 * 2.25
                case .animals, .attractions:
                    let showLines = 2
                    let numberOfItems: Int = (self._dataAllTagsForSection[indexPath.section]?.count)!
                    let sizeOfCollectionView = self.view.bounds.width - 28 * 2
                    let sizeOfItems = CGSize(width: 68 + 8, height: 68 + 8) // item size + minimumLineSpacing + minimumInteritemSpacing
                    var heightOfShowLines = CGFloat(showLines) * sizeOfItems.height
                    
                    if let showAllTag: Bool = self._dataShowAllTagsForSection[indexPath.section], showAllTag == true {
                        let numberOfItemsPerLine: Int = Int(sizeOfCollectionView / sizeOfItems.width)
                        let numberOfLines = numberOfItems / numberOfItemsPerLine
                        heightOfShowLines = CGFloat(numberOfLines) * sizeOfItems.height
                    }
                    return heightOfShowLines + 8 // the "8" is for the padding to the top; see TagsTableCell: The collectionView has an inset top of "8"
                default:
                    return 0
                }
                
                
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let sections: [RealmParkSection] = self._realmParkSections, section == sections.count - 1 {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.frame = CGRect.zero
        view.backgroundColor = UIColor.yellow
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self._realmParkSections?.count {
            let view = UIView()
            view.frame = CGRect.zero
            return view
        }
        let view = UIView()
        let border = UIView()
        border.frame = CGRect(x: 28, y: 0, width: self.view.bounds.width - 56, height: 1)
        border.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00)
        view.addSubview(border)
        return view
    }
}
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let section: RealmParkSection = self._realmParkSections?[safe: indexPath.section] {
                switch section.getType() {
                case .live, .community:
                    if let checkbox: DLRadioButton = self._dataCheckboxes[indexPath.section] {
                        checkbox.isSelected = !checkbox.isSelected
                    }
                default:
                    self._dataShowAllTagsForSection[indexPath.section] = !self._dataShowAllTagsForSection[indexPath.section]!
                    self.tableView.reloadRows(at: [[indexPath.section, 0]], with: .none)
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.tableView.scrollToRow(at: [indexPath.section, 0], at: .top, animated: true)
                }
            }
        default:
            return
        }
        
        // self.tableView.reloadRows(at: [[indexPath.section, 1]], with: .none)
        
//        if let section: RealmParkSection = self._realmParkSections[safe: indexPath.section] {
//            self.selectedIndexPath = indexPath
//            let selectedCells = [IndexPath]()
//            let controller = AnimalFormCollections(title: "Select " + section.name.firstCharacterUpperCase(), type: section.getType(), selectedCells: selectedCells)
//            controller.delegate = self
//            controller.modalPresentationStyle = .custom
//            controller.modalPresentationCapturesStatusBarAppearance = true
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count: Int = self._realmParkSections?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section: RealmParkSection = self._realmParkSections?[safe: section] {
            switch section.getType() {
            case .community:
                return 1
            default:
                return 2
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let section: RealmParkSection = self._realmParkSections?[safe: indexPath.section] {
            
            switch indexPath.row {
            case 0:
                switch section.getType() {
                case .live, .community:
                    // Cell: .community (with checkbox)
                    let cell = tableView.dequeueReusableCell(withIdentifier: "checkboxCell", for: indexPath) as! CheckboxCell
                    if let checkBox: DLRadioButton = self._dataCheckboxes[indexPath.section] {
                        cell.checkbox = checkBox
                    }
                    let name = section.getType().rawValue.firstCharacterUpperCase()
                    print(name)
                    cell.textLabel?.attributedText = NSAttributedString(
                        string: name,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
                            NSForegroundColorAttributeName: self.colorSectionHeadline,
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.8,
                            ])
                    
                    return cell
                default:
                    // Cell: .animals & .attractions
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FilterTableViewCell
                    cell.backgroundColor = UIColor.white
                    let selectedBackgroundView = UIView()
                    selectedBackgroundView.backgroundColor = self.colorBackgroundView
                    cell.selectedBackgroundView = selectedBackgroundView
                    
                    cell.textLabel?.attributedText = NSAttributedString(
                        string: section.name,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
                            NSForegroundColorAttributeName: self.colorSectionHeadline,
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.8,
                            ])
                    
                    
                    
                    var titleForShowOrHideAll = "Show All"
                    if let sectionShowAllTags: Bool = self._dataShowAllTagsForSection[indexPath.section], sectionShowAllTags == true {
                        titleForShowOrHideAll = "Hide All"
                    }
                    cell.accessoryLabel?.attributedText =  NSAttributedString(
                        string: titleForShowOrHideAll,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
                            NSForegroundColorAttributeName: self.colorSectionAccessoryLabel,
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.8,
                            ])
                    let size = NSAttributedString(
                        string: titleForShowOrHideAll,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
                            NSKernAttributeName: 0.8,
                            ]).size()
                    cell.accessoryLabel?.frame = CGRect(x: cell.bounds.width - size.width - 28, y: cell.bounds.height / 2 - size.height / 2, width: size.width, height: size.height)
                    return cell
                    
                } // Swicth section.getType() for row == 1 (the title row)
                
            default: // indexPath.row == 2
                switch section.getType() {
                case .live:
                    if let rangeSlider: RangeSlider = self._dataRangeSliders[indexPath.section] {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "rangesliderCell", for: indexPath) as! RangeSliderCell
                        cell.selectionStyle = .none
                        // cell.contentView.frame = cell.bounds
                        // rangeSlider.frame = CGRect(x: 28, y: cell.bounds.height - 31 - 8, width: cell.bounds.width - 28 * 2, height: 31)
                        rangeSlider.tag = indexPath.section
                        rangeSlider.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .editingDidEnd)
                        
                        cell.rangeSlider = rangeSlider
                        
                        cell.textLabel?.attributedText = NSAttributedString(
                            string: self._dataTimeTextForSection[indexPath.section]!,
                            attributes: [
                                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight),
                                NSForegroundColorAttributeName: self.colorSectionSubHeadline,
                                NSBackgroundColorAttributeName: UIColor.white,
                                NSKernAttributeName: 0.8,
                                ])
                        
                        return cell
                    }
                default:
                    // Cell: CollectionViewCell
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "collectionViewCell", for: indexPath) as! TagsTableCell
                    cell.selectionStyle = .none
                    return cell
                }
                
            }
       
        } // if section exists for indexPath.section
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tagsTableCell = cell as? TagsTableCell else { return }
        tagsTableCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        tagsTableCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
        if let tagsForSection: [String] = self._dataAllTagsForSection[indexPath.section], let selectedTagsForSection: [String] = self._dataSelectedTagsForSection[indexPath.section] {
            tagsTableCell.setSelectedRows(tags: tagsForSection, selectedTags: selectedTagsForSection)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tagsTableCell = cell as? TagsTableCell else { return }
        storedOffsets[indexPath.section] = tagsTableCell.collectionViewOffset
    }
    
}

/**
 * CollectionView
 */
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let tagsKey: [String] = self._dataAllTagsForSection[collectionView.tag] {
            return tagsKey.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if let section: RealmParkSection = self._realmParkSections?[safe: collectionView.tag], let tagsKey: [String] = self._dataAllTagsForSection[collectionView.tag], let tag: String = tagsKey[safe: indexPath.row], let tagsForImage: [String: String] = self._dataAllTags.getTags(type: section.getType()), let imageString = tagsForImage[tag]  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! TagCell
            DispatchQueue.global(qos: .userInitiated).async {
                
                let tagImage = AssetManager.getImage(imageString).withRenderingMode(.alwaysTemplate)
                let tagTitle = tag.firstCharacterUpperCase()
                
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                    cell.textLabel.attributedText = NSAttributedString(
                        string: tagTitle,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin),
                            NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00),
                            NSKernAttributeName: 0.6,
                            ])
                    let textLabelSize = cell.textLabel.attributedText != nil ? cell.textLabel.attributedText!.size() : CGSize(width: 27.806250000000006, height: 14.3203125)
                    cell.textLabel.frame = CGRect(x: cell.bounds.width / 2 - textLabelSize.width / 2, y: cell.bounds.height - textLabelSize.height, width: textLabelSize.width, height: textLabelSize.height)
                    cell.imageView.image = tagImage
                    
                    if cell.isSelected {
                        cell.borderView.backgroundColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00) // green ...
                        cell.borderView.layer.borderColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00).cgColor // green ...
                        cell.imageView.tintColor = UIColor.white
                        cell.textLabel.textColor = UIColor.black
                    } else {
                        cell.borderView.backgroundColor = UIColor.clear
                        cell.borderView.layer.borderColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6).cgColor
                        cell.imageView.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
                        cell.textLabel.textColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
                    }
                    
                }
                
            }
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! TagCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        if let tagsForSection: [String] = self._dataAllTagsForSection[collectionView.tag], let tag: String = tagsForSection[safe: indexPath.row], let selectedTags: [String] = self._dataSelectedTagsForSection[collectionView.tag] {
            
            if !selectedTags.contains(tag) {
                self._dataSelectedTagsForSection[collectionView.tag]!.append(tag)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let tagsForSection: [String] = self._dataAllTagsForSection[collectionView.tag], let tag: String = tagsForSection[safe: indexPath.row], let selectedTags: [String] = self._dataSelectedTagsForSection[collectionView.tag] {
            
            if selectedTags.contains(tag) {
                self._dataSelectedTagsForSection[collectionView.tag]! = self._dataSelectedTagsForSection[collectionView.tag]!.filter{$0 != tag}
            }
            
        }
    }
}
