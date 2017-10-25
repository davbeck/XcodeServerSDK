//
//  XcodeServerEndpointsTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 20/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import XcodeServerSDK

class XcodeServerEndpointsTests: XCTestCase {

    let serverConfig = try! XcodeServerConfig(host: "https://127.0.0.1", user: "test", password: "test")
    var endpoints: XcodeServerEndpoints?
    
    override func setUp() {
        super.setUp()
        self.endpoints = XcodeServerEndpoints(serverConfig: serverConfig)
    }
    
    // MARK: createRequest()
    
    // If malformed URL is passed to request creation function it should early exit and retur nil
    func testMalformedURLCreation() {
        let expectation = endpoints?.createRequest(.get, endpoint: .Bots, params: ["test": "test"], query: ["test//http\\": "!test"], body: ["test": "test"], doBasicAuth: true)
        XCTAssertNil(expectation, "Shouldn't create request from malformed URL")
    }
    
    func testRequestCreationForEmptyAuthorizationParams() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/bots/bot_id/integrations")
        let expectedRequest = NSMutableURLRequest(URL: expectedUrl!)
        // HTTPMethod
        expectedRequest.HTTPMethod = "GET"
        // Authorization header: "": ""
        expectedRequest.setValue("Basic Og==", forHTTPHeaderField: "Authorization")
        
