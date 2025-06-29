# 【HarmonyOS 5】Detailed Explanation of UIAbility in HarmonyOS (Part 1)  

## HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  

## 一、What is UIAbility?  

UIAbility is a component type name in the Stage model. The UIAbility component includes a UI and provides the capability to display the UI, mainly used for interacting with users.  

UIAbility is similar to Activity or Fragment in traditional Android mobile development, and analogous to UIViewController in iOS development. It is a core component of the HarmonyOS application framework, responsible for managing the user interface lifecycle and context information of the application.  


### 二、Setting a Specified Launch Page  
**The launch page must be set**; otherwise, the application will show a white screen after launching.  

To avoid a white screen after application launch, set the default loading page in the `onWindowStageCreate` lifecycle. Use the `loadContent()` method of `WindowStage` to specify the page path.  
```typescript
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err, data) => { /* Handle callback */ });
  }
}
```  
DevEco Studio automatically loads the `Index` page for default-generated projects, which can be modified as needed.  


### 三、Obtaining Context Information (UIAbilityContext)  
Obtain application configuration information (such as package name, Ability name, etc.) or call methods to operate on Abilities (such as starting or terminating an Ability) by directly accessing `this.context`.  
```typescript
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const context = this.context; // Directly obtain the context
  }
}
```  
**Obtaining in page components**:  
Convert via `getUIContext().getHostContext()` to `UIAbilityContext`.  
```typescript
@Entry
@Component
struct Page {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  startAbilityTest() { this.context.startAbility(want); } // Start another Ability
}
```  

#### Code Example for Launch Page Setting and Context Usage  
```typescript
// UIAbility definition
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Main', () => {}); // Set the launch page
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    const context = this.context; // Obtain the context
    context.startAbility({ abilityName: 'OtherAbility' }); // Start another Ability
  }
}

// Using context in page components
@Entry
@Component
struct MainPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  build() {
    Button('Terminate Current Ability').onClick(() => this.context.terminateSelf());
  }
}
```  


### 四、UIAbility Lifecycle and Operations  

The UIAbility lifecycle includes four core states: **Create, Foreground, Background, and Destroy**, as well as sub-states related to the window (WindowStage). Through lifecycle callback hooks, you can listen for state changes and perform corresponding operations.  

### Lifecycle State Flow Chart  
```
Instance creation      Window creation      Enter foreground        Switch to background        Window destruction      Instance destruction
  ↓                   ↓                    ↓                      ↓                          ↓                      ↓
onCreate() → onWindowStageCreate() → onForeground() → onBackground() → onWindowStageDestroy() → onDestroy()
         ↑       ↖                    ↗                    ↖                    ↑
         └─────── WindowStageWillDestroy() ────────────────────────┘
```  


#### 1. onCreate  
Triggered when the UIAbility instance is created. Use it to initialize page data and load resources (such as defining variables and obtaining the context `this.context`).  
```typescript
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // Initialization operations (e.g., obtaining context, configuring data)
    const context = this.context; 
  }
}
```  


#### 2. onWindowStageCreate  
Triggered when the system creates a WindowStage after the UIAbility instance is created and before it enters the foreground. Use it to set the launch page (`loadContent()`) and subscribe to window events (such as foreground/background switching and focus changes).  
```dart
onWindowStageCreate(windowStage: window.WindowStage) {
  windowStage.loadContent('pages/Index'); // Set the launch page
  windowStage.on('windowStageEvent', (event) => { // Subscribe to window events
    switch (event) {
      case window.WindowStageEventType.SHOWN: // Switch to foreground
        console.log('Window switched to foreground');
        break;
    }
  });
}
```  


#### 3. onWindowStageWillDestroy  
Triggered before the WindowStage is destroyed (the window is still usable at this time). Release resources obtained through the WindowStage and unsubscribe from events (`off('windowStageEvent')`).  


#### 4. onWindowStageDestroy  
Triggered when the WindowStage is destroyed (UI resources are released). Release UI-related resources (such as temporary files and graphic objects).  


#### 5. onForeground  
Triggered before the UIAbility switches to the foreground and the UI becomes visible. Use it to apply for system resources (such as location and sensor permissions) and restore resources released in the background.  
```dart
onForeground() {
  // Enable location function
  location.start(); 
}
```  


#### 6. onBackground  
Triggered after the UIAbility switches to the background and the UI is completely invisible. Use it to release unused resources and perform time-consuming operations (such as data persistence).  
```dart
onBackground() {
  // Stop location and save the current state
  location.stop(); 
  saveDataToLocal();
}
```  


#### 7. onDestroy  
Triggered when the UIAbility instance is terminated (such as by calling `terminateSelf()`). Use it to release global resources and clean up memory (such as closing network connections and unsubscribing from listeners).  
```typescript
onDestroy() {
  // Release database connection and cancel the timer
  db.close(); 
  clearInterval(timer);
}
```  
**Note**: In API 13+, if the user clears the application through the recent tasks list, `onDestroy()` **will not be triggered**; instead, the process will be terminated directly.  


### 四、Common Functional Operations of UIAbility  
#### 1. Terminating the UIAbility Instance  
Call `terminateSelf()` to terminate the current Ability.  
```typescript
context.terminateSelf((err) => {
  if (err) { console.error('Termination failed:', err); } 
  else { console.info('Termination successful'); }
});
```  


#### 2. Obtaining Caller Information  
When UIAbilityA starts UIAbilityB via `startAbility`, UIAbilityB can obtain information about the caller.  
```typescript
export default class UIAbilityB extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log(`Caller Pid: ${want.parameters?.['ohos.aafwk.param.callerPid']}`);
  }
}
```  


#### Code Example for Cross-Ability Information Transfer  
```typescript
// Starting UIAbilityB in UIAbilityA
@Entry
@Component
struct UIAbilityAPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  build() {
    Button('Launch UIAbilityB').onClick(() => {
      this.context.startAbility({ 
        bundleName: this.context.abilityInfo.bundleName, 
        abilityName: 'UIAbilityB' 
      });
    });
  }
}

// Obtaining caller information in UIAbilityB
export default class UIAbilityB extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    console.log(`Caller package name: ${want.parameters?.['ohos.aafwk.param.callerBundleName']}`);
  }
}
```  


### Note  
When the UIAbility is set to the `singleton` launch mode, repeatedly calling `startAbility()` to launch the same instance will **not trigger the `onCreate` and `onWindowStageCreate` processes again**, but will trigger the `onNewWant` callback.  
```typescript
onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
  // Update page data based on new Want parameters
  this.data = want.parameters?.data; 
}
```