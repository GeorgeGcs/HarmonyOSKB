## 【HarmonyOS 5】Detailed Explanation of Privacy Protection in HarmonyOS Applications  

## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Preface  
In today's era where smartphones are indispensable, we use our devices for payments, communication, and daily records, unknowingly storing vast amounts of personal information. But have you ever considered the consequences of privacy data leaks? From spam calls to identity theft, the risks are significant. Fortunately, HarmonyOS has implemented comprehensive privacy protection measures.  

Imagine strangers accessing your health data, chat logs, or payment passwords—terrifying, isn't it? Privacy breaches not only violate personal rights but also pose financial risks. Moreover, privacy protection is a legal requirement and a corporate responsibility. HarmonyOS prioritizes privacy at every level, from the system core to application development.  


### 二、Six Golden Principles of HarmonyOS Privacy Protection  
HarmonyOS provides developers with strict privacy protection guidelines, acting as a "security manual" to ensure every application safeguards user privacy:  

1. **Transparency & Disclosure**  
   Applications must explicitly inform users about collected data and its purposes, avoiding hidden practices.  

2. **Data Minimization**  
   Collect only necessary data. For example, a weather app only needs your city, not precise location.  

3. **User Consent**  
   All data processing requires user authorization, with the right to revoke consent at any time.  

5. **Enhanced Security**  
   Data is encrypted throughout storage and transmission, protected by advanced encryption.  

7. **Local Processing Priority**  
   Process data locally whenever possible. Cloud uploads must adhere to the "minimum necessary" principle.  

9. **Special Protection for Minors**  
   Applications targeting minors must comply with relevant laws, requiring parental consent for data collection.  


### 三、Developer's "Privacy Protection Toolkit"  
To implement these principles, HarmonyOS offers developers practical security tools:  

#### 1. Privacy Statement Dialog: Empowering User Awareness  
When launching an app, the privacy statement dialog (though seemingly verbose) serves to inform users: "We collect this data for these purposes—proceed only with your consent." This transparency allows users to make informed decisions and retain control.  

**Key Developer Considerations:**  
(1) Clearly specify collected data.  
(2) Explain data usage.  
(3) Obtain explicit user consent.  

**Code Example:**  
Implementing a privacy statement dialog in the "HMOS World" app (`SafePage.ets`):  
```typescript  
// Assume dialog components and logic are defined here  
@Entry  
@Component  
struct SafePage {  
  build() {  
    // Dialog layout and interaction logic  
    if (!this.isAgreed) {  
      Dialog()  
        .title('Privacy Statement')  
        .message('This app collects basic information to enable features...')  
        .button('Agree', () => {  
          this.isAgreed = true;  
          // Navigate to the main interface  
          router.pushUrl({  
            url: '/pages/MainPage'  
          });  
        })  
        .button('Disagree', () => {  
          // Handle disagreement (e.g., exit app)  
          exit();  
        });  
    } else {  
      // User agreed; display app content  
      Column() {  
        // Main interface components  
      }  
    }  
  }  
}  
```  

#### 2. Fuzzy Location: Protecting Your Movements  
Many are unaware that location services offer both "precise" and "fuzzy" options. For apps that don’t require exact coordinates (e.g., music players), HarmonyOS recommends fuzzy location, which reveals only city/region-level information. This balances functionality with privacy.  

**Location Permission Application对照表:**  
| Target API Level | Permission Requested         | Result         | Location Precision         |  
|------------------|------------------------------|----------------|----------------------------|  
| <9               | `ohos.permission.LOCATION`   | Success        | Precise (meter-level)      |  
| ≥9               | `ohos.permission.LOCATION`   | Failure        | No access                  |  
| ≥9               | `ohos.permission.APPROXIMATELY_LOCATION` | Success | Fuzzy (5km precision) |  
| ≥9               | Both permissions             | Success        | Precise (meter-level)      |  

