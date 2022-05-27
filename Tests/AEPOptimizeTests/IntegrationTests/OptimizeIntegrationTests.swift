/*
Copyright 2021 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/
    
@testable import AEPCore
@testable import AEPServices
import AEPEdge
import AEPIdentity
import AEPEdgeIdentity
import AEPOptimize

import XCTest

class OptimizeIntegrationTests: XCTestCase {
    static let supportedSchemas = [
        "https://ns.adobe.com/personalization/html-content-item",
        "https://ns.adobe.com/personalization/json-content-item",
        "https://ns.adobe.com/personalization/default-content-item",
        "https://ns.adobe.com/experience/offer-management/content-component-html",
        "https://ns.adobe.com/experience/offer-management/content-component-json",
        "https://ns.adobe.com/experience/offer-management/content-component-imagelink",
        "https://ns.adobe.com/experience/offer-management/content-component-text"
    ]
    
    override func setUp() {
        UserDefaults.clear()
        FileManager.default.clearCache()
        ServiceProvider.shared.reset()
        EventHub.reset()
    }

    override func tearDown() {
        let unregisterExpectation = XCTestExpectation(description: "Unregister extension.")
        unregisterExpectation.expectedFulfillmentCount = 1
        MobileCore.unregisterExtension(Optimize.self) {
            unregisterExpectation.fulfill()
        }
        wait(for: [unregisterExpectation], timeout: 1)
    }

    func initExtensionsAndWait() {
        let initExpectation = XCTestExpectation(description: "Init extensions.")
        MobileCore.setLogLevel(.trace)
        MobileCore.registerExtensions([AEPIdentity.Identity.self, Edge.self, AEPEdgeIdentity.Identity.self, Optimize.self]) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 1)
    }

    func testUpdatePropositions_validEdgeRequest() {
        // setup
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                let data = request.connectPayload
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    let events = json["events"] as? [[String: Any]]
                    let event = events?[0]
                    
                    // xdm
                    let xdm = event?["xdm"] as? [String: Any]
                    let eventType = xdm?["eventType"] as? String
                    XCTAssertEqual("personalization.request", eventType)
                    
                    // query
                    let query = event?["query"] as? [String: Any]
                    let personalization = query?["personalization"] as? [String: Any]
                    let schemas = personalization?["schemas"] as? [String]
                    XCTAssertEqual(7, schemas?.count)
                    XCTAssertEqual(OptimizeIntegrationTests.supportedSchemas, schemas)
                    let decisionScopes = personalization?["decisionScopes"] as? [String]
                    XCTAssertEqual(1, decisionScopes?.count)
                    XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes?[0])
                } else {
                    XCTFail("Personalization query request to Edge network should be valid.")
                }

                requestExpectation.fulfill()
            }
            return nil
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"
        ])
        
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")
        
        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)

        wait(for: [requestExpectation], timeout: 2)
    }

    func testGetPropositions_propositionsInCache() {
        // setup
        let validResponse = HTTPURLResponse(url: URL(string: "https://edge.adobedc.net/ee/v1/interact?configId=configId&requestId=requestId")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseString = """
                {\
                   "requestId": "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF",\
                   "handle": [\
                      {\
                         "payload": [\
                            { \
                               "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",\
                               "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",\
                               "activity": {\
                                  "id": "xcore:offer-activity:1111111111111111",\
                                  "etag": "8"\
                               },\
                               "placement": {\
                                  "id": "xcore:offer-placement:1111111111111111",\
                                  "etag": "1"\
                               },\
                               "items": [\
                                  {\
                                     "id": "xcore:personalized-offer:2222222222222222",\
                                     "etag": "39",\
                                     "score": 1,\
                                     "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
                                     "data": {\
                                        "id": "xcore:personalized-offer:2222222222222222",\
                                        "format": "text/plain",\
                                        "language": [\
                                           "en-us"\
                                        ],\
                                        "content": "This is a plain text content!",\
                                        "characteristics": {\
                                           "mobile": "true"\
                                        }\
                                     }\
                                  }\
                               ]\
                            }\
                         ],\
                         "type":"personalization:decisions",\
                         "eventIndex":0\
                      }\
                   ]\
                }
        """

        // mock edge response
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                requestExpectation.fulfill()
                return (data: responseString.data(using: .utf8), response: validResponse, error: nil)
            }
            return (data: nil, response: validResponse, error: nil)
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"])

        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)
        wait(for: [requestExpectation], timeout: 2)

        sleep(2)
        
        // get propositions
        let retrieveExpectation = XCTestExpectation(description: "getPropositions should return the fetched propositions from the extension propositions cache.")
        Optimize.getPropositions(for: [decisionScope]) { propositionsDictionary, _ in
            guard let propositionsDictionary = propositionsDictionary else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertEqual(1, propositionsDictionary.count)
            
            let proposition = propositionsDictionary[decisionScope]
            XCTAssertNotNil(proposition)
            
            XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", proposition?.id)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition?.scope)
            
            XCTAssertEqual(1, proposition?.offers.count)
            XCTAssertEqual("xcore:personalized-offer:2222222222222222", proposition?.offers[0].id)
            XCTAssertEqual("39", proposition?.offers[0].etag)
            XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-text", proposition?.offers[0].schema)
            XCTAssertEqual(1, proposition?.offers[0].score)
            XCTAssertEqual(.text, proposition?.offers[0].type)
            XCTAssertEqual("This is a plain text content!", proposition?.offers[0].content)
            XCTAssertEqual(["en-us"], proposition?.offers[0].language)
            XCTAssertEqual(["mobile": "true"], proposition?.offers[0].characteristics)

            retrieveExpectation.fulfill()
        }
        wait(for: [retrieveExpectation], timeout: 2)
    }

    func testGetPropositions_propositionsInCacheFromTargetWithClickTracking() {
        // setup
        let validResponse = HTTPURLResponse(url: URL(string: "https://edge.adobedc.net/ee/v1/interact?configId=configId&requestId=requestId")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseString = """
                {\
                   "requestId": "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF",\
                   "handle": [\
                      {\
                         "payload": [\
                            {\
                               "id": "AT:eyJhY3Rpdml0eUlkIjoiMTExMTExIiwiZXhwZXJpZW5jZUlkIjoiMCJ9",\
                               "scope": "myMbox1",\
                               "scopeDetails": {\
                                    "activity": {\
                                        "id": "111111"\
                                    },\
                                    "experience": {\
                                        "id": "0"\
                                    },\
                                    "decisionProvider": "TGT",\
                                    "strategies": [\
                                        {\
                                            "step": "entry",\
                                            "algorithmID": "0",\
                                            "trafficType": "0"\
                                        },\
                                        {\
                                            "step": "display",\
                                            "algorithmID": "0",\
                                            "trafficType": "0"\
                                        }\
                                    ],\
                                    "characteristics": {\
                                        "stateToken": "SGFZpwAqaqFTayhAT2xsgzG3+2fw4m+O9FK8c0QoOHfxVkH1ttT1PGBX3/jV8a5uFF0fAox6CXpjJ1PGRVQBjHl9Zc6mRxY9NQeM7rs/3Es1RHPkzBzyhpVS6eg9q+kw",\
                                        "eventTokens": {\
                                            "display": "MmvRrL5aB4Jz36JappRYg2qipfsIHvVzTQxHolz2IpSCnQ9Y9OaLL2gsdrWQTvE54PwSz67rmXWmSnkXpSSS2Q==",\
                                            "click": "EZDMbI2wmAyGcUYLr3VpmA=="\
                                        }\
                                    }\
                               },\
                               "items": [\
                                  {\
                                     "id": "0",\
                                     "schema": "https://ns.adobe.com/personalization/json-content-item",\
                                     "data": {\
                                        "id": "0",\
                                        "format": "application/json",\
                                        "content": {\
                                            "device": "mobile"\
                                        }\
                                     }\
                                  },\
                                  {\
                                      "id": "111111",\
                                      "schema": "https://ns.adobe.com/personalization/measurement",\
                                      "data": {\
                                         "type": "click",\
                                         "format": "application/vnd.adobe.target.metric"\
                                      }\
                                  }\
                               ]\
                            }\
                         ],\
                         "type":"personalization:decisions",\
                         "eventIndex":0\
                      }\
                   ]\
                }
        """

        // mock edge response
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                requestExpectation.fulfill()
                return (data: responseString.data(using: .utf8), response: validResponse, error: nil)
            }
            return (data: nil, response: validResponse, error: nil)
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"])

        let decisionScope = DecisionScope(name: "myMbox1")

        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)
        wait(for: [requestExpectation], timeout: 2)

        sleep(2)
        
        // get propositions
        let retrieveExpectation = XCTestExpectation(description: "getPropositions should return the fetched propositions from the extension propositions cache.")
        Optimize.getPropositions(for: [decisionScope]) { propositionsDictionary, _ in
            guard let propositionsDictionary = propositionsDictionary else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertEqual(1, propositionsDictionary.count)
            
            let proposition = propositionsDictionary[decisionScope]
            XCTAssertNotNil(proposition)
            
            XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTExMTExIiwiZXhwZXJpZW5jZUlkIjoiMCJ9", proposition?.id)
            XCTAssertEqual("myMbox1", proposition?.scope)
            
            XCTAssertEqual(5, proposition?.scopeDetails.count)
            XCTAssertEqual("TGT", proposition?.scopeDetails["decisionProvider"] as? String)
            let sdActivity = proposition?.scopeDetails["activity"] as? [String: Any]
            XCTAssertEqual("111111", sdActivity?["id"] as? String)
            let sdExperience = proposition?.scopeDetails["experience"] as? [String: Any]
            XCTAssertEqual("0", sdExperience?["id"] as? String)
            let sdStrategies = proposition?.scopeDetails["strategies"] as? [[String: Any]]
            XCTAssertEqual(2, sdStrategies?.count)
            XCTAssertEqual("entry", sdStrategies?[0]["step"] as? String)
            XCTAssertEqual("0", sdStrategies?[0]["algorithmID"] as? String)
            XCTAssertEqual("0", sdStrategies?[0]["trafficType"] as? String)
            
            XCTAssertEqual("display", sdStrategies?[1]["step"] as? String)
            XCTAssertEqual("0", sdStrategies?[1]["algorithmID"] as? String)
            XCTAssertEqual("0", sdStrategies?[1]["trafficType"] as? String)
            
            let sdCharacteristics = proposition?.scopeDetails["characteristics"] as? [String: Any]
            XCTAssertEqual(2, sdCharacteristics?.count)
            XCTAssertEqual("SGFZpwAqaqFTayhAT2xsgzG3+2fw4m+O9FK8c0QoOHfxVkH1ttT1PGBX3/jV8a5uFF0fAox6CXpjJ1PGRVQBjHl9Zc6mRxY9NQeM7rs/3Es1RHPkzBzyhpVS6eg9q+kw", sdCharacteristics?["stateToken"] as? String)
            let eventTokens = sdCharacteristics?["eventTokens"] as? [String: Any]
            XCTAssertEqual(2, eventTokens?.count)
            XCTAssertEqual("MmvRrL5aB4Jz36JappRYg2qipfsIHvVzTQxHolz2IpSCnQ9Y9OaLL2gsdrWQTvE54PwSz67rmXWmSnkXpSSS2Q==", eventTokens?["display"] as? String)
            XCTAssertEqual("EZDMbI2wmAyGcUYLr3VpmA==", eventTokens?["click"] as? String)
            
            XCTAssertEqual(1, proposition?.offers.count)
            XCTAssertEqual("0", proposition?.offers[0].id)
            XCTAssertEqual("https://ns.adobe.com/personalization/json-content-item", proposition?.offers[0].schema)
            XCTAssertEqual(.json, proposition?.offers[0].type)
            XCTAssertEqual("{\"device\":\"mobile\"}", proposition?.offers[0].content)
            XCTAssertNil(proposition?.offers[0].language)
            XCTAssertNil(proposition?.offers[0].characteristics)

            retrieveExpectation.fulfill()
        }
        wait(for: [retrieveExpectation], timeout: 2)
    }

    func testGetPropositions_propositionNotInCache() {
        // init extensions
        initExtensionsAndWait()

        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"
        ])
        
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        let retrieveExpectation = XCTestExpectation(description: "getPropositions should not return propositions, if not previously cached.")
        Optimize.getPropositions(for: [decisionScope]) { propositionsDictionary, _ in
            XCTAssertEqual(0, propositionsDictionary?.count)
            retrieveExpectation.fulfill()
        }
        wait(for: [retrieveExpectation], timeout: 2)
    }

    func testGetPropositions_invalidEdgeResponse() {
        // setup
        let validResponse = HTTPURLResponse(url: URL(string: "https://edge.adobedc.net/ee/v1/interact?configId=configId&requestId=requestId")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseString = """
        {\
           "requestId":"FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF",\
           "handle":[],\
           "errors":[\
              {\
                 "type":"EXEG-0201-503",\
                 "status":503,\
                 "title":"The 'com.adobe.experience.platform.ode' service is temporarily unable to serve this request. Please try again later."\
              }\
           ]\
        }
        """

        // mock edge response
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                requestExpectation.fulfill()
                return (data: responseString.data(using: .utf8), response: validResponse, error: nil)
            }
            return (data: nil, response: validResponse, error: nil)
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"])
        
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                              placementId: "xcore:offer-placement:1111111111111111")

        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)
        wait(for: [requestExpectation], timeout: 2)

        // get propositions
        let retrieveExpectation = XCTestExpectation(description: "getPropositions should not return propositions, if update request errors out.")
        Optimize.getPropositions(for: [decisionScope]) { propositionsDictionary, error in
            XCTAssertEqual(0, propositionsDictionary?.count)
            retrieveExpectation.fulfill()
        }
        wait(for: [retrieveExpectation], timeout: 2)
    }

    func testOnPropositionsUpdate() {
        // setup
        let validResponse = HTTPURLResponse(url: URL(string: "https://edge.adobedc.net/ee/v1/interact?configId=configId&requestId=requestId")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseString = """
                {\
                   "requestId": "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF",\
                   "handle": [\
                      {\
                         "payload": [\
                            { \
                               "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",\
                               "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",\
                               "activity": {\
                                  "id": "xcore:offer-activity:1111111111111111",\
                                  "etag": "8"\
                               },\
                               "placement": {\
                                  "id": "xcore:offer-placement:1111111111111111",\
                                  "etag": "1"\
                               },\
                               "items": [\
                                  {\
                                     "id": "xcore:personalized-offer:2222222222222222",\
                                     "etag": "39",\
                                     "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
                                     "data": {\
                                        "id": "xcore:personalized-offer:2222222222222222",\
                                        "format": "text/plain",\
                                        "language": [\
                                           "en-us"\
                                        ],\
                                        "content": "This is a plain text content!",\
                                        "characteristics": {\
                                           "mobile": "true"\
                                        }\
                                     }\
                                  }\
                               ]\
                            }\
                         ],\
                         "type":"personalization:decisions",\
                         "eventIndex":0\
                      }\
                   ]\
                }
        """

        // mock edge response
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                requestExpectation.fulfill()
                return (data: responseString.data(using: .utf8), response: validResponse, error: nil)
            }
            return (data: nil, response: validResponse, error: nil)
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"])

        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        let updateExpectation = XCTestExpectation(description: "onPropositionsUpdate should be invoked upon a valid personalization query response from the Edge network.")
        Optimize.onPropositionsUpdate { propositionsDictionary in
            XCTAssertEqual(1, propositionsDictionary.count)
            
            let proposition = propositionsDictionary[decisionScope]
            XCTAssertNotNil(proposition)
            
            XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", proposition?.id)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition?.scope)
            
            XCTAssertEqual(1, proposition?.offers.count)
            XCTAssertEqual("xcore:personalized-offer:2222222222222222", proposition?.offers[0].id)
            XCTAssertEqual("39", proposition?.offers[0].etag)
            XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-text", proposition?.offers[0].schema)
            XCTAssertEqual(.text, proposition?.offers[0].type)
            XCTAssertEqual("This is a plain text content!", proposition?.offers[0].content)
            XCTAssertEqual(["en-us"], proposition?.offers[0].language)
            XCTAssertEqual(["mobile": "true"], proposition?.offers[0].characteristics)
            
            updateExpectation.fulfill()
        }

        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)
        wait(for: [requestExpectation], timeout: 2)

        wait(for: [updateExpectation], timeout: 2)
    }

    func testClearPropositions() {
        // setup
        let validResponse = HTTPURLResponse(url: URL(string: "https://edge.adobedc.net/ee/v1/interact?configId=configId&requestId=requestId")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseString = """
                {\
                   "requestId": "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF",\
                   "handle": [\
                      {\
                         "payload": [\
                            { \
                               "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",\
                               "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",\
                               "activity": {\
                                  "id": "xcore:offer-activity:1111111111111111",\
                                  "etag": "8"\
                               },\
                               "placement": {\
                                  "id": "xcore:offer-placement:1111111111111111",\
                                  "etag": "1"\
                               },\
                               "items": [\
                                  {\
                                     "id": "xcore:personalized-offer:2222222222222222",\
                                     "etag": "39",\
                                     "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
                                     "data": {\
                                        "id": "xcore:personalized-offer:2222222222222222",\
                                        "format": "text/plain",\
                                        "language": [\
                                           "en-us"\
                                        ],\
                                        "content": "This is a plain text content!",\
                                        "characteristics": {\
                                           "mobile": "true"\
                                        }\
                                     }\
                                  }\
                               ]\
                            }\
                         ],\
                         "type":"personalization:decisions",\
                         "eventIndex":0\
                      }\
                   ]\
                }
        """

        // mock edge response
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                requestExpectation.fulfill()
                return (data: responseString.data(using: .utf8), response: validResponse, error: nil)
            }
            return (data: nil, response: validResponse, error: nil)
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"])

        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)
        wait(for: [requestExpectation], timeout: 2)

        sleep(2)
        Optimize.clearCachedPropositions()
        
        // get propositions
        let retrieveExpectation = XCTestExpectation(description: "getPropositions should not return the fetched propositions, if the extension propositions cache is cleared.")
        Optimize.getPropositions(for: [decisionScope]) { propositionsDictionary, _ in
            XCTAssertEqual(0, propositionsDictionary?.count)
            retrieveExpectation.fulfill()
        }
        wait(for: [retrieveExpectation], timeout: 2)
    }

    func testOfferDisplayed() {
        // setup
        let validResponse = HTTPURLResponse(url: URL(string: "https://edge.adobedc.net/ee/v1/interact?configId=configId&requestId=requestId")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseString = """
                {\
                   "requestId": "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF",\
                   "handle": [\
                      {\
                         "payload": [\
                            { \
                               "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",\
                               "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",\
                               "activity": {\
                                  "id": "xcore:offer-activity:1111111111111111",\
                                  "etag": "8"\
                               },\
                               "placement": {\
                                  "id": "xcore:offer-placement:1111111111111111",\
                                  "etag": "1"\
                               },\
                               "items": [\
                                  {\
                                     "id": "xcore:personalized-offer:2222222222222222",\
                                     "etag": "39",\
                                     "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
                                     "data": {\
                                        "id": "xcore:personalized-offer:2222222222222222",\
                                        "format": "text/plain",\
                                        "language": [\
                                           "en-us"\
                                        ],\
                                        "content": "This is a plain text content!",\
                                        "characteristics": {\
                                           "mobile": "true"\
                                        }\
                                     }\
                                  }\
                               ]\
                            }\
                         ],\
                         "type":"personalization:decisions",\
                         "eventIndex":0\
                      }\
                   ]\
                }
        """

        // mock edge response
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                requestExpectation.fulfill()
                return (data: responseString.data(using: .utf8), response: validResponse, error: nil)
            }
            return (data: nil, response: validResponse, error: nil)
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"])

        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)
        wait(for: [requestExpectation], timeout: 2)

        sleep(2)
        mockNetworkService.clear()
        
        // get propositions
        let retrieveExpectation = XCTestExpectation(description: "getPropositions should return the fetched propositions from the extension propositions cache.")
        Optimize.getPropositions(for: [decisionScope]) { propositionsDictionary, _ in
            guard let propositionsDictionary = propositionsDictionary else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertEqual(1, propositionsDictionary.count)
            
            let proposition = propositionsDictionary[decisionScope]
            XCTAssertNotNil(proposition)
            
            XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", proposition?.id)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition?.scope)
            
            XCTAssertEqual(1, proposition?.offers.count)
            XCTAssertEqual("xcore:personalized-offer:2222222222222222", proposition?.offers[0].id)
            XCTAssertEqual("39", proposition?.offers[0].etag)
            XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-text", proposition?.offers[0].schema)
            XCTAssertEqual(.text, proposition?.offers[0].type)
            XCTAssertEqual("This is a plain text content!", proposition?.offers[0].content)
            XCTAssertEqual(["en-us"], proposition?.offers[0].language)
            XCTAssertEqual(["mobile": "true"], proposition?.offers[0].characteristics)

            retrieveExpectation.fulfill()
            
            // track offer display
            proposition?.offers[0].displayed()
        }
        
        let trackExpectation = XCTestExpectation(description: "Offer display should result in a valid interaction request to the Edge network.")
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                let data = request.connectPayload
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    let events = json["events"] as? [[String: Any]]
                    let event = events?[0]
                    
                    // xdm
                    let xdm = event?["xdm"] as? [String: Any]
                    let eventType = xdm?["eventType"] as? String
                    XCTAssertEqual("decisioning.propositionDisplay", eventType)
                    
                    let experience = xdm?["_experience"] as? [String: Any]
                    let decisioning = experience?["decisioning"] as? [String: Any]
                    let propositionDetailsArray = decisioning?["propositions"] as? [[String: Any]]
                    
                    let propositionDetailsData = propositionDetailsArray?[0]
                    XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", propositionDetailsData?["id"] as? String)
                    XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", propositionDetailsData?["scope"] as? String)
                    
                    // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
                    let scopeDetails = propositionDetailsData?["scopeDetails"] as? [String: Any] ?? [:]
                    XCTAssertTrue(scopeDetails.isEmpty)

                    let items = propositionDetailsData?["items"] as? [[String: Any]]
                    XCTAssertEqual(1, items?.count)

                    let item = items?[0]
                    XCTAssertEqual("xcore:personalized-offer:2222222222222222", item?["id"] as? String)

                } else {
                    XCTFail("Decisioning proposition display request to Edge network should be valid.")
                }

                trackExpectation.fulfill()
            }
            return nil
        }
        
        wait(for: [retrieveExpectation], timeout: 2)
        
        wait(for: [trackExpectation], timeout: 2)
    }

    func testOfferTapped() {
        // setup
        let validResponse = HTTPURLResponse(url: URL(string: "https://edge.adobedc.net/ee/v1/interact?configId=configId&requestId=requestId")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseString = """
                {\
                   "requestId": "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF",\
                   "handle": [\
                      {\
                         "payload": [\
                            { \
                               "id": "AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9",\
                               "scope": "myMbox",\
                               "scopeDetails": {\
                                 "decisionProvider": "TGT",\
                                 "activity": {\
                                   "id": "125589"\
                                 },\
                                 "experience": {\
                                   "id": "0"\
                                 },\
                                 "strategies": [\
                                   {\
                                     "algorithmID": "0",\
                                     "trafficType": "0"\
                                   }\
                                 ]\
                               },\
                               "items": [\
                                  {\
                                     "id": "246315",\
                                     "schema": "https://ns.adobe.com/personalization/html-content-item",\
                                     "data": {\
                                        "id": "246315",\
                                        "format": "text/html",\
                                        "content": "<h1>Hello, Welcome!</h1>",\
                                     }\
                                  }\
                               ]\
                            }\
                         ],\
                         "type":"personalization:decisions",\
                         "eventIndex":0\
                      }\
                   ]\
                }
        """

        // mock edge response
        let requestExpectation = XCTestExpectation(description: "updatePropositions should result in a valid personalization query request to the Edge network.")
        let mockNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = mockNetworkService
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                requestExpectation.fulfill()
                return (data: responseString.data(using: .utf8), response: validResponse, error: nil)
            }
            return (data: nil, response: validResponse, error: nil)
        }

        // init extensions
        initExtensionsAndWait()
        
        // update configuration
        MobileCore.updateConfigurationWith(configDict: [
                                            "experienceCloud.org": "orgid",
                                            "experienceCloud.server": "test.com",
                                            "global.privacy": "optedin",
                                            "edge.configId": "configId"])

        let decisionScope = DecisionScope(name: "myMbox")

        // update propositions
        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)
        wait(for: [requestExpectation], timeout: 2)

        sleep(2)
        mockNetworkService.clear()
        
        // get propositions
        let retrieveExpectation = XCTestExpectation(description: "getPropositions should return the fetched propositions from the extension propositions cache.")
        Optimize.getPropositions(for: [decisionScope]) { propositionsDictionary, _ in
            guard let propositionsDictionary = propositionsDictionary else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertEqual(1, propositionsDictionary.count)
            
            let proposition = propositionsDictionary[decisionScope]
            XCTAssertNotNil(proposition)
            
            XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", proposition?.id)
            XCTAssertEqual("myMbox", proposition?.scope)
            XCTAssertEqual(1, proposition?.offers.count)
            XCTAssertEqual("246315", proposition?.offers[0].id)
            XCTAssertEqual("https://ns.adobe.com/personalization/html-content-item", proposition?.offers[0].schema)
            XCTAssertEqual(.html, proposition?.offers[0].type)
            XCTAssertEqual("<h1>Hello, Welcome!</h1>", proposition?.offers[0].content)

            retrieveExpectation.fulfill()
            
            // track offer tap
            proposition?.offers[0].tapped()
        }
        
        let trackExpectation = XCTestExpectation(description: "Offer tap should result in a valid interaction request to the Edge network.")
        mockNetworkService.mock { request in
            if request.url.absoluteString.contains("edge.adobedc.net/ee/v1/interact?configId=configId") {
                let data = request.connectPayload
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    let events = json["events"] as? [[String: Any]]
                    let event = events?[0]
                    
                    // xdm
                    let xdm = event?["xdm"] as? [String: Any]
                    let eventType = xdm?["eventType"] as? String
                    XCTAssertEqual("decisioning.propositionInteract", eventType)

                    let experience = xdm?["_experience"] as? [String: Any]
                    let decisioning = experience?["decisioning"] as? [String: Any]
                    let propositionDetailsArray = decisioning?["propositions"] as? [[String: Any]]
                    
                    let propositionDetailsData = propositionDetailsArray?[0]
                    XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", propositionDetailsData?["id"] as? String)
                    XCTAssertEqual("myMbox", propositionDetailsData?["scope"] as? String)
                    
                    let scopeDetails = propositionDetailsData?["scopeDetails"] as? [String: Any]
                    XCTAssertEqual(4, scopeDetails?.count)
                    XCTAssertEqual("TGT", scopeDetails?["decisionProvider"] as? String)
                    let sdActivity = scopeDetails?["activity"] as? [String: Any]
                    XCTAssertEqual("125589", sdActivity?["id"] as? String)
                    let sdExperience = scopeDetails?["experience"] as? [String: Any]
                    XCTAssertEqual("0", sdExperience?["id"] as? String)
                    let sdStrategies = scopeDetails?["strategies"] as? [[String: Any]]
                    XCTAssertEqual(1, sdStrategies?.count)
                    XCTAssertEqual("0", sdStrategies?[0]["algorithmID"] as? String)
                    XCTAssertEqual("0", sdStrategies?[0]["trafficType"] as? String)

                    let items = propositionDetailsData?["items"] as? [[String: Any]]
                    XCTAssertEqual(1, items?.count)

                    let item = items?[0]
                    XCTAssertEqual("246315", item?["id"] as? String)

                } else {
                    XCTFail("Decisioning proposition interact request to Edge network should be valid.")
                }

                trackExpectation.fulfill()
            }
            return nil
        }
        
        wait(for: [retrieveExpectation], timeout: 2)
        
        wait(for: [trackExpectation], timeout: 2)
    }
}
