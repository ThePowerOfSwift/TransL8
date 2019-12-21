//
//  UIViewController+Embed.swift
//  kite
//
//  Created by kreait on 10.09.18.
//  Copyright © 2018 kreait. All rights reserved.
//

import UIKit


extension UIViewController {
  
  func embedChild(_ viewController: UIViewController, container: UIView) {

    container.translatesAutoresizingMaskIntoConstraints = false
    viewController.view.translatesAutoresizingMaskIntoConstraints = false

    viewController.view.frame = container.bounds
    addChild(viewController)
    container.addSubview(viewController.view)
    viewController.didMove(toParent: self)

    let contentView = ["contentView": viewController.view as Any]
    container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentView]-0-|", options: [], metrics: nil, views: contentView))
    container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[contentView]-0-|", options: [], metrics: nil, views: contentView))
    
    // force immediate update of AL
    container.setNeedsUpdateConstraints()
    container.setNeedsLayout()
    container.layoutIfNeeded()
    container.layoutSubviews()
  }
  
  func liftChild(_ container: UIView) {
    if let childViewController = childViewControllerOf(container) {
      childViewController.willMove(toParent: nil)
      childViewController.view.removeFromSuperview()
      childViewController.removeFromParent()
    }
  }
  
  func childViewControllerOf(_ view: UIView) -> UIViewController? {
    return children.filter({ $0.view.superview == view }).first
  }
}
