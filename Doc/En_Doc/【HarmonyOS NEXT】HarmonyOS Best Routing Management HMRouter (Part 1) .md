# 【HarmonyOS NEXT】HarmonyOS Best Routing Management: HMRouter (Part 1)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


## 一、Preface  

From **router** to **navigation**, and now the emergence of **HMRouter**, the most powerful in-app routing management for HarmonyOS has finally arrived. The previously criticized `router` was abandoned by the official due to its inability to meet various routing requirements and inflexible usage. After the top 200 apps adapted to `navigation`, a series of bugs and new requirements emerged. Now, with HMRouter, developers can finally manage routing smoothly.  

For example, the most common back navigation requirement in Android and iOS. Neither `router` nor `navigation` can achieve this. For a three-level page flow A-B-C-D, returning from page D to A can be directly implemented by specifying the jump URL with `pop`.  

This chapter explains what HMRouter is, its capabilities, and how to quickly integrate it. Subsequent chapters will detail its extended features.  


## 二、HMRouter  

1. **Understanding HMRouter**:  
   HMRouter serves as a routing management framework that encapsulates Navigation-related capabilities at the底层 (底层, underlying layer), allowing us to ignore tedious navigation logic.  

2. **What Can HMRouter Do?**  
   Capabilities include **page navigation, pop-up prompts, transition effects, data loading, and testing scenarios**. In summary, it is a scene solution for page navigation in HarmonyOS, mainly addressing the problem of inter-page navigation within applications.  

3. **Form and Integration**:  
   Integrated as a plugin into projects, currently open-sourced on Gitee. You can directly use the source code module or modify it (note the open-source license for commercial projects).  


## 三、Quick Start  

### (1) Integrate HMRouter Plugin  

#### 1. Download Dependencies  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/5649e03bf0604c9ebe09d4d03604907db1862.png)  
```dart
"dependencies": {
   "@hadss/hmrouter": "^1.0.0-rc.5"
 }
```  

#### 2. Compilation Plugin Configuration  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/419b47a5d951437b85a71cd9694d34aab1862.png)  
```dart
"dependencies": {
  "@hadss/hmrouter-plugin": "^1.0.0-rc.4" // Use npm repository version number
},
```  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/dd8e2519fece49bcac1fd9821d3fbfcdb1862.png)  
```bash
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { hapPlugin } from "@hadss/hmrouter-plugin";

export default {
    system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins: [hapPlugin()]         /* Custom plugin to extend the functionality of Hvigor. */
}
```  


### (2) Initialize the Toolkit  
Configure initialization in `EntryAbility`, your launch module.  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/030ae4adc4be46a3afe7cfb1a1abdc9fb1862.png)  
```bash
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  HMRouterMgr.init({
    context: this.context
  });
}
```  


### (3) Initialize the Home Page  
Similar to Navigation, the page build needs to be wrapped in a container for display.  
Different from Navigation, this container should be used within a `Column` or `Stack`.  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/4d13652589764ea1af0751f335b000dfb1862.png)  
See the DEMO code example below for text.  


### (4) Configure Navigation Pages  
The target page to navigate to is configured via HMRouter routing annotation tags to set anchors for upper-level pages to jump to.  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/3b9cc06ae02949d1b046bdf7b59617f6b1862.png)  
See the DEMO code example below for text.  


### (5) Complete (Implement Basic Page Navigation and Back)  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/ce1bccf443364f30887a6dba96f4c992b1862.png)  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/fe454690818d4b7a9b3935cf80e635d5b1862.png)  


### DEMO Code Example  

#### Index.ets (Home Page)  
```dart
import { AttributeUpdater } from '@ohos.arkui';
import { HMDefaultGlobalAnimator, HMNavigation, HMRouterMgr } from '@hadss/hmrouter';

/**
 * Common interface style functions
 */
class NavModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.mode(NavigationMode.Stack);
    instance.navBarWidth('100%');
    instance.hideTitleBar(true);
    instance.hideToolBar(true);
  }
}

@Entry
@Component
struct Index {
  modifier: NavModifier = new NavModifier();

  aboutToAppear(): void {

  }

  build() {
    // @Entry requires an additional container component, such as Column or Stack
    Column() {
      // Use HMNavigation container
      HMNavigation({
        navigationId: 'mainNavigation', options: {
          // Set animation style
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          // Set pop-up animation style
          dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
          // Set navigation parameters (title bar, toolbar, etc.)
          modifier: this.modifier
        }
      }) {
        Row() {
          Text("Click to Navigate")
            .fontSize(50)
            .onClick(() => {
              HMRouterMgr.push({ pageUrl: 'pageB' })
            })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Yellow)
        .justifyContent(FlexAlign.Center)
      }
    }
    .height('100%')
    .width('100%')
  }
}
```  

#### PageB.ets (Navigated Page)  
```dart
import { HMRouter, HMRouterMgr } from "@hadss/hmrouter"

// HMRouter routing tags are used on custom components, which need the export keyword
@HMRouter({ pageUrl: 'pageB' })
@Component
export struct PageB {

  build() {
    Row() {
      Text("Click to Return")
        .fontSize(50)
        .onClick(() => {
          HMRouterMgr.pop();
        })
    }.width("100%").height("100%").backgroundColor(Color.Red).justifyContent(FlexAlign.Center)
  }
}
```