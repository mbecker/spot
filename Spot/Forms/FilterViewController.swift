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
    func saveFilter(filterStruct: FilterStruct)
    func saveFiler(tags: [String]?, sections: [RealmParkSection: Bool]?, lowerDate: DateInRegion?, upperDate: DateInRegion?)
    func dismiss()
}

enum FilterDateAction {
    case upperDate
    case lowerDate
    case both
    case none
}

struct FilterDate {
    var lowerDate:  DateInRegion?
    var upperDate:  DateInRegion?
    var describing: String = ""
    
    init(lowerDate: DateInRegion, upperDate: DateInRegion){
        self.lowerDate = lowerDate
        self.upperDate = upperDate
    }
    
    mutating func setDescribing(lowerString: String, upperString: String){
        self.describing = "between \(lowerString) and \(upperString)"
    }
    
    mutating func setDate(lowerDate: DateInRegion?, upperDate: DateInRegion?){
        self.lowerDate = lowerDate
        self.upperDate = upperDate
    }
    
    func isSet() -> Bool {
        if upperDate != nil || lowerDate != nil {
            return true
        } else {
            return false
        }
    }
    
    func getAction() -> FilterDateAction {
        if self.lowerDate == nil && self.upperDate == nil {
            return .both
        }
        if self.lowerDate == nil {
            return .lowerDate
        }
        if self.upperDate == nil {
            return .upperDate
        }
        return .none
    }
    
    func getValue() -> (lowerValue: Double, upperValue: Double){
        return (0.00, 0.00)
    }
}

struct FilterTag {
    var tag: String
    var count: Int
    
    init(tag: String, count: Int) {
        self.tag    = tag
        self.count  = count
    }
    
    mutating func increment(){
        self.count = self.count + 1
    }
}
struct FilterSection {
    var selectedTags: [FilterTag] = [FilterTag]()
    var typeTags: [String]?
    var tagImages: [String: String]?
    var isEnabled: Bool
    var isShowTags = false
    var realmParkSection: RealmParkSection
    
    init(realmParkSection: RealmParkSection, isEnabled: Bool){
        self.realmParkSection   = realmParkSection
        self.isEnabled          = isEnabled
        self.typeTags           = Tags().getKeys(type: realmParkSection.getType())
        self.tagImages          = Tags().getTags(type: realmParkSection.getType())
    }
    
    mutating func setEnabled(isEnabled: Bool){
        self.isEnabled = isEnabled
    }
    
    func getSelectedTags() -> [String] {
        var tagsAll = [String]()
        for tag in self.selectedTags {
            tagsAll.append(tag.tag)
        }
        return tagsAll
    }
    
    func isAllTagsSelected() -> Bool {
        if self.selectedTags.count == 0 || self.typeTags == nil {
            return false
        }
        if self.selectedTags.count == self.typeTags!.count {
            return true
        } else {
            return false
        }
    }
    
    func isParkItem2TagsInSelectedTags(item2: ParkItem2) -> Bool {
        if let sectionSelectedTags: [String] = self.getSelectedTags() {
            for tag in item2.tags {
                if sectionSelectedTags.contains(tag) {
                    return true
                }
            }
        }
        return false
    }
    
    mutating func addTag(tag: String, count: Int){
        
        var tagIsInSelectedTags = false
        for (index, filterTag) in self.selectedTags.enumerated() {
            if filterTag.tag == tag {
                self.selectedTags[index].increment()
                tagIsInSelectedTags = true
            }
        }
        if !tagIsInSelectedTags {
            let filterTag = FilterTag(tag: tag, count: count)
            self.selectedTags.append(filterTag)
        }
        
    }
    
    mutating func removeSelectedTag(tag: String){
        var i = 0
        for selectedTag in self.selectedTags {
            if selectedTag.tag == tag {
                self.selectedTags.remove(at: i)
                return
            }
            i = i + 1
        }
    }
    
    mutating func toggleIsShowTags() {
        self.isShowTags = !self.isShowTags
    }
}
struct FilterStruct {
    var isActive: Bool
    var isLive: Bool
    var timerange: FilterDate
    var filterSections: [FilterSection]
    
