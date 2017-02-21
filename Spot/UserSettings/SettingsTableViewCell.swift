//
//  SettingsTableViewCell.swift
//  Spot
//
//  Created by Mats Becker on 2/15/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    let chevronImageView: UIImageView = UIImageView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightUltraLight)
        self.textLabel?.textColor = UIColor.radicalRed
        let chevronImage = UIImage(named: "chevronright_32x17")?.withRenderingMode(.alwaysTemplate)
        
        self.chevronImageView.frame = CGRect(x: self.frame.width, y: self.contentView.bounds.height / 2 - 16 / 2 + 2, width: 8.5, height: 16)
        self.chevronImageView.image = chevronImage
        self.chevronImageView.tintColor = UIColor.radicalRed
        self.contentView.addSubview(self.chevronImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.textLabel?.textColor = UIColor.white
            self.chevronImageView.tintColor = UIColor.white
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.radicalRed
            self.selectedBackgroundView = selectedView
        } else {
            self.textLabel?.textColor = UIColor.radicalRed
            self.chevronImageView.tintColor = UIColor.radicalRed
            
        }
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.textLabel?.textColor = UIColor.white
            self.chevronImageView.tintColor = UIColor.white
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.radicalRed
            self.selectedBackgroundView = selectedView
        } else {
            self.textLabel?.textColor = UIColor.radicalRed
            self.chevronImageView.tintColor = UIColor.radicalRed
            
        }
        super.setHighlighted(highlighted, animated: animated)
    }
    
    

}
