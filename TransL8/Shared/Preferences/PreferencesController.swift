//
//  PreferencesController.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import Foundation


class PreferencesController: NSObject {
	
	static let shared = PreferencesController()
	static let languages = ["EN", "DE", "FR", "ES", "PT", "IT", "NL", "PL", "RU"]

	@Storage(key: "lang", defaultValue: "EN")
	var lang: String

	@SecureStorage(key: "apiKey", defaultValue: nil)
	var apiKey: String?
	
	// pseudo cache
	@Storage(key: "pairCache", defaultValue: [])
  var pairCache: [TextPair]
}


extension PreferencesController {
	var isValidAccess: Bool {
		return !(apiKey?.isEmpty ?? true)
	}
}