    init(filterSections: [FilterSection], isActive: Bool, timerange: FilterDate, isLive: Bool) {
        self.filterSections  = filterSections
        self.isActive           = isActive
        self.timerange          = timerange
        self.isLive             = isLive
    }
    
}

class FilterViewController: UIViewController, ExpandingTransitionPresentingViewController {
    // Create a new DateInRegion which represent the current moment (Date()) in current device's local settings
    
    let colorSectionHeadline = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00) // Black ...
    let colorSectionSubHeadline = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00).withAlphaComponent(0.6)
    let colorSectionAccessoryLabel = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00) // Persian Green
    let colorBackgroundView = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
    
    
    // Data public
    // var _realmPark: RealmPark?
    var _filterStruct: FilterStruct!
//    var _realmParkSections: [RealmParkSection]?
//    var _enabledSections: [String: Bool]?
//    var _weightedTags: [ItemType :[String: Int]]?
    var delegate: FilterProtocol?
//    var _dataLowerDate: DateInRegion?
//    var _dataUpperDate: DateInRegion?
    
    // Data private
//    fileprivate let _dataAllTags                = Tags()
//    fileprivate var _dataAllTagsForSection      = [Int : [String]]()
//    fileprivate var _dataSelectedTagsForSection = [Int : [String]]()
//    fileprivate var _dataShowAllTagsForSection  = [Int: Bool]()
    fileprivate var _dataCheckboxes             = [Int: DLRadioButton]()
    fileprivate var _dataRangeSliders           = [Int: RangeSlider]()
