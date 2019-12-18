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

	func translate(text: String, lang: String, completion: @escaping (Result<String, TranslationError>) -> Void) {
		
		let sourcePair = TranslationPair(sourceText: text, sourceLang: nil, destText: nil, destLang: PreferencesController.shared.lang)

		if let cachedPair = PreferencesController.shared.pairs.first(where: { $0 == sourcePair }) {
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
						PreferencesController.shared.pairs.append(pair)
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
