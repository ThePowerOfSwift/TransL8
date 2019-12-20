//
//  TranslationViewController+Clipboard.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit


extension TranslateViewController: UIContextMenuInteractionDelegate {

	func setupClipboard() {
		let interaction = UIContextMenuInteraction(delegate: self)
		clipboardInputButton.addInteraction(interaction)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		
		let list = PreferencesController.shared.pairCache
		guard !list.isEmpty else {
			return nil
		}
		
		let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
			var actions = [UIMenuElement]()
			for idx in 0..<min(10, list.count) {
				let pair = list[idx]
				let action = UIAction(title: pair.sourceText) { [weak self] action in
					guard let self = self else { return }

					self.pair = pair
					self.textInputView.becomeFirstResponder()
				}
				actions.append(action)
			}
			let action = UIAction(title: "Clear", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
				guard let self = self else { return }

				PreferencesController.shared.pairCache = []
				self.pair = self.pair.with(sourceText: "", destText: "")
				self.textInputView.becomeFirstResponder()
			}
			actions.append(action)
			return UIMenu(title: "", children: actions)
		}
		return configuration
	}
}
