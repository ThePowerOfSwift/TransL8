//
//  FileProviderItem.swift
//  File
//
//  Created by Oliver Michalak on 27.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import FileProvider

class FileProviderItem: NSObject, NSFileProviderItem {
	
	var pair: TextPair
	
	init(pair: TextPair) {
		self.pair = pair
	}

	convenience init?(identifier: NSFileProviderItemIdentifier) {
		guard identifier != .rootContainer, let pair = identifier.textPair else {
			return nil
		}
		self.init(pair: pair)
	}

	var itemIdentifier: NSFileProviderItemIdentifier {
		return NSFileProviderItemIdentifier(pair.filename)
	}
	
	var parentItemIdentifier: NSFileProviderItemIdentifier {
		return NSFileProviderItemIdentifier.rootContainer	// no subfolders needed, hence hardcoded value
	}
	
	var capabilities: NSFileProviderItemCapabilities {
		return .allowsReading
	}
	
	var filename: String {
		return pair.filename
	}
	
	var typeIdentifier: String {
		return "public.plain-text"
	}
	
	var documentSize: NSNumber? {
		return pair.textContent.count as NSNumber
  }
}
