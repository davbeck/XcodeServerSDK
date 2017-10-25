//
//  Bot.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Bot : XcodeServerEntity {
    
    public let name: String
    public let configuration: BotConfiguration
    public let integrationsCount: Int

    public required init(json: [String:Any]) throws {
        
        self.name = try json["name"].unwrap(as: String.self)
        self.configuration = try BotConfiguration(json: try json["configuration"].unwrap(as: [String:Any].self))
        self.integrationsCount = json["integration_counter"] as? Int ?? 0
        
        try super.init(json: json)
    }
    
    /**
    *  Creating bots on the server. Needs dictionary representation.
    */
    public init(name: String, configuration: BotConfiguration) {
        
        self.name = name
        self.configuration = configuration
        self.integrationsCount = 0
        
        super.init()
    }

    public override func dictionarify() -> [String:Any] {
		var dictionary = [String:Any]()

        //name
        dictionary["name"] = self.name
        
        //configuration
        dictionary["configuration"] = self.configuration.dictionarify()
        
        //others
        dictionary["type"] = 1 //magic more
        dictionary["requiresUpgrade"] = false
        dictionary["group"] = [
            "name": UUID().uuidString
        ]
        
        return dictionary
    }
    

}

extension Bot : CustomStringConvertible {
    public var description : String {
        get {
            return "[Bot \(self.name)]"
        }
    }
}


