//
//  CameraSpotViewController.swift
//  Spot
//
//  Created by Mats Becker on 1/30/17.
//  Copyright © 2017 safari.digital. All rights reserved.
//

import UIKit

protocol CameraSpotViewControllerDelegate {
    func camerSpotViewController(cameraSpotViewController: CameraSpotViewController, image: UIImage)
    func dismiss()
}

class CameraSpotViewController: UIViewController {
    
    var image: UIImage
    var delegate: CameraSpotViewControllerDelegate?
    
    init(image: UIImage){
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = self.image
        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
        
        let okButton = UIButton(frame: CGRect(x: self.view.frame.width - 150, y: self.view.frame.height - 24 - 12, width: 100, height: 24))
        okButton.setBackgroundColor(color: UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00), forState: .normal)
        okButton.setBackgroundColor(color: UIColor(red:0.80, green:0.82, blue:0.85, alpha:1.00), forState: .highlighted)
        okButton.tintColor = UIColor.black
        okButton.setTitle("OK", for: .normal)
        okButton.addTarget(self, action: #selector(buttonAction), for: UIControlEvents.touchUpInside)
        self.view.addSubview(okButton)
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height - 24 - 12, width: 100, height: 24))
        cancelButton.setBackgroundColor(color: UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00), forState: .normal)
        cancelButton.setBackgroundColor(color: UIColor(red:0.80, green:0.82, blue:0.85, alpha:1.00), forState: .highlighted)
        cancelButton.tintColor = UIColor.black
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(buttonDismiss), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton)
    }
    
    func buttonAction() {
        delegate?.camerSpotViewController(cameraSpotViewController: self, image: self.image)
    }
    
    func buttonDismiss() {
        delegate?.dismiss()
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
