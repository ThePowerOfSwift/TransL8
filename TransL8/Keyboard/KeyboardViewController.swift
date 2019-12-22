//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Oliver Michalak on 22.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
	
	var nextKeyboardButton: UIButton!
	var retrieveButton: UIButton!
	var outputLabel: UILabel!
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		// Add custom view sizing constraints here
	}

	@objc func translateText() {
		let proxy = textDocumentProxy
		guard var text = proxy.selectedText, text.count > 0 else {
			outputLabel.text = "Please select a text first"
			return
		}

		text = String(text.reversed())
		proxy.insertText(text)
		
		outputLabel.text = text
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Perform custom UI setup here
		nextKeyboardButton = UIButton(type: .system)
		
		nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next board' button"), for: [])
		nextKeyboardButton.sizeToFit()
		nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
		
		nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
		
		view.addSubview(nextKeyboardButton)
		
		nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		
		retrieveButton = UIButton(frame: CGRect(x: 8, y: 8, width: 40, height: 20))
		retrieveButton.addTarget(self, action: #selector(translateText), for: .touchUpInside)
		retrieveButton.setImage(UIImage(systemName: "globe"), for: .normal)
		view.addSubview(retrieveButton)
		
		outputLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 300, height: 200))
		outputLabel.font = UIFont.systemFont(ofSize: 10)
		outputLabel.numberOfLines = 0
		outputLabel.text = "..."
		view.addSubview(outputLabel)
	}
	
	//	override func viewWillLayoutSubviews() {
	//		self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
	//		super.viewWillLayoutSubviews()
	//	}
	
	override func textWillChange(_ textInput: UITextInput?) {
		// The app is about to change the document's contents. Perform any preparation here.
	}
	
	override func textDidChange(_ textInput: UITextInput?) {
		// The app has just changed the document's contents, the document context has been updated.
		
		var textColor: UIColor
		let proxy = self.textDocumentProxy
		if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
			textColor = UIColor.white
		} else {
			textColor = UIColor.black
		}
		self.nextKeyboardButton.setTitleColor(textColor, for: [])
	}
	
}
