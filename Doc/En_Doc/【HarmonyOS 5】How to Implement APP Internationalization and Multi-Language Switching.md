# 【HarmonyOS 5】How to Implement APP Internationalization and Multi-Language Switching  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


## Preface  

Internationalization handling in HarmonyOS is fundamentally consistent with Android and iOS, both of which use JSON to configure text content for different languages. During UI display, field keys from the JSON configuration are used to call and display corresponding language text content.  


## Follow System Language Switching  

The most common approach only requires configuring JSON files for different languages. Take Chinese and English as examples:  
First, we need to configure key-value pairs in the string configuration table of the corresponding language JSON text in resource files:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/d107ee8e3fc245a293709f2ab09a6fd8b1862.png)  

`zh_CN` for Chinese, `en_US` for English, and `string.json` in `base-element` as the default configuration. The default configuration is mandatory; if you create a language folder without the corresponding field node in the default configuration, the system will prompt an error:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/af0c58ccc8b945e69a5c2353e32b10e8b1862.png)  

As shown in the following figure, configure the field text content:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/f0cf5b8f3c96436c84ac38d21b8795eab1862.png)  

Once the fields are configured, simply reference them in the UI:  
```dart
$r("app.string.xxx");
For example:
$r("app.string.test_content");
```  


## Create Language Resource Folders  

1. Right-click in the resources folder and select to add a new resource folder as shown below:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/619c0e8231ee42b5985184e2ecd3a338b1862.png)  

2. In the pop-up dialog, select **Locale**, click the right button to display languages and regions:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/04b8a9ebc8a648458b38f1e89d87a013b1862.png)  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/9223787cb99e45a79f7be9550252e9dfb1862.png)  

3. Take English as an example. In the language list, use the English input method to trigger the filter search box, select the corresponding language and region, then click **OK** to generate the folder:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/020399aef9ff4eb9a0c40a6cebc7faa0b1862.png)  


## Independent Multi-Language Switching for APP  

When the app needs to use a language independent of the system (e.g., setting the app to English while the system is in Chinese), we can achieve this by setting the app's preferred language:  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/ba0d4ef225d64fefb628b51597f65566b1862.png)  

For the language ID list, see the bottom of this article.  
```dart
try {
  i18n.System.setAppPreferredLanguage("zh"); // Set app preferred language to zh-Hans
} catch(error) {
  let err: BusinessError = error as BusinessError;
  console.error(`call System.setAppPreferredLanguage zh failed, error code: ${err.code}, message: ${err.message}.`);
}
```  

### DEMO Example: Launch Page Test Code  
```dart
import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State message: string | Resource = $r("app.string.test_content");

  build() {
    Column() {
      Text(this.message).fontSize(50)

      Text("Switch to Chinese").fontSize(50)
      .onClick(()=>{
        // Set language preference
        try {
          i18n.System.setAppPreferredLanguage("zh"); // Set app preferred language to zh-Hans
        } catch(error) {
          let err: BusinessError = error as BusinessError;
          console.error(`call System.setAppPreferredLanguage zh failed, error code: ${err.code}, message: ${err.message}.`);
        }
      })

      Text("Switch to English").fontSize(50)
        .onClick(()=>{
          // Set language preference
          try {
            i18n.System.setAppPreferredLanguage("en");
          } catch(error) {
            let err: BusinessError = error as BusinessError;
            console.error(`call System.setAppPreferredLanguage en failed, error code: ${err.code}, message: ${err.message}.`);
          }
        })
    }
    .height('100%')
    .width('100%')
  }
}
```  

#### English JSON Configuration  
```dart
{
  "string": [
    {
      "name": "module_desc",
      "value": "module description"
    },
    {
      "name": "EntryAbility_desc",
      "value": "description"
    },
    {
      "name": "EntryAbility_label",
      "value": "label"
    },
    {
      "name": "test_content",
      "value": "English"
    }
  ]
}
```  

#### Chinese JSON Configuration  
```dart
{
  "string": [
    {
      "name": "module_desc",
      "value": "模块描述"
    },
    {
      "name": "EntryAbility_desc",
      "value": "描述"
    },
    {
      "name": "EntryAbility_label",
      "value": "标签"
    },
    {
      "name": "test_content",
      "value": "中文"
    }
  ]
}
```  

#### Default JSON Configuration  
```dart
{
  "string": [
    {
      "name": "module_desc",
      "value": "module description"
    },
    {
      "name": "EntryAbility_desc",
      "value": "description"
    },
    {
      "name": "EntryAbility_label",
      "value": "label"
    },
    {
      "name": "test_content",
      "value": "English"
    }
  ]
}
```  
