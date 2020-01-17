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
		NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)

		let dropInteraction = UIDropInteraction(delegate: self)
		textOutputView.addInteraction(dropInteraction)
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

	@objc func hideKeyboard() {
		UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: {
			self.bottomHeight.constant = 8
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
}


extension TranslateViewController: UIDropInteractionDelegate {
	
	func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {

		if session.localDragSession == nil {
			showInput()
		}

		return false
	}
}


extension TranslateViewController: UITextViewDelegate {

	func textViewDidChange(_ textView: UITextView) {
		guard textView == textInputView else { return }

		pair = pair.with(sourceText: textView.text)
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		guard textView == textInputView else { return }

		showInput()
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		guard textView == textInputView else { return }

		// meh, could not find another way to reliably detect hiding keyboard
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
			self.hideKeyboard()
		}
	}
}
