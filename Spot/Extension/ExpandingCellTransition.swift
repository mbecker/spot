//
//  ExpandingCellTransition.swift
//  ExpandingCells
//
//  Created by Matthew Cheok on 24/11/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

import UIKit

import Foundation

public extension UIScreen {
  /**
   Return a view snapshot containing the status bar.
   - returns: The `UIView` snapshot.
   - author: Daniel Loewenherz
   - copyright: ©2016 Lionheart Software LLC
   - date: February 17, 2016
   */
  func statusBarView() -> UIView {
    let view = snapshotView(afterScreenUpdates: true)
    return view.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: (bounds).width, height: (bounds).height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)!
  }
  
  func statusBarView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, afterScreenUpdates: Bool, withCapInsets: UIEdgeInsets) -> UIView {
    let view = snapshotView(afterScreenUpdates: afterScreenUpdates)
    return view.resizableSnapshotView(from: CGRect(x: x, y: y, width: width, height: height), afterScreenUpdates: afterScreenUpdates, withCapInsets: withCapInsets)!
  }
}

private let kExpandingCellTransitionDuration: TimeInterval = 0.9

class ExpandingCellTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
  enum TransitionType {
    case None
    case Presenting
    case Dismissing
  }
  
  enum TransitionState {
    case Initial
    case Final
  }
  
  var type: TransitionType = .None
  var presentingController: UIViewController!
  var presentedController: UIViewController!
  
  var targetSnapshot: UIView!
  var targetContainer: UIView!
  
  var topRegionSnapshot: UIView!
  var bottomRegionSnapshot: UIView!
  var navigationBarSnapshot: UIView!
  
  init(type: TransitionType) {
    self.type = type
    super.init()
  }
  
  func sliceSnapshotsInBackgroundViewController(backgroundViewController: UIViewController, targetFrame: CGRect, targetView: UIView) {
    let view = backgroundViewController.view!
    let width = view.bounds.width
    let height = view.bounds.height
    
    // create top region snapshot
    view.snapshotView(afterScreenUpdates: true)
    topRegionSnapshot = view.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: width, height: targetFrame.minY), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)
