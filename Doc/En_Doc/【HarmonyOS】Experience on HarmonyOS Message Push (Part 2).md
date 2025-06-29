## 【HarmonyOS】Experience on HarmonyOS Message Push (Part 2)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/3435410839d247078c5dd4cc11b0c196b1862.png)  

### Preface  

Developing push functionality differs significantly from traditional feature development. The most prominent difference is the need for cross-department collaboration. As a HarmonyOS client developer, **you must collaborate with product managers, operations staff, and backend developers to successfully implement this feature**.  

In the previous article, [【HarmonyOS】Experience on HarmonyOS Message Push (Part 1)](https://blog.csdn.net/superherowupan/article/details/140476623?spm=1001.2014.3001.5501), enabling push services and configuring push settings on the AGC platform are primarily the responsibility of operations staff in the company. After all, the company's Huawei AGC platform account is not freely accessible to developers.  

However, current integration documents for push services, whether official Huawei documents or third-party push SDK provider documents, **mix operational content together**. Huawei's official documentation only slightly splits the backend REST API. Some content requires developer operations, while other tasks belong to product managers, operations staff, or even the push initiation backend, all of which are included in the same document.  

In summary, HarmonyOS client developers need to go through the entire document, verify push functionality using demos, and then divide the tasks for formal integration, collaborating with other departments to complete configurations and processing.  

This highlights the need for **application developers to have a test application account with authorized permissions** to validate integration before cross-department communication. Otherwise, they can only wait for preconditions to be met, which is time-consuming.  

It is recommended that such documents **be categorized by roles**, allowing each team to perform its duties efficiently.  


### Role Division for Push Functionality  

As a HarmonyOS application developer who has learned from experience, I have sorted out the role division for HarmonyOS push services.  

Of course, this is for reference only, and the actual division should be based on your company's department responsibilities. If your company's product team does not take charge, and operations staff handle tasks like project managers, there is no need to use this article to criticize others—after all, it's not worth getting angry over.  

In my case, there are product managers, operations staff, backend developers, and application developers. UI design mainly involves push notification icons and interactions, which is less relevant and will not be elaborated here. If you lack corresponding roles, **you need authorized permissions to operate**. Remember not to proceed alone.  

If anything goes wrong, others may ask why you operated without authorization—you understand.  

Without further ado, here is the role-based task breakdown for reference:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/b774270143bc4345b7a26a08064c0bc6b1862.png)  

1. **Operations Personnel** need to enable push services on the Huawei AGC platform and handle push types. It is essential to know that Push Kit classifies notification messages into **Service & Communication** and **Information Marketing** categories.  
In simple terms, Huawei officially categorizes push content based on scenarios to **strictly control message display positions, push frequencies, and reminder methods**. It is essentially a set of corresponding relationship tables; operations staff should carefully read the content and **match their application's push scenarios accordingly**.  
For detailed information, refer to the document **Apply for Push Scenario-based Message Rights** under Push Kit.  

2. **Product Personnel** should participate in confirming the scenario classification by operations staff, as well as the notification interactions and UI design with developers.  

3. **HarmonyOS Application Developers** must ensure that notification permissions are granted by users. When the application starts for the first time, a pop-up must ask users for permission to send notifications, as the notification switch is disabled by default. Failing to request authorization means pushes will not be displayed. If the error code 1600004 is returned, it indicates that authorization was rejected.  

***Note: If a user has previously denied authorization, calling the API again will not display the authorization modal dialog. Therefore, you need to add a custom prompt for this error type, notifying users that they have rejected authorization and need to manually enable the application's notification switch in the settings.***  

```dart
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit'; 
 
/**
 * Request to enable notifications
 */
public requestEnableNotificationByUser(context: common.UIAbilityContext){
  let requestEnableNotificationCallback = (err: BusinessError): void => {
    if (err) {
      console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    } else {
      console.info("requestEnableNotification success");
    }
  };
  notificationManager.requestEnableNotification(context, requestEnableNotificationCallback);
}
```  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/0c948d34e3344b6dabe9bce14fa6c1e8b1862.png)  

Next is the operation of obtaining the Push Token mentioned in the previous article (Part 1). After acquiring the token, you need to send it to the backend server for push operations.  

Finally, handle the action when a notification is clicked. If the business requires navigating to the application's home page upon clicking a notification, you need to process it in:  

```dart
import { UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class MainAbility extends UIAbility {
  onCreate(want: Want): void {
    // Get the data passed in the message
    const data = want.parameters;
    hilog.info(0x0000, 'testTag', 'Succeeded in getting message data');
    // Process the data according to the actual business scenario
  }
}
```  

If your ability uses the singleton mode, you need to handle it again in the `onNewWant()` method.  
***When clicking a message to enter the application's home page for the first time, the message data is obtained in the `onCreate()` method. When the application process is already running, clicking a new message to enter the home page will obtain the data in the `onNewWant()` method.***  
**When your ability sets a URL or action, it can navigate to a specific page within the application for processing.**  

4. **Backend Developers** need to read the REST API documentation to develop interfaces for push message structures, message receipts,撤回 (withdrawal), push, live windows, VoIP, etc.  
The application server calls the REST API to push notification messages. A notification message example is as follows:  

```dart
// Request URL
POST https://push-api.cloud.huawei.com/v3/[projectId]/messages:send

// Request Header
Content-Type: application/json
// JWT format string, refer to Authorization for acquisition.
Authorization: Bearer eyJr*****OiIx---****.eyJh*****iJodHR--***.QRod*****4Gp---****
push-type: 0 // 0 indicates the notification message scenario.

// Request Body
{
  "payload": {
    "notification": {
      "category": "MARKETING",// Information marketing type, 2 messages per day
      "title": "普通通知标题",
      "body": "普通通知内容",
      "profileId": "111***222", // Unique identification ID obtained by binding the application account and token
      "clickAction": {
        "actionType": 0 // 0 means clicking the message opens the application's home page.
      }
    }
  },
  "target": {
    "token": ["IQAAAA**********4Tw"] // User push token sent from the client to the server backend
  }
}
```  

After completing the entire process above, your application can implement push functionality. Of course, this is just the basic usage; advanced features like live windows and VoIP are not elaborated here. Those interested can refer to the official API for detailed study.  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/a2351b0f28174c80a2513a13b12fef3eb1862.png)