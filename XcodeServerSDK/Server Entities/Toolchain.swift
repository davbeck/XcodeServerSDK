//
//  Toolchain.swift
//  XcodeServerSDK
//
//  Created by Laurent Gaches on 21/04/16.
//  Copyright © 2016 Laurent Gaches. All rights reserved.
//

import Foundation

public class Toolchain: XcodeServerEntity {
    
    public let displayName: String
    public let path: String
    public let signatureVerified: Bool
 
    public required init(json: [String:Any]) throws {
        
        self.displayName = try json["displayName"].unwrap(as: String.self)
        self.path = try json["path"].unwrap(as: String.self)
        self.signatureVerified = try json["signatureVerified"].unwrap(as: Bool.self)
        
        try super.init(json: json)
    }
}
