## 【HarmonyOS 5】How to Access User Album Images in HarmonyOS? photoAccessHelper.PhotoViewPicker  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

### Introduction to Accessing User Albums in HarmonyOS  

As mentioned in previous articles about Huawei's privacy and security policies, this series compares APIs for accessing user information in Android/iOS with their equivalents in HarmonyOS.  

Accessing the user's photo album is a common requirement. Currently, Huawei discourages apps from accessing all album resources. For example, iOS provides a "select photos" feature where users can choose specific images to share with apps, rather than granting full album access like Android. HarmonyOS takes a similar approach by integrating secure album components that allow conditional filtering (e.g., QR codes, barcodes, IDs).  


### Code Explanation  

**photoAccessHelper** is a system API for accessing the user's photo album. It provides interfaces to create albums and manage media data.  

**PhotoViewPicker** is a sub-API that creates a gallery picker for selecting images/videos.  

**PhotoSelectOptions** configures gallery picker behavior through properties like MIME type filtering and selection limits.  

Note: The `photoAccessHelper` approach is now officially recommended over the deprecated `picker.PhotoViewPicker(context)`, which has poor performance in beta1 systems (e.g., white screen flicker, lack of filtering support).  


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/22519f3144544177a9754b23a0a1a56a.png)  


```dart
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * Photo Album Selection
 */
@Entry
@Component
struct AlbumSelectPage {

  private TAG: string = "AlbumSelectPage";

  onClickSelectPhoto = ()=>{
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // Set MIME type filter
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      // Set maximum selection count
      PhotoSelectOptions.maxSelectNumber = 1;
      // Instantiate photo picker
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      // Launch secure album component
      photoPicker.select(PhotoSelectOptions, (err: BusinessError, PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (err) {
          console.error(this.TAG, "onClickSelectPhoto photoPicker.select error:" + JSON.stringify(err));
          return;
        }
        // Callback when user confirms selection
        console.info(this.TAG, "onClickSelectPhoto photoPicker.select successfully:" + JSON.stringify(PhotoSelectResult));
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(this.TAG, "onClickSelectPhoto photoPicker.select catch failed:" + JSON.stringify(err));
    }
  }

  build() {
    Row(){
      Button('Click to Select Photo')
        .onClick(this.onClickSelectPhoto)
    }
    .justifyContent(FlexAlign.Center)
    .size({
      width: "100%",
      height: "100%"
    })
  }
}
```  


![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/a9d2820b377246949ed85c6800d46144b1862.png)
