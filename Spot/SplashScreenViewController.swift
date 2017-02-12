//
//  SplashScreenViewController.swift
//  Spot
//
//  Created by Mats Becker on 2/11/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SplashScreenViewController: UIViewController {
    
    let launchImageView = UIImageView()
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0)
    let loadingLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.launchImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.launchImageView.image = #imageLiteral(resourceName: "SplahScreenAirBNB")
        
        self.loadingIndicatorView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 88 / 2, y: UIScreen.main.bounds.height / 2 + UIScreen.main.bounds.height / 4 - 44 / 2, width: 88, height: 44)
        self.loadingIndicatorView.startAnimating()
        
        self.loadingLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.height  - 44, width: self.view.bounds.width, height: 24)
        self.loadingLabel.textAlignment = .center
        self.loadingLabel.text = "Initializing parks ..."
        self.loadingLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        self.loadingLabel.textColor = UIColor.white
        
        self.view.addSubview(launchImageView)
        self.view.addSubview(loadingIndicatorView)
        self.view.addSubview(self.loadingLabel)
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
