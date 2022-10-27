
# Introduction

The AEPOptimize Mobile SDK extension is an open-source Swift extension. The extension powers personalization workflows in the mobile applications using Adobe Journey Optimizer - Offer Decisioning and/or Adobe Target capabilities via the Experience Platform Edge network.

The extension provides APIs to:

1. Fetch personalization decisions from the Experience Platform Edge network, and cache them locally in the SDK.
2. Retrieve previously cached propositions from the SDK.
3. Track interactions (e.g. display, tap) with the propositions.

| ![Optimize API Workflow](../assets/optimize-api-workflow.png?raw=true) |
| :---: |
| **Optimize API Workflow** |

In this tutorial, we will learn how to:

1. Set up a datastream to enable Adobe Target and configure tag property (including Optimize extension) on Data Collection UI.
2. Configure schema with the desired field group for streaming validation and create dataset for storing events in the Experience Platform.
3. Install Optimize extension and its dependencies in your mobile application, and initialize the SDK.
4. Implement the Optimize extension APIs to send personalization query requests and proposition interaction requests to the Experience Platform Edge network.
5. Validate the extension configuration and SDK workflows using Assurance.