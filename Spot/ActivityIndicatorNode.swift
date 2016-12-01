//
//  SpinnerNode.swift
//  Spot
//
//  Created by Mats Becker on 11/9/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//
import UIKit
import AsyncDisplayKit
import NVActivityIndicatorView

final class SpinnerNode: ASDisplayNode {
    var activityIndicatorView: UIActivityIndicatorView {
        return view as! UIActivityIndicatorView
    }
    
    override init() {
        super.init(viewBlock: { UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge) }, didLoad: nil)
        
        self.style.minHeight = ASDimensionMakeWithPoints(44.0)
    }
    
    override func didLoad() {
        super.didLoad()
        activityIndicatorView.backgroundColor = UIColor.clear
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
    }
    
}

final class BallPulse: ASDisplayNode {
    
    var activityIndicatorView: NVActivityIndicatorView {
        return view as! NVActivityIndicatorView
    }
    
    override init() {
        super.init(viewBlock: {
            NVActivityIndicatorView(frame: CGRect(x: 90, y: 90, width: 44, height: 44), type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 8.0)
        }, didLoad: nil)
        self.style.minHeight = ASDimensionMakeWithPoints(44.0)
    }
    
    override func didLoad() {
        super.didLoad()
        activityIndicatorView.backgroundColor = UIColor.clear
        activityIndicatorView.startAnimating()
    }
    
}
