// Delete this line
/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */


import Foundation

class Propositions_OptimizeTests {
    static let shared = Propositions_OptimizeTests()
    
    let PROPOSITION_VALID =
     """
     {\
         "id": "de03ac85-802a-4331-a905-a57053164d35",\
         "items": [{\
             "id": "xcore:personalized-offer:1111111111111111",\
             "etag": "10",\
             "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",\
             "data": {\
                 "id": "xcore:personalized-offer:1111111111111111",\
                 "format": "text/html",\
                 "content": "<h1>This is a HTML content</h1>"\
             }\
         }],\
         "placement": {\
             "etag": "1",\
             "id": "xcore:offer-placement:1111111111111111"\
         },\
         "activity": {\
             "etag": "8",\
             "id": "xcore:offer-activity:1111111111111111"\
         },\
         "scope": "eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="\
     }
     """
        
        let PROPOSITION_VALID_WITH_LANGUAGE_AND_CHARACTERISTICS =
      """
      {\
          "id": "de03ac85-802a-4331-a905-a57053164d35",\
          "items": [{\
              "id": "xcore:personalized-offer:1111111111111111",\
              "etag": "10",\
              "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",\
              "data": {\
                  "id": "xcore:personalized-offer:1111111111111111",\
                  "format": "text/html",\
                  "content": "<h1>This is a HTML content</h1>",\
                  "language": [\
                      "en-us"\
                  ],\
                  "characteristics": {\
                      "mobile": "true"\
                  }\
              }\
          }],\
          "placement": {\
              "etag": "1",\
              "id": "xcore:offer-placement:1111111111111111"\
          },\
          "activity": {\
              "etag": "8",\
              "id": "xcore:offer-activity:1111111111111111"\
          },\
          "scope": "eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="\
      }
      """
        
        let PROPOSITION_VALID_TARGET =
     """
     {\
         "id": "AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9",\
         "items": [{\
             "id": "246315",\
             "schema": "https://ns.adobe.com/personalization/json-content-item",\
             "data": {\
                 "id": "246315",\
                 "format": "application/json",
                 "content": {\
                     "device": "mobile"\
                 }\
             }\
         }],\
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
         }\
     }
     """
        
        let PROPOSITION_INVALID =
     """
     {\
         "items": [{\
             "id": "xcore:personalized-offer:1111111111111111",\
             "etag": "10",\
             "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",\
             "data": {\
                 "id": "xcore:personalized-offer:1111111111111111",\
                 "format": "text/html",\
                 "content": "<h1>This is a HTML content</h1>"\
             }\
         }],\
         "placement": {\
             "etag": "1",\
             "id": "xcore:offer-placement:1111111111111111"\
         },\
         "activity": {\
             "etag": "8",\
             "id": "xcore:offer-activity:1111111111111111"\
         },\
         "scope": "eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="\
     }
     """
}
