//
//  TextPair+Filename.swift
//  File
//
//  Created by Oliver Michalak on 28.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import Foundation


extension TextPair {
	
	var filename: String {
		let tokens = sourceText.components(separatedBy: CharacterSet.whitespacesAndNewlines)
		let name = tokens[0..<min(tokens.count, 30)].joined(separator: " ")
		// this is broken for pairs having the same first 30 tokens
		// adding hashValue is solving it but at the price of an ugly file name
		return String(format: "%@.txt", String(name.prefix(100)))
	}
	
	var textContent: String {
		return String(format: "%@:\n\n%@\n\n%@:\n\n%@\n", sourceLang ?? "EN", sourceText, destLang, destText ?? "")
	}
}
