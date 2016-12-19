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

protocol ChangePage {
    func changePage(tab: Int, showSelectedPage: Bool)
}


class ListASPagerNode: ASViewController<ASDisplayNode> {
    private var shadowImageView: UIImageView?
    /**
     * AsyncDisplayKit
     */
    var pagerNode: ASPagerNode {
        return node as! ASPagerNode
    }
    
    /**
     * Firebase
     */
    let ref         :   FIRDatabaseReference
    
    var segmentView: SMSegmentView!
    var margin: CGFloat = 10.0
    var seletionBar: UIView = UIView()
    var selectedPage: Int = 0
    var showSelectedPage: Bool = false
    var dataLoaded: Bool = false
    
    var park: Park
    
    
    init(park: Park){
        self.ref = FIRDatabase.database().reference()
        self.park = park
        
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
        
        self.segmentView = SMSegmentView(frame: CGRect.zero, dividerColour: UIColor.clear, dividerWidth: 1.0, segmentAppearance: appearance)
        
        for parkSection in self.park.sections {
            self.segmentView.addSegmentWithTitle(parkSection.name, onSelectionImage: nil, offSelectionImage: nil)
        }

        super.init(node: ASPagerNode.init())
        
        self.segmentView.selectedSegmentIndex   = 0
        
        self.pagerNode.delegate     = self
        self.pagerNode.dataSource   = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSelectionBar(){
        if self.park.sections.count > 1 {
            self.seletionBar.removeFromSuperview()
            self.seletionBar.frame = CGRect(x: 0.0, y: self.segmentView.bounds.height - 2, width: self.segmentView.bounds.width/CGFloat(self.segmentView.numberOfSegments), height: 2.0)
            self.seletionBar.backgroundColor = UIColor.black
            self.placeSelectionBar()
            self.segmentView.addSubview(self.seletionBar)
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
        self.segmentView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = false
        
        if self.showSelectedPage && !self.dataLoaded{
            self.pagerNode.reloadData {
                self.dataLoaded = true
                self.showSelectedPage = false
                self.segmentView.selectedSegmentIndex = self.selectedPage
                self.pagerNode.scrollToPage(at: self.selectedPage, animated: false)
            }
        } else if self.showSelectedPage {
            self.showSelectedPage = false
            self.segmentView.selectedSegmentIndex = self.selectedPage
            self.pagerNode.scrollToPage(at: self.selectedPage, animated: false)
        }
        
        self.navigationController!.navigationBar.addSubview(self.segmentView)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.pagerNode.view.backgroundColor = UIColor.clear
        self.pagerNode.view.isScrollEnabled = false
        
        /*
         Init SMsegmentView
         Set divider colour and width here if there is a need
         */
        let segmentFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationController!.navigationBar.bounds.height)
        self.segmentView.frame = segmentFrame
        self.segmentView.backgroundColor = UIColor.clear
        
        self.segmentView.layer.cornerRadius = 0.0
        self.segmentView.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        self.segmentView.layer.borderWidth = 0.0
        
        self.segmentView.addTarget(self, action: #selector(selectSegmentInSegmentView(segmentView:)), for: .valueChanged)
        // self.navigationController!.navigationBar.addSubview(self.segmentView)
        
        /**
         * Selection indicator for segmented view
         */
        self.initSelectionBar()
        
    }
    
    func placeSelectionBar() {
        var barFrame = self.seletionBar.frame
        barFrame.origin.x = barFrame.size.width * CGFloat(self.selectedPage)
        self.seletionBar.frame = barFrame
    }
    
    func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        self.selectedPage = segmentView.selectedSegmentIndex
        UIView.animate(withDuration: 0.3, animations: {
            self.placeSelectionBar()
        })
        self.pagerNode.scrollToPage(at: self.selectedPage, animated: true)
    }
    
}

extension ListASPagerNode: ChangePage {
    
    func changePage(tab: Int, showSelectedPage: Bool){
        self.showSelectedPage = showSelectedPage
        switch tab {
        case 0:
            self.selectedPage = 0
        case 1:
            self.selectedPage = 1
        default:
            self.selectedPage = 0
        }
        self.placeSelectionBar()
    }
    
}

extension ListASPagerNode: ASPagerDelegate {
    func pagerNode(_ pagerNode: ASPagerNode, constrainedSizeForNodeAt index: Int) -> ASSizeRange {
        return ASSizeRange(min: CGSize(width: 10, height: 100), max: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
    }
    
}
extension ListASPagerNode: ASPagerDataSource {
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return self.park.sections.count
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let parkSection = self.park.sections[index]
        let page        = index
        let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
            let view = TableAsViewController(page: page, park: self.park, parkSection: self.park.sections[index])
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
        return self.park.sections.count
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
        let detailTableViewConroller = DetailASViewController(parkItem: item)
        self.navigationController?.pushViewController(detailTableViewConroller, animated: true)
    }
}
