//
//  TranslationViewController+Record.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//
//	derived from: https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio

import UIKit
import Speech


extension TranslateViewController {
	
	func setupRecord() {
		recordRequest.shouldReportPartialResults = true
		//		recorderRequest.requiresOnDeviceRecognition = true
		micInputButton.isEnabled = record?.isAvailable ?? false
		micInputButton.tintColor = micInputButton.isEnabled ? enabledColor : disabledColor
	}
	
	@IBAction func recordMicInput() {
		view.endEditing(true)
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
						self.pair = self.pair.with(sourceText: self.micPreviewLabel.text ?? "")
						self.textInputView.becomeFirstResponder()
					}
					else {
						self.micPreviewLabel.text = ""
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
}
