//
//  TranslateViewController+Keyboard.swift
//  TransL8
//
//  Created by Oliver Michalak on 30.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit


extension TranslateViewController {
	
	func setupKeyboard() {		
		NotificationCenter.default.addObserver(self, selector: #selector(changeKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(changeKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(changeKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	@objc func changeKeyboard(notification: Notification) {
		var endFrame = CGRect.zero
		
		if let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve {
			animationOptions = [UIView.AnimationOptions.layoutSubviews,  UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))]
		}
		
		if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
			animationDuration = duration
		}
		
		if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
			endFrame = frame
		}
		
		let height = max(0, endFrame.height - view.layoutMargins.bottom) + 8

		UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: {
			self.bottomHeight.constant = height
			self.view.layoutIfNeeded()
		}, completion: nil)
	}

	func hideKeyboard() {
		UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: {
			self.bottomHeight.constant = 8
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
}
