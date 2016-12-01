//
//  DetailViewController.swift
//  Spot
//
//  Created by Mats Becker on 12/1/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import ImageSlideshow

class DetailViewController: UIViewController {
    
    /**
     * Firebase
     */
    var ref: FIRDatabaseReference!
    
    let _parkItem: ParkItem2
    let slideShow: ImageSlideshow
    
    init(parkItem: ParkItem2) {
        self._parkItem = parkItem
        self.slideShow = ImageSlideshow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.ref = FIRDatabase.database().reference() // Firebase Databse: Set park image from firebase database
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self._parkItem.name
        self.navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = UIColor.white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 246))
        headerView.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.96, alpha:1.00)
        self.view.addSubview(headerView)
        headerView.addSubview(slideShow)
        
        slideShow.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 206)
        slideShow.backgroundColor = UIColor.white
        slideShow.cornerRadius = 10
        slideShow.slideshowInterval = 5.0
        slideShow.pageControlPosition = PageControlPosition.insideScrollView
        slideShow.pageControl.currentPageIndicatorTintColor = UIColor.white
        slideShow.pageControl.pageIndicatorTintColor = UIColor.lightGray
        slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        var imageSource: [KingfisherSource] = []
        
        if let publicURL: URL = self._parkItem.urlPublic {
            let remoteImage = KingfisherSource(url: publicURL)
            imageSource.append(remoteImage)
        }
        
        if self._parkItem.imagesPublic.count > 0 {
            for (_, url) in self._parkItem.imagesPublic {
                let remoteImage = KingfisherSource(url: url)
                imageSource.append(remoteImage)
            }
        }
        
        slideShow.setImageInputs(imageSource)
        
        let detailView = UIView(frame: CGRect(x: 10, y: 246, width: UIScreen.main.bounds.width - 20, height: 123))
        detailView.cornerRadius = 10
        detailView.backgroundColor = UIColor.white
        self.view.addSubview(detailView)
        
        let parkTitle = UILabel()
        parkTitle.attributedText = NSAttributedString(
            string: "@ Addo Elephant National Park",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightBlack),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        
        parkTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let detailPark = UILabel()
        detailPark.attributedText = NSAttributedString(
            string: "10mins ago",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium),
                NSForegroundColorAttributeName: UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00), // Lavender grey
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        detailPark.translatesAutoresizingMaskIntoConstraints = false
        
        let spottedBy = UILabel()
        detailPark.attributedText = NSAttributedString(
            string: "Spotted by: mbecker",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), // Bunker
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        spottedBy.translatesAutoresizingMaskIntoConstraints = false
        
        detailView.addSubview(parkTitle)
        detailView.addSubview(detailPark)
        detailView.addSubview(spottedBy)
        
        parkTitle.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 20).isActive = true
        parkTitle.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 20).isActive = true
        parkTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        detailPark.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -20).isActive = true
        detailPark.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 4).isActive = true
        
        spottedBy.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 20).isActive = true
        spottedBy.topAnchor.constraint(equalTo: parkTitle.bottomAnchor, constant: 8).isActive = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
