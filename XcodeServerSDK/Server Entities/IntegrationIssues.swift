//
//  IntegrationIssues.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 12.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public class IntegrationIssues: XcodeServerEntity {
    
    public let buildServiceErrors: [IntegrationIssue]
    public let buildServiceWarnings: [IntegrationIssue]
    public let triggerErrors: [IntegrationIssue]
    public let errors: [IntegrationIssue]
    public let warnings: [IntegrationIssue]
    public let testFailures: [IntegrationIssue]
    public let analyzerWarnings: [IntegrationIssue]
    
    // MARK: Initialization
    
    public required init(json: [String:Any]) throws {
		self.buildServiceErrors = try json["buildServiceErrors"].unwrap(as: [[String:Any]].self).map { try IntegrationIssue(json: $0) }
        self.buildServiceWarnings = try json["buildServiceWarnings"].unwrap(as: [[String : Any]].self).map { try IntegrationIssue(json: $0) }
        self.triggerErrors = try json["triggerErrors"].unwrap(as: [[String : Any]].self).map { try IntegrationIssue(json: $0) }
        
        // Nested issues
		self.errors = try json["errors"].unwrap(as: [String:[[String:Any]]].self)
            .values
            .filter { $0.count != 0 }
            .flatMap {
				try $0.map { try IntegrationIssue(json: $0) }
        }
        self.warnings = try json["warnings"].unwrap(as: [String:[[String:Any]]].self)
            .values
            .filter { $0.count != 0 }
            .flatMap {
				try $0.map { try IntegrationIssue(json: $0) }
        }
        self.testFailures = try json["testFailures"].unwrap(as: [String:[[String:Any]]].self)
            .values
            .filter { $0.count != 0 }
            .flatMap {
				try $0.map { try IntegrationIssue(json: $0) }
        }
        self.analyzerWarnings = try json["analyzerWarnings"].unwrap(as: [String:[[String:Any]]].self)
            .values
            .filter { $0.count != 0 }
            .flatMap {
				try $0.map { try IntegrationIssue(json: $0) }
        }
        
        try super.init(json: json)
    }
    
}
