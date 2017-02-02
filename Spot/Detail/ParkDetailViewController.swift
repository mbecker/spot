//
//  ParkDetailViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/1/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Down

class ParkDetailViewController: UIViewController {
    
    private var shadowImageView: UIImageView?
    let _scrollView = UIScrollView()
    let _park:          Park
    let _ref = FIRDatabaseReference()
    
    @IBOutlet var label: UILabel!
    
    init(park: Park){
        self._park = park
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        // Hide navigationBar hairline at the bottom
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = false
        
        // Hide text "Back"
        let backImage = UIImage(named: "back64")?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        self.navigationController?.navigationBar.tintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        
    }
    
    func changeStatusbarColor(color: UIColor){
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
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


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.visibleViewController?.title = self._park.parkName
        
        self._scrollView.frame = self.view.bounds
        self.view.addSubview(self._scrollView);
        let frame: CGRect = CGRect(x: 0, y: 0, width: self._scrollView.bounds.width, height: self._scrollView.bounds.height - (self.tabBarController?.tabBar.frame.height)! - 48)
        do {
            let downView = try DownView(frame: frame, markdownString: self._park.markdown!)
            self._scrollView.addSubview(downView)
        } catch {
            print("Error: DownView")
        }
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
