//
//  NSView+Border.swift
//  kreait-tools
//
//  Created by kreait on 27.07.18.
//  Copyright © 2018 kreait. All rights reserved.
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
