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
        wait(for: [unregisterExpectation], timeout: 2)
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
                    let query = event?["query"] as? [String: Any]
                    let personalization = query?["personalization"] as? [String: Any]
                    let decisionScopes = personalization?["decisionScopes"] as? [String]
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
            XCTAssertEqual(.text, proposition?.offers[0].type)
            XCTAssertEqual("This is a plain text content!", proposition?.offers[0].content)
            XCTAssertEqual(["en-us"], proposition?.offers[0].language)
            XCTAssertEqual(["mobile": "true"], proposition?.offers[0].characteristics)

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
}
