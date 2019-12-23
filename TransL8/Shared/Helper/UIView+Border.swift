//
//  NSView+Border.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit

extension UIView {
  
  @objc var borderColor: UIColor? {
    set {
      if let color = newValue {
        layer.borderColor = color.cgColor
      }
      else {
        layer.borderColor = nil
      }
    }
    get {
      if let color = layer.borderColor {
        return UIColor(cgColor:color)
      }
      return nil
    }
  }
  
  @objc var borderWidth: CGFloat {
    set {
      clipsToBounds = true
      layer.borderWidth = (1 == newValue ? 1 / UIScreen.main.scale : newValue)
    }
    get {
      return layer.borderWidth
    }
  }
  
  @objc var borderRadius: CGFloat {
    set {
      clipsToBounds = true
      layer.cornerRadius = newValue
    }
    get {
      return layer.cornerRadius
    }
  }
}