//    fileprivate var _dataTimeTextForSection     = [Int : String]()
    fileprivate var _dataDateNow                = DateInRegion()
    
    
    // Tableview
    let tableView   = UITableView(frame: CGRect.zero, style: .grouped)
    let doneButton  = SaveCancelButton(title: "Save", position: .Right, type: .Reverted, showimage: false)
    var storedOffsets = [Int: CGFloat]()
    
    // View & Transition
    let transition = ExpandingCellTransition(type: .Presenting)
    var selectedIndexPath: IndexPath?
    private var shadowImageView: UIImageView?
    
    
    
    func createCheckbox(tag: Int, isSelected: Bool, indicatorColor: UIColor = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00)) -> DLRadioButton {
        let checkBox = DLRadioButton()
        checkBox.backgroundColor = UIColor.clear
        checkBox.iconStrokeWidth = 1.0
        checkBox.iconSize = 24
        checkBox.isIconSquare = true
        checkBox.isSelected = isSelected
        checkBox.isMultipleSelectionEnabled = true
        checkBox.iconColor = UIColor.lightGray
        checkBox.indicatorColor = indicatorColor // Perian green
        checkBox.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        checkBox.tag = tag
        checkBox.addTarget(self, action: #selector(selectCheckbox), for: UIControlEvents.touchUpInside);
        return checkBox
    }
    
    @objc private func selectCheckbox(checkBox : DLRadioButton) {
        if checkBox.tag == 0 {
            self._filterStruct.isLive = checkBox.isSelected
        } else {
            self._filterStruct.filterSections[checkBox.tag - 1].setEnabled(isEnabled: checkBox.isSelected)
            print(self._filterStruct.filterSections[checkBox.tag - 1].isEnabled)
            print("---")
        }
    }
    
    
    
    func createRangeSlider(lowerValue: Double, upperValue: Double) -> RangeSlider {
        let rangeSlider = RangeSlider(frame: CGRect.zero)
        rangeSlider.trackTintColor      = self.colorBackgroundView
        rangeSlider.thumbTintColor      = UIColor.white
        rangeSlider.thumbBorderWidth    = 1.0
        rangeSlider.curvaceousness      = 1.0
        rangeSlider.lowerValue          = lowerValue
        rangeSlider.upperValue          = upperValue
        
        if lowerValue < 0.1 && upperValue > 0.9 {
            rangeSlider.trackHighlightTintColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
            rangeSlider.thumbBorderColor        = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
        } else {
            rangeSlider.trackHighlightTintColor = self.colorSectionAccessoryLabel
            rangeSlider.thumbBorderColor        = self.colorSectionAccessoryLabel
        }
        
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
        var lowerDate: DateInRegion?
        var upperDate: DateInRegion?
        var lowerValue: String = "todays"
        var upperValue: String = ""
        
        switch rangeSlider.lowerValue {
        case 0.0..<0.1:
            lowerValue = "today"
            lowerDate = nil // self._dataDateNow
        case 0.1..<0.2:
            lowerValue = "yesterday"
            lowerDate = self._dataDateNow - 1.days
        case 0.2..<0.3:
            lowerValue = "2 days ago"
            lowerDate = self._dataDateNow - 2.days
        case 0.3..<0.4:
            lowerValue = "3 days ago"
            lowerDate = self._dataDateNow - 3.days
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
            upperDate = nil //self._dataDateNow - 10.years
        default:
            upperValue = "yesterday"
            upperDate = self._dataDateNow - 1.days
        }
        
        self._filterStruct.timerange.setDate(lowerDate: lowerDate, upperDate: upperDate)
        self._filterStruct.timerange.setDescribing(lowerString: lowerValue, upperString: upperValue)
    }
    
    func saveFilter() {
//        var tags: [String]?
//        
//        for (_, selectedTags) in self._dataSelectedTagsForSection {
//            for selectedTag in selectedTags {
//                if tags == nil {
//                    tags = [String]()
//                }
//                tags!.append(selectedTag)
//            }
//        }
//        
//        var sections =  [RealmParkSection: Bool]()
//        if let realmParkSection: [RealmParkSection] = self._realmParkSections {
//            var i = 0
//            for section in realmParkSection {
//                switch section.getType() {
//                case .live, .community:
//                    if let checkBox: DLRadioButton = self._dataCheckboxes[i] {
//                        if checkBox.isSelected {
//                            sections[section] = true
//                        } else {
//                            sections[section] = false
//                        }
//                        
//                    }
//                    
//                default:
//                    sections[section] = true
//                }
//                i = i + 1
//            }
//        }
//        
//        self.delegate?.saveFiler(tags: tags, sections: sections, lowerDate: self._dataLowerDate, upperDate: self._dataUpperDate)
        self._filterStruct.isActive = true
        self.delegate?.saveFilter(filterStruct: self._filterStruct)
    }
    
    func checkDateInterval(lowerDate: DateInRegion, upperDate: DateInRegion) -> (lowerSlider: Double, lowerString: String, lowerDate: DateInRegion?, upperSlider: Double, upperString: String, upperDate: DateInRegion?) {
        
        let now = DateInRegion() // 2016-11-30 10:37:23 +0000
        let sepreat = (now - lowerDate).in([.day,.hour,.minute]) // -3.days (3 days in the past)
        
        var lowerDateNew: DateInRegion!
        var lowerString: String = "today"
        var lowerSlider: Double!
        
        switch sepreat[.day]! {
        case 0..<1:
            lowerSlider = 0.00
            lowerString = "today"
            lowerDateNew = nil //self._dataDateNow
        case 1..<2:
            lowerSlider = 0.11
            lowerString = "yesterday"
            lowerDateNew = self._dataDateNow - 1.days
        case 2..<3:
            lowerSlider = 0.21
            lowerString = "2 days ago"
            lowerDateNew = self._dataDateNow - 2.days
        case 3..<4:
            lowerSlider = 0.31
            lowerString = "3 days ago"
            lowerDateNew = self._dataDateNow - 3.days
        case 4..<5:
            lowerSlider = 0.41
            lowerString = "4 days ago"
            lowerDateNew = self._dataDateNow - 4.days
        case 5..<6:
            lowerSlider = 0.51
            lowerString = "5 days ago"
            lowerDateNew = self._dataDateNow - 5.days
        case 6..<7:
            lowerSlider = 0.61
            lowerString = "6 days ago"
            lowerDateNew = self._dataDateNow - 6.days
        case 7..<8:
            lowerSlider = 0.71
            lowerString = "1 week ago"
            lowerDateNew = self._dataDateNow - 1.weeks
        case 8..<(7*2)+1:
            lowerSlider = 0.81
            lowerString = "2 weeks ago"
            lowerDateNew = self._dataDateNow - 2.weeks
        default:
            lowerSlider = 0.91
            lowerString = "1 month"
            lowerDateNew = self._dataDateNow - 1.months
        }
        
        
        
        let sepreatUpper = (now - upperDate).in([.day,.hour,.minute]) // -3.days (3 days in the past)
        var upperDateNew: DateInRegion!
        var upperString: String = "yesterday"
        var upperSlider: Double!
        print(sepreatUpper)
        
        switch sepreatUpper[.day]! - 1 {
        case 0..<1:
            upperSlider = 0.09
            upperString = "yesterday"
            upperDateNew = self._dataDateNow - 1.days
        case 1..<2:
            upperSlider = 0.19
            upperString = "2 days ago"
            upperDateNew = self._dataDateNow - 2.days
        case 2..<3:
            upperSlider = 0.29
            upperString = "3 days ago"
            upperDateNew = self._dataDateNow - 3.days
        case 3..<4:
            upperSlider = 0.39
            upperString = "4 days ago"
            upperDateNew = self._dataDateNow - 4.days
        case 4..<5:
            upperSlider = 0.49
            upperString = "5 days ago"
            upperDateNew = self._dataDateNow - 5.days
        case 5..<6:
            upperSlider = 0.59
            upperString = "6 days ago"
            upperDateNew = self._dataDateNow - 6.days
        case 6..<(7*2)-1:
            upperSlider = 0.69
            upperString = "1 week ago"
            upperDateNew = self._dataDateNow - 1.weeks
        case (7*2)-1..<(7*3)-1:
            upperSlider = 0.79
            upperString = "2 week ago"
            upperDateNew = self._dataDateNow - 2.weeks
        case (7*3)-1..<(7*4)+4: // A month has in general 31 days; so 28+4
            upperSlider = 0.89
            upperString = "1 month ago"
            upperDateNew = self._dataDateNow - 1.months
        default:
            upperSlider = 1.0
            upperString = "all"
            upperDateNew = nil // self._dataDateNow - 10.years
        }
        
        return(lowerSlider, lowerString, lowerDateNew, upperSlider, upperString, upperDateNew)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        
        self.view.backgroundColor = UIColor.white
        
        /**
         * Data model
         */
        var interval: (lowerSlider: Double, lowerString: String, lowerDate: DateInRegion?, upperSlider: Double, upperString: String, upperDate: DateInRegion?)!
        switch self._filterStruct.timerange.getAction() {
        case .upperDate:
            interval = checkDateInterval(lowerDate: self._filterStruct.timerange.lowerDate!, upperDate: DateInRegion()-11.years)
        case .lowerDate:
            interval = checkDateInterval(lowerDate: DateInRegion(), upperDate: self._filterStruct.timerange.upperDate!)
        case .both:
            interval = checkDateInterval(lowerDate: DateInRegion(), upperDate: DateInRegion()-11.years)
        default:
            interval = checkDateInterval(lowerDate: self._filterStruct.timerange.lowerDate!, upperDate: self._filterStruct.timerange.upperDate!)
        }
        self._dataRangeSliders[0]       = createRangeSlider(lowerValue: interval.lowerSlider, upperValue: interval.upperSlider)
        self._filterStruct.timerange.setDescribing(lowerString: interval.lowerString, upperString: interval.upperString)
        self._filterStruct.timerange.setDate(lowerDate: interval.lowerDate, upperDate: interval.upperDate)
        self._dataCheckboxes[0]            = createCheckbox(tag: 0, isSelected: self._filterStruct.isLive, indicatorColor: UIColor.radicalRed)
        
        var i = 1
        for filterSection: FilterSection in self._filterStruct.filterSections {
            switch filterSection.realmParkSection.getType() {
            case .community:
                self._dataCheckboxes[i]         = createCheckbox(tag: i, isSelected: filterSection.isEnabled)
            default:
                break
            }
            i = i + 1
        }
        
//        if let sections: [RealmParkSection] = self._realmParkSections {
//            for section in sections {
//                
//                if let i = sections.index(of: section) {
//                    switch section.getType() {
//                    case .live:
//                        
//                        
//                        
//                        if let lowerDate: DateInRegion = self._dataLowerDate, let upperDate: DateInRegion = self._dataUpperDate {
//                            let interval = checkDateInterval(lowerDate: lowerDate, upperDate: upperDate)
//                            self._dataRangeSliders[i]       = createRangeSlider(lowerValue: interval.lowerSlider, upperValue: interval.upperSlider)
//                            self._dataTimeTextForSection[i] = "between \(interval.lowerString) and \(interval.upperString)"
//                            self._dataLowerDate             = interval.lowerDate
//                            self._dataUpperDate             = interval.upperDate
//                        } else if let lowerDate: DateInRegion = self._dataLowerDate, self._dataUpperDate == nil {
//                            let interval = checkDateInterval(lowerDate: lowerDate, upperDate: DateInRegion()-11.years)
//                            self._dataRangeSliders[i]       = createRangeSlider(lowerValue: interval.lowerSlider, upperValue: interval.upperSlider)
//                            self._dataTimeTextForSection[i] = "between \(interval.lowerString) and \(interval.upperString)"
//                            self._dataLowerDate             = interval.lowerDate
//                            self._dataUpperDate             = interval.upperDate
//                        } else if self._dataLowerDate == nil, let upperDate: DateInRegion = self._dataUpperDate {
//                            let interval = checkDateInterval(lowerDate: DateInRegion(), upperDate: upperDate)
//                            self._dataRangeSliders[i]       = createRangeSlider(lowerValue: interval.lowerSlider, upperValue: interval.upperSlider)
//                            self._dataTimeTextForSection[i] = "between \(interval.lowerString) and \(interval.upperString)"
//                            self._dataLowerDate             = interval.lowerDate
//                            self._dataUpperDate             = interval.upperDate
//                        } else {
//                            self._dataRangeSliders[i]       = createRangeSlider(lowerValue: 0.00, upperValue: 1)
//                            self._dataTimeTextForSection[i] = "between today and all"
//                            // self._dataLowerDate             = self._dataDateNow
//                            // self._dataUpperDate             = self._dataDateNow - 3.days
//                        }
//                        
//                        
//                        if let sectionEnabled: Bool = self._enabledSections?[section.key] {
//                            self._dataCheckboxes[i]         = createCheckbox(isSelected: sectionEnabled, indicatorColor: UIColor.radicalRed)
//                        } else {
//                            self._dataCheckboxes[i]         = createCheckbox(isSelected: false, indicatorColor: UIColor.radicalRed)
//                        }
//                        
//                    case .community:
//                        if let sectionEnabled: Bool = self._enabledSections?[section.key] {
//                            self._dataCheckboxes[i]         = createCheckbox(isSelected: sectionEnabled)
//                        } else {
//                            self._dataCheckboxes[i]         = createCheckbox(isSelected: false)
//                        }
//                    default:
//                        self._dataShowAllTagsForSection[i]  = false
//                        self._dataAllTagsForSection[i]      = self._dataAllTags.getKeys(type: section.getType())
//                        self._dataSelectedTagsForSection[i] = [String]()
//                        if let weightedSelectedTags: [String: Int] = self._weightedTags?[section.getType()] {
//                            for (tag, _) in weightedSelectedTags {
//                                self._dataSelectedTagsForSection[i]?.append(tag)
//                            }
//                        }
//                    }
//                }
//                
//            }
//        }
//        
        
        
        
        
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
        self.delegate?.dismiss()
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
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 49 * 1.5
            default:
                return 49 * 2.25
            }
        default:
            switch indexPath.row {
            case 0:
                return 49 * 1.5
            default:
                if let filterSection: FilterSection = self._filterStruct.filterSections[safe: indexPath.section - 1], filterSection.realmParkSection.getType() != .community {
                    
                    let showLines = 2
                    let numberOfItems: Int = filterSection.typeTags?.count != nil ? filterSection.typeTags!.count : 4
                    let sizeOfCollectionView = self.view.bounds.width - 28 * 2
                    let sizeOfItems = CGSize(width: 68 + 8, height: 68 + 8) // item size + minimumLineSpacing + minimumInteritemSpacing
                    var heightOfShowLines = CGFloat(showLines) * sizeOfItems.height
                    
                    if filterSection.isShowTags {
                        let numberOfItemsPerLine: Int = Int(sizeOfCollectionView / sizeOfItems.width)
                        let numberOfLines: CGFloat = ceil(CGFloat(numberOfItems) / CGFloat(numberOfItemsPerLine))
                        heightOfShowLines = numberOfLines * sizeOfItems.height
                    }
                    return heightOfShowLines + 8 // the "8" is for the padding to the top; see TagsTableCell: The collectionView has an inset top of "8"
                    
                    
                }
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self._filterStruct.filterSections.count - 1 {
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
        if section == self._filterStruct.filterSections.count {
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
        
        switch indexPath.section {
        case 0: // "Live"
            if let checkbox: DLRadioButton = self._dataCheckboxes[indexPath.section] {
                checkbox.isSelected = !checkbox.isSelected
                self._filterStruct.isLive = checkbox.isSelected
            }
        default: // .community, .attractions, .animals
            if let filterSection: FilterSection = self._filterStruct.filterSections[safe: indexPath.section - 1] {
                switch filterSection.realmParkSection.getType() {
                case .community:
                    if let checkbox: DLRadioButton = self._dataCheckboxes[indexPath.section] {
                        checkbox.isSelected = !checkbox.isSelected
                        self._filterStruct.filterSections[indexPath.section - 1].setEnabled(isEnabled: checkbox.isSelected)
                        print(self._filterStruct.filterSections[indexPath.section - 1].isEnabled)
                        print("---")
                    }
                default:
                    self._filterStruct.filterSections[indexPath.section - 1].toggleIsShowTags()
                    self.tableView.reloadRows(at: [[indexPath.section, 0]], with: .none)
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    if filterSection.isShowTags {
                        self.tableView.scrollToRow(at: [indexPath.section, 0], at: .top, animated: true)
                    }
                }
            }
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        print(self._filterStruct.filterSections.count)
        return self._filterStruct.filterSections.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        default:
            if let filterSection: FilterSection = self._filterStruct.filterSections[safe: section - 1] {
                switch filterSection.realmParkSection.getType() {
                case .community:
                    return 1
                default:
                    return 2
                }
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: // Live
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "checkboxCell", for: indexPath) as! CheckboxCell
                if let checkBox: DLRadioButton = self._dataCheckboxes[0] {
                    cell.checkbox = checkBox
                }
                let name = "Live"
                cell.textLabel?.attributedText = NSAttributedString(
                    string: name,
                    attributes: [
                        NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
                        NSForegroundColorAttributeName: self.colorSectionHeadline,
                        NSBackgroundColorAttributeName: UIColor.clear,
                        NSKernAttributeName: 0.8,
                        ])
                
                return cell
                
            default: // Timerange
                if let rangeSlider: RangeSlider = self._dataRangeSliders[indexPath.section] {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "rangesliderCell", for: indexPath) as! RangeSliderCell
                    cell.selectionStyle = .none
                    // cell.contentView.frame = cell.bounds
                    // rangeSlider.frame = CGRect(x: 28, y: cell.bounds.height - 31 - 8, width: cell.bounds.width - 28 * 2, height: 31)
                    rangeSlider.tag = indexPath.section
                    rangeSlider.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .editingDidEnd)
                    
                    cell.rangeSlider = rangeSlider
                    
                    cell.textLabel?.attributedText = NSAttributedString(
                        string: self._filterStruct.timerange.describing,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight),
                            NSForegroundColorAttributeName: self.colorSectionSubHeadline,
                            NSBackgroundColorAttributeName: UIColor.white,
                            NSKernAttributeName: 0.8,
                            ])
                    
                    return cell
                }

            }
            
        default: // indexPath.Section
            if let filterSection: FilterSection = self._filterStruct.filterSections[safe: indexPath.section - 1] {
                switch filterSection.realmParkSection.getType() {
                case .community:
                    switch indexPath.row {
                    case 0:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "checkboxCell", for: indexPath) as! CheckboxCell
                        if let checkBox: DLRadioButton = self._dataCheckboxes[indexPath.section] {
                            cell.checkbox = checkBox
                        }
                        let name = filterSection.realmParkSection.getType().rawValue.firstCharacterUpperCase()
                        cell.textLabel?.attributedText = NSAttributedString(
                            string: name,
                            attributes: [
                                NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
                                NSForegroundColorAttributeName: self.colorSectionHeadline,
                                NSBackgroundColorAttributeName: UIColor.clear,
                                NSKernAttributeName: 0.8,
                                ])
                        
                        return cell
                    default: // No 2. row for .community
                        break
                    }
                default: // .animals, .attractions
                    switch indexPath.row {
                    case 0:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FilterTableViewCell
                        cell.backgroundColor = UIColor.white
                        let selectedBackgroundView = UIView()
                        selectedBackgroundView.backgroundColor = self.colorBackgroundView
                        cell.selectedBackgroundView = selectedBackgroundView
                        
                        cell.textLabel?.attributedText = NSAttributedString(
                            string: filterSection.realmParkSection.getType().rawValue.firstCharacterUpperCase(),
                            attributes: [
                                NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
                                NSForegroundColorAttributeName: self.colorSectionHeadline,
                                NSBackgroundColorAttributeName: UIColor.clear,
                                NSKernAttributeName: 0.8,
                                ])
                        
                        // countLabel
                        let style = NSMutableParagraphStyle()
                        style.alignment = NSTextAlignment.center
                        cell.countLabel.attributedText = NSAttributedString(
                            string: "\(filterSection.getSelectedTags().count)",
                            attributes: [
                                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
                                NSForegroundColorAttributeName: UIColor.white,
                                NSBackgroundColorAttributeName: self.colorSectionAccessoryLabel,
                                NSKernAttributeName: 0.8,
                                NSParagraphStyleAttributeName: style
                            ])
                        cell.countLabel.backgroundColor = self.colorSectionAccessoryLabel
                        
                        // Accessory Labe: Show / hide all
                        let titleForShowOrHideAll = filterSection.isShowTags ? "Hide all" : "Show all"
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
                        
                    default: // indexPath.row
                        // Cell: CollectionViewCell
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "collectionViewCell", for: indexPath) as! TagsTableCell
                        cell.selectionStyle = .none
                        return cell
                    }
                    
                }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tagsTableCell = cell as? TagsTableCell else { return }
        tagsTableCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        tagsTableCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
        
        if let filterSection: FilterSection = self._filterStruct.filterSections[safe: indexPath.section - 1], let typeTags: [String] = filterSection.typeTags {
            tagsTableCell.setSelectedRows(tags: typeTags, selectedTags: filterSection.getSelectedTags())
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
        
        if let filterSection: FilterSection = self._filterStruct.filterSections[safe: collectionView.tag - 1], let typeTags: [String] = filterSection.typeTags {
            return typeTags.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if let filterSection: FilterSection = self._filterStruct.filterSections[safe: collectionView.tag - 1], let typeTags: [String] = filterSection.typeTags, let tag: String = typeTags[safe: indexPath.row], let tagsForImage: [String: String] = filterSection.tagImages, let imageString = tagsForImage[tag]  {
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
        
        if let filterSection: FilterSection = self._filterStruct.filterSections[safe: collectionView.tag - 1], let typeTags: [String] = filterSection.typeTags, let tag: String = typeTags[safe: indexPath.row], !filterSection.getSelectedTags().contains(tag) {
            self._filterStruct.filterSections[collectionView.tag - 1].addTag(tag: tag, count: 1)
            self.tableView.reloadRows(at: [[collectionView.tag, 0]], with: .none)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let filterSection: FilterSection = self._filterStruct.filterSections[safe: collectionView.tag - 1], let typeTags: [String] = filterSection.typeTags, let tag: String = typeTags[safe: indexPath.row], filterSection.getSelectedTags().contains(tag) {
            self._filterStruct.filterSections[collectionView.tag - 1].removeSelectedTag(tag: tag)
            self.tableView.reloadRows(at: [[collectionView.tag, 0]], with: .none)
        }
        
    }
}
