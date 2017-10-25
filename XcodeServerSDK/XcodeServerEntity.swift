//
//  XcodeServerEntity.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public protocol XcodeRead {
    init(json: [String:Any]) throws
}

public protocol XcodeWrite {
    func dictionarify() -> [String:Any]
}

public class XcodeServerEntity : XcodeRead, XcodeWrite {
    
    public let id: String!
    public let rev: String!
    public let tinyID: String!
    public let docType: String!
    
    //when created from json, let's save the original data here.
	public let originalJSON: [String:Any]?
    
    //initializer which takes a dictionary and fills in values for recognized keys
    public required init(json: [String:Any]) throws {
        
        self.id = json["_id"] as? String
        self.rev = json["_rev"] as? String
        self.tinyID = json["tinyID"] as? String
        self.docType = json["doc_type"] as? String
        self.originalJSON = json
    }
    
    public init() {
        self.id = nil
        self.rev = nil
        self.tinyID = nil
        self.docType = nil
        self.originalJSON = nil
    }
    
    public func dictionarify() -> [String:Any] {
        assertionFailure("Must be overriden by subclasses that wish to dictionarify their data")
        return [String:Any]()
    }
    
    public class func optional<T: XcodeRead>(json: [String:Any]?) throws -> T? {
        if let json = json {
            return try T(json: json)
        }
        return nil
    }
}

//parse an array of dictionaries into an array of parsed entities
public func XcodeServerArray<T>(_ array: [[String:Any]]) throws -> [T] where T:XcodeRead {
    let parsed = try array.map { (_ json: [String:Any]) -> (T) in
        return try T(json: json)
    }
    return parsed
}

