## 【HarmonyOS 5】Detailed Explanation of Stage Model and FA Model in HarmonyOS  

## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Preface  
In the application development model of HarmonyOS 5, **`featureAbility` is the usage of the old FA model (Feature Ability)**, while the Stage model adopts a brand-new application architecture, recommending the use of **componentized context acquisition methods** instead of relying on `featureAbility`.  

The FA model was used before API 7. A development model refers to the system container and interfaces on which you develop after creating a HarmonyOS development project.  

When I first developed OpenHarmony, I used the FA model. Due to its inconveniences, the official introduced the Stage model around API 8 for initial replacement. As the name suggests, the Stage model develops applications on a stage container provided by the system, featuring better low coupling, high cohesion, and more reasonable and efficient application process management.  

This article focuses on the differences between the Stage model and the FA model, as well as how to obtain context in the Stage model.  


### 二、Core Differences Between Stage Model and FA Model  
The following table is sorted from official documentation. It is recommended to have a general understanding of the FA model while focusing on the Stage model.  

| **Feature**          | **Stage Model (Recommended)**                           | **FA Model (Legacy)**                 |  
|---------------------|-------------------------------------------------------|--------------------------------------|  
| **Application Unit** | Based on `AbilityStage`, manages UI components through `UIAbility` | Focuses on `FeatureAbility` and `PageAbility` |  
| **Context Acquisition** | Through the component `context` property or `@ohos.app.ability.Context` | Uses `featureAbility.getContext()` |  
| **Lifecycle Management** | Lifecycle callbacks based on `UIAbility` (`onCreate`/`onDestroy`) | Lifecycle based on `FeatureAbility` |  

In HarmonyOS 5 Stage model development, **`featureAbility` belongs to outdated FA model interfaces**, and context must be obtained through the component or the `context` property of `UIAbility`. This change reflects the Stage model's design philosophy of "everything is a component," ensuring a simpler code structure, more thorough componentization, and avoiding coupling with legacy APIs.  


### 三、Correct Context Acquisition in Stage Model  
In the Stage model, the **context of a component (Context) is directly obtained through the `context` property of the component instance**, without using `featureAbility`.  


#### Code Example:  
```typescript  
// In the Stage model, directly obtain context via this.context within the component  
@Entry  
@Component  
struct FileStorageDemo {  
  // File writing  
  async writeToFile() {  
    try {  
      // Correct way: Use the component's context property  
      const filesDir = await this.context.getFilesDir();  
      const filePath = `${filesDir}/example.txt`;  
      const fd = await fileio.open(filePath, 0o102); // 0o102 represents write mode (O_WRONLY | O_CREAT)  
      const data = 'File storage example under Stage model';  
      await fileio.write(fd, data);  
      await fileio.close(fd);  
      console.log('File written successfully');  
    } catch (error) {  
      console.error('File writing failed:', error);  
    }  
  }  

  // File reading  
  async readFromFile() {  
    try {  
      const filesDir = await this.context.getFilesDir();  
      const filePath = `${filesDir}/example.txt`;  
      const fd = await fileio.open(filePath, 0o100); // 0o100 represents read mode (O_RDONLY)  
      const buffer = new ArrayBuffer(1024);  
      const bytesRead = await fileio.read(fd, buffer);  
      const data = new TextDecoder('utf-8').decode(buffer.slice(0, bytesRead));  
      await fileio.close(fd);  
      console.log('File content:', data);  
    } catch (error) {  
      console.error('File reading failed:', error);  
    }  
  }  

  build() {  
    Column() {  
      Button('Write to File').onClick(() => this.writeToFile())  
      Button('Read from File').onClick(() => this.readFromFile())  
    }  
  }  
}  
```  


#### Context Acquisition Principles  
- Directly use `this.context` within components (context property inherited from `Component`).  
- Use `this.context` in `UIAbility` (representing the context of the current Ability).  
- Avoid any legacy APIs starting with `featureAbility`.