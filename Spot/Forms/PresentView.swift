//
//  PresentView.swift
//  Spot
//
//  Created by Mats Becker on 2/28/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

class PresentView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var collectionView: UICollectionView!
    let layout = UICollectionViewFlowLayout()
    var items2: [ParkItem2]?
    var item2: ParkItem2?
    
    let _imageHeight: CGFloat   = 140 // 96
    let _imageWidth: CGFloat    = 186 // 103.55417528 // 142
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor    = UIColor.white
        self.borderColor        = UIColor(red:0.85, green:0.84, blue:0.81, alpha:1.00) // Timberwolf
        self.borderWidth        = 1.0
        self.layer.shadowColor           = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset     = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity    = 0.6
        self.layer.shadowRadius     = 1.0
        self.layer.masksToBounds    = false
        
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: _imageWidth, height: 184 - 18)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.delegate    = self
        self.collectionView.dataSource  = self
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.register(PresentCell.self, forCellWithReuseIdentifier: "collectionViewCell")
        self.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.collectionView.frame = CGRect(x: 12, y: self.bounds.height / 2 - (184 - 18) / 2, width: self.bounds.width - 24, height: 184 - 18)
        self.collectionView.reloadData()
        if self.item2 != nil {
            self.collectionView.selectItem(at: [0, 0], animated: false, scrollPosition: .left)
        }
        self.collectionView.scrollToItem(at: [0, 0], at: .left, animated: false)
    }
    
}

extension PresentView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.item2 != nil && self.items2 != nil {
            return 1 + self.items2!.count
        }
        if self.item2 != nil {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! PresentCell
        switch indexPath.row {
        case 0:
            cell.item2 = self.item2
        default:
            cell.item2 = self.items2?[indexPath.row - 1]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) deselected index path \(indexPath)")
    }
}
