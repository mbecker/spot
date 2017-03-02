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

    let _realmPark: RealmPark
    var delegate: SelectParkMapDelegate?
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 22, height: 22), type: NVActivityIndicatorType.ballScale, color: UIColor.flatBlack.withAlphaComponent(0.4), padding: 0.0)
    
    init(realmPark: RealmPark, frame: CGRect) {
        self._realmPark = realmPark
        
        super.init(frame: frame)
        
        // Layout options
        backgroundColor     = UIColor.white
        contentMode         = .scaleAspectFill
        cornerRadius        = 10
        kf.indicatorType    = .activity
        isUserInteractionEnabled = true
        
        // Loadingindicator
        self.loadingIndicatorView.frame = CGRect(x: frame.width / 2 - 11, y: frame.height / 2 - 11, width: 22, height: 22)
        self.loadingIndicatorView.startAnimating()
        self.addSubview(self.loadingIndicatorView)
        
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
    
}
