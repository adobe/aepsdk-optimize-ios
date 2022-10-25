### Create a Datastream

In order to send data to the Edge Network, the datastream must be configured with the Event schema.

1. Select **Datastreams** (**1**) under **DATA COLLECTION** in the left side navigation panel . Select **New Datastream** (**2**) in the top right .

| ![Create new Datastream](../../assets/datastreams-main-view.png?raw=true) |
| :---: |
| **Create new Datastream** |

2. Give the datastream an identifying name and description (**1**), then pick the schema created in the previous section using the dropdown menu (**2**). Then select **Save** (**3**).

| ![Set Datastream values](../../assets/datastreams-new-datastream.png?raw=true) |
| :---: |
| **Set Datastream values** |

### Adobe Experience Platform Datastream configuration

With the datastream set up, data can be directed to its destination by adding services:
1. Select **Add Service** (**1**)

| ![Add Datastream Service](../../assets/datastreams-add-service.png?raw=true) |
| :---: |
| **Add Datastream Service** |

2. From the **Service (required)** dropdown, select **Adobe Experience Platform** (**1**) and enable it (**2**).
3. From the `Event Dataset`dropdown, select the dataset created for this tutorial (**3**).
4. Select **Save** (**4**).

| ![Add Experience Platform to Datastream](../../assets/datastreams-add-platform.png?raw=true) |
| :---: |
| **Add Experience Platform to Datastream** |


### Adobe Target Datastream configuration

With the datastream set up, data can be directed to its destination by adding services:
1. Select **Add Service** (**1**)

| ![Add Datastream Service](../../assets/datastreams-add-service2.png?raw=true) |
| :---: |
| **Add Datastream Service** |

2. From the **Service (required)** dropdown, select **Adobe Target** (**1**) and enable it (**2**).
3. Add the `Property Token` (**3**) copied from the Target UI Administration view.
4. Select **Save** (**4**).

| ![Add Target to Datastream](../../assets/datastreams-add-target.png?raw=true) |
| :---: |
| **Add Target to Datastream** |
