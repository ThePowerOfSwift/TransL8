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
	
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var busyView: UIVisualEffectView!

	let engine = TranslationEngine()

	var pair: TextPair = TextPair(sourceText: "", sourceLang: nil, destText: "", destLang: PreferencesController.shared.lang)

	override func viewDidLoad() {
		super.viewDidLoad()
		
		extensionContext!.inputItems.extractText { (text) in
			self.pair = self.pair.with(sourceText: self.pair.sourceText + text)
			self.translate()
		}
	}

	func translate() {
		guard !pair.sourceText.isEmpty else {
			extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
			return
		}
		
		pair = pair.with(destText: "")
		self.infoLabel.text = "→ \(pair.destLang): \(pair.sourceText) ..."
		engine.translate(pair) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let destPair):
				self.pair = destPair
				if let text = destPair.destText, !text.isEmpty {
					UIPasteboard.general.string = text
					self.infoLabel.text = "Copied: \(text)"
					DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) { [weak self] in
						guard let self = self else { return }

						let provider = NSItemProvider(item: self.pair.destText as NSSecureCoding?, typeIdentifier: kUTTypeText as String)
						let item = NSExtensionItem()
						item.attachments = [provider]
						self.extensionContext!.completeRequest(returningItems: [item], completionHandler: nil)
					}
				}
				else {
					self.showErrorAndTerminate(message: "Empty translation!")
				}

			case .failure(let error):
				switch error {
				case .empty:
					self.showErrorAndTerminate(message: "No translation found")
				case .network(let message):
					self.showErrorAndTerminate(message: message)
				}
			}
		}
	}

	func showErrorAndTerminate(message: String) {
		self.infoLabel.text = message
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) { [weak self] in
			guard let self = self else { return }

			self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
		}
	}
}
