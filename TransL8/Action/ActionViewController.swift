//
//  ActionViewController.swift
//  Action
//
//  Created by Oliver Michalak on 23.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var translateButton: UIButton!
	@IBOutlet weak var textInputView: UITextView!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var busyView: UIVisualEffectView!

	let engine = TranslationEngine()

	var pair: TextPair = TextPair(sourceText: "", sourceLang: nil, destText: "", destLang: PreferencesController.shared.lang) {
		didSet {
			let source = pair.sourceText
			if textInputView.text != source {
				textInputView.text = source
			}
			let hasInput = !pair.sourceText.isEmpty
			translateButton.setTitle("→ \(pair.destLang)", for: .normal)
			translateButton.isEnabled = hasInput
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		extensionContext!.inputItems.extractText { (text) in
			self.pair = self.pair.with(sourceText: self.pair.sourceText + text)
		}
	}

	@IBAction func cancel() {
		extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
	}
	
	@IBAction func translate() {
		guard !pair.sourceText.isEmpty else { return }
		
		view.endEditing(true)
		infoLabel.text = ""
		pair = pair.with(destText: "")
		busyView.isHidden = false
		engine.translate(pair) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let destPair):
				self.pair = destPair
				if let text = destPair.destText, !text.isEmpty {
					UIPasteboard.general.string = text
					self.infoLabel.text = "Copied: \(text)"
					DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) { [weak self] in
						guard let self = self else { return }

						let provider = NSItemProvider(item: self.pair.destText as NSSecureCoding?, typeIdentifier: kUTTypeText as String)
						let item = NSExtensionItem()
						item.attachments = [provider]
						self.extensionContext!.completeRequest(returningItems: [item], completionHandler: nil)
					}
				}

			case .failure(let error):
				switch error {
				case .empty:
					self.infoLabel.text = "No translation found"
				case .network(let message):
					self.infoLabel.text = message
				}
				self.busyView.isHidden = true
			}
		}
	}
}
