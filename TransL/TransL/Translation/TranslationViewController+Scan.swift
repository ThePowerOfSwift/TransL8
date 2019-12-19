//
//  TranslationViewController+Scan.swift
//  TransL
//
//  Created by Oliver Michalak on 19.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//
//	derived from: https://developer.apple.com/documentation/vision/locating_and_displaying_recognized_text_on_a_document

import UIKit
import Vision
import VisionKit


extension TranslateViewController: VNDocumentCameraViewControllerDelegate {
	
	func setupScan() {
		let request = VNRecognizeTextRequest { (request, error) in
			guard let observations = request.results as? [VNRecognizedTextObservation] else {
				return
			}
			
			let maximumCandidates = 1
			for observation in observations {
				guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
				self.scannedText += candidate.string + "\n"
			}
		}
		request.recognitionLevel = .accurate
		self.scanRequests = [request]
	}
	
	@IBAction func scanImageInput() {
		view.endEditing(true)
		let documentCameraViewController = VNDocumentCameraViewController()
		documentCameraViewController.delegate = self
		present(documentCameraViewController, animated: true)
	}
	
	public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {

		controller.dismiss(animated: true)
		pair = pair.with(sourceText: "")

		Root.shared.isBusy = true
		scanQueue.async {
			self.scannedText = ""
			for pageIndex in 0 ..< scan.pageCount {
				let image = scan.imageOfPage(at: pageIndex)
				if let cgImage = image.cgImage {
					let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
					do {
						try handler.perform(self.scanRequests)
					} catch {
						print(error)
					}
				}
				self.scannedText += "\n\n"
			}
			DispatchQueue.main.async(execute: {
				Root.shared.isBusy = false
				self.pair = self.pair.with(sourceText: self.scannedText)
				self.textInputView.becomeFirstResponder()
			})
		}
	}
}
