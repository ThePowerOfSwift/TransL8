//
//  TranslationViewController+Action.swift
//  TransL
//
//  Created by Oliver Michalak on 19.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit


extension TranslateViewController {
	
	@IBAction func clearInput() {
		self.pair = self.pair.with(sourceText: "", destText: "")
		textInputView.becomeFirstResponder()
	}

	@IBAction func copyInput() {
		guard let pair = PreferencesController.shared.pairCache.first else { return }

		self.pair = pair
	}

	@IBAction func recordMicInput() {
		Root.shared.showBanner(message: "(not implemented)")
	}

	@IBAction func copyOutput() {
		guard let text = pair.destText, !text.isEmpty else { return }
		
		UIPasteboard.general.string = text
		Root.shared.showBanner(message: "Copy: \(text)")
	}

	@IBAction func shareOutput() {
		guard let text = pair.destText, !text.isEmpty else { return }

		let shareSheet = UIActivityViewController(activityItems: [text], applicationActivities: nil)
		self.present(shareSheet, animated: true, completion: nil)
	}

	@IBAction func translate() {
		guard !pair.sourceText.isEmpty else { return }
		
		view.endEditing(true)
		pair = pair.with(destText: "")
		Root.shared.isBusy = true
		engine.translate(pair) { [weak self] result in
			Root.shared.isBusy = false
			guard let self = self else { return }

			switch result {
			case .success(let destPair):
				self.pair = destPair
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
