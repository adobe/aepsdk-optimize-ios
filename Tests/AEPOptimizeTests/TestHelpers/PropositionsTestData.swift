// Delete this line
/*
Copyright 2025 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/
    

import Foundation

struct PropositionsTestData {
    static let PROPOSITION_VALID =
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
        
    static let PROPOSITION_VALID_WITH_LANGUAGE_AND_CHARACTERISTICS =
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
        
    static let PROPOSITION_VALID_TARGET =
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
        
    static let PROPOSITION_INVALID =
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

    static let OFFER_1 =
     """
     {\
         "id": "xcore:personalized-offer:1111111111111111",\
         "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
         "data": {\
             "id": "xcore:personalized-offer:1111111111111111",\
             "type": 2,\
             "content": "Test content 1"\
         }\
     }
     """

    static let OFFER_2 =
     """
     {\
         "id": "xcore:personalized-offer:2222222222222222",\
         "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
         "data": {\
             "id": "xcore:personalized-offer:2222222222222222",\
             "type": 2,\
             "content": "Test content 2"\
         }\
     }
     """

    static let OFFER_3 =
     """
     {\
         "id": "xcore:personalized-offer:3333333333333333",\
         "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
         "data": {\
             "id": "xcore:personalized-offer:3333333333333333",\
             "type": 2,\
             "content": "Test content 3"\
         }\
     }
     """

    static let PROPOSITION_1 =
     """
     {\
         "id": "de03ac85-802a-4331-a905-a57053164d35",\
         "scope": "eyJ4ZG06YWN0aXZpdHlJZCI6ImRwczpvZmZlci1hY3Rpdml0eToxYTc4OWFkYTE0ODQ1YjA2IiwieGRtOnBsYWNlbWVudElkIjoiZHBzOm9mZmVyLXBsYWNlbWVudDoxYTc4Njc0YWI1MDg1MDZjIn0=",\
         "scopeDetails": {},\
         "items": [\
             {\
                 "id": "xcore:personalized-offer:1111111111111111",\
                 "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
                 "data": {\
                     "id": "xcore:personalized-offer:1111111111111111",\
                     "type": 2,\
                     "content": "Test content 1"\
                 }\
             },\
             {\
                 "id": "xcore:personalized-offer:2222222222222222",\
                 "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
                 "data": {\
                     "id": "xcore:personalized-offer:2222222222222222",\
                     "type": 2,\
                     "content": "Test content 2"\
                 }\
             }\
         ]\
     }
     """

    static let PROPOSITION_2 =
     """
     {\
         "id": "AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9",\
         "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",\
         "scopeDetails": {\
             "decisionProvider": "TGT",\
             "activity": { "id": "125589" },\
             "experience": { "id": "0" },\
             "strategies": [{"algorithmID": "0", "trafficType": "0"}]\
         },\
         "items": [\
             {\
                 "id": "xcore:personalized-offer:3333333333333333",\
                 "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
                 "data": {\
                     "id": "xcore:personalized-offer:3333333333333333",\
                     "type": 2,\
                     "content": "Test content 3"\
                 }\
             }\
         ]\
     }
     """
}
