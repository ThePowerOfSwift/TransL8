//
//  OnboardingApiKeyViewController.swift
//  kite
//
//  Created by Oliver Michalak on 20.09.19.
//  Copyright © 2019 kreait. All rights reserved.
//

import UIKit
import Moya


class OnboardingApiKeyViewController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var apiKeyView: UITextField!
	@IBOutlet weak var okButton: UIBarButtonItem!
	
	var apiKey: String? {
		didSet {
			apiKeyView.text = apiKey ?? ""
			okButton.isEnabled = !(apiKey?.isEmpty ?? true)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let domainNavigationController = navigationController as? OnboardingNavigationController {
			apiKey = domainNavigationController.apiKey
		}
	}
	
	@IBAction func changeText(_ sender: UITextField) {
		if sender == apiKeyView {
			apiKey = apiKeyView.text!
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}
	
	@IBAction func saveAccess(_ sender: UIBarButtonItem) {
		view.endEditing(true)

		guard let domainNavigationController = navigationController as? OnboardingNavigationController else { return }

		domainNavigationController.apiKey = apiKey
		domainNavigationController.login()
	}
}
