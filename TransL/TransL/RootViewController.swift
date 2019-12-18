//
//  RootViewController.swift
//  kite
//
//  Created by kreait on 10.09.18.
//  Copyright © 2018 kreait. All rights reserved.
//

import UIKit


class Root {
  
  static let shared = Root()

	var isBusy = false {
		didSet {
			rootViewController?.isBusy = isBusy
		}
	}

  func showBanner(message: String) {
    rootViewController?.showBanner(message: message)
  }

  func hideBanner() {
    rootViewController?.hideBanner()
  }

  private var rootViewController: RootViewController? {
    return UIApplication.shared.keyWindow?.rootViewController as? RootViewController
  }
}

class RootViewController: UIViewController {
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var busyView: UIVisualEffectView!
  @IBOutlet weak var bannerView: UIView!
  @IBOutlet weak var bannerLabel: UILabel!
  @IBOutlet weak var bannerTopContraint: NSLayoutConstraint!

	private var autoHideTimer: Timer?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// hide properly
		self.bannerTopContraint.constant = -self.bannerView.frame.size.height
			self.view.layoutIfNeeded()
		self.bannerView.isHidden = true
	}

  var isBusy = false {
    didSet {
      if isBusy {
        self.busyView.alpha = 0
        busyView.isHidden = false
        UIView.animate(withDuration: .AnimationDuration) {
          self.busyView.alpha = 1
        }
      }
      else {
        UIView.animate(withDuration: .AnimationDuration, animations: {
          self.busyView.alpha = 0
        }, completion: { [weak self] _ in
          self?.busyView.isHidden = true
        })
      }
    }
  }
}

extension RootViewController {

  func showBanner(message: String) {
    self.bannerView.isHidden = false
    self.bannerLabel.text = message
		self.view.layoutIfNeeded()
    UIView.animate(withDuration: 2 * .AnimationDuration, animations: {
      self.bannerTopContraint.constant = 40
			self.view.layoutIfNeeded()
    }, completion: { [weak self] _ in
      guard let self = self else { return }
      
      self.autoHideTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
        self?.hideBanner()
      }

    })
  }
  
  @IBAction func hideBanner() {
    if autoHideTimer != nil {
      autoHideTimer?.invalidate()
      autoHideTimer = nil
    }

		self.view.layoutIfNeeded()
    UIView.animate(withDuration: .AnimationDuration, animations: {
      self.bannerTopContraint.constant = -self.bannerView.frame.size.height
			self.view.layoutIfNeeded()
    }, completion: { [weak self] _ in
      self?.bannerView.isHidden = true
    })
  }
}
