//
//  OnboardingNavigationController.swift
//  kite
//
//  Created by Oliver Michalak on 20.09.19.
//  Copyright © 2019 kreait. All rights reserved.
//

import UIKit
import Moya


class OnboardingNavigationController: UINavigationController {
	
	let service = MoyaProvider<DeepLService>()
	
	var apiKey: String?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		apiKey = PreferencesController.shared.apiKey
	}

	func login() {
		guard let apiKey = apiKey, !apiKey.isEmpty else { return }

		Root.shared.isBusy = true
		service.request(.retrieveUsage(apiKey: apiKey)) { result in
			Root.shared.isBusy = false
			switch result {
			case .success(let response):
				if let _ = try? response.data.decoded() as DeepL.Usage {
					PreferencesController.shared.apiKey = apiKey
					Root.shared.restart()
				}
				else {
					Root.shared.showBanner(message: String(format: "Error logging in: '%@'", String(data: response.data, encoding: .utf8) ?? ""))
				}
			case .failure(let error):
				Root.shared.showBanner(message: error.localizedDescription)
			}
		}
	}
}
