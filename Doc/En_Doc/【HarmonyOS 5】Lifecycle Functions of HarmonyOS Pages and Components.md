## 【HarmonyOS 5】Lifecycle Functions of HarmonyOS Pages and Components  

## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Lifecycle Stages  
#### Creation Stage  
**build:**  
Constructs the UI structure and styles of the component.  

**onDidBuild:**  
Invoked after the `build` method executes, suitable for data initialization or additional UI adjustments.  

#### Mounting Stage  
**onPageShow:**  
Invoked when the page is displayed.  

**onReady:**  
Invoked after the component is mounted to the page.  

**onWindowStageShow:**  
Invoked when the window is displayed.  

#### Interaction Stage  
**onBackPress:**  
Invoked when the user clicks the back button.  

#### Destruction Stage  
**onPageHide:**  
Invoked when the page is hidden.  

**onDestroy:**  
Invoked when the component is destroyed.  


### 二、How to Distinguish Lifecycle Functions Between Pages and Components?  
First, we need to understand the concepts of page components and custom components.  

In ArkUI, a **page component** refers to a component decorated with `@Entry`, which has unique lifecycle interfaces crucial for controlling the page's behavior in different states.  

A **custom component** is decorated with `@Component`.  

**How to identify page-specific lifecycle functions?** The key lies in the word "page" in the function name. For example, `onPageShow` and `onPageHide` are exclusive to pages. Additionally, there's a special function: the back button trigger function `onBackPress`. Remember that only pages can respond to the back button.  


### 三、Demo Example  
```dart  
@Entry  
@Component  
struct LifeCycleExample {  
  build() {  
    Column({ space: 50 }) {  
      Text('LifeCycleExample')  
        .fontSize(50)  
        .fontWeight(FontWeight.Bold)  
    }  
    .width('100%')  
  }  

  onDidBuild() {  
    console.log('onDidBuild');  
  }  

  onPageShow() {  
    console.log('onPageShow');  
  }  

  onReady() {  
    console.log('onReady');  
  }  

  onWindowStageShow() {  
    console.log('onWindowStageShow');  
  }  

  onBackPress(): boolean {  
    console.log('onBackPress');  
    return false;  
  }  

  onDestroy() {  
    console.log('onDestroy');  
  }  

  onDestroy() {  
    console.log('onDestroy');  
  }  
}  
```