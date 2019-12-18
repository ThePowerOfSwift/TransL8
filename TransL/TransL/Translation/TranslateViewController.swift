//
//  ViewController.swift
//  TransL
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import AVFoundation


class TranslateViewController: UIViewController, UITextViewDelegate {
	
	@IBOutlet weak var textInputView: UITextView!
	@IBOutlet weak var clipboardInputButton: UIButton!
	@IBOutlet weak var clipboardTriangleView: UIImageView!
	@IBOutlet weak var cameraInputButton: UIButton!
	@IBOutlet weak var micInputButton: UIButton!
	@IBOutlet weak var clearInputButton: UIButton!
	
	@IBOutlet weak var translateButton: UIButton!
	
	@IBOutlet weak var textOutputView: UITextView!
	@IBOutlet weak var clipboardOutputButton: UIButton!
	@IBOutlet weak var shareOutputButton: UIButton!
	@IBOutlet weak var speakOutputButton: UIButton!
	
	private let engine = Engine()
	private lazy var synthesizer: AVSpeechSynthesizer = {
		let synth = AVSpeechSynthesizer()
//		synth.delegate = self
		return synth
	}()

	private lazy var enabledColor = UIView().tintColor
	private lazy var disabledColor = UIColor.lightGray.withAlphaComponent(0.2)

	var pair: TextPair = TextPair(sourceText: "", sourceLang: nil, destText: "", destLang: PreferencesController.shared.lang) {
		didSet {
			let source = pair.sourceText
			if textInputView.text != source {
				textInputView.text = source
			}
			let hasInput = !pair.sourceText.isEmpty
			clearInputButton.isHidden = !hasInput
			translateButton.isEnabled = hasInput
			translateButton.backgroundColor = hasInput ? enabledColor : disabledColor

			if let dest = pair.destText {
				if textOutputView.text != dest {
					textOutputView.text = dest
				}
				let hasOutput = !dest.isEmpty
				clipboardOutputButton.isEnabled = hasOutput
				shareOutputButton.isEnabled = hasOutput
				speakOutputButton.isEnabled = hasOutput
				clipboardOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
				shareOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
				speakOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
			}
			
			let hasClips = !PreferencesController.shared.pairCache.isEmpty
			clipboardInputButton.isEnabled = hasClips
			clipboardInputButton.tintColor = hasClips ? enabledColor : disabledColor
			clipboardTriangleView.isHidden = !hasClips
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let interaction = UIContextMenuInteraction(delegate: self)
		clipboardInputButton.addInteraction(interaction)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// preferences could have changed lang
		pair = pair.with(destLang: PreferencesController.shared.lang)

		if pair.sourceText.isEmpty {
			if let text = UIPasteboard.general.string, !text.isEmpty {
				pair = pair.with(sourceText: text)
			}
			else {
				textInputView.becomeFirstResponder()
			}
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		pair = pair.with(sourceText: textView.text)
	}
}

extension TranslateViewController: UIContextMenuInteractionDelegate {

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		
		let list = PreferencesController.shared.pairCache
		guard !list.isEmpty else {
			return nil
		}
		
		let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
			var actions = [UIMenuElement]()
			for idx in 0..<min(10, list.count) {
				let pair = list[idx]
				let action = UIAction(title: pair.sourceText) { [weak self] action in
					guard let self = self else { return }

					self.pair = pair
				}
				actions.append(action)
			}
			let action = UIAction(title: "Clear", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
				guard let self = self else { return }

				PreferencesController.shared.pairCache = []
				self.pair = self.pair.with(sourceText: "", destText: "")
			}
			actions.append(action)
			return UIMenu(title: "", children: actions)
		}
		return configuration
	}
}

extension TranslateViewController {
	
	@IBAction func clearInput() {
		self.pair = self.pair.with(sourceText: "", destText: "")
		textInputView.becomeFirstResponder()
	}

	@IBAction func copyInput() {
		guard let pair = PreferencesController.shared.pairCache.first else { return }

		self.pair = pair
	}

	@IBAction func scanImageInput() {
		Root.shared.showBanner(message: "(not implemented))")
	}

	@IBAction func recordMicInput() {
		Root.shared.showBanner(message: "(not implemented))")
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

	@IBAction func speakOutput() {
		guard let text = pair.destText, !text.isEmpty else { return }

		// needs proper mapping
		// lang lookup broken if clipboarded and destLang != Pref.lang
		let langMapping = ["EN": "en-US", "DE": "de-DE"]
		
		synthesizer.stopSpeaking(at: .immediate)
		let phrase = AVSpeechUtterance.init(string: text)
		if let voice = AVSpeechSynthesisVoice(language: langMapping[PreferencesController.shared.lang]) {
			phrase.voice = voice
		}
		synthesizer.speak(phrase)
		Root.shared.showBanner(message: "Speak: \(text)")
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
