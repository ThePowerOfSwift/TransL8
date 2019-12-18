//
//  ViewController.swift
//  TransL
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit


class TranslateViewController: UIViewController {

	@IBOutlet weak var textInputView: UITextView!
	@IBOutlet weak var cameraInputButton: UIButton!
	@IBOutlet weak var micInputButton: UIButton!
	@IBOutlet weak var clearInputButton: UIButton!
	
	@IBOutlet weak var translateButton: UIButton!
	
	@IBOutlet weak var textOutputView: UITextView!
	@IBOutlet weak var clipboardOutputButton: UIButton!
	@IBOutlet weak var shareOutputButton: UIButton!
	@IBOutlet weak var speakOutputButton: UIButton!
	
	private let engine = Engine()

	@IBAction func translate() {
		guard let text = textInputView.text, text.count > 0 else { return }

		view.endEditing(true)
		textOutputView.text = ""
		Root.shared.isBusy = true
		engine.translate(text: text) { [weak self] result in
			Root.shared.isBusy = false
			
			switch result {
			case .success(let destText):
				self?.textOutputView.text = destText
			case .failure(let error):
				switch error {
				case .empty:
					Root.shared.showBanner(message: "No translation found")
				case .network(let message):
					Root.shared.showBanner(message: message)
				}
			}
		}
	}
}

extension TranslateViewController {

	@IBAction func clearInput() {
		textInputView.text = ""
		textInputView.becomeFirstResponder()
	}

	@IBAction func copyOutput() {
		guard let text = textOutputView.text else { return }

		UIPasteboard.general.string = text
		Root.shared.showBanner(message: "Copied: \(text)")
	}
}
