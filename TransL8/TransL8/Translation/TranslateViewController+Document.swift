//
//  TranslationViewController+Document.swift
//  TransL8
//
//  Created by Oliver Michalak on 29.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit
import MobileCoreServices


extension TranslateViewController: UIDocumentPickerDelegate {
		
	@IBAction func pickDocument() {
		switchToInput()
		let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as String], in: .import)
		picker.allowsMultipleSelection = false
		picker.delegate = self
		present(picker, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		for url in urls {
			if let data = try? Data(contentsOf: url),
				let text = String(data: data, encoding: .utf8),
				!text.isEmpty {
				pair = pair.with(sourceText: text)
				break
			}
		}
	}
}
