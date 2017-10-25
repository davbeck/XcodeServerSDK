//
//  Contributor.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

// MARK: Constants
let kContributorName = "XCSContributorName"
let kContributorDisplayName = "XCSContributorDisplayName"
let kContributorEmails = "XCSContributorEmails"

public class Contributor: XcodeServerEntity {
    
    public let name: String
    public let displayName: String
    public let emails: [String]
    
    public required init(json: [String:Any]) throws {
        self.name = try json[kContributorName].unwrap(as: String.self)
        self.displayName = try json[kContributorDisplayName].unwrap(as: String.self)
        self.emails = try json[kContributorEmails].unwrap(as: [String].self)
        
        try super.init(json: json)
    }
    
    public override func dictionarify() -> [String:Any] {
        return [
            kContributorName: self.name,
            kContributorDisplayName: self.displayName,
            kContributorEmails: self.emails
        ]
    }
    
    public func description() -> String {
        return "\(displayName) [\(emails[0])]"
    }
    
}
