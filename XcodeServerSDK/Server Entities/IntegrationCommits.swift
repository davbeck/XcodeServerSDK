//
//  IntegrationCommits.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 23/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public class IntegrationCommits: XcodeServerEntity {
    
    public let integration: String
    public let botTinyID: String
    public let botID: String
    public let commits: [String: [Commit]]
    public let endedTimeDate: Date?
    
    public required init(json: [String:Any]) throws {
        self.integration = try json["integration"].unwrap(as: String.self)
        self.botTinyID = try json["botTinyID"].unwrap(as: String.self)
        self.botID = try json["botID"].unwrap(as: String.self)
		self.commits = try IntegrationCommits.populateCommits(json: try json["commits"].unwrap(as: [String:Any].self))
		self.endedTimeDate = IntegrationCommits.parseDate(array: try json["endedTimeDate"].unwrap(as: NSArray.self))
        
        try super.init(json: json)
    }
    
    /**
    Method for populating commits property with data from JSON dictionary.
    
    - parameter json: JSON dictionary with blueprints and commits for each one.
    
    - returns: Dictionary of parsed Commit objects.
    */
    class func populateCommits(json: [String:Any]) throws -> [String: [Commit]] {
        var resultsDictionary = [String: [Commit]]()
        
        for (blueprintID, value) in json {
            guard let commitsArray = value as? [[String:Any]] else {
                Log.error("Couldn't parse key \(blueprintID) and value \(value)")
                continue
            }
            
            resultsDictionary[blueprintID] = try commitsArray.map { try Commit(json: $0) }
        }
        
        return resultsDictionary
    }
    
    /**
    Parser for data objects which comes in form of array.
    
    - parameter array: Array with date components.
    
    - returns: Optional parsed date to the format used by Xcode Server.
    */
    class func parseDate(array: NSArray) -> Date? {
        guard let dateArray = array as? [Int] else {
            Log.error("Couldn't parse XCS date array")
            return nil
        }
        
        do {
            let stringDate = try dateArray.dateString()
            
            guard let date = Date.dateFromXCSString(stringDate) else {
                Log.error("Formatter couldn't parse date")
                return nil
            }
            
            return date
		} catch DateParsingError.wrongNumberOfElements(let elements) {
            Log.error("Couldn't parse date as Array has \(elements) elements")
        } catch {
            Log.error("Something went wrong while parsing date")
        }
        
        return nil
    }
    
}
