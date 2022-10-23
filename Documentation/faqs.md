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