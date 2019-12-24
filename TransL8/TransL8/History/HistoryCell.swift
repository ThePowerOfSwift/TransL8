//
//  HistoryCell.swift
//  TransL8
//
//  Created by Oliver Michalak on 24.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit


class HistoryCell: UITableViewCell {
	
  class var identifier: String {
    return String(describing: self)
  }
	
	@IBOutlet weak var sourceView: UILabel!
	@IBOutlet weak var destView: UILabel!

	var pair: TextPair? {
		didSet {
			sourceView.text = pair?.sourceText
			destView.text = pair?.destText ?? ""
		}
	}
}