**Code Example:**  
Declare permissions in `module.json5`:  
```json  
{  
  "module": {  
    // ...  
    "requestPermissions": [  
      {  
        "name": "ohos.permission.APPROXIMATELY_LOCATION",  
        "reason": "$string:location_reason",  
        "usedScene": {  
          "abilities": [  
            "EntryAbility"  
          ],  
          "when": "inuse"  
        }  
      },  
      // ...  
    ],  
  }  
}  
```  

Dynamically request permissions and retrieve location:  
```typescript  
import geoLocationManager from '@ohos.geoLocationManager';  
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';  
import Logger from '@ohos.hilog';  

let atManager = abilityAccessCtrl.createAtManager();  
atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.APPROXIMATELY_LOCATION'])  
  .then((data) => {  
    Logger.info(`request permissions result: ${JSON.stringify(data)}`);  
    let requestInfo: geoLocationManager.LocationRequest = {  
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,  
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,  
      'timeInterval': 1,  
      'distanceInterval': 0,  
      'maxAccuracy': 0  
    };  

    geoLocationManager.getCurrentLocation(requestInfo).then((result) => {  
      Logger.info(`geoLocationManager current location: ${JSON.stringify(result)}`);  
      // Process location data  
    }).catch((error: BusinessError) => {  
      Logger.error(`geoLocationManager promise, getCurrentLocation: error: ${JSON.stringify(error)}`);  
    });  
  });  
```  

#### 3. Picker Selector: Avoiding "Data Sweeps"  
Previously, storage permissions gave apps unrestricted access to all files. With the Picker selector, users can now grant access to specific files or photos, similar to selecting items in a supermarket. For example, when sharing a photo on social media, the app only accesses the selected image, leaving other data untouched.  

**Code Example:**  
```typescript  
import { photoAccessHelper } from '@kit.MediaLibraryKit';  
import { BusinessError } from '@kit.BasicServicesKit';  

const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();  
photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;  
photoSelectOptions.maxSelectNumber = 5;  
const photoViewPicker = new photoAccessHelper.PhotoViewPicker();  
photoViewPicker.select(photoSelectOptions).then((photoSelectResult) => {  
  this.imageUri = photoSelectResult.photoUris[0];  
  console.log(`PhotoViewPicker.select successfully, uris: ${JSON.stringify(photoSelectResult)}`);  
}).catch((err: BusinessError) => {  
  console.error(`PhotoViewPicker.select failed with err: ${JSON.stringify(err)}`);  
});  
```  

#### 4. Dynamic Permission Requests: Authorizing Only What’s Needed  
When requesting sensitive permissions (e.g., camera, contacts), apps must explicitly state their purpose: "Camera access is required for QR code scanning." Developers should only request essential permissions, preventing overreach.  

**Code Example:**  
Declare camera permission in `module.json5`:  
```json  
{  
  "module": {  
    // ...  
    "requestPermissions": [  
      {  
        "name": "ohos.permission.CAMERA",  
        "reason": "$string:camera_reason",  
        "usedScene": {  
          "abilities": [  
            "EntryAbility"  
          ],  
          "when": "inuse"  
        }  
      }  
    ],  
  }  
}  
```  

Define permission rationale in `string.json`:  
```json  
{  
  "string": [  
    {  
      "name": "camera_reason",  
      "value": "QR code scanning requires camera access to capture images"  
    }  
  ]  
}  
```  

Dynamically request permission in code:  
```typescript  
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';  
import Logger from '@ohos.hilog';  

let atManager = abilityAccessCtrl.createAtManager();  
atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.CAMERA'])  
  .then((data) => {  
    let grantStatus: Array<number> = data.authResults;  
    if (grantStatus.length > 0 && grantStatus[0] === 0) {  
      // Permission granted; proceed  
      Logger.info('request permissions granted');  
      // Execute QR code scanning logic  
    } else {  
      // Permission denied  
      Logger.info('request permissions denied');  
      // Handle denial (e.g., show prompt)  
    }  
  });  
```  


### Summary: Three Key Points of Privacy Protection  
1. **Transparency & Control**: Users understand data usage.  
2. **Data Minimization**: Collect only essential data.  
3. **Full-Stack Encryption**: Secure data from storage to transmission.