//
//  ParkTableHeaderUIView.swift
//  Spot
//
//  Created by Mats Becker on 11/30/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher

class ParkTableHeaderUIView: UIView {

    var park: String
    var parkTitle: String
    
    init(park: String, parkTitle: String) {
        self.park = park
        self.parkTitle = parkTitle
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 82 + 82 + 82 + 82))
        backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        
        addTitleView()
        // addMapView()
        let mapView = ParkTableHeaderMapUIImageView.init(frame: CGRect(x: 20, y: 102, width: self.bounds.width - 40, height: self.bounds.height - 82 - 20 - 20), park: self.park)
        addSubview(mapView)
        
    }
    
    func addTitleView() -> () {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 82))
        titleView.backgroundColor = UIColor.clear
        
        let parkTitle = UIButton()
        parkTitle.setAttributedTitle(NSAttributedString(
            string: self.parkTitle,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBlack),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
            , for: .normal)
        // ToDo: Remove
        parkTitle.setAttributedTitle(NSAttributedString(
            string: self.parkTitle,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBlack),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
            , for: .highlighted)
        parkTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let chooseButton = UIButton()
        chooseButton.setAttributedTitle(NSAttributedString(
            string: "Select Park",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00), // Lavender grey
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
            , for: .normal)
        chooseButton.setAttributedTitle(NSAttributedString(
            string: "Select Park",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00).withAlphaComponent(0.6), // Lavender grey
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
            , for: .highlighted)
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(parkTitle)
        titleView.addSubview(chooseButton)
        
        self.addSubview(titleView)
        
        
        parkTitle.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 20).isActive = true
        parkTitle.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        chooseButton.leadingAnchor.constraint(equalTo: parkTitle.leadingAnchor).isActive = true
        chooseButton.topAnchor.constraint(equalTo: titleView.centerYAnchor, constant: 6).isActive = true
        
        let borderLine = UIView(frame: CGRect(x: 20, y: 82, width: self.bounds.width - 20, height: 1))
        borderLine.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00) // iron
        
        self.addSubview(borderLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
