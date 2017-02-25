//
//  FilterTableViewCell.swift
//  Spot
//
//  Created by Mats Becker on 2/24/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    let accessoryLabel: UILabel?
//    let accessoryLabelSize: CGSize?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        self.accessoryLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(self.accessoryLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        if selected {
//            self.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
//        } else {
//            self.backgroundColor = UIColor.white
//        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
        } else {
            self.backgroundColor = UIColor.white
        }
    }
    
    
    override func layoutSubviews() {
        if let attributedTextSize: CGSize = self.textLabel?.attributedText?.size() {
            self.textLabel?.frame = CGRect(x: 28, y: self.bounds.height / 2 - attributedTextSize.height / 2, width: attributedTextSize.width, height: attributedTextSize.height)
        }
//        if self.accessoryLabelSize != nil {
//            self.accessoryLabel?.frame = CGRect(x: self.bounds.width - self.accessoryLabelSize!.width - 28, y: self.bounds.height / 2 - self.accessoryLabelSize!.height / 2, width: self.accessoryLabelSize!.width, height: self.accessoryLabelSize!.height)
//        }
    }

}
