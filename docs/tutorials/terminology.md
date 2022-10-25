# Terminology

`Decision Scope`: An Adobe Target mbox location name or a base64 encoded JSON, containing Offer Decisioning activityId, placementId and an optional itemCount, serialized to UTF-8 string. It specifies the context in which an offer appears to the user and is usually associated with a decision activity.

`Decision` (or `Activity`): A decision contains the logic that informs the selection of an offer.

`Proposition`: It encapsulates the offers proposed for a given scope based on certain eligibility rules and constraints.

`Offer`: An offer is a marketing message that may have rules associated with it that specify who is eligible to see the offer.

`Datastream` : A datastream is a server-side configuration on Platform Edge Network that controls where data goes. Datastreams ensure that incoming data is routed to the Adobe Experience Platform application and services (like Target) appropriatel. For more information, see the [datastreams documentation](https://experienceleague.adobe.com/docs/experience-platform/edge/datastreams/overview.html?lang=en) or this [video](https://experienceleague.adobe.com/docs/platform-learn/data-collection/edge-network/configure-datastreams.html?lang=en).
