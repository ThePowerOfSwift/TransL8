//
//  HistoryViewController.swift
//  TransL8
//
//  Created by Oliver Michalak on 24.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//

import UIKit


class HistoryViewController: UIViewController, TextPairSelectable {
	
	@IBOutlet weak var listView: UITableView!
	private var dataSource: TextPairDataSource?

	var selectedPair: TextPair?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource = TextPairDataSource(tableView: listView!, cellProvider: { (tableView, indexPath, pair) -> UITableViewCell? in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier) as? HistoryCell else {
				return nil
			}
			cell.pair = pair
			return cell
		})
		listView.dataSource = dataSource
		
		var snapshot = NSDiffableDataSourceSnapshot<Int, TextPair>()
		snapshot.appendSections([0])
		snapshot.appendItems(PreferencesController.shared.pairCache, toSection: 0)
		dataSource?.apply(snapshot, animatingDifferences: false)
	}
}


extension HistoryViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedPair = PreferencesController.shared.pairCache[indexPath.item]
		performSegue(withIdentifier: "unwind", sender: self)
	}
}


class TextPairDataSource: UITableViewDiffableDataSource<Int, TextPair> {
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }

		let pair = PreferencesController.shared.pairCache[indexPath.item]
		var snap = snapshot()
		snap.deleteItems([pair])
		apply(snap, animatingDifferences: true)
		PreferencesController.shared.pairCache.remove(at: indexPath.item)
	}
}
