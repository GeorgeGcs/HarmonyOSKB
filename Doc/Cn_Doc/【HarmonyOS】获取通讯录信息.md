## 【HarmonyOS】获取通讯录信息

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

**一、问题背景：**
在Android和IOS中，获取手机通讯录信息的方式，一般是申请通讯录权限后，获得手机所有的通讯录列表信息。

在鸿蒙中，因为权限方式安全性提高的变更：将用户权限限制，不让App应用随意获取到所有的信息，只能根据用户选择后，根据用户选择的范围，传送给App。而不是App直接获取到所有的源信息。

例如，相册图片和视频的获取，都是跳到系统的组件中选择，不会将所有图片和视频访问开放给APP，进行自定义相册来展示了。这样对用户信息来说，安全层面会提升很多。

之前谣言腾x，被传偷偷上传用户的相册，也是因为权限被开放给应用了，会有这方面的技术可行性。而现在华为的这种崭新的权限提供方式，给了用户极大的安全。对应用来说，也避免了很多风险，也提升了应用开发的效率。

在鸿蒙中通讯录的信息获取，也是需要先调用华为提供的通讯录选择组件，让用户主动从通讯录中选择需要传给APP的通讯录联系人，勾选确认之后传给APP。

值得注意的是，华为提供的这种授权方式，应用APP是不需要单独申请权限的，因为我们是通过华为的安全组件，让用户主动确认勾选，将信息传给APP的，所以省略了用户再授权的过程。因为这个过程本身就代表了用户的授权。

**二、解决方案：**

```dart
import { contact } from '@kit.ContactsKit';
import { BusinessError } from '@kit.BasicServicesKit';

/***
 * 通讯录获取页面
 */
@Entry
@Component
struct ContactPage {

  private TAG: string = "ContactPage";

  onClickContacts = ()=>{
    // 选择联系人时的筛选条件 (是否多选)
    let contactSelectionOptions: contact.ContactSelectionOptions = { isMultiSelect:false };
    // 调用唤起通讯录选择组件，让用户去选择需要传入给APP的通讯录联系人
    let promise = contact.selectContacts(contactSelectionOptions);
    // 异步获取
    promise.then((data) => {
      // 用户选择确认之后，会在此处收到回调。
      console.log(this.TAG, `selectContacts success: data->${JSON.stringify(data)}`);
      // Array<Contact> ，返回选择的联系人对象数组。
      let contactList: Array<contact.Contact> = new Array<contact.Contact>();
      if(contactList && contactList.length > 0){
        let info: contact.Contact = contactList[0];
        let id = info.id; // 通讯录用户的唯一标识
      }
    }).catch((err: BusinessError) => {
      console.error(this.TAG, `selectContacts fail: err->${JSON.stringify(err)}`);
    });
  }

  build() {
    Row(){
      Button('点击获取通讯录信息')
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

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/a973067c9a9d4c54955a162fdf662db0b1862.png)

