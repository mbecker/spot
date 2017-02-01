//
//  ListASPagerNode.swift
//  Spot
//
//  Created by Mats Becker on 12/7/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import SMSegmentView
import Hero

protocol ChangePage {
    func changePage(tab: Int, showSelectedPage: Bool)
}


class ListASPagerNode: ASViewController<ASDisplayNode> {
    private var shadowImageView: UIImageView?
    /**
     * AsyncDisplayKit
     */
    var _pagerNode: ASPagerNode {
        return node as! ASPagerNode
    }
    
    /**
     * Firebase
     */
    let _ref:   FIRDatabaseReference
    let _park:  Park
    let _segmentView: SMSegmentView!
    var margin: CGFloat = 10.0
    var seletionBar: UIView = UIView()
    var selectedPage: Int = 0
    var showSelectedPage: Bool = false
    var dataLoaded: Bool = false
    
    
    
    
    init(park: Park){
        self._ref    = FIRDatabase.database().reference()
        self._park   = park
        
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = UIColor.white
        appearance.segmentOffSelectionColour = UIColor.white
        appearance.titleOnSelectionFont = UIFont.systemFont(ofSize: 14.0)
        appearance.titleOffSelectionFont = UIFont.systemFont(ofSize: 14.0)
        appearance.contentVerticalMargin = 10.0
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        appearance.tileOffSelectionAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold), // UIFont(name: "Avenir-Heavy", size: 12)!,
            NSForegroundColorAttributeName: UIColor.black.withAlphaComponent(0.6),
            NSBackgroundColorAttributeName: UIColor.clear,
            NSKernAttributeName: 0.0,
            NSParagraphStyleAttributeName: paragraph,
        ]
        appearance.tileOnSelectionAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold), // UIFont(name: "Avenir-Heavy", size: 12)!,
            NSForegroundColorAttributeName: UIColor.black,
            NSBackgroundColorAttributeName: UIColor.clear,
            NSKernAttributeName: 0.0,
            NSParagraphStyleAttributeName: paragraph,
        ]
        
        self._segmentView = SMSegmentView(frame: CGRect.zero, dividerColour: UIColor.clear, dividerWidth: 1.0, segmentAppearance: appearance)
        
        for parkSection in self._park.sections {
            self._segmentView.addSegmentWithTitle(parkSection.name, onSelectionImage: nil, offSelectionImage: nil)
        }

        super.init(node: ASPagerNode.init())
        
        self._segmentView.selectedSegmentIndex   = 0
        
        self._pagerNode.delegate     = self
        self._pagerNode.dataSource   = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSelectionBar(){
        if self._park.sections.count > 1 {
            self.seletionBar.removeFromSuperview()
            self.seletionBar.frame = CGRect(x: 0.0, y: self._segmentView.bounds.height - 2, width: self._segmentView.bounds.width/CGFloat(self._segmentView.numberOfSegments), height: 2.0)
            self.seletionBar.backgroundColor = UIColor.black
            // self.placeSelectionBar(posX: 0)
            self._segmentView.addSubview(self.seletionBar)
        }
    }
    
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shadowImageView?.isHidden = false
        self._segmentView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = false
        
        if self.showSelectedPage {
            if !self.dataLoaded {
                // User cliked on "See all"; this is the first time that's why the data must be loaded
                self._pagerNode.reloadData {
                    self.dataLoaded = true
                }
            }
            self.showSelectedPage = false
            self._segmentView.selectedSegmentIndex = self.selectedPage
            self._pagerNode.scrollToPage(at: self.selectedPage, animated: false)
        }
        
        self.navigationController!.navigationBar.addSubview(self._segmentView)
        // self.isScrolling = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self._pagerNode.view.backgroundColor = UIColor.clear
        self._pagerNode.view.isScrollEnabled = true
        
        /*
         Init SMsegmentView
         Set divider colour and width here if there is a need
         */
        let segmentFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationController!.navigationBar.bounds.height)
        self._segmentView.frame = segmentFrame
        self._segmentView.backgroundColor = UIColor.clear
        
        self._segmentView.layer.cornerRadius = 0.0
        self._segmentView.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        self._segmentView.layer.borderWidth = 0.0
        
        self._segmentView.addTarget(self, action: #selector(selectSegmentInSegmentView(segmentView:)), for: .valueChanged)
        // self.navigationController!.navigationBar.addSubview(self.segmentView)
        
        /**
         * Selection indicator for segmented view
         */
        self.initSelectionBar()
        
    }
    
    func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        let selectedPage = segmentView.selectedSegmentIndex
        let scrollViewEndPosX: CGFloat = self.view.bounds.width * CGFloat(selectedPage)
        self._pagerNode.scrollToPage(at: selectedPage, animated: true)
        self.selectedPage = selectedPage
    }
}

extension ListASPagerNode: ChangePage {
    
    func changePage(tab: Int, showSelectedPage: Bool){
        self.showSelectedPage = showSelectedPage
        switch tab {
        case 0:
            self.selectedPage = 0
            self._segmentView.selectedSegmentIndex = 0
        case 1:
            self.selectedPage = 1
            self._segmentView.selectedSegmentIndex = 1
        default:
            self.selectedPage = 0
            self._segmentView.selectedSegmentIndex = 0
        }
    }
    
}

extension ListASPagerNode: ASPagerDelegate {
    func pagerNode(_ pagerNode: ASPagerNode, constrainedSizeForNodeAt index: Int) -> ASSizeRange {
        return ASSizeRange(min: CGSize(width: 10, height: 100), max: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
    }
    
    // Called at: User drags scrollview; scrollview anomation ends
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewContentOffsetX = scrollView.contentOffset.x
        let pageWidth = self.view.bounds.width * 0.5
        if scrollViewContentOffsetX > pageWidth {
            self.selectedPage = 1
            self._segmentView.selectedSegmentIndex = 1
        } else {
            self.selectedPage = 0
            self._segmentView.selectedSegmentIndex = 0
        }
    }
    // Called at: self._pagerNode.scrollToPage(at: selectedPage, animated: true)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // self.isScrolling = false
        let scrollViewContentOffsetX = scrollView.contentOffset.x
        let pageWidth = self.view.bounds.width - 1
        if scrollViewContentOffsetX > pageWidth {
            self.selectedPage = 1
            self._segmentView.selectedSegmentIndex = 1
        } else {
            self.selectedPage = 0
            self._segmentView.selectedSegmentIndex = 0
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
        var barFrame = self.seletionBar.frame
        barFrame.origin.x = barFrame.size.width * CGFloat(scrollView.contentOffset.x) / self.view.bounds.width
        self.seletionBar.frame = barFrame
    }
}
extension ListASPagerNode: ASPagerDataSource {
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return self._park.sections.count
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let parkSection = self._park.sections[index]
        let page        = index
        let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
            let view = TableAsViewController(page: page, type: parkSection.type, park: self._park, parkSection: self._park.sections[page])
            view.delegate = self
            return view
        }, didLoad: nil)
        
        node.style.preferredSize = pagerNode.bounds.size
        
        return node
    }
    
}

extension ListASPagerNode: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self._park.sections.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let node = ASCellNode()
            return node
        }
    }
}

extension ListASPagerNode : ParkASCellNodeDelegate {
    func didSelectPark(_ item: ParkItem2) {
        let detailTableViewConroller = DetailASViewController(park: self._park, parkItem: item)
        detailTableViewConroller.isHeroEnabled = true
        self.navigationController?.pushViewController(detailTableViewConroller, animated: true)
    }
}
