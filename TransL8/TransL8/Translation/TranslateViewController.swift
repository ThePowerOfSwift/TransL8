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
	
	@IBOutlet weak var textInputView: UITextView!
	@IBOutlet weak var cameraInputButton: UIButton!
	@IBOutlet weak var micInputButton: UIButton!
	@IBOutlet weak var micOverlay: UIVisualEffectView!
	@IBOutlet weak var micPreviewLabel: UILabel!
	@IBOutlet weak var micStopButton: UIButton!
	@IBOutlet weak var clearInputButton: UIButton!
	@IBOutlet weak var clipboardButton: UIBarButtonItem!
	
	@IBOutlet weak var translateButton: UIButton!
	
	@IBOutlet weak var textOutputView: UITextView!
	@IBOutlet weak var shareOutputButton: UIButton!
	@IBOutlet weak var speakOutputButton: UIButton!
	
	let engine = TranslationEngine()
	let synthesizer = AVSpeechSynthesizer()

	let record = SFSpeechRecognizer()
	let recordEngine = AVAudioEngine()
	var recordRequest = SFSpeechAudioBufferRecognitionRequest()
	var recordTask: SFSpeechRecognitionTask?

	var scanRequests = [VNRequest]()
	let scanQueue = DispatchQueue(label: "ScanQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
	var scannedText = ""

	lazy var enabledColor = UIView().tintColor
	lazy var disabledColor = UIColor.lightGray.withAlphaComponent(0.2)

	var pair: TextPair = TextPair(sourceText: "", sourceLang: nil, destText: "", destLang: PreferencesController.shared.lang) {
		didSet {
			let source = pair.sourceText
			if textInputView.text != source {
				textInputView.text = source
			}
			let hasInput = !pair.sourceText.isEmpty
			clearInputButton.isHidden = !hasInput
			translateButton.isEnabled = hasInput
			translateButton.setTitle("→ \(pair.destLang)", for: .normal)
			translateButton.backgroundColor = hasInput ? enabledColor : disabledColor

			if let dest = pair.destText {
				if textOutputView.text != dest {
					textOutputView.text = dest
				}
				let hasOutput = !dest.isEmpty
				shareOutputButton.isEnabled = hasOutput
				speakOutputButton.isEnabled = hasOutput
				shareOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
				speakOutputButton.tintColor = hasOutput ? enabledColor : disabledColor
			}
			
			let hasClips = !PreferencesController.shared.pairCache.isEmpty
			clipboardButton.isEnabled = hasClips
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupRecord()
		setupScan()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if pair.sourceText.isEmpty {
			if let text = UIPasteboard.general.string, !text.isEmpty {
				pair = pair.with(sourceText: text)
			}
			else {
				textInputView.becomeFirstResponder()
			}
		}
	}

	@IBAction func unwindFromPreferences(unwindSegue: UIStoryboardSegue) {
		// preferences could have changed lang
		pair = pair.with(destLang: PreferencesController.shared.lang)
	}

	@IBAction func unwindFromClipboard(unwindSegue: UIStoryboardSegue) {
		guard let vc = unwindSegue.source as? HistoryViewController, let selectedPair = vc.selectedPair else {
			return
		}
		pair = selectedPair
	}

	@IBAction func tapBackground(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}
}


extension TranslateViewController: UITextViewDelegate {

	func textViewDidChange(_ textView: UITextView) {
		pair = pair.with(sourceText: textView.text)
	}
}
