//
//  Trigger.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public struct TriggerConfig: XcodeRead, XcodeWrite {
    
    public let id: RefType
    
    public enum Phase: Int {
        case Prebuild = 1
        case Postbuild
        
        public func toString() -> String {
            switch self {
            case .Prebuild:
                return "Run Before the Build"
            case .Postbuild:
                return "Run After the Build"
            }
        }
    }
    
    public enum Kind: Int {
        case RunScript = 1
        case EmailNotification
        
        public func toString() -> String {
            switch self {
            case .RunScript:
                return "Run Script"
            case .EmailNotification:
                return "Send Email"
            }
        }
    }
    
    public var phase: Phase
    public var kind: Kind
    public var scriptBody: String
    public var name: String
    public var conditions: TriggerConditions?
    public var emailConfiguration: EmailConfiguration?
    
    //creates a default trigger config
    public init() {
        self.phase = .Prebuild
        self.kind = .RunScript
        self.scriptBody = "cd *\n"
        self.name = ""
        self.conditions = nil
        self.emailConfiguration = nil
        self.id = Ref.new()
    }
    
    public init?(phase: Phase, kind: Kind, scriptBody: String?, name: String?,
        conditions: TriggerConditions?, emailConfiguration: EmailConfiguration?, id: RefType? = Ref.new()) {
            
            self.phase = phase
            self.kind = kind
            self.scriptBody = scriptBody ?? ""
            self.name = name ?? kind.toString()
            self.conditions = conditions
            self.emailConfiguration = emailConfiguration
            self.id = id ?? Ref.new()
            
            //post build triggers must have conditions
            if phase == Phase.Postbuild {
                if conditions == nil {
                    return nil
                }
            }
            
            //email type must have a configuration
            if kind == Kind.EmailNotification {
                if emailConfiguration == nil {
                    return nil
                }
            }
    }
    
    public init(json: [String:Any]) throws {
        
        let phase = Phase(rawValue: try json["phase"].unwrap(as: Int.self))!
        self.phase = phase
		if let conditionsJSON = json["conditions"] as? [String:Any], phase == .Postbuild {
            //also parse conditions
            self.conditions = try TriggerConditions(json: conditionsJSON)
        } else {
            self.conditions = nil
        }
        
        let kind = Kind(rawValue: try json["type"].unwrap(as: Int.self))!
        self.kind = kind
		if let configurationJSON = json["emailConfiguration"] as? [String:Any], kind == .EmailNotification {
            //also parse email config
            self.emailConfiguration = try EmailConfiguration(json: configurationJSON)
        } else {
            self.emailConfiguration = nil
        }
        
        self.name = try json["name"].unwrap(as: String.self)
        self.scriptBody = try json["scriptBody"].unwrap(as: String.self)
        
        self.id = json["id"] as? String ?? Ref.new()
    }
    
    public func dictionarify() -> [String:Any] {
        
        var dict = [String:Any]()
        
        dict["id"] = self.id
        dict["phase"] = self.phase.rawValue
        dict["type"] = self.kind.rawValue
        dict["scriptBody"] = self.scriptBody
        dict["name"] = self.name
		dict["conditions"] = self.conditions?.dictionarify()
		dict["emailConfiguration"] = self.emailConfiguration?.dictionarify()
        
        return dict
    }
}

public class Trigger : XcodeServerEntity {
    
    public let config: TriggerConfig
    
    public init(config: TriggerConfig) {
        self.config = config
        super.init()
    }
    
    required public init(json: [String:Any]) throws {
        
        self.config = try TriggerConfig(json: json)
        try super.init(json: json)
    }
    
    public override func dictionarify() -> [String:Any] {
        let dict = self.config.dictionarify()
        return dict
    }
}




