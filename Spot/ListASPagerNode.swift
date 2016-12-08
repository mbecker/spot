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
    
    var selectedPage: Int = 0
    var showSelectedPage: Bool = false
    
    var park: Park
    var parkSections: [ParkSection]
    
    init(park: String, parkName: String, parkSections: [ParkSection]){
        self.park           = Park(name: parkName, path: "parkinfo/\(park)", sections: parkSections)
        self.parkSections   = parkSections
        self.ref = FIRDatabase.database().reference()
        
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = UIColor(red: 245.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0)
        appearance.segmentOffSelectionColour = UIColor.white
        appearance.titleOnSelectionFont = UIFont.systemFont(ofSize: 14.0)
        appearance.titleOffSelectionFont = UIFont.systemFont(ofSize: 14.0)
        appearance.contentVerticalMargin = 10.0
        
        self.segmentView = SMSegmentView(frame: CGRect.zero, dividerColour: UIColor.clear, dividerWidth: 1.0, segmentAppearance: appearance)
        
        for parkSection in parkSections {
            self.segmentView.addSegmentWithTitle(parkSection.name, onSelectionImage: nil, offSelectionImage: nil)
        }
        
        self.segmentView.selectedSegmentIndex = self.selectedPage
        
        super.init(node: ASPagerNode.init())
        
        self.pagerNode.delegate = self
        self.pagerNode.dataSource = self
    }
    
    func updateParkSections(park: String, parkName: String, parkSections: [ParkSection]){
        self.park           = Park(name: parkName, path: "parkinfo/\(park)", sections: parkSections)
        self.parkSections   = parkSections
        self.pagerNode.reloadData()
        
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = UIColor(red: 245.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0)
        appearance.segmentOffSelectionColour = UIColor.white
        appearance.titleOnSelectionFont = UIFont.systemFont(ofSize: 14.0)
        appearance.titleOffSelectionFont = UIFont.systemFont(ofSize: 14.0)
        appearance.contentVerticalMargin = 10.0
        self.segmentView.removeFromSuperview()
        self.segmentView = SMSegmentView(frame: CGRect.zero, dividerColour: UIColor.clear, dividerWidth: 1.0, segmentAppearance: appearance)
        for parkSection in parkSections {
            self.segmentView.addSegmentWithTitle(parkSection.name, onSelectionImage: nil, offSelectionImage: nil)
        }
        self.segmentView.selectedSegmentIndex = 0
        
        self.segmentView.removeFromSuperview()
        
        let segmentFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationController!.navigationBar.bounds.height)
        self.segmentView.frame = segmentFrame
        self.segmentView.backgroundColor = UIColor.clear
        
        self.segmentView.layer.cornerRadius = 0.0
        self.segmentView.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        self.segmentView.layer.borderWidth = 0.0
        self.segmentView.addTarget(self, action: #selector(selectSegmentInSegmentView(segmentView:)), for: .valueChanged)
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func catchNotification(notification:Notification) -> Void {
        print("Catch notification")
        
        guard let userInfo = notification.userInfo, let message  = userInfo["message"] as? String, let date = userInfo["date"] as? Date
            else {
                print("No userInfo found in notification")
                return
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
        shadowImageView?.isHidden = true
        
        if self.showSelectedPage {
            self.pagerNode.reloadData {
                self.showSelectedPage = false
                self.segmentView.selectedSegmentIndex = self.selectedPage
                self.pagerNode.scrollToPage(at: self.selectedPage, animated: false)
            }
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
        
        
        self.navigationController!.navigationBar.addSubview(self.segmentView)
        
        /**
         * Load data from firebase
         */
        self.ref.child(self.park.path).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get park value
            if let value = snapshot.value as? NSDictionary {
                self.park.loadDB(value: value)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    // SMSegment selector for .ValueChanged
    func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        /*
         Replace the following line to implement what you want the app to do after the segment gets tapped.
         */
        print("Select segment at index: \(segmentView.selectedSegmentIndex)")
        self.selectedPage = segmentView.selectedSegmentIndex
        self.pagerNode.scrollToPage(at: self.selectedPage, animated: false)
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
    }
    
}

extension ListASPagerNode: ASPagerDelegate {
    func pagerNode(_ pagerNode: ASPagerNode, constrainedSizeForNodeAt index: Int) -> ASSizeRange {
        return ASSizeRange(min: CGSize(width: 10, height: 100), max: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
    }
}
extension ListASPagerNode: ASPagerDataSource {
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return self.parkSections.count
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let parkSection = self.parkSections[index]
        let page        = index
        print(parkSection.name)
        let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
            let view = TableAsViewController(page: page, park: self.park, parkSection: parkSection)
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
        return self.parkSections.count
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

extension ListASPagerNode : ParkASCellNodeDelegate {
    func didSelectPark(_ item: ParkItem2) {
        let detailTableViewConroller = DetailASViewController(parkItem: item)
        self.navigationController?.pushViewController(detailTableViewConroller, animated: true)
    }
}
