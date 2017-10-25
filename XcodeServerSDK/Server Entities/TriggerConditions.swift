//
//  TriggerConditions.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class TriggerConditions : XcodeServerEntity {
    
    public let status: Int
    public let onAnalyzerWarnings: Bool
    public let onBuildErrors: Bool
    public let onFailingTests: Bool
    public let onInternalErrors: Bool
    public let onSuccess: Bool
    public let onWarnings: Bool
    
    public init(status: Int = 2, onAnalyzerWarnings: Bool, onBuildErrors: Bool, onFailingTests: Bool, onInternalErrors: Bool, onSuccess: Bool, onWarnings: Bool) {
        
        self.status = status
        self.onAnalyzerWarnings = onAnalyzerWarnings
        self.onBuildErrors = onBuildErrors
        self.onFailingTests = onFailingTests
        self.onInternalErrors = onInternalErrors
        self.onSuccess = onSuccess
        self.onWarnings = onWarnings
        
        super.init()
    }
    
    public override func dictionarify() -> [String:Any] {
        var dict = [String:Any]()
        
        dict["status"] = self.status
        dict["onAnalyzerWarnings"] = self.onAnalyzerWarnings
        dict["onBuildErrors"] = self.onBuildErrors
        dict["onFailingTests"] = self.onFailingTests
        dict["onInternalErrors"] = self.onInternalErrors
        dict["onSuccess"] = self.onSuccess
        dict["onWarnings"] = self.onWarnings
        
        return dict
    }
    
    public required init(json: [String:Any]) throws {
        
        self.status = json["status"] as? Int ?? 2
        self.onAnalyzerWarnings = try json["onAnalyzerWarnings"].unwrap(as: Bool.self)
        self.onBuildErrors = try json["onBuildErrors"].unwrap(as: Bool.self)
        self.onFailingTests = try json["onFailingTests"].unwrap(as: Bool.self)
        
        //not present in Xcode 8 anymore, make it optional & default to false
        let internalErrors = json["onInternalErrors"] as? Bool
        self.onInternalErrors = internalErrors ?? false
        self.onSuccess = try json["onSuccess"].unwrap(as: Bool.self)
        self.onWarnings = try json["onWarnings"].unwrap(as: Bool.self)
        
        try super.init(json: json)
    }
}
