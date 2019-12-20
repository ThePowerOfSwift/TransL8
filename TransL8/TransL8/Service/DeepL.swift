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
