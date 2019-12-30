//
//  TranslationPair.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import Foundation


struct TextPair: Codable, Hashable {

	let sourceText: String
	let sourceLang: String?

	let destText: String?
	let destLang: String
}


extension TextPair: Equatable {
	
	// source text and dest lang
	static func == (lhs: TextPair, rhs: TextPair) -> Bool {
		return lhs.sourceText == rhs.sourceText && lhs.destLang == rhs.destLang
	}
}

extension TextPair {
	
	func with(sourceText source: String) -> TextPair {
		return TextPair(sourceText: source, sourceLang: sourceLang, destText: destText, destLang: destLang)
	}
	
	func with(destText dest: String) -> TextPair {
		return TextPair(sourceText: sourceText, sourceLang: sourceLang, destText: dest, destLang: destLang)
	}
	
	func with(sourceText source: String, destText dest: String) -> TextPair {
		return TextPair(sourceText: source, sourceLang: sourceLang, destText: dest, destLang: destLang)
	}
	
	func with(destLang lang:String) -> TextPair {
		return TextPair(sourceText: sourceText, sourceLang: sourceLang, destText: destText, destLang: lang)
	}
}
