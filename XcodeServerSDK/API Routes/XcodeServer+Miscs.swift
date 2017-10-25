//
//  XcodeServer+Miscs.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 10/10/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

import BuildaUtils

// MARK: - Miscellaneous XcodeSever API Routes
extension XcodeServer {
    
    /**
    XCS API call for retrieving its canonical hostname.
    */
	public final func getHostname(completion: @escaping (_ hostname: String?, _ error: Error?) -> ()) {
        
        self.sendRequest(with: .get, endpoint: .Hostname, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            if let hostname = (body as? [String:Any])?["hostname"] as? String {
                completion(hostname, nil)
            } else {
				completion(nil, MyError.withInfo("Wrong body \(String(describing: body))"))
            }
        }
    }
    
}

