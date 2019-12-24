//
//  ActionViewController.swift
//  Share
//
//  Created by Oliver Michalak on 23.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import MobileCoreServices


class ShareViewController: UIViewController {
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var okButton: UIBarButtonItem!
	@IBOutlet weak var textInputView: UITextView!
	@IBOutlet weak var translateButton: UIButton!
	@IBOutlet weak var textOutputView: UITextView!
	@IBOutlet weak var busyView: UIVisualEffectView!

	lazy var enabledColor = UIView().tintColor
	lazy var disabledColor = UIColor.lightGray.withAlphaComponent(0.2)

	let engine = TranslationEngine()

	var pair: TextPair = TextPair(sourceText: "", sourceLang: nil, destText: "", destLang: PreferencesController.shared.lang) {
		didSet {
			let source = pair.sourceText
			if textInputView.text != source {
				textInputView.text = source
			}
			let hasInput = !pair.sourceText.isEmpty
			translateButton.isEnabled = hasInput
			translateButton.setTitle("Translate into \(pair.destLang)", for: .normal)
			translateButton.backgroundColor = hasInput ? enabledColor : disabledColor

			if let dest = pair.destText {
				if textOutputView.text != dest {
					textOutputView.text = dest
				}
				let hasOutput = !dest.isEmpty
				okButton.isEnabled = hasOutput
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		extensionContext!.inputItems.extractText { (text) in
			self.pair = self.pair.with(sourceText: self.pair.sourceText + text)
		}
	}

	@IBAction func translate() {
		guard !pair.sourceText.isEmpty else { return }
		
		view.endEditing(true)
		pair = pair.with(destText: "")
		busyView.isHidden = false
		engine.translate(pair) { [weak self] result in
			guard let self = self else { return }
			self.busyView.isHidden = true

			switch result {
			case .success(let destPair):
				self.pair = destPair
			case .failure(let error):
				switch error {
				case .empty:
					print("No translation found")
				case .network(let message):
					print(message)
				}
			}
		}
	}

	@IBAction func tapBackground(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}

	@IBAction func cancel() {
		extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
	}
	
	@IBAction func save() {
		let provider = NSItemProvider(item: pair.destText as NSSecureCoding?, typeIdentifier: kUTTypeText as String)
		let item = NSExtensionItem()
		item.attachments = [provider]
		extensionContext!.completeRequest(returningItems: [item], completionHandler: nil)
	}
}
