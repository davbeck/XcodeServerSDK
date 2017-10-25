//
//  Commit.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Commit: XcodeServerEntity {
    
    public let hash: String
    public let filePaths: [File]
    public let message: String?
    public let date: Date
    public let repositoryID: String
    public let contributor: Contributor
    
    // MARK: Initializers
    public required init(json: [String:Any]) throws {
        self.hash = try json["XCSCommitHash"].unwrap(as: String.self)
		self.filePaths = try json["XCSCommitCommitChangeFilePaths"].unwrap(as: [[String:Any]].self).map { try File(json: $0) }
        self.message = json["XCSCommitMessage"] as? String
		self.date = try Date.dateFromXCSString(json["XCSCommitTimestamp"].unwrap(as: String.self)).unwrap()
        self.repositoryID = try json["XCSBlueprintRepositoryID"].unwrap(as: String.self)
        self.contributor = try Contributor(json: json["XCSCommitContributor"].unwrap(as: [String:Any].self))
        
        try super.init(json: json)
    }
    
}
