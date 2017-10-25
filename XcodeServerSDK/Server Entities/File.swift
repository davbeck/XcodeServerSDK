//
//  File.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class File: XcodeServerEntity {
    
    public let status: FileStatus
    public let filePath: String
    
    public init(filePath: String, status: FileStatus) {
        self.filePath = filePath
        self.status = status
        
        super.init()
    }
    
    public required init(json: [String:Any]) throws {
        self.filePath = try json["filePath"].unwrap(as: String.self)
        self.status = FileStatus(rawValue: try json["status"].unwrap(as: Int.self)) ?? .Other
        
        try super.init(json: json)
    }
    
    public override func dictionarify() -> [String:Any] {
        return [
            "status": self.status.rawValue,
            "filePath": self.filePath
        ]
    }
    
}

/**
*  Enum which describes file statuses.
*/
public enum FileStatus: Int {
    case Added = 1
    case Deleted = 2
    case Modified = 4
    case Moved = 8192
    case Other
}
