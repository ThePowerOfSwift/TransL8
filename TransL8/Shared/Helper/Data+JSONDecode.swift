//
//  Data+JSONDecode.swift
//  TransL8
//
//  Created by Oliver Michalak on 16.12.19.
//  Copyright © 2019 Oliver Michalak. All rights reserved.
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