        let noAuthorizationConfig = try! XcodeServerConfig(host: "https://127.0.0.1")
        let noAuthorizationEndpoints = XcodeServerEndpoints(serverConfig: noAuthorizationConfig)
        let request = noAuthorizationEndpoints.createRequest(.get, endpoint: .Integrations, params: ["bot": "bot_id"], query: nil, body: nil, doBasicAuth: true)
        XCTAssertEqual(expectedRequest, request!)
    }
    
    func testGETRequestCreation() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/bots/bot_id/integrations?format=json")
        let expectedRequest = NSMutableURLRequest(URL: expectedUrl!)
        // HTTPMethod
        expectedRequest.HTTPMethod = "GET"
        // Authorization header: "test": "test"
        expectedRequest.setValue("Basic dGVzdDp0ZXN0", forHTTPHeaderField: "Authorization")
        
        let request = self.endpoints?.createRequest(.get, endpoint: .Integrations, params: ["bot": "bot_id"], query: ["format": "json"], body: nil, doBasicAuth: true)
        XCTAssertEqual(expectedRequest, request!)
    }
    
    func testPOSTRequestCreation() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/auth/logout")
        let expectedRequest = NSMutableURLRequest(URL: expectedUrl!)
        // HTTPMethod
        expectedRequest.HTTPMethod = "POST"
        // httpBody
        let expectedData = "{\n  \"bodyParam\" : \"bodyValue\"\n}".dataUsingEncoding(NSUTF8StringEncoding)
        expectedRequest.httpBody = expectedData!
        expectedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let request = self.endpoints?.createRequest(.post, endpoint: .Logout, params: nil, query: nil, body: ["bodyParam": "bodyValue"], doBasicAuth: false)
        XCTAssertEqual(expectedRequest, request!)
        XCTAssertEqual(expectedRequest.httpBody!, request!.httpBody!)
    }
    
    func testDELETERequestCreation() {
        let expectedUrl = URL(string: "https://127.0.0.1:20343/api/bots/bot_id/rev_id")
        let expectedRequest = NSMutableURLRequest(URL: expectedUrl!)
        // HTTPMethod
        expectedRequest.HTTPMethod = "DELETE"
        
        let request = self.endpoints?.createRequest(.delete, endpoint: .Bots, params: ["bot": "bot_id", "rev": "rev_id"], query: nil, body: nil, doBasicAuth: false)
        XCTAssertEqual(expectedRequest, request!)
    }
    
    // MARK: endpointURL(for: .Bots)
    
    func testEndpointURLCreationForBotsPath() {
        let expectation = "/api/bots"
        let url = self.endpoints?.endpointURL(for: .Bots)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Bots) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotPath() {
        let expectation = "/api/bots/bot_id"
        let params = [
            "bot": "bot_id"
        ]
        let url = self.endpoints?.endpointURL(for: .Bots, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Bots, \(params)) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotRevPath() {
        let expectation = "/api/bots/bot_id/rev_id"
        let params = [
            "bot": "bot_id",
            "rev": "rev_id",
            "method": "DELETE"
        ]
        let url = self.endpoints?.endpointURL(for: .Bots, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Bots, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .Integrations)
    
    func testEndpointURLCreationForIntegrationsPath() {
        let expectation = "/api/integrations"
        let url = self.endpoints?.endpointURL(for: .Integrations)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Integrations) should return \(expectation)")
    }
    
    func testEndpointURLCreationForIntegrationsIntegrationPath() {
        let expectation = "/api/integrations/integration_id"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(for: .Integrations, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Integrations, \(params)) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotIntegrationsPath() {
        let expectation = "/api/bots/bot_id/integrations"
        let params = [
            "bot": "bot_id"
        ]
        let url = self.endpoints?.endpointURL(for: .Integrations, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Integrations, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .CancelIntegration)
    
    func testEndpointURLCreationForIntegrationsIntegrationCancelPath() {
        let expectation = "/api/integrations/integration_id/cancel"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(for: .CancelIntegration, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .CancelIntegration, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .Devices)
    
    func testEndpointURLCreationForDevicesPath() {
        let expectation = "/api/devices"
        let url = self.endpoints?.endpointURL(for: .Devices)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Devices) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .UserCanCreateBots)
    
    func testEndpointURLCreationForAuthIsBotCreatorPath() {
        let expectation = "/api/auth/isBotCreator"
        let url = self.endpoints?.endpointURL(for: .UserCanCreateBots)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .UserCanCreateBots) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .Login)
    
    func testEndpointURLCreationForAuthLoginPath() {
        let expectation = "/api/auth/login"
        let url = self.endpoints?.endpointURL(for: .Login)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Login) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .Logout)
    
    func testEndpointURLCreationForAuthLogoutPath() {
        let expectation = "/api/auth/logout"
        let url = self.endpoints?.endpointURL(for: .Logout)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Logout) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .Platforms)
    
    func testEndpointURLCreationForPlatformsPath() {
        let expectation = "/api/platforms"
        let url = self.endpoints?.endpointURL(for: .Platforms)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Platforms) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .SCM_Branches)
    
    func testEndpointURLCreationForScmBranchesPath() {
        let expectation = "/api/scm/branches"
        let url = self.endpoints?.endpointURL(for: .SCM_Branches)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .SCM_Branches) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .Repositories)
    
    func testEndpointURLCreationForRepositoriesPath() {
        let expectation = "/api/repositories"
        let url = self.endpoints?.endpointURL(for: .Repositories)
        XCTAssertEqual(url!, expectation, "endpointURL(for: .Repositories) should return \(expectation)")
    }
    
    // MARK: endpointURL(for: .Commits)
    
    func testEndpointURLCreationForCommits() {
        let expected = "/api/integrations/integration_id/commits"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(for: .Commits, params: params)
        XCTAssertEqual(url!, expected)
    }
    
    // MARK: endpointURL(for: .Issues)
    
    func testEndpointURLCreationForIssues() {
        let expected = "/api/integrations/integration_id/issues"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(for: .Issues, params: params)
        XCTAssertEqual(url!, expected)
    }
    
    // MARK: endpoingURL(.LiveUpdates)
    
    func testEndpointURLCreationForLiveUpdates_Start() {
        let expected = "/xcode/internal/socket.io/1"
        let url = self.endpoints?.endpointURL(for: .LiveUpdates, params: nil)
        XCTAssertEqual(url!, expected)
    }
    
    func testEndpointURLCreationForLiveUpdates_Poll() {
        let expected = "/xcode/internal/socket.io/1/xhr-polling/sup3rS3cret"
        let params = [
            "poll_id": "sup3rS3cret"
        ]
        let url = self.endpoints?.endpointURL(for: .LiveUpdates, params: params)
        XCTAssertEqual(url!, expected)
    }
}
