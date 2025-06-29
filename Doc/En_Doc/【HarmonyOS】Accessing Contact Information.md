## 【HarmonyOS 5】Accessing Contact Information  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

### I. Problem Background  

In Android and iOS, accessing phone contact information typically involves requesting contact permissions to obtain the entire contact list.  

In HarmonyOS, enhanced privacy measures restrict apps from freely accessing all contact information. Instead, apps can only receive data within the scope selected by the user. This is similar to how album images/videos are accessed—users select content via a system component, rather than granting apps full access to all media. This approach significantly improves user privacy, mitigates risks for apps, and enhances development efficiency.  

To access contacts in HarmonyOS, developers must use Huawei's contact selection component, where users actively select contacts to share with the app. Notably, this authorization method eliminates the need for apps to apply for separate permissions, as user confirmation through the secure component inherently constitutes authorization.  


### II. Solution  

```dart
import { contact } from '@kit.ContactsKit';
import { BusinessError } from '@kit.BasicServicesKit';

/***
 * Contact access page
 */
@Entry
@Component
struct ContactPage {

  private TAG: string = "ContactPage";

  onClickContacts = ()=>{
    // Contact selection filter (supports multi-selection)
    let contactSelectionOptions: contact.ContactSelectionOptions = { isMultiSelect: false };
    // Invoke the contact selection component for user selection
    let promise = contact.selectContacts(contactSelectionOptions);
    // Asynchronous callback handling
    promise.then((data) => {
      // Callback when user confirms selection
      console.log(this.TAG, `selectContacts success: data->${JSON.stringify(data)}`);
      // Array<Contact> containing selected contact objects
      let contactList: Array<contact.Contact> = new Array<contact.Contact>();
      if (contactList && contactList.length > 0) {
        let info: contact.Contact = contactList[0];
        let id = info.id; // Unique identifier of the contact
      }
    }).catch((err: BusinessError) => {
      console.error(this.TAG, `selectContacts fail: err->${JSON.stringify(err)}`);
    });
  }

  build() {
    Row() {
      Button('Click to Access Contact Information')
        .onClick(this.onClickContacts)
    }
    .justifyContent(FlexAlign.Center)
    .size({
      width: "100%",
      height: "100%"
    })
  }
}
```  
