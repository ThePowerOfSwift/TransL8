//
//  FileProviderEnumerator.swift
//  File
//
//  Created by Oliver Michalak on 27.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import FileProvider

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
	
	func invalidate() {	}
	
	func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
		
		let items = PreferencesController.shared.pairCache.map { (pair) -> FileProviderItem in
			FileProviderItem(pair: pair)
		}
		observer.didEnumerate(items)
		observer.finishEnumerating(upTo: nil)
	}
}
