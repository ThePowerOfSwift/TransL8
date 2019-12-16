//
//  Data+JSONDecode.swift
//  prefest
//
//  Created by Oliver Michalak on 06.08.18.
//  Copyright © 2018 Oliver Michalak. All rights reserved.
//

import Foundation


extension Data {
	
	func decoded<T: Decodable>() throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
		decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(T.self, from: self)
	}
}
