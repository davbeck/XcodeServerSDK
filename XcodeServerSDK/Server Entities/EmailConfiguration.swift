//
//  EmailConfiguration.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class EmailConfiguration : XcodeServerEntity {
    
    public let additionalRecipients: [String]
    public let emailCommitters: Bool
    public let includeCommitMessages: Bool
    public let includeIssueDetails: Bool
    
    public init(additionalRecipients: [String], emailCommitters: Bool, includeCommitMessages: Bool, includeIssueDetails: Bool) {
        
        self.additionalRecipients = additionalRecipients
        self.emailCommitters = emailCommitters
        self.includeCommitMessages = includeCommitMessages
        self.includeIssueDetails = includeIssueDetails
        
        super.init()
    }
    
    public override func dictionarify() -> [String:Any] {
		var dict = [String:Any]()

        dict["emailCommitters"] = self.emailCommitters
        dict["includeCommitMessages"] = self.includeCommitMessages
        dict["includeIssueDetails"] = self.includeIssueDetails
        dict["additionalRecipients"] = self.additionalRecipients
        
        return dict
    }
    
    public required init(json: [String:Any]) throws {
        
        self.emailCommitters = try json["emailCommitters"].unwrap(as: Bool.self)
        self.includeCommitMessages = try json["includeCommitMessages"].unwrap(as: Bool.self)
        self.includeIssueDetails = try json["includeIssueDetails"].unwrap(as: Bool.self)
        self.additionalRecipients = try json["additionalRecipients"].unwrap(as: [String].self)
        
        try super.init(json: json)
    }
}
