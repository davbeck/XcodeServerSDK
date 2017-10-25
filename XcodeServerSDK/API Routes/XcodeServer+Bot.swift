//
//  XcodeServer+Bot.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01.07.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Bot management
extension XcodeServer {
    
    // MARK: Bot management
    
    /**
    Creates a new Bot from the passed in information. First validates Bot's Blueprint to make sure
    that the credentials are sufficient to access the repository and that the communication between
    the client and XCS will work fine. This might take a couple of seconds, depending on your proximity
    to your XCS.
    
    - parameter botOrder:   Bot object which is wished to be created.
    - parameter response:   Response from the XCS.
    */
	public final func createBot(botOrder: Bot, completion: @escaping (_ response: CreateBotResponse) -> ()) {
        
        //first validate Blueprint
        let blueprint = botOrder.configuration.sourceControlBlueprint
		self.verifyGitCredentials(from: blueprint) { (response) -> () in
            
            switch response {
            case .Error(let error):
				completion(XcodeServer.CreateBotResponse.Error(error: error))
                return
            case .SSHFingerprintFailedToVerify(let fingerprint, _):
                blueprint.certificateFingerprint = fingerprint
				completion(XcodeServer.CreateBotResponse.BlueprintNeedsFixing(fixedBlueprint: blueprint))
                return
            case .Success(_, _): break
            }
            
            //blueprint verified, continue creating our new bot
            
            //next, we need to fetch all the available platforms and pull out the one intended for this bot. (TODO: this could probably be sped up by smart caching)
			self.getPlatforms(completion: { (platforms, error) -> () in
                
                if let error = error {
					completion(XcodeServer.CreateBotResponse.Error(error: error))
                    return
                }
                
                do {
                    //we have platforms, find the one in the bot config and replace it
					try self.replacePlaceholderPlatform(in: botOrder, platforms: platforms!)
                } catch {
                    completion(.Error(error: error))
                    return
                }
                
                //cool, let's do it.
                self.createBotNoValidation(botOrder, completion: completion)
            })
        }
    }

    /**
    XCS API call for getting all available bots.
    
    - parameter bots:       Optional array of available bots.
    - parameter error:      Optional error.
    */
	public final func getBots(completion: @escaping (_ bots: [Bot]?, _ error: Error?) -> ()) {
        
        self.sendRequest(with: .get, endpoint: .Bots, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
			
			do {
				if let body = (body as? [String:Any])?["results"] as? [[String:Any]] {
					completion(try XcodeServerArray(body), nil)
				} else {
					throw MyError.withInfo("Wrong data returned: \(String(describing: body))")
				}
			} catch {
				completion(nil, error)
			}
        }
    }
    
    /**
    XCS API call for getting specific bot.
    
    - parameter botTinyId:  ID of bot about to be received.
    - parameter bot:        Optional Bot object.
    - parameter error:      Optional error.
    */
	public final func getBot(botTinyId: String, completion: @escaping (_ bot: Bot?, _ error: Error?) -> ()) {
        
        let params = [
            "bot": botTinyId
        ]
        
        self.sendRequest(with: .get, endpoint: .Bots, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
			
			do {
				if let body = body as? [String:Any] {
					completion(try Bot(json: body), nil)
				} else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
			} catch {
				completion(nil, error)
			}
        }
    }
    
    /**
    XCS API call for deleting bot on specified revision.
    
    - parameter botId:      Bot's ID.
    - parameter revision:   Revision which should be deleted.
    - parameter success:    Operation result indicator.
    - parameter error:      Optional error.
    */
	public final func deleteBot(botId: String, revision: String, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        
        let params = [
            "rev": revision,
            "bot": botId
        ]
        
        self.sendRequest(with: .delete, endpoint: .Bots, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(false, error)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 204 {
                    completion(true, nil)
                } else {
                    completion(false, MyError.withInfo("Wrong status code: \(response.statusCode)"))
                }
            } else {
                completion(false, MyError.withInfo("Nil response"))
            }
        }
    }
    
    // MARK: Helpers
    
    /**
    Enum for handling Bot creation response.
    
    - Success:              Bot has been created successfully.
    - BlueprintNeedsFixing: Source Control needs fixing.
    - Error:                Couldn't create Bot.
    */
    public enum CreateBotResponse {
        case Success(bot: Bot)
        case BlueprintNeedsFixing(fixedBlueprint: SourceControlBlueprint)
        case Error(error: Error)
    }
    
    enum PlaceholderError: Error {
        case PlatformMissing
        case DeviceFilterMissing
    }
    
    private func replacePlaceholderPlatform(in bot: Bot, platforms: [DevicePlatform]) throws {
        
        if let filter = bot.configuration.deviceSpecification.filters.first {
            let intendedPlatform = filter.platform
            if let platform = platforms.findFirst({ $0.type == intendedPlatform.type }) {
                //replace
                filter.platform = platform
            } else {
                // Couldn't find intended platform in list of platforms
                throw PlaceholderError.PlatformMissing
            }
        } else {
            // Couldn't find device filter
            throw PlaceholderError.DeviceFilterMissing
        }
    }
    
	private func createBotNoValidation(_ botOrder: Bot, completion: @escaping (_ response: CreateBotResponse) -> ()) {
        
        let body = botOrder.dictionarify()
        
        self.sendRequest(with: .post, endpoint: .Bots, params: nil, query: nil, body: body) { (response, body, error) -> () in
            
            if let error = error {
                completion(XcodeServer.CreateBotResponse.Error(error: error))
                return
            }
            
            guard let dictBody = body as? [String:Any] else {
				let e = MyError.withInfo("Wrong body \(String(describing: body))")
                completion(XcodeServer.CreateBotResponse.Error(error: e))
                return
            }
			
			do {
				completion(XcodeServer.CreateBotResponse.Success(bot: try Bot(json: dictBody)))
			} catch {
				completion(XcodeServer.CreateBotResponse.Error(error: error))
			}
        }
    }

}
