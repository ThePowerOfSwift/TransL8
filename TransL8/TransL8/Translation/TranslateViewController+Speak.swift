//
//  TranslationViewController+Speak.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import AVFoundation


extension TranslateViewController {

	@IBAction func speakOutput() {
		showOutput()
		guard let text = pair.destText, !text.isEmpty else { return }

		let langMapping = ["EN": "en-US",
											 "DE": "de-DE",
											 "FR": "fr-FR",
											 "ES": "es-ES",
											 "PT": "pt-PT",
											 "IT": "it-IT",
											 "NL": "nl-NL",
											 "PL": "pl-PL",
											 "RU": "ru-RU"]
		
		synthesizer.stopSpeaking(at: .immediate)
		let phrase = AVSpeechUtterance.init(string: text)
		if let voice = AVSpeechSynthesisVoice(language: langMapping[PreferencesController.shared.lang]) {
			phrase.voice = voice
		}
		synthesizer.speak(phrase)
		Root.shared.showBanner(message: "Speak: \(text)")
	}
}
