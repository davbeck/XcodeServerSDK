//
//  Issue.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 04.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class IntegrationIssue: XcodeServerEntity {
    
    public enum IssueType: String {
        case BuildServiceError = "buildServiceError"
        case BuildServiceWarning = "buildServiceWarning"
        case TriggerError = "triggerError"
        case Error = "error"
        case Warning = "warning"
        case TestFailure = "testFailure"
        case AnalyzerWarning = "analyzerWarning"
    }
    
    public enum IssueStatus: Int {
        case Fresh = 0
        case Unresolved
        case Resolved
        case Silenced
    }
    
    /// Payload is holding whole Dictionary of the Issue
    public let payload: [String:Any]
    
    public let message: String?
    public let type: IssueType
    public let issueType: String
    public let commits: [Commit]
    public let integrationID: String
    public let age: Int
    public let status: IssueStatus
    
    // MARK: Initialization
    public required init(json: [String:Any]) throws {
        self.payload = json
        
        self.message = json["message"] as? String
        self.type = try IssueType(rawValue: json["type"].unwrap(as: String.self))!
        self.issueType = try json["issueType"].unwrap(as: String.self)
        self.commits = try (json["commits"] as? [[String : Any]]).unwrap().map { try Commit(json: $0) }
        self.integrationID = try json["integrationID"].unwrap(as: String.self)
        self.age = try json["age"].unwrap(as: Int.self)
        self.status = try IssueStatus(rawValue: json["status"].unwrap(as: Int.self)).unwrap()
        
        try super.init(json: json)
    }
    
}
