//
//  ParkTableHeaderUIView.swift
//  Spot
//
//  Created by Mats Becker on 11/30/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Kingfisher

class ParkTableHeaderUIView: UIView {
    
    var delegate    : SelectParkDelegate?
    var delegateMap : SelectParkMapDelegate?
    
    var mapView: ParkTableHeaderMapUIImageView?

    init(realmPark: RealmPark) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 328))
        
        backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        
        let parkTitleView = ParkTableHeaderTitleUIView(parkName: realmPark.name, frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 82))
        parkTitleView.delegate = self
        addSubview(parkTitleView)
        
        self.mapView = ParkTableHeaderMapUIImageView.init(realmPark: realmPark, frame: CGRect(x: 20, y: 102, width: self.bounds.width - 40, height: 206))
        self.mapView?.delegate = self
        addSubview(self.mapView!)
        
    }
    
    init(parkName: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 82 + 12))
        backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00) // grey
        
        let parkTitleView = ParkTableHeaderTitleUIView(parkName: parkName, frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 82))
        parkTitleView.delegate = self
        addSubview(parkTitleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension ParkTableHeaderUIView: SelectParkDelegate {
    func selectPark() {
        self.delegate?.selectPark()
    }
    
    func selectPark(park: String, name: String) {
        
    }
}

extension ParkTableHeaderUIView: SelectParkMapDelegate {
    func selectParkMap() {
        self.delegateMap?.selectParkMap()
    }
}

class ParkTableHeaderTitleUIView: UIView {
    let parkTitle = UILabel()
    var delegate: SelectParkDelegate?
    init(parkName: String, frame:CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        addTitleView(parkName: parkName)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ParkTableHeaderTitleUIView touchesEnded...")
        self.parkTitle.textColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00)
        self.delegate?.selectPark()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.parkTitle.textColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00).withAlphaComponent(0.6)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.parkTitle.textColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00)
    }

    
    func updateParkTitle(parkName: String){
        self.parkTitle.attributedText = NSAttributedString(
            string: parkName,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBlack),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
    }
    
    func addTitleView(parkName: String) -> () {
        
        updateParkTitle(parkName: parkName)
        parkTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let chooseButton = UILabel()
        chooseButton.attributedText = NSAttributedString(
            string: "Select Park",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00), // Lavender grey
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(parkTitle)
        self.addSubview(chooseButton)
        
        
        parkTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        parkTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        chooseButton.leadingAnchor.constraint(equalTo: parkTitle.leadingAnchor).isActive = true
        chooseButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 12).isActive = true
        
        let borderLine = UIView(frame: CGRect(x: 20, y: 82, width: self.bounds.width - 20, height: 1))
        borderLine.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00) // iron
        
        self.addSubview(borderLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
