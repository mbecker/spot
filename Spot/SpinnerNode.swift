//
//  SpinnerNode.swift
//  Spot
//
//  Created by Mats Becker on 11/9/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//
import UIKit
import AsyncDisplayKit

final class SpinnerNode: ASDisplayNode {
    var activityIndicatorView: UIActivityIndicatorView {
        return view as! UIActivityIndicatorView
    }
    
    override init() {
        super.init(viewBlock: { UIActivityIndicatorView(activityIndicatorStyle: .gray) }, didLoad: nil)
        
        self.style.minHeight = ASDimensionMakeWithPoints(44.0)
    }
    
    override func didLoad() {
        super.didLoad()
        activityIndicatorView.backgroundColor = UIColor.clear
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
    }
    
    
}
