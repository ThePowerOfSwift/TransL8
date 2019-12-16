//
//  PreferencesViewController.swift
//  kite
//
//  Created by kreait on 13.09.18.
//  Copyright © 2018 kreait. All rights reserved.
//

import UIKit
import Moya


class PreferencesViewController: UIViewController, UITextFieldDelegate {
  
	@IBOutlet weak var languageSwitch: UISegmentedControl!
	@IBOutlet weak var apiKeyView: UITextField!
  @IBOutlet weak var stateView: UILabel!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
  let service = MoyaProvider<DeepLService>()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		languageSwitch.selectedSegmentIndex = PreferencesController.languages.firstIndex(of: PreferencesController.shared.lang) ?? 0
		apiKeyView.text = PreferencesController.shared.apiKey
		stateView.text = ""
	}

	@IBAction func changeLang() {
		PreferencesController.shared.lang = PreferencesController.languages[languageSwitch.selectedSegmentIndex]
	}
	
	@IBAction func changeText(_ sender: UITextField) {
		if sender == apiKeyView {
			PreferencesController.shared.apiKey = apiKeyView.text!
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}

	@IBAction func update() {
		guard let apiKey = PreferencesController.shared.apiKey, !apiKey.isEmpty else { return }
		view.endEditing(true)
		
		Root.shared.isBusy = true
		service.request(.retrieveUsage) { [weak self] result in
      guard let self = self else { return }
      
			Root.shared.isBusy = false
			switch result {
			case .success(let response):
				if let usage = try? response.data.decoded() as DeepL.Usage {
					self.stateView.text = "Used characters: \(usage.characterCount)\nAvailable Characters: \(usage.characterLimit)"
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
