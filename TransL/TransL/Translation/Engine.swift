//
//  Engine.swift
//  TransL
//
//  Created by Oliver Michalak on 18.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import Foundation
import Moya


class Engine {
	
	enum TranslationError: Error {
		case empty
		case network(String)
	}
	
  private let service = MoyaProvider<DeepLService>() // plugins: [NetworkLoggerPlugin(verbose: true)])

	func translate(text: String, completion: @escaping (Result<String, TranslationError>) -> Void) {
		
		let sourcePair = TranslationPair(sourceText: text, sourceLang: nil, destText: nil, destLang: PreferencesController.shared.lang)

		if let cachedPair = PreferencesController.shared.pairCache.first(where: { $0 == sourcePair }) {
			completion(.success(cachedPair.destText ?? ""))
		}
		else {
			service.request(.translate(text)) { result in
				switch result {
				case let .success(response):
					if let resultContainer = try? response.data.decoded() as DeepL.TranslationContainer,
						resultContainer.translations.count > 0 {
						let destText = resultContainer.translations.compactMap({ $0.text }).joined(separator: "\n")
						let sourceLang = resultContainer.translations.first!.detectedSourceLanguage
						let pair = TranslationPair(sourceText: text, sourceLang: sourceLang, destText: destText, destLang: sourcePair.destLang)
						
						// store limited number of pairs into "cache"
						var list = PreferencesController.shared.pairCache
						list.insert(pair, at: 0)
						let over = list.count - 100
						if over > 0 {
							_ = list.dropLast(over)
						}
						PreferencesController.shared.pairCache = list

						completion(.success(pair.destText ?? ""))
					}
					else {
						completion(.failure(.empty))
					}
				case let .failure(error):
					completion(.failure(.network(error.localizedDescription)))
				}
			}
		}
	}
}