//    topRegionSnapshot = UIScreen.main.statusBarView(x: 0, y: 0, width: width, height: targetFrame.minY, afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)
    
    // create bottom region snapshot
    bottomRegionSnapshot = view.resizableSnapshotView(from: CGRect(x: 0, y: targetFrame.maxY, width: width, height: height-targetFrame.maxY), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)
    
    // create target view snapshot
    targetSnapshot = targetView.snapshotView(afterScreenUpdates: false)
    targetContainer = UIView(frame: targetFrame)
    targetContainer.backgroundColor = UIColor.white
    targetContainer.clipsToBounds = true
    targetContainer.addSubview(targetSnapshot)
    
    // create navigation bar snapshot
    let barHeight = (backgroundViewController.navigationController?.navigationBar.frame.maxY)! > CGFloat(0) ? backgroundViewController.navigationController?.navigationBar.frame.maxY : UIApplication.shared.statusBarFrame.height
    
    if barHeight! > CGFloat(20) {
      UIGraphicsBeginImageContext(CGSize(width: width, height: barHeight!))
      view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
      let navigationBarImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      navigationBarSnapshot = UIImageView(image: navigationBarImage)
      navigationBarSnapshot.backgroundColor = backgroundViewController.navigationController?.navigationBar.barTintColor
      navigationBarSnapshot.contentMode = .bottom
      navigationBarSnapshot = UIScreen.main.statusBarView(x: 0, y: 0, width: width, height: barHeight!, afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)

    } else {
      navigationBarSnapshot = UIView(frame: CGRect(x: 0, y: 0, width: width, height: barHeight!))
      navigationBarSnapshot.backgroundColor = UIColor.white
    }
    
  }
  
  func configureViewsToState(state: TransitionState, width: CGFloat, height: CGFloat, targetFrame: CGRect, fullFrame: CGRect, foregroundView: UIView) {
    switch state {
    case .Initial:
      topRegionSnapshot.frame = CGRect(x: 0, y: 0, width: width, height: targetFrame.minY)
      bottomRegionSnapshot.frame = CGRect(x: 0, y: targetFrame.maxY + 0, width: width, height: height-targetFrame.maxY)
      targetContainer.frame = CGRect(x: targetFrame.origin.x, y: targetFrame.origin.y + 0, width: targetFrame.size.width, height: targetFrame.size.height)
      targetSnapshot.alpha = 1
      foregroundView.alpha = 0
      navigationBarSnapshot.sizeToFit()
      
    case .Final:
      topRegionSnapshot.frame = CGRect(x: 0, y: -targetFrame.minY, width: width, height: targetFrame.minY)
      bottomRegionSnapshot.frame = CGRect(x: 0, y: height, width: width, height: height-targetFrame.maxY)
      targetContainer.frame = fullFrame
      targetSnapshot.alpha = 0
      foregroundView.alpha = 1
    }
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return kExpandingCellTransitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let duration = transitionDuration(using: transitionContext)
    let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let containerView = transitionContext.containerView
    
    var foregroundViewController = toViewController
    var backgroundViewController = fromViewController
    print(":: TYPE - \(type)")
    if type == .Dismissing {
      foregroundViewController = fromViewController
      backgroundViewController = toViewController
    }
    
    
    //create a new button
    // let button: UIButton = UIButton(type: .custom)
    // set image for button
    // let cancelImage: UIImage = StyleKitName.imageOfCancel
    // button.setImage(cancelImage, for: UIControlState.normal)
    // button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
    // let barButton = UIBarButtonItem(customView: button)
    // backgroundViewController.navigationItem.leftBarButtonItem = barButton
    
    containerView.frame = backgroundViewController.view.frame
    containerView.backgroundColor = UIColor.white
    print(":: TRANSITION - frame: \(containerView.frame)")
    containerView.addSubview(backgroundViewController.view)
    containerView.addSubview(foregroundViewController.view)
    
    // get target view
    var targetViewController = backgroundViewController
    if let navController = targetViewController as? UINavigationController {
      // targetViewController = navController.topViewController!
    }
    let targetViewMaybe = (targetViewController as? ExpandingTransitionPresentingViewController)?.expandingTransitionTargetViewForTransition(transition: self)
    
    assert(targetViewMaybe != nil, "Cannot find target view in background view controller")
    
    let targetView = targetViewMaybe!
    
    // setup animation
    let targetFrame = backgroundViewController.view.convert(targetView.frame, from: targetView.superview)
    
    if type == .Presenting {
      sliceSnapshotsInBackgroundViewController(backgroundViewController: backgroundViewController, targetFrame: targetFrame, targetView: targetView)
      (foregroundViewController as? ExpandingTransitionPresentedViewController)?.expandingTransition(transition: self, navigationBarSnapshot: navigationBarSnapshot)
    }
    else {
      navigationBarSnapshot.frame = containerView.convert(navigationBarSnapshot.frame, from: navigationBarSnapshot.superview)
    }
    
    
    targetContainer.addSubview(foregroundViewController.view)
    
    
    containerView.addSubview(targetContainer)
    containerView.addSubview(topRegionSnapshot)
    containerView.addSubview(bottomRegionSnapshot)
    containerView.addSubview(navigationBarSnapshot)
    
    let width = backgroundViewController.view.bounds.width
    let height = backgroundViewController.view.bounds.height
    
    let preTransition: TransitionState = (type == .Presenting ? .Initial : .Final)
    let postTransition: TransitionState = (type == .Presenting ? .Final : .Initial)
    
    configureViewsToState(state: preTransition, width: width, height: height, targetFrame: targetFrame, fullFrame: foregroundViewController.view.frame, foregroundView: foregroundViewController.view)
    
    // perform animation
    backgroundViewController.view.isHidden = true
    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
      
      self.configureViewsToState(state: postTransition, width: width, height: height, targetFrame: targetFrame, fullFrame: foregroundViewController.view.frame, foregroundView: foregroundViewController.view)
      
      if self.type == .Presenting {
        self.navigationBarSnapshot.frame.size.height = 0
      }
      
      
      }, completion: {
        (finished) in
        
        self.targetContainer.removeFromSuperview()
        self.topRegionSnapshot.removeFromSuperview()
        self.bottomRegionSnapshot.removeFromSuperview()
        self.navigationBarSnapshot.removeFromSuperview()
        
        containerView.addSubview(foregroundViewController.view)
        backgroundViewController.view.isHidden = false
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
  }
  
  func offsetView(view: UIView, offset: CGFloat) -> UIView {
    view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + offset, width: view.frame.size.width, height: view.frame.size.height)
    return view
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentingController = presenting
    if let navController = presentingController as? UINavigationController {
      presentingController = navController.topViewController
    }
    
    if presentingController is ExpandingTransitionPresentingViewController {
      type = .Presenting
      return self
    }
    else {
      type = .None
      return nil
    }
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if presentingController is ExpandingTransitionPresentingViewController {
      type = .Dismissing
      return self
    }
    else {
      type = .None
      return nil
    }
  }
  
}

@objc
protocol ExpandingTransitionPresentingViewController {
  func expandingTransitionTargetViewForTransition(transition: ExpandingCellTransition) -> UIView!
}

@objc
protocol ExpandingTransitionPresentedViewController {
  func expandingTransition(transition: ExpandingCellTransition, navigationBarSnapshot: UIView)
}
