# 【HarmonyOS 5】Detailed Implementation of Desktop Shortcut Function  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


## 一、Preface  

In mobile application development, enabling users to quickly access core functions is one of the most common requirements.  

The **Desktop Shortcuts** function provided by HarmonyOS allows developers to create direct entry points for frequently used in-app functions. Users can quickly launch specific functions by long-pressing the app icon, significantly reducing operation layers.  

This article will detail the implementation principles and development process of HarmonyOS shortcuts in combination with the map navigation scenario, expanding on Huawei's official open-source example [DesktopShortcut](https://gitee.com/harmonyos_samples/DesktopShortcut.git). This example is implemented based on HarmonyOS 5.0, demonstrating the complete development process of shortcuts in the map navigation scenario.  


## 二、Requirement Analysis and Example Project Introduction  

Take a map application as an example, where users frequently use navigation functions like "Go Home" and "Go to Company" in daily use. The traditional process requires opening the app, searching for the destination, and then starting navigation. With shortcuts, users can:  
1. **Long-press the app icon** and directly click "Go Home" or "Go to Company" in the shortcut list;  
2. **Drag the shortcut to the desktop** and launch navigation with one click via an independent icon.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_8ca1a98d.png 'image.png')  

### Project Directory Introduction  
```
├── entry/src/main/ets                  
│  ├── entryability                         
│  │  └── EntryAbility.ets                  // Core logic: Process shortcut parameters and jump pages
│  └── pages                                
│     ├── GoCompany.ets                     // Company navigation page (@Entry decorated)
│     ├── GoHouse.ets                       // Home navigation page (@Entry decorated)
│     └── Index.ets                         // App home page
├── entry/src/main/resources                
│  └── base/profile                         
│     └── shortcuts_config.json             // Shortcut metadata configuration
└── module.json5                             // Module configuration file,关联快捷方式 (associated with shortcuts)
```  


## 三、Implementation Steps for Shortcut Function  

### 1. Core Configuration Files  

#### (1) shortcuts_config.json  
Defines shortcut metadata, including ID, name, icon, and target jump information.  
```json
{
  "shortcuts": [
    {
      "shortcutId": "id_go_company",
      "label": "$string:go_company",        // Corresponding to the string resource in resources/base/element/string.json
      "icon": "$media:icon_company",        // Corresponding to the icon file in the resources/base/media directory
      "wants": [
        {
          "bundleName": "com.example.desktopshortcut", // App package name (must match module.json5)
          "moduleName": "entry",                        // Module name (fixed as entry)
          "abilityName": "EntryAbility",               // Target Ability (entry Ability)
          "parameters": { "page": "GoCompany" }         // Custom parameter: Identifies the target page
        }
      ]
    },
    {
      "shortcutId": "id_go_house",
      "label": "$string:go_home",
      "icon": "$media:icon_home",
      "wants": [
        {
          "bundleName": "com.example.desktopshortcut",
          "moduleName": "entry",
          "abilityName": "EntryAbility",
          "parameters": { "page": "GoHouse" } // The `parameters` key name can be customized (using `page` instead of `shortCutKey` in the example), which must match the code logic.
        }
      ]
    }
  ]
}
```  

#### (2) module.json5  
Declares the reference to the shortcut configuration file and associates it with the app module.  
```json
{
  "module": {
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "skills": [
          {
            "entities": ["entity.system.home"],
            "actions": ["ohos.want.action.home"]
          }
        ],
        "metadata": [
          {
            "name": "ohos.ability.shortcuts",
            "resource": "$profile:shortcuts_config" // Reference to the configuration file in the profile directory
          }
        ]
      }
    ]
  }
}
```  

#### (3) Key Field Explanations  

| Field        | Description                                            |
| ------------ | ------------------------------------------------------ |
| shortcutId   | Unique identifier (length ≤ 63 bytes), e.g., id_company.       |
| label        | Display name (supports resource indexing), e.g., $string:Go_to_the_Company. |
| icon         | Icon resource index, e.g., $media:company.                    |
| wants        | Target jump information, including package name, module name, Ability name, and custom parameters (parameters). |  


### 2. Shortcut Entry Jump Logic  
```typescript
import router from '@ohos.router';

export default class EntryAbility extends Ability {
  private context: UIAbilityContext | undefined;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    super.onCreate(want, launchParam);
    this.context = this.getContext();
    // Load the home page on first launch
    router.pushUrl({
      url: 'pages/Index',
      context: this.context
    });
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    const page = want.parameters?.page; // Extract parameters passed by the shortcut
    if (page && this.context) {
      router.pushUrl({
        url: `pages/${page}`, // Dynamically concatenate the page path
        context: this.context
      });
    }
  }
}
```  


## Notes  

1. **Number of Shortcuts**: Only supports jumping to UIAbility entry pages, with a maximum of 4 configurations.  

2. **Parameter Validation**:  
   Add non-null parameter validation in onNewWant to prevent app crashes due to missing shortcut parameters:  
   ```typescript
   if (!page || !this.context) {
     hilog.error(0x0000, 'Shortcut', 'Invalid parameters or context');
     return;
   }
   ```  

3. **Widgets**: Can display dynamic content and support jumping to non-entry pages.