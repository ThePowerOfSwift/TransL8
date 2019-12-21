//
//  OnboardingDomainViewController.swift
//  kite
//
//  Created by Oliver Michalak on 20.09.19.
//  Copyright © 2019 kreait. All rights reserved.
//

import UIKit


class OnboardingIntroViewController: UIViewController {
		
	@IBAction func openMiteLink() {
		guard let url = URL(string: "https://www.deepl.com/pro.html?ref=TransL8") else { return }

		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
}

