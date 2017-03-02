//
//  FilterButton.swift
//  Spot
//
//  Created by Mats Becker on 2/28/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class FilterButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let buttonFilterCountLabel      = UILabel()
    let countLabelBackgroundColor   = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00)
    let loadingIndicatorView        = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor.radicalRed, padding: 0.0)
    var labelSize: CGSize           = CGSize.zero
    var countSize: CGSize           = CGSize.zero
    let paddingLabelCount: CGFloat  = 4
    var spots: Int                  = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor        = UIColor.white
        self.cornerRadius           = 16
        // Shadow and Radius
        self.layer.shadowColor      = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset     = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity    = 0.6
        self.layer.shadowRadius     = 1.0
        self.layer.masksToBounds    = false
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        
        let viewLabelAndCountWidth = labelSize.width + countSize.width + paddingLabelCount
        
        return CGRect(x: self.bounds.width / 2 - viewLabelAndCountWidth / 2, y: self.bounds.height / 2 - labelSize.height / 2, width: labelSize.width, height: labelSize.height)
    }
    
    override var isHighlighted: Bool {
        willSet(newValue) {
            if(newValue) {
                self.titleLabel?.textColor = UIColor.flatBlack.withAlphaComponent(0.6)
                self.buttonFilterCountLabel.backgroundColor = countLabelBackgroundColor.withAlphaComponent(0.6)
            } else {
                self.titleLabel?.textColor = UIColor.flatBlack
                self.buttonFilterCountLabel.backgroundColor = countLabelBackgroundColor
            }
        }
    }
    
    func setSpots(spots: Int){
        self.setAttributedTitle(NSAttributedString(
            string: "\(spots) Spots - Filter",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: UIColor.flatBlack,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ]), for: .normal)
        self.labelSize = NSAttributedString(
            string: "\(spots) Spots - Filter",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold),
                NSKernAttributeName: 0.6,
                ]).size()
    }
    
    func setTitleAndCount(spots: Int, count: Int){
        
        self.setAttributedTitle(NSAttributedString(
            string: "\(spots) Spots - Filter",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold),
                NSForegroundColorAttributeName: UIColor.flatBlack,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ]), for: .normal)
        self.labelSize = NSAttributedString(
            string: "\(spots) Spots - Filter",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold),
                NSKernAttributeName: 0.6,
                ]).size()
        
        self.titleLabel!.isHidden = false
        self.loadingIndicatorView.removeFromSuperview()
        self.buttonFilterCountLabel.removeFromSuperview()
        
        buttonFilterCountLabel.backgroundColor   = UIColor(red:0.03, green:0.71, blue:0.60, alpha:1.00) // Persian green
        buttonFilterCountLabel.tag               = tag
        let style       = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        buttonFilterCountLabel.attributedText    = NSAttributedString(
            string: "\(count)",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 10, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor.white,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                NSParagraphStyleAttributeName: style
            ])
        let buttonFilterCountLabelSize           = NSAttributedString(
            string: "\(count)",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 10, weight: UIFontWeightBold),
                NSKernAttributeName: 0.6,
                ]).size()
        let buttonFilterCountLabelLongerSize     = buttonFilterCountLabelSize.width > buttonFilterCountLabelSize.height ? buttonFilterCountLabelSize.width : buttonFilterCountLabelSize.height // To have a rounded cirlce both width and heigt must be same
        let buttonFilterCountLabelSizePadding    = 4 + buttonFilterCountLabelLongerSize
        self.countSize = CGSize(width: buttonFilterCountLabelSizePadding, height: buttonFilterCountLabelSizePadding)
        
//        buttonFilterCountLabel.frame             = CGRect(x: self.bounds.width - buttonFilterCountLabelSizePadding - 12, y: self.bounds.height / 2 - buttonFilterCountLabelSizePadding / 2, width: buttonFilterCountLabelSizePadding, height: buttonFilterCountLabelSizePadding)
        
        let viewLabelAndCountWidth = labelSize.width + countSize.width + paddingLabelCount
        
        buttonFilterCountLabel.frame = CGRect(x: self.bounds.width / 2 - viewLabelAndCountWidth / 2 + labelSize.width + paddingLabelCount, y: self.bounds.height / 2 - self.countSize.height / 2, width: self.countSize.width, height: self.countSize.height)
        
        
        buttonFilterCountLabel.layer.cornerRadius = buttonFilterCountLabelSizePadding / 2
        buttonFilterCountLabel.cornerRadius = buttonFilterCountLabelSizePadding / 2
        self.addSubview(buttonFilterCountLabel)
    }
    
    func removeCount() {
        self.buttonFilterCountLabel.removeFromSuperview()
    }
    
    func loadingIndicator(_ show: Bool) {
        if show {
            self.buttonFilterCountLabel.removeFromSuperview()
            self.titleLabel!.isHidden = true
            self.isEnabled = true
            
            loadingIndicatorView.isUserInteractionEnabled = false
            let loadingIndicatorViewWidth = self.bounds.width * 2 / 3
            let loadingIndicatorViewHeight = self.bounds.height * 2 / 3
            loadingIndicatorView.frame = CGRect(x: self.bounds.width / 2 - loadingIndicatorViewWidth / 2, y: self.bounds.height / 2 - loadingIndicatorViewHeight / 2, width: loadingIndicatorViewWidth, height: loadingIndicatorViewHeight)
            loadingIndicatorView.tag = tag
            self.addSubview(loadingIndicatorView)
            loadingIndicatorView.startAnimating()
        } else {
            self.titleLabel!.isHidden = false
            self.loadingIndicatorView.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
