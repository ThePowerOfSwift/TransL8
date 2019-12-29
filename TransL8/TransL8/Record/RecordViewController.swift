//
//  RecordViewController.swift
//  TransL8
//
//  Created by Oliver Michalak on 29.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//
//	derived from: https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio

import UIKit
import Speech


class RecordViewController: UIViewController, TextPairSelectable {
	
	@IBOutlet weak var micOverlay: UIVisualEffectView!
	@IBOutlet weak var micPreviewLabel: UILabel!
	@IBOutlet weak var micStopButton: UIButton!

	var selectedPair: TextPair?

	private let record = SFSpeechRecognizer()
	private let recordEngine = AVAudioEngine()
	private var recordRequest = SFSpeechAudioBufferRecognitionRequest()
	private var recordTask: SFSpeechRecognitionTask?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		micPreviewLabel.text = ""
		recordRequest.shouldReportPartialResults = true
		//		recorderRequest.requiresOnDeviceRecognition = true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		startStopRecording()
	}
	
	@IBAction func startStopRecording() {
		SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				switch authStatus {
				case .notDetermined:
					()
				case .authorized:
					if self.recordEngine.isRunning {
						self.recordEngine.stop()
						self.recordRequest.endAudio()
						self.micOverlay.isHidden = true
						self.selectedPair = TextPair(sourceText: self.micPreviewLabel.text ?? "", sourceLang: nil, destText: "", destLang: PreferencesController.shared.lang)
						self.performSegue(withIdentifier: "unwind", sender: self)
					}
					else {
						self.micPreviewLabel.text = "..."
						do {
							try self.startRecording()
							self.micOverlay.isHidden = false
						}
						catch {
							self.micOverlay.isHidden = true
							Root.shared.showBanner(message: "Recording not available")
						}
					}
				default:
					Root.shared.showBanner(message: "No microphone access granted")
				}
			}
		}
	}

	private func startRecording() throws {
		
		recordTask?.cancel()
		recordTask = nil
		let inputNode = recordEngine.inputNode
		
		recordTask = record?.recognitionTask(with: recordRequest) { [weak self] result, error in
			guard let self = self else { return }
			
			var isFinal = false
			if let result = result {
				self.micPreviewLabel.text = result.bestTranscription.formattedString
				isFinal = result.isFinal
			}
			
			if error != nil || isFinal {
				self.recordEngine.stop()
				inputNode.removeTap(onBus: 0)
				self.recordTask = nil
			}
		}
		
		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
			self.recordRequest.append(buffer)
		}
		
		recordEngine.prepare()
		try recordEngine.start()
		self.micOverlay.isHidden = false
	}

	@IBAction func cancel() {
		recordEngine.stop()
		recordRequest.endAudio()
		recordEngine.inputNode.removeTap(onBus: 0)
		recordTask?.cancel()
		performSegue(withIdentifier: "unwind", sender: self)
	}
}
