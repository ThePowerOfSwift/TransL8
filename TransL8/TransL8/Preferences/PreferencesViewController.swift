//
//  PreferencesViewController.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import Moya


class PreferencesViewController: UIViewController, UITextFieldDelegate {
  
	@IBOutlet weak var languageSwitch: UISegmentedControl!
	@IBOutlet weak var apiKeyView: UITextField!
	@IBOutlet weak var updateButton: UIButton!
	@IBOutlet weak var statusLabel: UILabel!
	
  let service = MoyaProvider<DeepLService>()

	var lang : String? {
		didSet {
			languageSwitch.selectedSegmentIndex = PreferencesController.languages.firstIndex(of: lang ?? "") ?? 0
		}
	}

	var apiKey: String? {
		didSet {
			apiKeyView.text = apiKey ?? ""
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		lang = PreferencesController.shared.lang
		apiKey = PreferencesController.shared.apiKey
		statusLabel.text = ""
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		update()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		view.endEditing(true)
		guard let lang = lang, let apiKey = apiKey else { return }

		PreferencesController.shared.lang = lang
		PreferencesController.shared.apiKey = apiKey
	}

	@IBAction func changeLang() {
		view.endEditing(true)
		lang = PreferencesController.languages[languageSwitch.selectedSegmentIndex]
	}
	
	@IBAction func changeText(_ sender: UITextField) {
		apiKey = apiKeyView.text!
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}

	@IBAction func update() {
		guard let apiKey = apiKey else { return }
		view.endEditing(true)

		apiKeyView.isEnabled = false
		updateButton.isEnabled = false
		service.request(.retrieveUsage(apiKey: apiKey)) { [weak self] result in
      guard let self = self else { return }
			self.apiKeyView.isEnabled = true
			self.updateButton.isEnabled = true

			switch result {
			case .success(let response):
				if let usage = try? response.data.decoded() as DeepL.Usage {
					self.statusLabel.text = usage.formatted
				}
				else {
					self.statusLabel.text = String(format: "Error logging in: '%@'", String(data: response.data, encoding: .utf8) ?? "")
				}
			case .failure(let error):
				self.statusLabel.text = String(format: "Network error: '%@'", error.localizedDescription)
			}
		}
	}
}
