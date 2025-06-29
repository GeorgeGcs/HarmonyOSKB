【HarmonyOS 5】鸿蒙中@State的原理详解

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

#### 一、@State在鸿蒙中是做什么的？

`@State` 是 HarmonyOS ArkTS 框架中用于管理组件状态的核心装饰器，其核心作用是实现数据驱动 UI 的响应式编程模式。通过将变量标记为 `@State`，开发者可以确保当状态值发生变化时，**依赖该状态的 UI 组件会自动重新渲染**，从而保持数据与界面的实时同步。

`@State` 是 HarmonyOS ArkTS 实现响应式编程的大基础核心，可以说整个V1和V2都是围绕它来进行组合使用。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_06e58bf7.png 'image.png')


#### 二、@State的基本原理

`@State` 的响应式机制基于 **依赖收集** 和 **变更通知** 两大核心流程，结合 TypeScript 装饰器和元编程技术实现。其核心原理是通过依赖收集和变更通知机制，确保状态变化自动同步到 UI。

##### 1. **依赖关系的收集**

当组件渲染时，ArkUI框架会追踪所有被 `@State` 修饰的变量在 UI组件 中的使用情况。
通过装饰器在变量的 getter 中注入依赖收集逻辑，记录当前组件对该状态的依赖关系。观察者的模式来进行数据变化的监控。
例如，当组件的Text中使用 `this.message`，框架会将该组件注册为 `message` 的依赖者。

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

##### 2. **数据变更通知**

当 `@State` 变量通过 `this.message = xxxxxx` 被修改时，框架会检测到值的变化。
使用 **Proxy** 或 **Object.defineProperty** 拦截属性的赋值操作，触发变更通知。
框架遍历所有依赖该状态的组件，并调用其更新方法重新渲染 UI。
采用 **脏检查优化** 和 **异步渲染队列**，合并多次更新操作，避免频繁重绘

#####  **响应式系统的核心流程**

```typescript
数据变化 → 依赖追踪 → 自动重渲染（60FPS 高帧率更新）
```

**（1）数据变化**：开发者通过 `this.xxx = value` 修改状态。

**（2）依赖追踪**：ArkUI框架根据之前收集的依赖关系，确定哪些组件需要更新。（哪个UI组件用了@State修饰的变量。）

**（3）自动重渲染**：仅重新渲染依赖该状态的组件，提升性能。（最小限度的刷新UI）

#### 三、使用@State的注意事项

在使用 `@State` 时，需注意以下关键点以避免潜在问题：

**1. 必须初始化**：
`@State` 变量必须在组件构造函数中初始化，否则会导致编译错误。

```typescript
 @Component
 struct MyComponent {
   @State count: number = 0; // 正确初始化
   // @State message: string; // 错误：未初始化
 }
```

**2. 通过 `this` 赋值**：
必须通过 `this.xxx = value` 修改状态，直接赋值（如 `xxx = value`）不会触发 UI 更新。

```typescript
 onClick() {
   this.count = 1; // 正确，触发 UI 更新
   this.obj = { ...this.obj, key: 'new' }; // 正确，整体赋值
   this.obj.key = 'new'; // 错误，直接修改属性不触发更新
 }
```

**3. 避免频繁更新**：
连续多次修改状态会导致多次重绘，可通过合并操作优化。

##### 注意：

1.  将独立变化的状态拆分为多个 `@State` 变量，避免不必要的组件刷新。
2.  深层嵌套的对象或数组可能导致性能下降，建议使用扁平结构。
3.  组件销毁时，`@State` 变量会自动释放，但需注意手动清理定时器等外部资源。
