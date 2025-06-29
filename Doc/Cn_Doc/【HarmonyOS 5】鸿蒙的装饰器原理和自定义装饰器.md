## 【HarmonyOS 5】鸿蒙的装饰器原理和自定义装饰器

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

一、鸿蒙中的装饰器是什么？

在ArkTS中装饰器（Decorator）是一种特殊的声明，能够对类、方法、属性等进行标注和修改。

因为ArkTS 是TypeScript 扩展而来的编程语言，TypeScript 支持装饰器特性。它属于元编程的一种工具，可在不改变原有代码结构的基础上，为其添加额外的功能。比如在鸿蒙开发里，装饰器能够用来定义组件的属性、生命周期方法等。像@Component装饰器就用于把一个类标记成鸿蒙的组件类。

鸿蒙中的装饰器有状态装饰器V1和V2（@State、@Prop、@Link、@ObservedV2等等）。组件装饰器@Entry，@CustomDialog，@Component，@Builder等等。

**详情参见官方文档：**

状态管理（V1）
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v1

状态管理（V2）
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v2

二、装饰器的基本原理

ArkTS通过装饰器的方式，调用**函数**实现。在不侵入原有代码结构的基础上，进行扩展。

装饰器一般分为三种：类装饰器，方法装饰器，属性装饰器。

类装饰器在类之上声明，接收类的构造函数作为参数，可用于修改类的构造函数、添加类的属性和方法，或者对类进行一些元数据的标注：

```typeScript

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

方法装饰器应用于类的方法，在方法被定义时执行。它接收三个参数：目标对象、方法名和方法描述符。方法装饰器可以用于修改方法的行为，比如添加日志、进行权限验证、实现节流防抖等功能。在OpenHarmony开源系统中，对照系统相机源码，可看到以下自定义方法类如下所示。但是在HarmonyOS中，ArkTS对any强类型校验不通过。目前这种写法无法使用。

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

const TAG = '[Decorators]:'

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


属性装饰器应用于类的属性，在属性被定义时执行。它接收两个参数：目标对象和属性名。属性装饰器可以用于修改属性的访问器，比如添加属性验证逻辑、实现属性的缓存等。
但是在HarmonyOS中，ArkTS对any强类型校验不通过。目前这种写法无法使用。

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
myModel.age = -1; // 会抛出异常

```

三、在HarmonyOS中如何自定义装饰器

综上所述，在HarmonyOS中有特殊的ArkTS语法规则，any unknown这些不能使用。所以我们需要通过Object代替targe的any类型。

PropertyDescriptor中的value值也是any，直接按照ts的语法是没问题。但是在ArkTS中我们需要曲线实现目标，通过Function的形式获取value属性的值，再将target: Object, key: string, descriptor: PropertyDescriptor通过...args的形式赋值。

`...args` 是 JavaScript 和 TypeScript（ArkTS 基于 TypeScript）中的剩余参数（Rest Parameters）语法。

在HarmonyOS中定义类装饰器的方式如下所示，自定义属性装饰器同理：

```js

// 自定义方法装饰器：记录方法调用信息
function methodLogger(target: Object, key: string, descriptor: PropertyDescriptor) {
  const originalMethod: Function = descriptor.value;
  descriptor.value = (...args: Object[]) => {
    // 获取被装饰方法的名称、入参、返回值
    console.log(`Calling ${target.constructor.name} method ${key} with argument: ${args}`)
    const result: Object = originalMethod(...args)
    console.log(`Method ${key} returned: ${result}`)
    return result
  }
  return descriptor;
}

@Entry
@Component
struct DecoratorDemoComponent {
  @State message: string = 'Hello HarmonyOS';

  // 使用自定义装饰器
  @methodLogger
  private processData(input: string): string {
    console.log('正在处理数据...');
    return `处理后的数据：${input.toUpperCase()}`;
  }

  // 组件显示时触发方法调用
  aboutToAppear() {
    const processedResult: string = this.processData('decorator demo');
    console.log('最终结果：', processedResult);
    this.message = processedResult;
  }

  build() {
    Column({ space: 30 }) {
      Text(this.message)
        .fontSize(24)
        .margin(10);

      Button('点击触发方法')
        .onClick(() => this.processData('button click'))
        .margin(10);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center);
  }
}

```