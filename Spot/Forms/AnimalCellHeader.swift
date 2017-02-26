//
//  AnimalCellHeader.swift
//  ImagePicker
//
//  Created by Mats Becker on 10/27/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

protocol AnimalCellDelegate: class {
  func headerButtonPressed()
}

class AnimalCellHeader: UICollectionReusableView {
  
  var textLabel: UILabel!
  var button: UIButton!
  weak var delegate: AnimalCellDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.textLabel = UILabel(frame: frame)
    self.textLabel.textAlignment = .center
    
    
    self.button = UIButton(type: .custom)
    //set image for button
    let cancelImage: UIImage = StyleKitName.imageOfCancel.withRenderingMode(.alwaysTemplate)
    self.button.backgroundColor = UIColor.clear
    self.button.setImage(cancelImage, for: UIControlState.normal)
    self.button.tintColor = UIColor.white
    //add function for button
    self.button.addTarget(self, action: #selector(self.popBack), for: UIControlEvents.touchUpInside)
    
    self.addSubview(self.textLabel)
    self.addSubview(self.button)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    self.textLabel.frame = self.frame
    self.button.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
  }
  
  func popBack(){
    self.delegate?.headerButtonPressed()
  }
  
  
}
