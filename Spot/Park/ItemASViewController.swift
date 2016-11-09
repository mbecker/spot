//
//  ItemASViewController.swift
//  Spot
//
//  Created by Mats Becker on 11/9/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import MXParallaxHeader

class ItemViewController: UIViewController {
    
    var _scrollView: MXScrollView!
    var _parkItem: ParkItem!
    
    /**
     * AsyncDisplayKit
     */
    var _pagerNode: ASPagerNode!
    
    init(parkItem: ParkItem) {
        self._parkItem = parkItem
        super.init(nibName: nil, bundle: nil)
        self._scrollView = MXScrollView()
        self._pagerNode = ASPagerNode()
        self._pagerNode.delegate = self
        self._pagerNode.dataSource = self
        self._pagerNode.view.isScrollEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.backgroundColor = UIColor.clear
        self._pagerNode.backgroundColor = UIColor.clear
        
        self._scrollView.parallaxHeader.view = headerView
        self._scrollView.parallaxHeader.height = 300
        self._scrollView.parallaxHeader.minimumHeight = 80
        self._scrollView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self._scrollView.addSubnode(self._pagerNode)
        self.view.addSubview(self._scrollView)
//        self.view.addSubnode(self._pagerNode)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self._pagerNode.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        var frame = self.view.frame
        self._scrollView.frame = frame
        self._scrollView.contentSize = frame.size
        
        frame.size.height -= self._scrollView.parallaxHeader.minimumHeight
        
        self._pagerNode.frame = frame
        
    }
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:1.00, green:0.78, blue:0.02, alpha:1.00)
        let text = UILabel()
        text.attributedText = NSAttributedString(
            string: "Header VIEW",
            attributes: [
                NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 14)!,
                NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        text.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        let button = UIButton()
        button.setTitle("Scroll to 1", for: UIControlState.normal)
        button.addTarget(self, action: #selector(self.scrollTo1), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let button2 = UIButton()
        button2.setTitle("Scroll to 2", for: UIControlState.normal)
        button2.addTarget(self, action: #selector(self.scrollTo2), for: UIControlEvents.touchUpInside)
        button2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text)
        
        let controls = UISegmentedControl(items: ["Scroll1", "Scroll2"])
        controls.translatesAutoresizingMaskIntoConstraints = false
        
        controls.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(controls)
        
        controls.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        controls.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true

        return view
    }()
    
    func segmentedControlValueChanged(_ segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
        }
        self._pagerNode.scrollToPage(at: segment.selectedSegmentIndex, animated: false)
    }
    func scrollTo1(){
        self._pagerNode.scrollToPage(at: 0, animated: false)
    }
    func scrollTo2(){
        self._pagerNode.scrollToPage(at: 1, animated: true)
    }
}

extension ItemViewController : ASPagerDelegate, ASPagerDataSource, ASCollectionDataSource {
    // ASPagerDelegate
    func pagerNode(_ pagerNode: ASPagerNode, constrainedSizeForNodeAt index: Int) -> ASSizeRange {
        return ASSizeRange(min: CGSize(width: 10, height: 100), max: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
    }
    
    // ASPagerDataSource
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 2
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeBlockAt index: Int) -> ASCellNodeBlock {
        return {
            let node = ItemScrollASCellNode(number: index, parkItem: self._parkItem)
            return node
        }
    }
    
    // ASCollectionDataSource
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let position = index
        return {
            let node = ASCellNode()
            node.backgroundColor = UIColor.brown
            let label = ASTextNode()
            label.attributedText = NSAttributedString(
                string: "collectionNode - Position: \(position)",
                attributes: [
                    NSFontAttributeName: UIFont(name: "Avenir-Book", size: 12)!,
                    NSForegroundColorAttributeName: UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.00),
                    NSBackgroundColorAttributeName: UIColor.clear,
                    NSKernAttributeName: 0.0,
                    ])
            
            node.addSubnode(label)
            
            return node
        }
    }
}
