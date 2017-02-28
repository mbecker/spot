//
//  TagsTableCell.swift
//  Spot
//
//  Created by Mats Becker on 2/23/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

class TagsTableCell: UITableViewCell {
    
    let collectionView: UICollectionView!
    let layout = UICollectionViewFlowLayout()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 68, height: 68)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.allowsMultipleSelection = true
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.collectionView.frame = CGRect(x: 28, y: 8, width: self.bounds.width - 56, height: self.bounds.height - 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
        }
    }

}

extension TagsTableCell {
    
    func setSelectedRows(tags: [String], selectedTags: [String]){
        // tags are already sorted and is the leading datasource for the items; so do not sort it!
        let sortedSelectedTags = selectedTags.sorted { $0 < $1 }
        // 1. Loop through all selected tags
        for selectedTag in sortedSelectedTags {
            var i = 0
            // 2. Chekf if selectedTag is in tags; count to get indexpath
            for tag in tags {
                if tag == selectedTag {
                    self.collectionView.selectItem(at: [0, i], animated: true, scrollPosition: .top)
                }
                i = i + 1
            }
        }
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        self.collectionView.register(TagCell.self, forCellWithReuseIdentifier: "collectionViewCell")
        collectionView.isScrollEnabled = false
        collectionView.delegate     = dataSourceDelegate
        collectionView.dataSource   = dataSourceDelegate
        collectionView.tag          = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionView.contentOffset.x = newValue }
        get { return collectionView.contentOffset.x }
    }
}
