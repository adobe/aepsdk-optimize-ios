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

enum PersonalizationConstants {
    static let EXTENSION_NAME = "com.adobe.edge.personalization"
    static let FRIENDLY_NAME = "Edge Personalization"
    static let EXTENSION_VERSION = "1.0.0"
    static let LOG_TAG = FRIENDLY_NAME

    static let DECISION_SCOPE_NAME = "name"
    static let ACTIVITY_ID = "activityId"
    static let PLACEMENT_ID = "placementId"
    static let ITEM_COUNT = "itemCount"

    static let ERROR_UNKNOWN = "unknown"

    enum EventNames {
        static let UPDATE_PROPOSITIONS_REQUEST = "Update Propositions Request"
        static let GET_PROPOSITIONS_REQUEST = "Get Propositions Request"
        static let CLEAR_PROPOSITIONS_REQUEST = "Clear Propositions Request"
        static let PERSONALIZATION_NOTIFICATION = "Personalization Notification"
        static let EDGE_PERSONALIZATION_REQUEST = "Edge Personalization Request"
        static let PERSONALIZATION_RESPONSE = "Personalization Response"
    }

    enum EventSource {
        static let EDGE_PERSONALIZATION_DECISIONS = "personalization:decisions"
        static let EDGE_ERROR_RESPONSE = "com.adobe.eventSource.errorResponseContent"
    }

    enum EventDataKeys {
        static let REQUEST_TYPE = "requesttype"
        static let DECISION_SCOPES = "decisionscopes"
        static let XDM = "xdm"
        static let DATA = "data"
        static let DATASET_ID = "datasetid"
        static let PROPOSITIONS = "propositions"
        static let RESPONSE_ERROR = "responseerror"
    }

    enum EventDataValues {
        static let REQUEST_TYPE_UPDATE = "updatedecisions"
        static let REQUEST_TYPE_GET = "getdecisions"
    }

    enum Edge {
        static let EXTENSION_NAME = "com.adobe.edge"
        static let EVENT_HANDLE = "type"
        static let EVENT_HANDLE_TYPE_PERSONALIZATION = "personalization:decisions"
        static let PAYLOAD = "payload"
        enum ErrorKeys {
            static let TYPE = "type"
            static let DETAIL = "detail"
        }
    }

    enum Configuration {
        static let EXTENSION_NAME = "com.adobe.module.configuration"
    }

    enum JsonKeys {
        static let DECISION_SCOPES = "decisionScopes"
        static let XDM = "xdm"
        static let XDM_QUERY = "query"
        static let QUERY_PERSONALIZATION = "personalization"
        static let DATA = "data"
        static let DATASET_ID = "datasetId"
        static let XDM_EVENT_TYPE = "eventType"
    }

    enum JsonValues {
        static let XDM_EVENT_TYPE_PERSONALIZATION = "personalization.request"
    }
}
