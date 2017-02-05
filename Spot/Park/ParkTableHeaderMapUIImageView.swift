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
import NVActivityIndicatorView

class ParkTableHeaderMapUIImageView: UIImageView {

    var park: Park
    var delegate: SelectParkMapDelegate?
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 22, height: 22), type: NVActivityIndicatorType.ballScale, color: UIColor.flatBlack.withAlphaComponent(0.4), padding: 0.0)
    
    init(park: Park, frame: CGRect) {
        self.park = park
        super.init(frame: frame)
        backgroundColor = UIColor.white
        contentMode = .scaleAspectFill
        cornerRadius = 10
        kf.indicatorType = .activity
        isUserInteractionEnabled = true
        
        self.loadingIndicatorView.frame = CGRect(x: frame.width / 2 - 11, y: frame.height / 2 - 11, width: 22, height: 22)
        self.loadingIndicatorView.startAnimating()
        self.addSubview(self.loadingIndicatorView)
        // self.addInfo(url: self.park.mapImage, country: self.park.country, info: self.park.info)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // User clicked on map: Push ParkDetailUIViewController via ParkAsViewController (delegate to "ParkTableHeaderUIView" -> "ParkAsViewController")
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.selectParkMap()
    }
    
    // ToDo: We are loading the image in the Controller (ParkASViewController); Delete
    public func setMapImage(url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 10)
        self.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
            self.loadingIndicatorView.stopAnimating()
            self.loadingIndicatorView.removeFromSuperview()
        })
    }
    
    public func stopAndRemoveLoadingIndicator(){
        self.loadingIndicatorView.stopAnimating()
        self.loadingIndicatorView.removeFromSuperview()
    }
    
    public func addInfo(url: String?, country: String?, info: String?) -> () {
        
        var marginTop: CGFloat = 8
        
        // informationView
        let informationView = UIView()
        informationView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        informationView.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async(execute: {
            informationView.roundCorners(corner: [.bottomLeft,.bottomRight], radii: 10)
        })

        /**
         * Park details
         */
        
        // mapImage
        if url != nil, let mapImageURL: URL = URL(string: url!) {
            let processor = RoundCornerImageProcessor(cornerRadius: 10)
            self.kf.setImage(with: mapImageURL, placeholder: nil, options: [.processor(processor)])
        }
        
        // countryName
        if country != nil {
            let countryImage = UIImageView(frame: CGRect(x: 8, y: marginTop, width: 12, height: 12))
            countryImage.image = UIImage(named: "marker")
            let countryLabel = UILabel()
            countryLabel.attributedText = NSAttributedString(
                string: country!,
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
        
        // info - ToDo: Shorten info text to x charachters
        if info != nil {
            let infoImage = UIImageView(frame: CGRect(x: 8, y: marginTop , width: 12, height: 12)) // font size 12 = height 14.3203125
            infoImage.image = UIImage(named: "info")
            
            let infoLabel = UILabel()
            infoLabel.attributedText = NSAttributedString(
                string: info!,
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
        
        // BLOCK: More
//        let moreImage = UIImageView(frame: CGRect(x: 8, y: marginTop , width: 12, height: 12)) // font size 12 = height 14.3203125
//        moreImage.image = UIImage(named: "more")
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
        
//        informationView.addSubview(moreImage)
        informationView.addSubview(moreLabel)
        
        marginTop = marginTop + 14.3203125 + 8 // Add height of font to margintop to specify height of uiview
        
        // informationView: layout setup
        self.addSubview(informationView)
        
        informationView.heightAnchor.constraint(equalToConstant: marginTop).isActive = true
        informationView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        informationView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        informationView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        moreLabel.leadingAnchor.constraint(equalTo: informationView.trailingAnchor, constant: 4).isActive = true
        moreLabel.centerYAnchor.constraint(equalTo: informationView.centerYAnchor).isActive = true
        
    }

}
