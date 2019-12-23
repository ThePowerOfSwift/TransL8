//
//  DeepL.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import Foundation


struct DeepL: Codable {
	
	struct Usage: Codable {

		let characterCount: Int
		let characterLimit: Int
	}
	
	struct Translation: Codable {

		let detectedSourceLanguage: String
		let text: String
	}
	
	struct TranslationContainer: Codable {

		let translations: [Translation]
	}
}


extension DeepL.Usage {
	
	var formatted: String {
		var rate: Float = 0
		if characterLimit > 0 {
			rate = Float(characterCount) / Float(characterLimit) * 100
		}
		return String(format: "Usage: %.02f%%\nUsed characters: %d\nAvailable Characters: %d", rate, characterCount, characterLimit)
	}
}
