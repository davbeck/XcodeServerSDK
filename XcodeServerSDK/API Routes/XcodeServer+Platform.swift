//
//  XcodeServer+Platform.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Platform management
extension XcodeServer {
    
    /**
    XCS API method for getting available testing platforms on OS X Server.
    
    - parameter platforms:  Optional array of platforms.
    - parameter error:      Optional error indicating some problems.
    */
	public final func getPlatforms(completion: @escaping (_ platforms: [DevicePlatform]?, _ error: Error?) -> ()) {
        
        self.sendRequest(with: .get, endpoint: .Platforms, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
			
			do {
				if let array = (body as? [String:Any])?["results"] as? [[String:Any]] {
					completion(try XcodeServerArray(array), nil)
				} else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
			} catch {
				completion(nil, error)
			}
        }
    }
    
}
