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

	private var textInput: String = "" {
		didSet {
			if textInputView.text != textInput {
				textInputView.text = textInput
			}
			let hasInput = !textInput.isEmpty
			clearInputButton.isHidden = !hasInput
			translateButton.isEnabled = hasInput
			translateButton.backgroundColor = hasInput ? enabledColor : disabledColor
		}
	}
	
	private var textOutput: String = "" {
		didSet {
			if textOutputView.text != textOutput {
				textOutputView.text = textOutput
			}
			let hasOutput = !textOutputView.text.isEmpty
			clipboardOutputButton.isEnabled = hasOutput
			shareOutputButton.isEnabled = hasOutput
			speakOutputButton.isEnabled = hasOutput
			clipboardOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
			shareOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
			speakOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
			
			let hasClips = !PreferencesController.shared.pairCache.isEmpty
			clipboardInputButton.isEnabled = hasClips
			clipboardInputButton.tintColor = hasClips ? enabledColor : disabledColor
			clipboardTriangleView.isHidden = !hasClips
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		textInput = ""
		textOutput = ""
		clipboardInputButton.addInteraction(UIContextMenuInteraction(delegate: self))
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if textInput.isEmpty {
			if let text = UIPasteboard.general.string, !text.isEmpty {
				textInput = text
			}
			else {
				textInputView.becomeFirstResponder()
			}
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		textInput = textView.text
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
					self?.textInput = pair.sourceText
					self?.textOutput = pair.destText ?? ""
				}
				actions.append(action)
			}
			let action = UIAction(title: "Clear", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
				PreferencesController.shared.pairCache = []
				self?.textInput = ""
				self?.textOutput = ""
			}
			actions.append(action)
			return UIMenu(title: "", children: actions)
		}
		return configuration
	}
}

extension TranslateViewController {
	
	@IBAction func clearInput() {
		textInput = ""
		textOutput = ""
		textInputView.becomeFirstResponder()
	}

	@IBAction func copyInput() {
		guard let pair = PreferencesController.shared.pairCache.first else { return }
		
		textInput = pair.sourceText
		textOutput = pair.destText ?? ""
	}

	@IBAction func scanImageInput() {
		Root.shared.showBanner(message: "(not implemented))")
	}

	@IBAction func recordMicInput() {
		Root.shared.showBanner(message: "(not implemented))")
	}

	@IBAction func copyOutput() {
		guard !textOutput.isEmpty else { return }
		
		UIPasteboard.general.string = textOutput
		Root.shared.showBanner(message: "Copy: \(textOutput)")
	}

	@IBAction func shareOutput() {
		let shareSheet = UIActivityViewController(activityItems: [textOutput], applicationActivities: nil)
		self.present(shareSheet, animated: true, completion: nil)
	}

	@IBAction func speakOutput() {
		// needs proper mapping
		// lang lookup broken if clipboarded and destLang != Pref.lang
		let langMapping = ["EN": "en-US", "DE": "de-DE"]
		
		synthesizer.stopSpeaking(at: .immediate)
		let phrase = AVSpeechUtterance.init(string: textOutput)
		if let voice = AVSpeechSynthesisVoice(language: langMapping[PreferencesController.shared.lang]) {
			phrase.voice = voice
		}
		synthesizer.speak(phrase)
		Root.shared.showBanner(message: "Speak: \(textOutput)")
	}

	@IBAction func translate() {
		guard !textInput.isEmpty else { return }
		
		view.endEditing(true)
		textOutput = ""
		Root.shared.isBusy = true
		engine.translate(text: textInput) { [weak self] result in
			Root.shared.isBusy = false
			
			switch result {
			case .success(let destText):
				self?.textOutput = destText
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
