//
//  ParkTableHeaderMapUIImageView.swift
//  Spot
//
//  Created by Mats Becker on 11/30/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher

class ParkTableHeaderMapUIImageView: UIImageView {

    var ref: FIRDatabaseReference!    
    var park: String
    
    init(frame: CGRect, park: String) {
        self.park = park
        self.ref = FIRDatabase.database().reference() // Firebase Databse: Set park image from firebase database
        
        super.init(frame: frame)
        backgroundColor = UIColor.white
        contentMode = .scaleAspectFill
        cornerRadius = 10
        kf.indicatorType = .activity
        isUserInteractionEnabled = true
        
        addInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded...")
    }
    
    func addInfo() -> () {
        self.ref.child("parkinfo/" + self.park).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshotValue = snapshot.value as? [String: AnyObject] {
                if let image = snapshotValue["image"]  as? String {
                    print(image)
                    let url = URL(string: image)!
                    let processor = RoundCornerImageProcessor(cornerRadius: 10)
                    self.kf.setImage(with: url, placeholder: UIImage(named: "imagebackgrounddefault"), options: [.processor(processor)])
                }
                
                // informationView
                let informationView = UIView()
                informationView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
                informationView.translatesAutoresizingMaskIntoConstraints = false
                DispatchQueue.main.async(execute: {
                    informationView.roundCorners(corner: [.bottomLeft,.bottomRight], radii: 10)
                })
                
                var marginTop: CGFloat = 8
                
                if let country = snapshotValue["country"] as? String {
                    let countryImage = UIImageView(frame: CGRect(x: 8, y: marginTop, width: 12, height: 12))
                    countryImage.image = UIImage(named: "markerfilled")
                    let countryLabel = UILabel()
                    countryLabel.attributedText = NSAttributedString(
                        string: country,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight),
                            NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.0,
                            ])
                    countryLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    informationView.addSubview(countryImage)
                    informationView.addSubview(countryLabel)
                    
                    countryLabel.leadingAnchor.constraint(equalTo: countryImage.trailingAnchor, constant: 8).isActive = true
                    countryLabel.centerYAnchor.constraint(equalTo: countryImage.centerYAnchor).isActive = true
                    
                    marginTop = marginTop + 14.3203125 + 8
                }
                
                // margint is now > 8 && < 30.32
                
                if let info = snapshotValue["info"] as? String {
                    let infoImage = UIImageView(frame: CGRect(x: 8, y: marginTop , width: 12, height: 12)) // font size 12 = height 14.3203125
                    infoImage.image = UIImage(named: "info")
                    
                    let infoLabel = UILabel()
                    infoLabel.attributedText = NSAttributedString(
                        string: info,
                        attributes: [
                            NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight),
                            NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                            NSBackgroundColorAttributeName: UIColor.clear,
                            NSKernAttributeName: 0.0,
                            ])
                    infoLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    informationView.addSubview(infoImage)
                    informationView.addSubview(infoLabel)
                    
                    infoLabel.leadingAnchor.constraint(equalTo: infoImage.trailingAnchor, constant: 8).isActive = true
                    infoLabel.trailingAnchor.constraint(equalTo: informationView.trailingAnchor, constant: -8).isActive = true
                    infoLabel.centerYAnchor.constraint(equalTo: infoImage.centerYAnchor).isActive = true
                    
                    marginTop = marginTop + 14.3203125 + 8
                }
                
                /* BLOCK: More */
                let moreImage = UIImageView(frame: CGRect(x: 8, y: marginTop , width: 12, height: 12)) // font size 12 = height 14.3203125
                moreImage.image = UIImage(named: "more")
                let moreLabel = UILabel()
                moreLabel.attributedText = NSAttributedString(
                    string: "Click for more information",
                    attributes: [
                        NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight),
                        NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                        NSBackgroundColorAttributeName: UIColor.clear,
                        NSKernAttributeName: 0.0,
                        ])
                moreLabel.translatesAutoresizingMaskIntoConstraints = false
                
                informationView.addSubview(moreImage)
                informationView.addSubview(moreLabel)
                
                moreLabel.leadingAnchor.constraint(equalTo: moreImage.trailingAnchor, constant: 8).isActive = true
                moreLabel.centerYAnchor.constraint(equalTo: moreImage.centerYAnchor).isActive = true
                
                marginTop = marginTop + 14.3203125 + 8 // Add height of font to margintop to specify height of uiview
                /* BLOCK: More */
                
                self.addSubview(informationView)
                
                informationView.heightAnchor.constraint(equalToConstant: marginTop).isActive = true
                informationView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                informationView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                informationView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}
