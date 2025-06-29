## 【HarmonyOS 5】Decorator Principles and Custom Decorators in HarmonyOS  

## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  

### 一、What is a Decorator in HarmonyOS?  
In ArkTS, a **Decorator** is a special declaration that can annotate and modify classes, methods, properties, etc. Since ArkTS is a programming language extended from TypeScript, it supports decorator features. As a tool for metaprogramming, decorators can add extra functionality to existing code without changing its structure. For example, in HarmonyOS development, decorators are used to define component properties and lifecycle methods. The `@Component` decorator, for instance, marks a class as a HarmonyOS component class.  

HarmonyOS includes **state decorators (V1 and V2)**, such as `@State`, `@Prop`, `@Link`, `@ObservedV2`, etc., and **component decorators**, such as `@Entry`, `@CustomDialog`, `@Component`, `@Builder`, etc.  

**For details, refer to the official documentation:**  
State Management (V1)  
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v1  

State Management (V2)  
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v2  


### 二、Basic Principles of Decorators  
ArkTS implements decorators by invoking functions, extending functionality without intruding into the original code structure. Decorators are generally categorized into three types: **class decorators, method decorators, and property decorators**.  

#### Class Decorator  
A class decorator is declared above a class and receives the class's constructor as a parameter. It can modify the class constructor, add properties/methods, or annotate metadata:  

```typescript  
function logDecorator(constructor: Function) {  
  console.log(`Class ${constructor.name} is created.`);  
}  

@logDecorator  
class MyComponent {  
  constructor() {  
    console.log('MyComponent instance is created.');  
  }  
}  

const myComponent = new MyComponent();  
```  

#### Method Decorator  
A method decorator applies to class methods and executes when the method is defined. It receives three parameters: the target object, method name, and method descriptor. It can modify method behavior, such as adding logs, implementing permission verification, or throttling/debouncing. In the OpenHarmony open-source system, the camera source code includes custom method decorators as shown below. However, in HarmonyOS, ArkTS's strict type checking for `any` fails, making this syntax currently inapplicable:  

```js  
/*  
 * Copyright (c) 2023 Huawei Device Co., Ltd.  
 * Licensed under the Apache License, Version 2.0 (the "License");  
 * you may not use this file except in compliance with the License.  
 * You may obtain a copy of the License at  
 *  
 *     http://www.apache.org/licenses/LICENSE-2.0  
 *  
 * Unless required by applicable law or agreed to in writing, software  
 * distributed under the License is distributed on an "AS IS" BASIS,  
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  
 * See the License for the specific language governing permissions and  
 * limitations under the License.  
 */  

import { Log } from '../../utils/Log';  

const TAG = '[Decorators]:';  

export function debounce(timeout: number) {  
  return function inner(target: any, propKey: string, descriptor: PropertyDescriptor) {  
    let curFunc: number = 0;  
    const original = descriptor.value;  
    descriptor.value = function (...args: string[]) {  
      Log.log(`${TAG} debounce invoke ${propKey} curFunc: ${curFunc}`);  
      curFunc && clearTimeout(curFunc);  
      curFunc = setTimeout(() => original.call(this, ...args), timeout);  
    };  
  };  
}  

export function throttle(waitTime: number) {  
  return function inner(target: any, propKey: string, descriptor: PropertyDescriptor) {  
    let lastTime: number = 0;  
    const original = descriptor.value;  
    descriptor.value = function (...args: string[]) {  
      let curTime = Date.now();  
      Log.log(`${TAG} throttle invoke ${propKey} timeInterval: ${curTime - lastTime}`);  
      if (curTime - lastTime >= waitTime) {  
        original.call(this, ...args);  
        lastTime = curTime;  
      }  
    };  
  };  
}  
```  

#### Property Decorator  
A property decorator applies to class properties and executes when the property is defined. It receives two parameters: the target object and property name. It can modify property accessors, such as adding validation logic or implementing property caching. However, in HarmonyOS, ArkTS's strict type checking for `any` fails, making this syntax currently inapplicable:  

```js  
function positiveNumber(target: any, propertyKey: string) {  
  let value: number;  
  const getter = function () {  
    return value;  
  };  
  const setter = function (newValue: number) {  
    if (newValue < 0) {  
      throw new Error(`${propertyKey} must be a positive number.`);  
    }  
    value = newValue;  
  };  
  Object.defineProperty(target, propertyKey, {  
    get: getter,  
    set: setter,  
    enumerable: true,  
    configurable: true  
  });  
}  

class MyModel {  
  @positiveNumber  
  age: number = 20;  
}  

const myModel = new MyModel();  
myModel.age = -1; // Throws an exception  
```  


### 三、How to Create Custom Decorators in HarmonyOS  
As mentioned, HarmonyOS's ArkTS has specific syntax rules, and types like `any` or `unknown` are not allowed. Thus, we use `Object` to replace the `target` type. The `value` property in `PropertyDescriptor` is typically `any`, but in ArkTS, we can achieve the goal by obtaining the `value` via a function and passing `target: Object, key: string, descriptor: PropertyDescriptor` using the `...args` rest parameter syntax.  

The following demonstrates how to define a class decorator in HarmonyOS. Custom property decorators can be implemented similarly:  

```js  
// Custom method decorator: Log method invocation details  
function methodLogger(target: Object, key: string, descriptor: PropertyDescriptor) {  
  const originalMethod: Function = descriptor.value;  
  descriptor.value = (...args: Object[]) => {  
    // Log the decorated method's name, parameters, and return value  
    console.log(`Calling ${(target as any).constructor.name} method ${key} with argument: ${args}`);  
    const result: Object = originalMethod.call(target, ...args);  
    console.log(`Method ${key} returned: ${result}`);  
    return result;  
  };  
  return descriptor;  
}  

@Entry  
@Component  
struct DecoratorDemoComponent {  
  @State message: string = 'Hello HarmonyOS';  

  // Use the custom decorator  
  @methodLogger  
  private processData(input: string): string {  
    console.log('Processing data...');  
    return `Processed data: ${input.toUpperCase()}`;  
  }  

  // Trigger method call when the component appears  
  aboutToAppear() {  
    const processedResult: string = this.processData('decorator demo');  
    console.log('Final result:', processedResult);  
    this.message = processedResult;  
  }  

  build() {  
    Column({ space: 30 }) {  
      Text(this.message)  
        .fontSize(24)  
        .margin(10);  

      Button('Click to trigger method')  
        .onClick(() => this.processData('button click'))  
        .margin(10);  
    }  
    .width('100%')  
    .height('100%')  
    .justifyContent(FlexAlign.Center);  
  }  
}  
```