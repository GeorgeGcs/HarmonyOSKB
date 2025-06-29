## 【HarmonyOS 5】Detailed Explanation of @State Principle in HarmonyOS  

\## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、What Does @State Do in HarmonyOS?  
`@State` is a core decorator in HarmonyOS ArkTS framework for managing component states, playing a key role in implementing the reactive programming model of data-driven UI. By marking a variable as `@State`, developers ensure that when the state value changes, **UI components dependent on this state will automatically rerender**, maintaining real-time synchronization between data and the interface.  

`@State` is the fundamental core of HarmonyOS ArkTS to achieve reactive programming, and both V1 and V2 are built around its combined usage.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_06e58bf7.png 'image.png')  


### 二、Basic Principles of @State  
The reactive mechanism of `@State` is implemented through two core processes: **dependency collection** and **change notification**, combined with TypeScript decorators and metaprogramming techniques. Its core principle ensures that state changes are automatically synchronized to the UI via dependency collection and change notification mechanisms.  

#### 1. **Dependency Collection**  
When a component renders, the ArkUI framework tracks the usage of all variables decorated with `@State` in UI components.  
Dependency collection logic is injected into the getter of the variable through the decorator to record the dependency relationship of the current component on this state, using the observer pattern to monitor data changes.  
For example, when a component's Text uses `this.message`, the framework registers the component as a dependent of `message`.  

```js  
@Entry  
@Component  
struct Index {  
  @State message: string = 'Hello World';  

  build() {  
    RelativeContainer() {  
      Text(this.message)  
        .id('HelloWorld')  
        .fontSize($r('app.float.page_text_font_size'))  
        .fontWeight(FontWeight.Bold)  
        .alignRules({  
          center: { anchor: '__container__', align: VerticalAlign.Center },  
          middle: { anchor: '__container__', align: HorizontalAlign.Center }  
        })  
        .onClick(() => {  
          this.message = 'Welcome';  
        })  
    }  
    .height('100%')  
    .width('100%')  
  }  
}  
```  

#### 2. **Data Change Notification**  
When a `@State` variable is modified via `this.message = xxxxxx`, the framework detects the value change.  
**Proxy** or **Object.defineProperty** is used to intercept property assignment operations and trigger change notifications.  
The framework traverses all components dependent on this state and calls their update methods to rerender the UI.  
**Dirty checking optimization** and **asynchronous rendering queues** are adopted to merge multiple update operations and avoid frequent redrawing.  

#### Core Process of the Reactive System  
```typescript  
Data change → Dependency tracking → Automatic rerendering (60FPS high-frame-rate update)  
```  

**(1) Data change**: Developers modify the state via `this.xxx = value`.  
**(2) Dependency tracking**: The ArkUI framework determines which components need updating based on the collected dependency relationships (which UI components use the `@State`-decorated variable).  
**(3) Automatic rerendering**: Only the components dependent on this state are rerendered to improve performance (minimum UI refresh).  


### 三、Precautions for Using @State  
When using `@State`, pay attention to the following key points to avoid potential issues:  

#### 1. Must Be Initialized  
`@State` variables must be initialized in the component constructor; otherwise, a compilation error will occur.  

```typescript  
@Component  
struct MyComponent {  
  @State count: number = 0; // Correct initialization  
  // @State message: string; // Error: Uninitialized  
}  
```  

#### 2. Assignment via `this`  
State must be modified via `this.xxx = value`; direct assignment (e.g., `xxx = value`) will not trigger UI updates.  

```typescript  
onClick() {  
  this.count = 1; // Correct, triggers UI update  
  this.obj = { ...this.obj, key: 'new' }; // Correct, overall assignment  
  this.obj.key = 'new'; // Error, direct property modification does not trigger update  
}  
```  

#### 3. Avoid Frequent Updates  
Multiple consecutive state modifications can cause multiple redraws; optimize by merging operations.  

#### Notes:  
1. Split independently changing states into multiple `@State` variables to avoid unnecessary component refreshes.  
2. Deeply nested objects or arrays may cause performance degradation; flat structures are recommended.  
3. When a component is destroyed, `@State` variables are automatically released, but manually clean up external resources like timers.