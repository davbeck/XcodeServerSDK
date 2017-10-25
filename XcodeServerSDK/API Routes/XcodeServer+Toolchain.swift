//
//  XcodeServer+Toolchain.swift
//  XcodeServerSDK
//
//  Created by Laurent Gaches on 21/04/16.
//  Copyright © 2016 Laurent Gaches. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - Toolchain XcodeSever API Routes
extension XcodeServer {
    
    /**
     XCS API call for getting all available toolchains.
     
     - parameter toolchains: Optional array of available toolchains.
     - parameter error:      Optional error.
     */
	public final func getToolchains(completion: @escaping (_ toolchains: [Toolchain]?, _ error: Error?) -> ()) {
        self.sendRequest(with: .get, endpoint: .Toolchains, params: nil, query: nil, body: nil) { (response, body, error) in
            if error != nil {
				completion(nil, error)
                return
            }
			
			do {
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
}
