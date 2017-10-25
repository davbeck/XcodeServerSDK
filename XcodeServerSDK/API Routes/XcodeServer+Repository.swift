//
//  XcodeServer+Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 30.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - // MARK: - XcodeSever API Routes for Repositories management
extension XcodeServer {
    
    /**
    XCS API call for getting all repositories stored on Xcode Server.
    
    - parameter repositories: Optional array of repositories.
    - parameter error:        Optional error
    */
    public final func getRepositories(completion: @escaping (_ repositories: [Repository]?, _ error: Error?) -> ()) {
        
        self.sendRequest(with: .get, endpoint: .Repositories, params: nil, query: nil, body: nil) { (response, body, error) -> () in
			do {
				if let error = error {
					throw error
				}
				guard let repositoriesBody = (body as? [String:Any])?["results"] as? [[String:Any]] else {
					throw MyError.withInfo("Wrong body \(String(describing: body))")
				}
				
				completion(try XcodeServerArray(repositoriesBody), nil)
			} catch {
				completion(nil, error)
			}
        }
    }
    
    /**
    Enum with response from creation of repository.
    
    - RepositoryAlreadyExists: Repository with this name already exists on OS X Server.
    - NilResponse:             Self explanatory.
    - CorruptedJSON:           JSON you've used to create repository.
    - WrongStatusCode:         Something wrong with HHTP status.
    - Error:                   There was an error during netwotk activity.
    - Success:                 Repository was successfully created 🎉
    */
    public enum CreateRepositoryResponse {
        case RepositoryAlreadyExists
        case NilResponse
        case CorruptedJSON
        case WrongStatusCode(Int)
        case Error(Error)
        case Success(Repository)
    }
    
    /**
    XCS API call for creating new repository on configured Xcode Server.
    
    - parameter repository: Repository object.
    - parameter repository: Optional object of created repository.
    - parameter error:      Optional error.
    */
    public final func createRepository(repository: Repository, completion: @escaping (_ response: CreateRepositoryResponse) -> ()) {
        let body = repository.dictionarify()
        
        self.sendRequest(with: .post, endpoint: .Repositories, params: nil, query: nil, body: body) { (response, body, error) -> () in
			do {
				if let error = error {
					completion(XcodeServer.CreateRepositoryResponse.Error(error))
					return
				}
				guard let response = response as? HTTPURLResponse else {
					completion(XcodeServer.CreateRepositoryResponse.NilResponse)
					return
				}
				
				guard let repositoryBody = body as? [String:Any], response.statusCode == 204 else {
					switch response.statusCode {
					case 200:
						completion(XcodeServer.CreateRepositoryResponse.CorruptedJSON)
					case 409:
						completion(XcodeServer.CreateRepositoryResponse.RepositoryAlreadyExists)
					default:
						completion(XcodeServer.CreateRepositoryResponse.WrongStatusCode(response.statusCode))
					}
					
					return
				}
				
				let result = try Repository(json: repositoryBody)
				completion(.Success(result))
			} catch {
				completion(.Error(error))
			}
        }
    }
}
