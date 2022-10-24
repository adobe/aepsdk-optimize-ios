### Create a Tag property

Next, create a property for mobile. A property is basically the configuration settings for AEP extensions, allowing you to control their functionality. 

Select **Tags** (**1**) under **DATA COLLECTION** in the left-side navigation panel. Select **New Property** (**2**) to create a new property.

<img src="../Assets/optimize-tutorial/aep-setup/tags-main-view.png" alt="Navigating to tags" width="1100"/>  

Enter an identifying name for the new property in the **Name** textfield (**1**), select **Mobile** (**2**) under **Platform**, then select **Save** (**3**).

<img src="../Assets/optimize-tutorial/aep-setup/tags-create-property.png" alt="Navigating to tags" width="1100"/>  

Find and select the mobile property for this tutorial (**2**), optionally using the search box to help quickly narrow down the search (**1**).

<img src="../Assets/optimize-tutorial/aep-setup/property-search.png" alt="Finding desired mobile property" width="1100"/>  

Select **Extensions** (**2**) in the left-side navigation panel, under **AUTHORING**. Notice there are some extensions are that installed by default (**1**).

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-extensions.png" alt="Finding desired mobile property" width="1100"/>  

Select **Catalog** (**1**) and (optionally) use the search box (**2**) to find the required extensions; select the **Install** button in an extension card to install the extension. 

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-catalog.png" alt="Catalog search example" width="1100"/>  

Install the AEP extensions with the following configurations:

<details>
  <summary> AEP Assurance </summary><p>

Open the **Catalog** and install the `AEP Assurance` extension configuration.

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-catalog-assurance.png" alt="Catalog search for Adobe Experience Platform Edge Network" width="1100"/>  

</p></details>

<details>
  <summary> Adobe Experience Platform Edge Network </summary><p>

Open the **Catalog** and install the `Adobe Experience Platform Edge Network` extension configuration.

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-catalog-edge.png" alt="Catalog search for Adobe Experience Platform Edge Network" width="1100"/>  

In the extension configuration settings window, set the datastream for each environment (**1**) to the one created for this tutorial. Then select `Save` (**2**)

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-edge-settings.png" alt="Edge extension settings" width="1100"/>  

</p></details>

<details>
  <summary> Identity </summary><p>

Open the **Catalog** and install the **Identity** extension configuration. There are no settings for this extension.

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-catalog-identity.png" alt="Catalog search for Identity" width="1100"/>  

</p></details>

<details>
  <summary> Consent </summary><p>

Open the **Catalog** and install the **Consent** extension configuration.

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-catalog-consent.png" alt="Catalog search for Consent" width="1100"/>  

In the extension configuration settings window, the **Default Consent Level** should be set to **Yes** by default (**1**); for the tutorial app this setting is fine as-is, however when using this configuration in production apps, it should reflect the requirements of the company's actual data collection policy for the app. 

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-consent-settings.png" alt="Consent extension settings" width="1100"/>  

</p></details>

<details>
  <summary> Adobe Journey Optimizer - Decisioning </summary><p>

Open the **Catalog** and install the `Adobe Journey Optimizer - Decisioning` extension configuration.

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-catalog-decisioning.png" alt="Catalog search for Adobe Experience Platform Edge Network" width="1100"/>  

</p></details>

You should see the following after all the extensions are installed: 

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-edge-extensions.png" alt="All installed extensions" width="1100"/>  

### 4. Configure a Rule to forward Lifecycle metrics to Target 

To send mobile Lifecycle metrics to Target for creating audiences, a rule needs to be set up on Experience Platform Data Collection to attach these metrics to the Edge personalization query requests. Note that there is no need to install Lifecycle since it is already included with Mobile Core.

#### Create a rule <!-- omit in toc -->
1. On the Rules tab, select **Create New Rule**.
   - If your property already has rules, the button will be in the top right of the screen.

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-create-rule.png" alt="All installed extensions" width="1100"/>  

