//
//  FileProviderItemIdentifier+TextPair.swift
//  File
//
//  Created by Oliver Michalak on 28.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import FileProvider


extension NSFileProviderItemIdentifier {
	
	var textPair: TextPair? {
		return PreferencesController.shared.pairCache.first { (pair) -> Bool in
			pair.filename == rawValue
		}
	}
}
