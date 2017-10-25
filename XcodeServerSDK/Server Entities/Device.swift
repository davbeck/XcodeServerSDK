//
//  Device.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/03/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public class Device : XcodeServerEntity {
    
    public let osVersion: String
    public let connected: Bool
    public let simulator: Bool
    public let modelCode: String? // Enum?
    public let deviceType: String? // Enum?
    public let modelName: String?
    public let deviceECID: String?
    public let modelUTI: String?
    public let activeProxiedDevice: Device?
    public let trusted: Bool
    public let name: String
    public let supported: Bool
    public let processor: String?
    public let identifier: String
    public let enabledForDevelopment: Bool
    public let serialNumber: String?
    public let platform: DevicePlatform.PlatformType
    public let architecture: String // Enum?
    public let isServer: Bool
    public let retina: Bool
    
    public required init(json: [String:Any]) throws {
        
        self.connected = try json["connected"].unwrap(as: Bool.self)
        self.osVersion = try json["osVersion"].unwrap(as: String.self)
        self.simulator = try json["simulator"].unwrap(as: Bool.self)
        self.modelCode = json["modelCode"] as? String
        self.deviceType = json["deviceType"] as? String
        self.modelName = json["modelName"] as? String
        self.deviceECID = json["deviceECID"] as? String
        self.modelUTI = json["modelUTI"] as? String
        if let proxyDevice = json["activeProxiedDevice"] as? [String:Any] {
            self.activeProxiedDevice = try Device(json: proxyDevice)
        } else {
            self.activeProxiedDevice = nil
        }
        self.trusted = json["trusted"] as? Bool ?? false
        self.name = try json["name"].unwrap(as: String.self)
        self.supported = try json["supported"].unwrap(as: Bool.self)
        self.processor = json["processor"] as? String
        self.identifier = try json["identifier"].unwrap(as: String.self)
        self.enabledForDevelopment = try json["enabledForDevelopment"].unwrap(as: Bool.self)
        self.serialNumber = json["serialNumber"] as? String
        self.platform = DevicePlatform.PlatformType(rawValue: try json["platformIdentifier"].unwrap(as: String.self)) ?? .Unknown
        self.architecture = try json["architecture"].unwrap(as: String.self)
        
        //for some reason which is not yet clear to me (probably old/new XcS versions), sometimes
        //the key is "server" and sometimes "isServer". this just picks up the present one.
        self.isServer = json["server"] as? Bool ?? json["isServer"] as? Bool ?? false
        self.retina = try json["retina"].unwrap(as: Bool.self)
        
        try super.init(json: json)
    }
    
    public override func dictionarify() -> [String:Any] {
        
        return [
            "device_id": self.id
        ]
    }
    
}
