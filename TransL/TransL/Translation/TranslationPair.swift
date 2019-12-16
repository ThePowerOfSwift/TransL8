//
//  TranslationPair.swift
//  TransL
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import Foundation


struct TranslationPair: Codable, Equatable {

	let sourceText: String
	let sourceLang: String?

	let destText: String?
	let destLang: String

	// source text and dest lang
	static func == (lhs: TranslationPair, rhs: TranslationPair) -> Bool {
		return lhs.sourceText == rhs.sourceText && lhs.destLang == rhs.destLang
	}
}
