//
//  Integration.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Integration : XcodeServerEntity {
    
    //usually available during the whole integration's lifecycle
    public let queuedDate: Date
    public let shouldClean: Bool
    public let currentStep: Step!
    public let number: Int
    
    //usually available only after the integration has finished
    public let successStreak: Int?
    public let startedDate: Date?
    public let endedTime: Date?
    public let duration: TimeInterval?
    public let result: Result?
    public let buildResultSummary: BuildResultSummary?
    public let testedDevices: [Device]?
    public let testHierarchy: TestHierarchy?
    public let assets: [String:Any]?  //TODO: add typed array with parsing
    public let blueprint: SourceControlBlueprint?
    
    //new keys
    public let expectedCompletionDate: Date?
    
    public enum Step : String {
        case Unknown = ""
        case Pending = "pending"
        case Preparing = "preparing"
        case Checkout = "checkout"
        case BeforeTriggers = "before-triggers"
        case Building = "building"
        case Testing = "testing"
        case Archiving = "archiving"
        case Processing = "processing"
        case AfterTriggers = "after-triggers"
        case Uploading = "uploading"
        case Completed = "completed"
    }
    
    public enum Result : String {
        case Unknown = "unknown"
        case Succeeded = "succeeded"
        case BuildErrors = "build-errors"
        case TestFailures = "test-failures"
        case Warnings = "warnings"
        case AnalyzerWarnings = "analyzer-warnings"
        case BuildFailed = "build-failed"
        case CheckoutError = "checkout-error"
        case InternalError = "internal-error"
        case InternalCheckoutError = "internal-checkout-error"
        case InternalBuildError = "internal-build-error"
        case InternalProcessingError = "internal-processing-error"
        case Canceled = "canceled"
        case TriggerError = "trigger-error"
    }
    
    public required init(json: [String:Any]) throws {
        self.queuedDate = try Date.dateFromXCSString(json["queuedDate"].unwrap(as: String.self)).unwrap()
        self.startedDate = (json["startedTime"] as? String).flatMap(Date.dateFromXCSString)
        self.endedTime = (json["endedTime"] as? String).flatMap(Date.dateFromXCSString)
        self.duration = json["duration"] as? Double
        self.shouldClean = try json["shouldClean"].unwrap(as: Bool.self)
        self.currentStep = Step(rawValue: try json["currentStep"].unwrap(as: String.self)) ?? .Unknown
        self.number = try json["number"].unwrap(as: Int.self)
        self.successStreak = try json["success_streak"].unwrap(as: Int.self)
        self.expectedCompletionDate = (json["expectedCompletionDate"] as? String).flatMap(Date.dateFromXCSString)
        
        if let raw = json["result"] as? String {
            self.result = Result(rawValue: raw)
        } else {
            self.result = nil
        }
        
        if let raw = json["buildResultSummary"] as? [String:Any] {
            self.buildResultSummary = try BuildResultSummary(json: raw)
        } else {
            self.buildResultSummary = nil
        }
        
        if let testedDevices = json["testedDevices"] as? [[String:Any]] {
            self.testedDevices = try XcodeServerArray(testedDevices)
        } else {
            self.testedDevices = nil
        }
        
        if let testHierarchy = json["testHierarchy"] as? [String:Any], testHierarchy.count > 0 {
            self.testHierarchy = try TestHierarchy(json: testHierarchy)
        } else {
            self.testHierarchy = nil
        }

        self.assets = json["assets"] as? [String:Any]
        
        if let blueprint = json["revisionBlueprint"] as? [String:Any] {
            self.blueprint = try SourceControlBlueprint(json: blueprint)
        } else {
            self.blueprint = nil
        }
        
        try super.init(json: json)
    }
}

public class BuildResultSummary : XcodeServerEntity {
    
    public let analyzerWarningCount: Int
    public let testFailureCount: Int
    public let testsChange: Int
    public let errorCount: Int
    public let testsCount: Int
    public let testFailureChange: Int
    public let warningChange: Int
    public let regressedPerfTestCount: Int
    public let warningCount: Int
    public let errorChange: Int
    public let improvedPerfTestCount: Int
    public let analyzerWarningChange: Int
    public let codeCoveragePercentage: Int
    public let codeCoveragePercentageDelta: Int
    
    public required init(json: [String:Any]) throws {
        
        self.analyzerWarningCount = try json["analyzerWarningCount"].unwrap(as: Int.self)
        self.testFailureCount = try json["testFailureCount"].unwrap(as: Int.self)
        self.testsChange = try json["testsChange"].unwrap(as: Int.self)
        self.errorCount = try json["errorCount"].unwrap(as: Int.self)
        self.testsCount = try json["testsCount"].unwrap(as: Int.self)
        self.testFailureChange = try json["testFailureChange"].unwrap(as: Int.self)
        self.warningChange = try json["warningChange"].unwrap(as: Int.self)
        self.regressedPerfTestCount = try json["regressedPerfTestCount"].unwrap(as: Int.self)
        self.warningCount = try json["warningCount"].unwrap(as: Int.self)
        self.errorChange = try json["errorChange"].unwrap(as: Int.self)
        self.improvedPerfTestCount = try json["improvedPerfTestCount"].unwrap(as: Int.self)
        self.analyzerWarningChange = try json["analyzerWarningChange"].unwrap(as: Int.self)
        self.codeCoveragePercentage = json["codeCoveragePercentage"] as? Int ?? 0
        self.codeCoveragePercentageDelta = json["codeCoveragePercentageDelta"] as? Int ?? 0
        
        try super.init(json: json)
    }
    
}

extension Integration : Hashable {
    
    public var hashValue: Int {
        get {
            return self.number
        }
    }
}

public func ==(lhs: Integration, rhs: Integration) -> Bool {
    return lhs.number == rhs.number
}


