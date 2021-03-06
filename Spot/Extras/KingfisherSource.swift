//
//  KingfisherRemote.swift
//  Spot
//
//  Created by Mats Becker on 12/2/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import Kingfisher
import ImageSlideshow
import NVActivityIndicatorView

public class KingfisherSource: NSObject, InputSource {
    var url: URL
    var placeholder: UIImage?
    
    public init(url: URL) {
        self.url = url
        super.init()
    }
    
    public init(url: URL, placeholder: UIImage) {
        self.url = url
        self.placeholder = placeholder
        super.init()
    }
    
    public init?(urlString: String) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            return nil
        }
    }
    
    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
        imageView.kf.indicatorType = .custom(indicator: BallPulseIndicator(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 88 / 2, y: CGFloat(82 + 82 + 82) / 2 - CGFloat(44 / 2), width: CGFloat(88), height: CGFloat(44))))
        imageView.kf.setImage(with: self.url, placeholder: self.placeholder, options: [.transition(.fade(0.2))], progressBlock: nil) { (image, _, _, _) in
            if let image = image {
                callback(image)
            }
        }
    }
}

public class ImageRoundedSource: NSObject, InputSource {
    let image: UIImage
    let cornerRadius: CGFloat
    public init(image: UIImage, cornerRadius: CGFloat) {
        self.image = image
        self.cornerRadius = cornerRadius
    }
    
    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
        print(imageView.bounds)
        imageView.cornerRadius = self.cornerRadius
        imageView.image = self.image
    }
}

struct BallPulseIndicator: Indicator {
    let view: UIView = UIView()
    let loadingIndicatorView: NVActivityIndicatorView
    
    func startAnimatingView() {
        loadingIndicatorView.startAnimating()
        loadingIndicatorView.isHidden = false
        view.isHidden = false
    }
    func stopAnimatingView() {
        loadingIndicatorView.isHidden = true
        view.isHidden = true
    }
    
    init() {
        loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 88 / 2, y: CGFloat(82 + 82 + 82) / 2 - CGFloat(44 / 2), width: CGFloat(88), height: CGFloat(44)), type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
        view.addSubview(loadingIndicatorView)
    }
    
    init(frame: CGRect){
        loadingIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulse, color: UIColor(red:0.93, green:0.40, blue:0.44, alpha:1.00), padding: 0.0)
        view.addSubview(loadingIndicatorView)
    }
    
}
