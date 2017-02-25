//
//  CheckboxCell.swift
//  Spot
//
//  Created by Mats Becker on 2/24/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import DLRadioButton

class CheckboxCell: UITableViewCell {
    
    var checkbox: DLRadioButton?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
        }
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
        } else {
            self.backgroundColor = UIColor.white
        }
        
    }
    
    override func layoutSubviews() {
        if let attributedTextSize: CGSize = self.textLabel?.attributedText?.size() {
            self.textLabel?.frame = CGRect(x: 28, y: self.bounds.height / 2 - attributedTextSize.height / 2, width: self.bounds.width, height: attributedTextSize.height)
        }
        if self.checkbox != nil {
            self.addSubview(self.checkbox!)
            self.checkbox!.frame = CGRect(x: self.bounds.width - 28 - 42, y: self.bounds.height / 2 - 42 / 2, width: 42, height: 42)
            if let attributedTextSize: CGSize = self.textLabel?.attributedText?.size() {
                self.textLabel?.frame = CGRect(x: 28, y: self.bounds.height / 2 - attributedTextSize.height / 2, width: self.bounds.width - self.checkbox!.bounds.width, height: attributedTextSize.height)
            }
            
        }
        
    }

}

class RangeSliderCell: UITableViewCell {
    
    var rangeSlider: RangeSlider?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
        }
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
        }
        
    }
    
    override func layoutSubviews() {
        if let attributedTextSize: CGSize = self.textLabel?.attributedText?.size() {
            // TextLabel frame
            self.textLabel?.frame = CGRect(x: 28, y: 0, width: self.bounds.width - 2 * 28, height: attributedTextSize.height)
            // Add RangeSlider
            if self.rangeSlider != nil {
                self.rangeSlider!.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
                self.addSubview(self.rangeSlider!)
                self.rangeSlider!.frame = CGRect(x: 28, y: 8 + attributedTextSize.height + 16, width: self.bounds.width - 28 * 2, height: 31)
            }
        }
        
    }
    
    func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        var lowerValue: String = "todays"
        var upperValue: String = ""
        switch rangeSlider.lowerValue {
        case 0.0..<0.1:
            lowerValue = "today"
        case 0.1..<0.2:
            lowerValue = "yesterday"
        case 0.2..<0.3:
            lowerValue = "2 days ago"
        case 0.3..<0.4:
            lowerValue = "3 days ago"
        case 0.4..<0.5:
            lowerValue = "4 days ago"
        case 0.5..<0.6:
            lowerValue = "5 days ago"
        case 0.6..<0.7:
            lowerValue = "6 days ago"
        case 0.7..<0.8:
            lowerValue = "1 week ago"
        case 0.8..<0.9:
            lowerValue = "2 weeks ago"
        case 0.9...1.0:
            lowerValue = "1 month"
        default:
            lowerValue = "today"
        }
        
        switch rangeSlider.upperValue {
        case 0.0..<0.1:
            upperValue = "yesterday"
        case 0.1..<0.2:
            upperValue = "2 days ago"
        case 0.2..<0.3:
            upperValue = "3 days ago"
        case 0.3..<0.4:
            upperValue = "4 days ago"
        case 0.4..<0.5:
            upperValue = "5 days ago"
        case 0.5..<0.6:
            upperValue = "6 days ago"
        case 0.6..<0.7:
            upperValue = "1 week ago"
        case 0.7..<0.8:
            upperValue = "2 weeks ago"
        case 0.8..<0.9:
            upperValue = "1 month ago"
        case 0.9...1.0:
            upperValue = "all"
        default:
            upperValue = "yesterday"
        }
        
        self.textLabel!.setTextWhileKeepingAttributes(string: "between \(lowerValue) and \(upperValue)")
    }
    
}
