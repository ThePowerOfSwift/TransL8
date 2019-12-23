//
//  Array+NSExtensionItem.swift
//  TransL8
//
//  Created by Oliver Michalak on 23.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import Foundation
import MobileCoreServices


extension Array /* where Element == NSExtensionItem */ {
	
	func extractText (callback: @escaping (_ text: String) -> ()) {
		for item in self {
			guard let item = item as? NSExtensionItem else { continue }

			for provider in item.attachments! {
				if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
					provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (item, error) in
						guard let text = item as? String else { return }

						DispatchQueue.main.async {
							callback(text)
						}
					})
				}
			}
		}
	}
}
