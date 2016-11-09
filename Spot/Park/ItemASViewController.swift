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
    
    let extendedNavBarHeight: CGFloat = 40
    
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
        self.navigationItem.title = self._parkItem.name
        self.navigationController?.navigationBar.isHidden = false
        // Translucency of the navigation bar is disabled so that it matches with
        // the non-translucent background of the extension view.
        navigationController!.navigationBar.isTranslucent = false
        
        // The navigation bar's shadowImage is set to a transparent image.  In
        // addition to providing a custom background image, this removes
        // the grey hairline at the bottom of the navigation bar.  The
        // ExtendedNavBarView will draw its own hairline.
        navigationController!.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
        // "Pixel" is a solid white 1x1 image.
        navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .default)
        
        self.view.backgroundColor = UIColor.clear
        
        self._scrollView.parallaxHeader.view = headerView
        self._scrollView.parallaxHeader.height = 300
        self._scrollView.parallaxHeader.minimumHeight = 80
        self._scrollView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        
        self._pagerNode.backgroundColor = UIColor.clear
        
        self.view.addSubview(extendedNavBarView)
//        self._scrollView.addSubnode(self._pagerNode)
//        self.view.addSubview(self._scrollView)
        self.view.addSubnode(self._pagerNode)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self._pagerNode.frame = CGRect(x: 0, y: self.extendedNavBarHeight, width: self.view.bounds.width, height: self.view.bounds.height)
        
        var frame = self.view.frame //CGRect(x: 0, y: 120, width: self.view.bounds.width, height: self.view.bounds.height - 120)
        frame.origin.y = 120
        self._scrollView.frame = frame
        self._scrollView.contentSize = frame.size
        
        frame.size.height -= self._scrollView.parallaxHeader.minimumHeight
        
//        self._pagerNode.frame = frame
        
    }
    
    lazy var extendedNavBarView: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.extendedNavBarHeight))
        // Use the layer shadow to draw a one pixel hairline under this view.
        view.layer.shadowOffset = CGSize(width: 0, height: CGFloat(1) / UIScreen.main.scale)
        view.layer.shadowRadius = 0
        
        // UINavigationBar's hairline is adaptive, its properties change with
        // the contents it overlies.  You may need to experiment with these
        // values to best match your content.
        view.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.shadowOpacity = 0.25
        
        view.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.hairlineBottomWidth = 1
        
        let controls = UISegmentedControl(items: ["Spot", "Media", "Map"])
        controls.selectedSegmentIndex = 0
        controls.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
        controls.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(controls)
        
        controls.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        controls.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        controls.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        return view
    }()
    
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
        
        view.addSubview(text)
        
        let controls = UISegmentedControl(items: ["Scroll1", "Scroll2"])
        controls.translatesAutoresizingMaskIntoConstraints = false
        
        controls.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(controls)
        
        controls.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        controls.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        controls.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        return view
    }()
    
    func segmentedControlValueChanged(_ segment: UISegmentedControl) {
        self._pagerNode.scrollToPage(at: segment.selectedSegmentIndex, animated: false)
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
