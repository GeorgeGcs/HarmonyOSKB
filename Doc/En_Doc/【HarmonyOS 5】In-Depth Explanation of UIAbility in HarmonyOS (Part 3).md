# 【HarmonyOS 5】In-Depth Explanation of UIAbility in HarmonyOS (Part 3)  

## HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  

## 一、Preface  

This article is the final chapter of the UIAbility explanation series in HarmonyOS. It mainly focuses on the concepts and usage of advanced features such as cold start and warm start of UIAbility, processing of Want data, UIAbility backup and restoration, and UIAbility continuation.  


## 二、UIAbility Launch Modes: Want Data Processing for Cold Start and Warm Start  

### 1. Cold Start  

The application starts for the first time or is recreated after being completely terminated by the system.  

During a cold start, the application enters through the `onCreate` function, where we can process information carried in the `want` parameter, such as applink (URI), deeplink (parameters?.deepLink), push notifications, etc.  

The core logic is simple: process the logic (jump to the target page, data and business processing, etc.) based on the corresponding fields in `want`.  
```typescript
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
  const deepLinkData = want.parameters?.deepLink; // Parse deep link parameters
  this.initData(deepLinkData);
}
```  

### 2. Warm Start  

The application is reactivated while running in the background (e.g., switching tasks or receiving new events).  

Generally paired with cold start processing, the logic is consistent with cold start. However, the application enters through the `onNewWant` function when it has already been created and is reactivated.  
```typescript
onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
  if (launchParam.launchReason === AbilityConstant.LaunchReason.NEW_WANT) {
    const updateData = want.parameters?.updateData; // Parse warm start parameters
    this.refreshUI(updateData);
  }
}
```  

### Summary: Comparison of Cold Start and Warm Start  

| Feature            | Cold Start                      | Warm Start                      |
|--------------------|---------------------------------|---------------------------------|
| Trigger Condition  | First launch/重启 after process termination | Wake up from background/receive new Want |
| Lifecycle Entry    | `onCreate`                      | `onNewWant` (single instance)    |
| Page Stack Handling| Rebuild page stack              | Restore existing page stack     |
| Source of Want Params| Specified at launch (e.g., icon click, link) | Dynamically passed during runtime (e.g., cross-Ability call) |

### 3. Source Code Example  
```dart
// EntryAbility.ets
export default class EntryAbility extends UIAbility {
  private selectPage: string = '';

  // Triggered during cold start
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.parseParams(want); // Parse parameters
  }

  // Triggered during warm start
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.parseParams(want); // Parse parameters
    if (this.currentWindowStage) {
      this.onWindowStageCreate(this.currentWindowStage); // Reload the page
    }
  }

  // Parameter parsing logic
  private parseParams(want: Want) {
    if (want.parameters?.params) {
      const params = JSON.parse(want.parameters.params as string);
      this.selectPage = params.targetPage; // Get the target page identifier (funA/funB)
    }
  }

  // Load the page
  onWindowStageCreate(windowStage: window.WindowStage) {
    let targetPage = 'pages/Index'; // Default page
    switch (this.selectPage) {
      case 'funA': targetPage = 'pages/FunA'; break;
      case 'funB': targetPage = 'pages/FunB'; break;
    }
    windowStage.loadContent(targetPage); // Load the corresponding page
  }
}
```  


## 二、UIAbility Backup and Restoration: Ensuring State Continuity After Abnormal Termination  

When the application is terminated by the background due to insufficient system resources, the state is automatically saved.  
Data is restored during the next launch (e.g., content being edited, page position).  

#### 1. Enabling Backup Functionality  
Call `setRestoreEnabled(true)` in `onCreate`:  
```typescript
export default class EntryAbility extends UIAbility {
  onCreate() {
    this.context.setRestoreEnabled(true); // Enable backup during initialization
  }
}
```  

#### 2. Saving Custom Data  
Override the `onSaveState` method to store data via `WantParams`:  
```typescript
onSaveState(state: AbilityConstant.StateType, wantParams: Record<string, Object>) {
  wantParams["editorContent"] = this.editor.getText(); // Save edited content
  wantParams["currentPage"] = this.router.getCurrentPage(); // Save page route
  return AbilityConstant.OnSaveResult.ALL_AGREE;
}
```  

#### 3. Restoring Data  
Parse parameters in `onCreate` or `onNewWant`:  
```typescript
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
  if (want.parameters?.editorContent) {
    this.editor.setText(want.parameters.editorContent as string); // Restore text
    this.router.navigateTo(want.parameters.currentPage as string); // Restore page route
  }
}
```  

### Notes  
**1. Data Limitations**: Maximum 200KB per backup, storage validity period of 7 days, not retained after device restart.  
**2. Applicable Scenarios**: Temporary data (e.g., unsaved forms), page states (e.g., scroll position); **sensitive data is not recommended** for storage.  
**3. Performance Optimization**: Avoid time-consuming operations in `onSaveState`; prioritize storing key states.  


## 三、Application Continuation: Seamless Task Migration Across Devices  

Migrate the current page state and routing information to another device (e.g., phone → tablet).  
Supports enabling/disabling migration by scenario (e.g., allowing migration only on the edit page).  
Small data is transmitted via `wantParam` (≤100KB), and large data uses Distributed Data Object (DDO).  

#### 1. Configuring Migratable Capability  
Set `continuable: true` in `module.json5`:  
```json
{
  "abilities": [
    {
      "name": "EditorAbility",
      "continuable": true // Enable cross-device migration
    }
  ]
}
```  

#### 2. Implementation on the Source Device (Initiating Migration)  
`onContinue` callback: save data, verify compatibility, and decide whether to migrate.  
```typescript
onContinue(wantParam: Record<string, Object>): OnContinueResult {
  // Verify target device version
  if (wantParam.version < MIN_SUPPORT_VERSION) return MISMATCH;
  
  // Save edited content
  wantParam["editorData"] = this.editor.getData();
  
  // Dynamically control migration status (e.g., allow migration only on the edit page)
  if (this.currentPage !== 'EditorPage') return REJECT;
  
  return AGREE;
}
```  

#### 4. Restoration on the Target Device (Receiving Device)  
Restore via `onCreate` during cold start or `onNewWant` during warm start:  
```typescript
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
  if (launchParam.launchReason === CONTINUATION) {
    const editorData = want.parameters?.editorData;
    this.editor.setData(editorData); // Restore data
    this.context.restoreWindowStage(); // Automatically restore the page stack
  }
}
```  

### Notes  
**1. Dynamically Enabling/Disabling Migration**: Control via `setMissionContinueState` (e.g., disable on non-edit pages):  
```typescript
// Disable migration on non-edit pages
this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE);
```  

**2. Custom Page Stack**: Disable automatic restoration and manually specify the target page:  
```typescript
onContinue(wantParam) {
  wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = false; // Disable automatic restoration
  wantParam["targetPage"] = "SummaryPage"; // Custom target page
}
```  

**3. Large Data Migration**: Use Distributed Data Object (DDO) to synchronize files or large text:  
```typescript
// Create DDO on the source device and save data
const ddo = distributedDataObject.create(this.context, largeData);
wantParam["ddoSessionId"] = ddo.genSessionId(); // Pass the session ID to the target device
```