//
//  ViewController.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import Speech


class TranslateViewController: UIViewController {
	
	@IBOutlet weak var inputContainer: UIView!
	@IBOutlet weak var textInputView: UITextView!
	@IBOutlet weak var documentInputButton: UIButton!
	@IBOutlet weak var cameraInputButton: UIButton!
	@IBOutlet weak var micInputButton: UIButton!
	@IBOutlet weak var langInputLabel: UILabel!
	
	@IBOutlet weak var clearInputButton: UIButton!
	@IBOutlet weak var clipboardButton: UIBarButtonItem!
	@IBOutlet weak var translateButton: UIButton!
	
	@IBOutlet weak var outputContainer: UIView!
	@IBOutlet weak var textOutputView: UITextView!
	@IBOutlet weak var shareOutputButton: UIButton!
	@IBOutlet weak var speakOutputButton: UIButton!
	@IBOutlet weak var langOutputLabel: UILabel!
	
	@IBOutlet weak var bottomHeight: NSLayoutConstraint!
	
	let engine = TranslationEngine()
	let synthesizer = AVSpeechSynthesizer()

	private lazy var record = SFSpeechRecognizer()

	var scanRequests = [VNRequest]()
	let scanQueue = DispatchQueue(label: "ScanQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
	var scannedText = ""
	
	var animationDuration: TimeInterval = 0.0
	var animationOptions: UIView.AnimationOptions = UIView.AnimationOptions.layoutSubviews

	lazy var enabledColor = UIView().tintColor
	lazy var disabledColor = UIColor.lightGray.withAlphaComponent(0.5)

	var pair: TextPair = TextPair(sourceText: "", sourceLang: nil, destText: "", destLang: PreferencesController.shared.lang) {
		didSet {
			let source = pair.sourceText
			if textInputView.text != source {
				textInputView.text = source
			}
			langInputLabel.text = pair.sourceLang ?? " "
			let hasInput = !pair.sourceText.isEmpty
			clearInputButton.isHidden = !hasInput

			micInputButton.isEnabled = record?.isAvailable ?? false
			micInputButton.tintColor = micInputButton.isEnabled ? enabledColor : disabledColor

			langOutputLabel.text = pair.destLang
			let dest = pair.destText ?? ""
			if textOutputView.text != dest {
				textOutputView.text = dest
			}
			let hasOutput = !dest.isEmpty
			shareOutputButton.isEnabled = hasOutput
			speakOutputButton.isEnabled = hasOutput
			shareOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
			speakOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
			
			let hasClips = !PreferencesController.shared.pairCache.isEmpty
			clipboardButton.isEnabled = hasClips
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupScan()
		setupKeyboard()
		setupLanguage()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if pair.sourceText.isEmpty {
			if let text = UIPasteboard.general.string, !text.isEmpty {
				pair = pair.with(sourceText: text)
			}
			switchToInput(showKeyboard: true)
		}
	}

	@IBAction func unwind(unwindSegue: UIStoryboardSegue) {
		if let object = unwindSegue.source as? TextPairSelectable, let selectedPair = object.selectedPair {
			switchToInput()
			pair = selectedPair
			PreferencesController.shared.lang = selectedPair.destLang
		}
		
		if unwindSegue.source is PreferencesViewController {
			pair = pair.with(destLang: PreferencesController.shared.lang)
		}
	}

	func switchToInput(showKeyboard: Bool = false) {
		view.bringSubviewToFront(inputContainer)
		textOutputView.isUserInteractionEnabled = false	// ensure that text outout bg taps pass and hence tap raises it
		inputContainer.alpha = 1
		outputContainer.alpha = 0.5
		if showKeyboard {
			textInputView.becomeFirstResponder()	// uh, catalyst is picky when to call this
		}
	}

	func switchToOutput() {
		view.bringSubviewToFront(outputContainer)
		textOutputView.isUserInteractionEnabled = true
		hideKeyboard()
		inputContainer.alpha = 0.5
		outputContainer.alpha = 1
		textInputView.resignFirstResponder()
	}

	@IBAction func tapBackground(_ sender: UITapGestureRecognizer) {
		textInputView.resignFirstResponder()
		hideKeyboard()
	}
}
