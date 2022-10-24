# Frequently Asked Questions

**What is the difference between a decision scope and a Target mbox?**

The decision scope array provided in a personalization query request consists of strings which can be either Target mbox location names or base64 encoding JSON (comprising of placementId, activityId and an optional itemCount) serialized to UTF-8 string. The Optimize extension provides a `DecisionScope` initializer (designated) which accepts mbox name as an initialization parameter.

**Does `getPropositions` Optimize extension API fetch offers from Adobe Target or Offer Decisioning via Experience Edge Network?**

No, the `updatePropositions` Optimize extension API helps fetch offers from Adobe Target or Offer Decisioning via Experience Platform Edge Network. The `getPropositions` API only retrieves previously cached propositions from the in-memory proposition cache in the extension. No additional network request is made to fetch the propositions not found in the extension cache.

**Does Optimize extension support both execute and prefetch modes for Adobe Target requests via Experience Edge Network?**

No, Optimize extension only supports the prefetch mode when using the personalization query request to fetch offers from Adobe Target. It also implies that impressions are not automatically registered, and deferred until a subsequent display notification call.

**Does Optimize extension support Target parameters (mbox, profile, product and order parameters)?**

Target parameters such as mbox parameters, profile parameters, order and product parameters can be provided in a personalization query request by send them as freeform data under data->__adobe->target. Currently, these parameters are only supported at the request level and not per mbox (scope) level!

**Does Optimize extension automatically attach mobile Lifecycle metrics to mbox parameters similar to the Target extension?**

No, Optimize extension does not automatically attach mobile Lifecycle metrics to mbox parameters for Target audience segmentation. However, a rule can be set up on Adobe Experience Platform Data Collection UI to attach these metrics to all outgoing personalization query requests.

**Does Optimize extension honor the `global.privacy` mobile SDK configuration setting?**

No, `global.privacy` setting applies only to the direct Adobe Solution extensions e.g. Target extension. Experience Platform Edge Network based extensions such as Optimize extension use the Consent extension for managing data collection consent preferences. If the Consent extension is not registered, default data collection consent is assumed to be `yes`.

**What is the effect of calling Mobile Core's `resetIdentities` API on Optimize extension?**

Upon calling `resetIdentities` SDK API, all previously cached propositions, in the Optimize extension, are cleared from the in-memory cache. Invoking Optimize extensions's `clearCachedPropositions` API also helps clear any previously cached propositions in the extension.

**Does Optimize extension support Analytics for Target (A4T)? If yes, is the A4T support similar to the Target extension?**

Yes, Optimize extension supports A4T. The A4T support differs from direct Target extension in the following ways:

1. When using Target extension, experienceCloud->analytics->logging is always configured to `server_side` in the v1 delivery API request. This informs Adobe Target to always respond with the Analytics payload containing `pe`(=tnt) and `tnta`. With Optimize extension, it is possible to configure A4T logging to client-side or server-side via datastream on Data Collection UI.
2. If Analytics extension is installed and registered, an internal track action event is automatically sent by the Target extension for the Analytics extension to send the A4T hit to Adobe Analytics. With Optimize extension, no A4T hit is automatically sent to Adobe Analytics for client-side logging.

**How does Optimize extension support both client-side and server-side A4T logging?**

__Server-side A4T logging__: When Adobe Analytics is enabled in the datastream and report suite is configured on Data Collection UI, A4T logging is assumed to be server-side. No analytics payload is returned to the client in this case, upon a personalization query request. A4T works out of the box and Experience Platform Edge network handles forwarding any Analytics payload to Adobe Analytics server-side. 

__Client-side A4T logging__: When Adobe Analytics is not enabled/configured in the datastream on Data Collection UI, A4T logging is assumed to be client-side. In this case, Target upstream returns the analytics payload, upon a personalization query request, under scopeDetails->characteristics->analyticsToken(s). The client can then decide if they want to send data to Adobe Analytics, say use data insertion API.