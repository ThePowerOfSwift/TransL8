//
//  PreferencesController.swift
//  kite
//
//  Created by kreait on 13.09.18.
//  Copyright © 2018 kreait. All rights reserved.
//

import Foundation
import KeychainSwift


class PreferencesController: NSObject {
	
	static let shared = PreferencesController()
	static let languages = ["EN", "DE", "FR", "ES", "PT", "IT", "NL", "PL", "RU"]

	private let store = UserDefaults()
	private lazy var keychain = KeychainSwift()
		
	final func getValue<T>(for key: String) -> T? {
		return store.object(forKey: key) as? T
	}
	
	final func setValue<T>(_ value: T?, for key: String) {
		if let val = value {
			store.set(val, forKey: key)
		}
		else {
			store.removeObject(forKey: key)
		}
	}
	
	func getEncodedValue<T: Decodable>(for key:String) -> T? {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard let td = getValue(for: key) as Data?,
			let result = try? decoder.decode(T.self, from: td) else { return nil }
		return result
	}
	
	func setEncodedValue<T: Encodable>(_ val: T, for key: String) {
		let data = try? JSONEncoder().encode(val)
		setValue(data, for: key)
	}
	
	var lang: String {
		get {
			return store.string(forKey: "lang") ?? "en"
		}
		set {
			store.set(newValue, forKey: "lang")
		}
	}

	var apiKey: String? {
		get {
			return keychain.get("apiKey")
		}
		set {
			if let val = newValue {
				keychain.set(val, forKey: "apiKey", withAccess: .accessibleAfterFirstUnlock)
			}
			else {
				keychain.delete("apiKey")
			}
		}
	}
	
	// pseudo cache
  var pairs: [TranslationPair] {
    get {
      return getEncodedValue(for: "pairs") ?? []
    }
    set {
      setEncodedValue(newValue, for: "pairs")
    }
  }
}
