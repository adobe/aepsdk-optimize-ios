# Event Reference

## Events handled

The following events are dispatched by the Optimize extension:

### Optimize Request Content

This event is a request to the Optimize extension to prefetch, retrieve or track propositions. The event is generated in the following scenarios:

* When `updatePropositions` API is invoked to fetch propositions from the Experience Platform Edge network for an array of provided decision scopes.
* When `getPropositions` API is invoked to retrieve previously fetched propositions cached in the 
* 

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.optimize | com.adobe.eventSource.requestContent |

#### Data payload definition

| Key | Data Type | Required | Description |
| requesttype | String | yes | 

### Edge personalization decisions

This event is dispatched by the Edge network extension when it receives personalization decisions from the Experience Platform Edge network, following a personalization query request. When this event is received, the Optimize extension parses and caches the received propositions in an in-memory propositions dictionary keyed by the corresponding decision scope.

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.edge | personalization:decisions |

#### Data payload definition

| Key | Data Type | Required | Description |

### Edge error response content

This event is dispatched by the Edge network extension when it receives an error response from the Experience Platform Edge network, following a personalization query request. When this event is received, the Optimize extension logs error related information specifying error type along with a detailed message.

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.edge | com.adobe.eventSource.errorResponseContent |

#### Data payload definition

| Key | Data Type | Required | Description |

### Optimize request reset

This event is dispatched when Optimize extension's `clearCachedPropositions` API is invoked. When this event is received, the Optimize extension clears all the previous cached propositions from the in-memory propositions cache.

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.optimize | com.adobe.eventSource.requestReset |

#### Data payload definition

N/A

### Generic identity request reset

This event is dispatched when the Mobile Core's `resetIdentities` API is invoked. When this event is received, the Optimize extension clears all the previous cached propositions from the in-memory propositions cache.

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.generic.identity | com.adobe.eventSource.requestReset |

#### Data payload definition

N/A

## Events dispatched

### Edge request content

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.edge | com.adobe.eventSource.requestContent |

#### Data payload definition

| Key | Data Type | Required | Description |

### Optimize notification 

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.optimize | com.adobe.eventSource.notification |

#### Data payload definition

| Key | Data Type | Required | Description |

### Optimize response content 

#### Event details

| Event Type | Event Source |
| ---------- | ------------ |
| com.adobe.eventType.optimize | com.adobe.eventSource.responseContent |

#### Data payload definition

| Key | Data Type | Required | Description |