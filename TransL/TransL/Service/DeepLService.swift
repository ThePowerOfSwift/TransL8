//
//  DeepLService.swift
//  TransL
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
//
//	https://www.deepl.com/docs-api.html
//

import Foundation
import Moya


enum DeepLService {

	case retrieveUsage
	case translate(_ text: String)
}

extension DeepLService: TargetType {

  var baseURL: URL {
		return URL(string: "https://api.deepl.com/v2")!
  }
  
  var path: String {
    switch self {
    case .retrieveUsage:
      return "/usage"

    case .translate(_):
      return "/translate"
    }
  }
  
  var method: Moya.Method {
		return .post
  }
  
  var task: Task {
		let apiKey = PreferencesController.shared.apiKey ?? ""
		var params = ["auth_key": apiKey]

    switch self {
    case .retrieveUsage:
			()

    case .translate(let text):
			params["target_lang"] = PreferencesController.shared.lang
			params["text"] = text
		}

		return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
	}
  
	var headers: [String : String]? {
		return [:]
	}
  
  var sampleData: Data {
    return Data()
  }
}
