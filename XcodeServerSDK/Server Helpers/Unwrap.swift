//
//  Unwrap.swift
//  XcodeServerSDK
//
//  Created by David Beck on 10/25/17.
//  Copyright © 2017 Honza Dvorsky. All rights reserved.
//

import Foundation


public struct OptionalUnwrapError: Error {
	let message: String?
	let wrappedType: Any.Type
	
	init(message: String? = nil, wrappedType: Any.Type) {
		self.message = message
		self.wrappedType = wrappedType
	}
}

extension Optional {
	public func unwrap(_ message: String? = nil) throws -> Wrapped {
		if let value = self {
			return value
		} else {
			throw OptionalUnwrapError(message: message, wrappedType: Wrapped.self)
		}
	}
	
	public func unwrap<Cast>(as type: Cast.Type, _ message: String? = nil) throws -> Cast {
		if let value = self as? Cast {
			return value
		} else {
			throw OptionalUnwrapError(message: message, wrappedType: Cast.self)
		}
	}
}