2. Give your rule an easily recognizable name (**1**) in your list of rules. In this example, the rule is named "Forward Lifecycle metrics to Target".
3. Under the **EVENTS** section, select **Add** (**2**).

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-rule-1.png" alt="All installed extensions" width="1100"/>  

#### Select an event <!-- omit in toc -->

2. From the **Extension** dropdown list (**1**), select **Adobe Experience Platform Edge Network**.
3. From the **Event Type** dropdown list (**2**), select **AEP Request Event**.
4. On the right pane, click on + to specify XDM Event Type **equals**  (**3**) **personalization.request**  (**4**).
5. Select **Keep Changes** (**5**).

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-rule-2.png" alt="All installed extensions" width="1100"/>  

#### Define the action <!-- omit in toc -->
1. Under the Actions section, select **+ Add** (**1**).

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-rule-5.png" alt="All installed extensions" width="1100"/>  

2. From the **Extension** dropdown list (**1**), select **Mobile Core**.
3. From the **Action Type** dropdown list (**2**), select **Attach Data**.
4. On the right pane, specify the **JSON Payload** (**3**) containing metrics of interest. An example JSON Payload containing all of the mobile Lifecycle metrics is shown below.
```javascript
{
    "data": {
        "__adobe": {
            "target": {
                "a.appID": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.appid%}",
                "a.locale": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.locale%}",
                "a.RunMode": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.runmode%}",
                "a.Launches": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.launches%}",
                "a.DayOfWeek": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.dayofweek%}",
                "a.HourOfDay": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.hourofday%}",
                "a.OSVersion": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.osversion%}",
                "a.CrashEvent": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.crashevent%}",
                "a.DeviceName": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.devicename%}",
                "a.Resolution": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.resolution%}",
                "a.CarrierName": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.carriername%}",
                "a.InstallDate": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.installdate%}",
                "a.LaunchEvent": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.launchevent%}",
                "a.InstallEvent": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.installevent%}",
                "a.UpgradeEvent": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.upgradeevent%}",
                "a.DaysSinceLastUse": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.dayssincelastuse%}",
                "a.DailyEngUserEvent": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.dailyenguserevent%}",
                "a.DaysSinceFirstUse": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.dayssincefirstuse%}",
                "a.PrevSessionLength": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.prevsessionlength%}",
                "a.MonthlyEngUserEvent": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.monthlyenguserevent%}",
                "a.DaysSinceLastUpgrade": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.dayssincelastupgrade%}",
                "a.LaunchesSinceUpgrade": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.launchessinceupgrade%}",
                "a.ignoredSessionLength": "{%~state.com.adobe.module.lifecycle/lifecyclecontextdata.ignoredsessionlength%}"
            }
        }
    }
}
```
5. Select **Keep Changes** (**4**).

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-rule-6.png" alt="All installed extensions" width="1100"/>  

#### Save the rule and rebuild your property <!-- omit in toc -->
1. After you complete your configuration, verify that your rule looks like the following:
2. Select **Save** (**1**).

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-rule-7.png" alt="All installed extensions" width="1100"/>  

### 5. Publish changes
1. Select **Publishing Flow** under **PUBLISHING** in the left-side navigation window.
2. Select **Add Library** in the top right.
3. Set a **Name** (**1**) for the property, and set the environment to **Development** (**2**)
4. Select **Add All Changed Resources** (**3**)
5. Select **Save & Build to Development** (**4**)

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-publish.png" alt="All installed extensions" width="1100"/>  

#### Getting the mobile property ID <!-- omit in toc -->
Once the mobile property is published to the **Development** environment:  
1. Select the box icon next to the environment dropdown (**5**, from above)
2. Select the double overlapping box (**1**) to the right of the property ID to copy it. Save this unique ID (in a text file, or other easily accessible place), as it is required when setting up the app in the next section.

<img src="../Assets/optimize-tutorial/aep-setup/mobile-property-id.png" alt="All installed extensions" width="500"/>  

