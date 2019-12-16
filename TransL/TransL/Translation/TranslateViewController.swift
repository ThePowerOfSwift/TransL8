//
//  ViewController.swift
//  TransL
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import Moya


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
	
  private let service = MoyaProvider<DeepLService>() // plugins: [NetworkLoggerPlugin(verbose: true)])

	@IBAction func clearInput() {
		textInputView.text = ""
		textInputView.becomeFirstResponder()
	}

	@IBAction func copyOutput() {
		guard let text = textOutputView.text else { return }

		UIPasteboard.general.string = text
		Root.shared.showBanner(message: "Copied: \(text)")
	}

	@IBAction func translate() {
		guard let text = textInputView.text, text.count > 0 else { return }
		view.endEditing(true)

		let sourcePair = TranslationPair(sourceText: text, sourceLang: nil, destText: nil, destLang: PreferencesController.shared.lang)

		textOutputView.text = ""
		if let cachedPair = PreferencesController.shared.pairs.first(where: { $0 == sourcePair }) {
			textOutputView.text = cachedPair.destText
		}
		else {
			Root.shared.isBusy = true
			service.request(.translate(text)) { [weak self] result in
				guard let self = self else { return }

				Root.shared.isBusy = false
				switch result {
				case let .success(response):
					if let resultContainer = try? response.data.decoded() as DeepL.TranslationContainer,
						resultContainer.translations.count > 0 {
						let destText = resultContainer.translations.compactMap({ $0.text }).joined(separator: "\n")
						let sourceLang = resultContainer.translations.first!.detectedSourceLanguage
						let pair = TranslationPair(sourceText: text, sourceLang: sourceLang, destText: destText, destLang: sourcePair.destLang)
						PreferencesController.shared.pairs.append(pair)
						self.textOutputView.text = destText
					}
					else {
						Root.shared.showBanner(message: "No translation found")
					}
				case let .failure(error):
					Root.shared.showBanner(message: error.localizedDescription)
				}
			}
		}
	}
}

