//
//  TranslationViewController+Action.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit


extension TranslateViewController {
	
	@IBAction func clearInput() {
		switchToInput()
		self.pair = self.pair.with(sourceText: "", destText: "")
		textInputView.becomeFirstResponder()
	}

	@IBAction func shareOutput() {
		switchToOutput()
		guard let text = pair.destText, !text.isEmpty else { return }

		let shareSheet = UIActivityViewController(activityItems: [text], applicationActivities: nil)
		shareSheet.completionWithItemsHandler = { [weak self] (activityType, completed, items, error) in
			guard let self = self, completed, let items = items, error == nil else { return }
			
			self.pair = self.pair.with(sourceText: "", destText: "")
			items.extractText { (text) in
				self.pair = self.pair.with(sourceText: self.pair.sourceText + text)
			}
		}
		self.present(shareSheet, animated: true, completion: nil)
	}

	@IBAction func translate() {
		guard !pair.sourceText.isEmpty else { return }
		
		switchToOutput()
		pair = pair.with(destText: "")
		Root.shared.isBusy = true
		engine.translate(pair) { [weak self] result in
			guard let self = self else { return }
			Root.shared.isBusy = false

			switch result {
			case .success(let destPair):
				self.pair = destPair
				if let text = destPair.destText, !text.isEmpty {
					UIPasteboard.general.string = text
					Root.shared.showBanner(message: "Copied: \(text)")
				}

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
