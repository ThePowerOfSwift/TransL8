//
//  PreferencesController.swift
//  kite
//
//  Created by kreait on 13.09.18.
//  Copyright © 2018 kreait. All rights reserved.
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
