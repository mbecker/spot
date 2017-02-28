//
//  LiveView.swift
//  Spot
//
//  Created by Mats Becker on 2/28/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

class LiveView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    let liveIconImage = UIImageView()
    let liveIconLabel = UILabel()
    let strikethrough = UIView()
    
    let liveIconLabelSize = NSAttributedString(
        string: "Live",
        attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
            NSKernAttributeName: 0.6,
            ]).size()
    
    let liveIconLabelSize2 = NSAttributedString(
        string: "Not connected",
        attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
            NSKernAttributeName: 0.6,
            ]).size()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        /* Live icon image */
        
        let scale: CGFloat = 0.5
        liveIconImage.frame = CGRect(x: 0, y: 0, width: 18 * scale, height: 32 *  scale)
        liveIconImage.image = StyleKitName.imageOfBolt
        liveIconImage.tintColor = UIColor.radicalRed
        liveIconImage.contentMode = .scaleAspectFit
        
        /* Live icon label */
        
        liveIconLabel.attributedText = NSAttributedString(
            string: "Live",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor.radicalRed,
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        
        
        self.frame = CGRect(x: 8, y: 0, width: liveIconImage.bounds.width + 8 + liveIconLabelSize.width, height: liveIconImage.bounds.height)
        liveIconLabel.frame = CGRect(x: liveIconImage.bounds.width + 8, y: self.bounds.height / 2 - liveIconLabelSize.height / 2, width: liveIconLabelSize.width, height: liveIconLabelSize.height)
        
        self.strikethrough.frame = CGRect(x: 0, y: self.bounds.height / 2, width: liveIconImage.bounds.width + 4, height: 1)
        self.strikethrough.backgroundColor = UIColor.flatBlack
        
        self.addSubview(liveIconImage)
        self.addSubview(liveIconLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showStrikethrough(show: Bool) {
        if show {
            liveIconImage.tintColor = UIColor.flatBlack
            self.liveIconLabel.textColor = UIColor.flatBlack
            self.liveIconLabel.setTextWhileKeepingAttributes(string: "Not connected")
            
            
            self.frame = CGRect(x: 8, y: self.bounds.maxY + 8, width: liveIconImage.bounds.width + 8 + liveIconLabelSize2.width, height: liveIconImage.bounds.height)
            liveIconLabel.frame = CGRect(x: liveIconImage.bounds.width + 8, y: self.bounds.height / 2 - liveIconLabelSize2.height / 2, width: liveIconLabelSize2.width, height: liveIconLabelSize.height)
        } else {
            liveIconImage.tintColor = UIColor.radicalRed
            self.liveIconLabel.textColor = UIColor.radicalRed
            self.liveIconLabel.setTextWhileKeepingAttributes(string: "Live")
            
            
            self.frame = CGRect(x: 8, y: self.bounds.maxY + 8, width: liveIconImage.bounds.width + 8 + liveIconLabelSize.width, height: liveIconImage.bounds.height)
            liveIconLabel.frame = CGRect(x: liveIconImage.bounds.width + 8, y: self.bounds.height / 2 - liveIconLabelSize.height / 2, width: liveIconLabelSize.width, height: liveIconLabelSize.height)
        }
    }
    
}
