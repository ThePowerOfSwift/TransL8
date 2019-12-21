//
//  OnboardingAccessViewController.swift
//  kite
//
//  Created by Oliver Michalak on 24.09.19.
//  Copyright © 2019 kreait. All rights reserved.
//

import UIKit
import SafariServices


class OnboardingAccessViewController: UIViewController, SFSafariViewControllerDelegate, UIViewControllerTransitioningDelegate {
	
	@IBAction func login(_ sender: Any) {
		UIPasteboard.general.string = ""
		
		let url = URL(string: "https://www.deepl.com/pro-checkout.html?productId=1100")!
		let web = SFSafariViewController(url: url)
		web.delegate = self
		web.transitioningDelegate = self	// prevents push on navStack
		present(web, animated: true)
	}

	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		
		if let text = UIPasteboard.general.string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), !text.isEmpty, let domainNavigationController = navigationController as? OnboardingNavigationController {
			domainNavigationController.apiKey = text
			performSegue(withIdentifier: "showApiKey", sender: nil)
		}
		else {
			Root.shared.showBanner(message: "API key missing")
		}
	}
}

