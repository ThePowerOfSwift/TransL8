//
//  TranslateViewController+Language.swift
//  TransL8
//
//  Created by Oliver Michalak on 03.01.20.
//  Copyright © 2020 Oliver Michalak. All rights reserved.
//

import UIKit


extension TranslateViewController: UIContextMenuInteractionDelegate {
	
	func setupLanguage() {
		let interaction = UIContextMenuInteraction(delegate: self)
		translateButton.addInteraction(interaction)
	}
	
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
				
		let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
			var actions = [UIMenuElement]()
			for lang in PreferencesController.languages {
				if lang == PreferencesController.shared.lang {
					actions.append(UIAction(title: lang, state: .on, handler: {_ in}))
				}
				else {
					let action = UIAction(title: lang) { [weak self] action in
						guard let self = self else { return }

						PreferencesController.shared.lang = lang
						self.pair = self.pair.with(destLang: lang)
						self.translate()
					}
					actions.append(action)
				}
			}
			return UIMenu(title: "", children: actions)
		}
		return configuration
	}
}
