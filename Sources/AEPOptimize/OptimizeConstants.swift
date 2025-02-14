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

import Foundation

enum OptimizeConstants {
    static let EXTENSION_NAME = "com.adobe.optimize"
    static let FRIENDLY_NAME = "Optimize"
    static let EXTENSION_VERSION = "5.2.1"
    static let LOG_TAG = FRIENDLY_NAME

    static let DECISION_SCOPE_NAME = "name"
    static let XDM_NAME = "xdm:name"
    static let ACTIVITY_ID = "activityId"
    static let XDM_ACTIVITY_ID = "xdm:activityId"
    static let PLACEMENT_ID = "placementId"
    static let XDM_PLACEMENT_ID = "xdm:placementId"
    static let ITEM_COUNT = "itemCount"
    static let XDM_ITEM_COUNT = "xdm:itemCount"

    static let ERROR_UNKNOWN = "unknown"
    static let UNKNOWN_STATUS = 0
    static let CONFIGURATION_NAME = "com.adobe.module.configuration"
    static let DEFAULT_TIMEOUT: TimeInterval = 10

    enum EventNames {
        static let UPDATE_PROPOSITIONS_REQUEST = "Optimize Update Propositions Request"
        static let GET_PROPOSITIONS_REQUEST = "Optimize Get Propositions Request"
        static let TRACK_PROPOSITIONS_REQUEST = "Optimize Track Propositions Request"
        static let CLEAR_PROPOSITIONS_REQUEST = "Optimize Clear Propositions Request"
        static let OPTIMIZE_NOTIFICATION = "Optimize Notification"
        static let EDGE_PERSONALIZATION_REQUEST = "Edge Optimize Personalization Request"
        static let EDGE_PROPOSITION_INTERACTION_REQUEST = "Edge Optimize Proposition Interaction Request"
        static let OPTIMIZE_RESPONSE = "Optimize Response"
        static let OPTIMIZE_UPDATE_COMPLETE = "Optimize Update Propositions Complete"
    }

    enum EventSource {
        static let EDGE_PERSONALIZATION_DECISIONS = "personalization:decisions"
        static let EDGE_ERROR_RESPONSE = "com.adobe.eventSource.errorResponseContent"
        static let DEBUG = "com.adobe.eventSource.debug"
    }

    enum EventDataKeys {
        static let REQUEST_TYPE = "requesttype"
        static let DECISION_SCOPES = "decisionscopes"
        static let XDM = "xdm"
        static let DATA = "data"
        static let TIMEOUT = "timeout"
        static let PROPOSITIONS = "propositions"
        static let RESPONSE_ERROR = "responseerror"
        static let PROPOSITION_INTERACTIONS = "propositioninteractions"
        static let REQUEST_EVENT_ID = "requestEventId"
        static let COMPLETED_UPDATE_EVENT_ID = "completedUpdateRequestForEventId"
    }

    enum EventDataValues {
        static let REQUEST_TYPE_UPDATE = "updatepropositions"
        static let REQUEST_TYPE_GET = "getpropositions"
        static let REQUEST_TYPE_TRACK = "trackpropositions"
    }

    enum Edge {
        static let EXTENSION_NAME = "com.adobe.edge"
        static let EVENT_HANDLE = "type"
        static let EVENT_HANDLE_TYPE_PERSONALIZATION = "personalization:decisions"
        static let PAYLOAD = "payload"
        enum ErrorKeys {
            static let TYPE = "type"
            static let STATUS = "status"
            static let TITLE = "title"
            static let DETAIL = "detail"
            static let REPORT = "report"
        }
    }

    enum Configuration {
        static let EXTENSION_NAME = "com.adobe.module.configuration"
        static let OPTIMIZE_OVERRIDE_DATASET_ID = "optimize.datasetId"
        static let OPTIMIZE_TIMEOUT_VALUE = "optimize.timeout"
    }

    enum JsonKeys {
        static let DECISION_SCOPES = "decisionScopes"
        static let XDM = "xdm"
        static let QUERY = "query"
        static let QUERY_PERSONALIZATION = "personalization"
        static let SCHEMAS = "schemas"
        static let DATA = "data"
        static let DATASET_ID = "datasetId"
        static let EXPERIENCE_EVENT_TYPE = "eventType"
        static let EXPERIENCE = "_experience"
        static let EXPERIENCE_DECISIONING = "decisioning"
        static let DECISIONING_PROPOSITION_ID = "propositionID"
        static let DECISIONING_PROPOSITIONS = "propositions"
        static let DECISIONING_PROPOSITION_EVENT_TYPE = "propositionEventType"
        static let PROPOSITION_EVENT_TYPE_DISPLAY = "display"
        static let PROPOSITION_EVENT_TYPE_INTERACT = "interact"
        static let DECISIONING_PROPOSITIONS_ID = "id"
        static let DECISIONING_PROPOSITIONS_SCOPE = "scope"
        static let DECISIONING_PROPOSITIONS_SCOPEDETAILS = "scopeDetails"
        static let DECISIONING_PROPOSITIONS_ITEMS = "items"
        static let DECISIONING_PROPOSITIONS_ITEMS_ID = "id"
        static let REQUEST = "request"
        static let REQUEST_SEND_COMPLETION = "sendCompletion"
    }

    enum JsonValues {
        static let EE_EVENT_TYPE_PERSONALIZATION = "personalization.request"
        static let EE_EVENT_TYPE_PROPOSITION_DISPLAY = "decisioning.propositionDisplay"
        static let EE_EVENT_TYPE_PROPOSITION_INTERACT = "decisioning.propositionInteract"

        // Target schemas
        static let SCHEMA_TARGET_HTML = "https://ns.adobe.com/personalization/html-content-item"
        static let SCHEMA_TARGET_JSON = "https://ns.adobe.com/personalization/json-content-item"
        static let SCHEMA_TARGET_DEFAULT = "https://ns.adobe.com/personalization/default-content-item"

        // Offer Decisioning schemas
        static let SCHEMA_OFFER_HTML = "https://ns.adobe.com/experience/offer-management/content-component-html"
        static let SCHEMA_OFFER_JSON = "https://ns.adobe.com/experience/offer-management/content-component-json"
        static let SCHEMA_OFFER_IMAGE = "https://ns.adobe.com/experience/offer-management/content-component-imagelink"
        static let SCHEMA_OFFER_TEXT = "https://ns.adobe.com/experience/offer-management/content-component-text"
    }

    enum ErrorData {
        enum Timeout {
            static let STATUS = 408
            static let TITLE = "Request Timeout"
            static let DETAIL = "Update/Get proposition request resulted in a timeout."
        }

        enum InvalidRequest {
            static let STATUS = 400
            static let TITLE = "Invalid Request"
            static let DETAIL = "Decision scopes, in event data, is either not present or empty."
        }
    }

    enum HTTPResponseCodes: Int {
        case success = 200
        case noContent = 204
        case multiStatus = 207
        case invalidRequest = 400
        case clientTimeout = 408
        case tooManyRequests = 429
        case internalServerError = 500
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
    }
}
