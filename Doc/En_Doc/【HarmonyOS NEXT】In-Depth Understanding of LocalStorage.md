# 【HarmonyOS NEXT】In-Depth Understanding of LocalStorage  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


## 一、Preface  

HarmonyOS applications have various state management mechanisms, ranging from state decorators like `@State` and `@Prop`, to `LocalStrong`, `AppStrong`, preferences, and databases. These span from memory to persistent storage, and from lightweight to heavyweight solutions, providing comprehensive coverage.  

When learning technical points, it is recommended to understand both the what and the why. Clarifying the positioning of technologies allows for more effective usage.  

First, **LocalStorage is a page-level UI state storage** used for state storage and data synchronization between `@Entry`-decorated pages and their sub-views.  

***Read and write operations for LocalStorage are synchronous**, meaning the program will block until the operation completes before executing subsequent code. Frequent modifications to complex objects are not recommended.*  

UI decorators for data link synchronization will be covered in the second chapter; this chapter focuses on logical data storage and retrieval operations.  


## 二、Using LocalStorage for Data Storage in Logic Classes  

Using LocalStorage in logic classes essentially decouples data from UI binding, allowing data to be used primarily in logical operations without considering dynamic UI refresh and rendering.  

LocalStorage enables data storage units to be controlled at the level of individual pages or Abilities, stored separately. When directly using LocalStorage for `set` and `get` operations, the instance scope is limited to a single `@Entry`-decorated page and its sub-pages (requiring explicit instance passing to achieve sharing).  

Binding the instance object to the stage allows sharing a LocalStorage instance across a single Ability, expanding its scope. To use LocalStorage conveniently in logic classes, follow these steps:  

1. **Bind the LocalStorage instance to the stage.**  
   Without binding, the instance is shared only within an `@Entry`-decorated component and its sub-components (one page). For cross-view sharing, create a LocalStorage instance in the所属UIAbility (所属UIAbility, owning UIAbility) and call `windowStage.loadContent`.  

2. **Obtain the instance object and use `setOrCreate` for data storage.**  
   Use the `Share` function to get the LocalStorage instance bound to the stage. Use `setOrCreate` to store data: if `propName` already exists and `newValue` differs, the value is updated; otherwise, UI refresh for `propName` is not triggered.  

3. **Use `get` for data retrieval, with null checks.**  


## 三、DEMO Example  

The demo verifies the ability to share LocalStorage instances across pages within a UIAbility for key-value data storage and retrieval.  
![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/fb46191615ce4933b85b5f4d701d5f19b1862.png)  

### EntryAbility.ets  
```dart
import { UIAbility } from '@ohos.app.ability';
import { hilog } from '@ohos.hiviewdfx';
import { window } from '@ohos.arkui';

export default class EntryAbility extends UIAbility {
  storage: LocalStorage = new LocalStorage();

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', this.storage, (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }
}
```  

### Index.ets  
```dart
import { router } from '@ohos.arkui';
import systemDateTime from '@ohos.system.dateTime';
import TestMgr from './TestMgr';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    const pageID: string = systemDateTime.getTime() + "";
    console.log("debugStorage", " pageID: " + pageID);
    TestMgr.Ins().setPageID(pageID);
    const tempID: string = TestMgr.Ins().getPageID();
    console.log("debugStorage", " tempID: " + tempID);
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          router.pushUrl({
            url: "pages/Index2"
          });
        })
    }
    .height('100%')
    .width('100%')
  }
}
```  

### Index2.ets  
```dart
import TestMgr from './TestMgr';

@Entry
@Component
struct Index2 {
  @State message: string = 'Hello World222';

  aboutToAppear(): void {
    const tempID: string = TestMgr.Ins().getPageID();
    console.log("debugStorage", " Index2 tempID: " + tempID);
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('Index2HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}
```  

### TestMgr.ets  
```dart
export default class TestMgr {
  private static mTestMgr: TestMgr | undefined;

  public static Ins(): TestMgr {
    if (TestMgr.mTestMgr) {
      return TestMgr.mTestMgr;
    } else {
      TestMgr.mTestMgr = new TestMgr();
      return TestMgr.mTestMgr;
    }
  }

  public getPageID(): string {
    const storage = LocalStorage.getShared();
    return storage.get("pageID") ?? "";
  }

  public setPageID(pageID: string): void {
    const storage = LocalStorage.getShared();
    storage.setOrCreate("pageID", pageID);
  }
}
```  


## Key Points for LocalStorage in HarmonyOS NEXT  

1. **Scope Management**:  
   - Unbound instances are limited to `@Entry` pages and sub-components.  
   - Bound instances via `windowStage.loadContent` can be shared across an Ability.  

2. **Synchronous Operations**:  
   - Read/write operations block the thread, so avoid frequent modifications to large objects.  
   - Use `setOrCreate` to optimize updates by skipping UI refresh when values remain unchanged.  

3. **Practical Tips**:  
   - Combine with singleton patterns (e.g., `TestMgr`) for convenient cross-page data access.  
   - Always check for null values when retrieving data to prevent runtime errors.  

4. **Performance Considerations**:  
   - Prefer lightweight data structures to minimize blocking.  
   - For complex states, consider `AppStorage` for application-level sharing or databases for persistent storage.  

By mastering LocalStorage, developers can efficiently manage page-level states, ensuring smooth UI updates and consistent data across components in HarmonyOS applications.