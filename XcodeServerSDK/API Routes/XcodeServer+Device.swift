//
//  XcodeServer+Device.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Devices management
extension XcodeServer {
    
    /**
    XCS API call for retrieving all registered devices on OS X Server.
    
    - parameter devices: Optional array of available devices.
    - parameter error:   Optional error indicating that something went wrong.
    */
    public final func getDevices(completion: @escaping (_ devices: [Device]?, _ error: Error?) -> ()) {
        
        self.sendRequest(with: .get, endpoint: .Devices, params: nil, query: nil, body: nil) { (response, body, error) -> () in
			do {
				if let error = error {
					throw error
				}
				guard let array = (body as? [String:Any])?["results"] as? [[String:Any]] else { throw MyError.withInfo("Wrong body") }
				
				completion(try XcodeServerArray(array), nil)
			} catch {
				completion(nil, error)
			}
        }
    }
    
}
