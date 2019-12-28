//
//  FileProviderExtension.swift
//  File
//
//  Created by Oliver Michalak on 27.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import FileProvider

class FileProviderExtension: NSFileProviderExtension {
	
	override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
		guard let item = FileProviderItem(identifier: identifier) else {
      throw NSError.fileProviderErrorForNonExistentItem(withIdentifier: identifier)
		}
		return item
	}
	
	override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
		return NSFileProviderManager.default.documentStorageURL.appendingPathComponent(identifier.rawValue)
	}
	
	override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
    let identifier = url.lastPathComponent
    return NSFileProviderItemIdentifier(identifier)
  }
	
	override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
		guard let identifier = persistentIdentifierForItem(at: url),
				let pair = identifier.textPair
			else {
			completionHandler(NSFileProviderError(.noSuchItem))
			return
		}
		
		do {
			let item = FileProviderItem(pair: pair)
			let placeholderURL = NSFileProviderManager.placeholderURL(for: url)
			try NSFileProviderManager.writePlaceholder(at: placeholderURL, withMetadata: item)
			completionHandler(nil)
		}
		catch let error {
			completionHandler(error)
		}
	}
	
	override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
		let name = url.lastPathComponent
		let identifier = NSFileProviderItemIdentifier(name)
		let pair = identifier.textPair
		
		try? FileManager.default.removeItem(at: url)
		do {
			try pair?.textContent.write(to: url, atomically: true, encoding: .utf8)
			completionHandler(nil)
		}
		catch let error {
			completionHandler(error)
		}
	}
	
	override func stopProvidingItem(at url: URL) {
		try? FileManager.default.removeItem(at: url)
		providePlaceholder(at: url, completionHandler: { _ in
		})
	}
	
	// MARK: - Enumeration
	
	override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
		return FileProviderEnumerator()
	}
}
