//
//  XcodeServer+Integration.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01.07.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Integrations management
extension XcodeServer {
    
    // MARK: Bot releated integrations
    
    /**
    XCS API call for getting a list of filtered integrations for bot.
    Available queries:
    - **last**   - find last integration for bot
    - **from**   - find integration based on date range
    - **number** - find integration for bot by its number
    
    - parameter botId:          ID of bot.
    - parameter query:          Query which should be used to filter integrations.
    - parameter integrations:   Optional array of integrations returned from XCS.
    - parameter error:          Optional error.
    */
    public final func getBotIntegrations(botId: String, query: [String: String], completion: @escaping (_ integrations: [Integration]?, _ error: Error?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequest(with: .get, endpoint: .Integrations, params: params, query: query, body: nil) { (response, body, error) -> () in
            do {
				if let error = error {
					throw error
				}
				
				if let body = (body as? [String:Any])?["results"] as? [[String:Any]] {
					completion(try XcodeServerArray(body), nil)
				} else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
			} catch {
				completion(nil, error)
			}
        }
    }
    
    /**
    XCS API call for firing integration for specified bot.
    
    - parameter botId:          ID of the bot.
    - parameter integration:    Optional object of integration returned if run was successful.
    - parameter error:          Optional error.
    */
	public final func postIntegration(botId: String, completion: @escaping (_ integration: Integration?, _ error: Error?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequest(with: .post, endpoint: .Integrations, params: params, query: nil, body: nil) { (response, body, error) -> () in
			do {
				if let error = error {
					throw error
				}
				guard let body = body as? [String:Any] else { throw MyError.withInfo("Wrong body") }
				
				completion(try Integration(json: body), nil)
			} catch {
				completion(nil, error)
			}
        }
    }
    
    // MARK: General integrations methods
    
    /**
    XCS API call for retrievieng all available integrations on server.
    
    - parameter integrations:   Optional array of integrations.
    - parameter error:          Optional error.
    */
    public final func getIntegrations(completion: @escaping (_ integrations: [Integration]?, _ error: Error?) -> ()) {
        
        self.sendRequest(with: .get, endpoint: .Integrations, params: nil, query: nil, body: nil) {
            (response, body, error) -> () in
            
            do {
				if let error = error {
					throw error
				}
				
				guard let integrationsBody = (body as? [String:Any])?["results"] as? [[String:Any]] else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
				
				completion(try XcodeServerArray(integrationsBody), nil)
			} catch {
				completion(nil, error)
			}
        }
    }
    
    /**
    XCS API call for retrievieng specified Integration.
    
    - parameter integrationId: ID of integration which is about to be retrieved.
    - parameter completion:
    - Optional retrieved integration.
    - Optional operation error.
    */
	public final func getIntegration(integrationId: String, completion: @escaping (_ integration: Integration?, _ error: Error?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequest(with: .get, endpoint: .Integrations, params: params, query: nil, body: nil) {
            (response, body, error) -> () in
			do {
				if let error = error {
					throw error
				}
				guard let integrationBody = body as? [String:Any] else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
				
				completion(try Integration(json: integrationBody), nil)
			} catch {
				completion(nil, error)
			}
        }
    }
    
    /**
    XCS API call for canceling specified integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Integration cancelling success indicator.
    - parameter error:         Optional operation error.
    */
    public final func cancelIntegration(integrationId: String, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequest(with: .post, endpoint: .CancelIntegration, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(false, error)
                return
            }
            
            completion(true, nil)
        }
    }
    
    /**
    XCS API call for fetching all commits for specific integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Optional Integration Commits object with result.
    - parameter error:         Optional operation error.
    */
    public final func getIntegrationCommits(integrationId: String, completion: @escaping (_ integrationCommits: IntegrationCommits?, _ error: Error?) ->()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequest(with: .get, endpoint: .Commits, params: params, query: nil, body: nil) { (response, body, error) -> () in
			do {
				if let error = error {
					throw error
				}
				guard let integrationCommitsBody = (body as? [String:Any])?["results"] as? NSArray else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
				
				completion(try IntegrationCommits(json: integrationCommitsBody[0] as! [String:Any]), nil)
			} catch {
				completion(nil, error)
			}
        }
        
    }
    
    /**
    XCS API call for fetching all commits for specific integration.
    
    - parameter integrationId: ID of integration.
    - parameter success:       Optional Integration Issues object with result.
    - parameter error:         Optional operation error.
    */
    public final func getIntegrationIssues(integrationId: String, completion: @escaping (_ integrationIssues: IntegrationIssues?, _ error: Error?) ->()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequest(with: .get, endpoint: .Issues, params: params, query: nil, body: nil) { (response, body, error) -> () in
			do {
				if let error = error {
					throw error
				}
				guard let integrationIssuesBody = body as? [String:Any] else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
				
				completion(try IntegrationIssues(json: integrationIssuesBody), nil)
			} catch {
				completion(nil, error)
			}
        }
        
    }
    
    // TODO: Methods about to be implemented...
    
    // public func reportQueueSizeAndEstimatedWaitingTime(integration: Integration, completion: @escaping ((queueSize: Int, estWait: Double), Error?) -> ()) {
    
    //TODO: we need to call getIntegrations() -> filter pending and running Integrations -> get unique bots of these integrations -> query for the average integration time of each bot -> estimate, based on the pending/running integrations, how long it will take for the passed in integration to finish
    
}
