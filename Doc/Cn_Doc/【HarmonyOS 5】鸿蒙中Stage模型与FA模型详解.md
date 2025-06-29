【HarmonyOS 5】鸿蒙中Stage模型与FA模型详解

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言

在HarmonyOS 5的应用开发模型中，**`featureAbility`是旧版FA模型（Feature Ability）的用法**，Stage模型已采用全新的应用架构，推荐使用**组件化的上下文获取方式**，而非依赖`featureAbility`。

FA大概是API7之前的开发模型。所谓的开发模型，值得是创建鸿蒙开发工程后，你在什么样子的系统容器和接口上进行开发。

当初我在开发OpenHarmony的时候，最早用的就是FA模型，正是因为FA模型在开发过程中的诸多不方便，大概在API8时，官方推出了Stage模型，进行初步替代。

Stage模型，见名知意，是在系统提供的舞台容器上，进行应用的开发。整理更新的低耦合，高内聚。应用进程的管理也更加合理高效。

本文主要针对Stage模型与FA模型的区别。以及Stage模型如何获取上下文作出讲解。
### 二、Stage模型与FA模型的核心区别
下面的表格是官方文档的信息梳理，建议针对FA模型有大概了解即可。重点关注Stage模型的内容。

| **特性**         | **Stage模型（推荐）**                          | **FA模型（旧版）**                  |
|------------------|------------------------------------------------|-------------------------------------|
| **应用单元**       | 以`AbilityStage`为基础，通过`UIAbility`管理UI组件 | 以`FeatureAbility`和`PageAbility`为主 |
| **上下文获取**     | 通过组件`context`属性或`@ohos.app.ability.Context` | 使用`featureAbility.getContext()`   |
| **生命周期管理**   | 基于`UIAbility`的生命周期回调（`onCreate`/`onDestroy`） | 基于`FeatureAbility`的生命周期       |

在HarmonyOS 5 的Stage模型开发中，**`featureAbility`属于过时的FA模型接口**，必须通过组件或`UIAbility`的`context`属性获取上下文。这一变化体现了Stage模型“一切皆组件”的设计思想，确保代码结构更简洁、组件化更彻底，同时避免与旧版API的耦合。
### 三、Stage模型中正确的上下文获取方式
在Stage模型中，**组件的上下文（`Context`）直接通过组件实例的`context`属性获取**，无需通过`featureAbility`。


#### 代码示例：
```typescript
// Stage模型中，组件内直接通过this.context获取上下文
@Entry
@Component
struct FileStorageDemo {
  // 文件写入
  async writeToFile() {
    try {
      // 正确方式：使用组件的context属性
      const filesDir = await this.context.getFilesDir(); 
      const filePath = `${filesDir}/example.txt`;
      const fd = await fileio.open(filePath, 0o102); // 0o102表示写入模式（O_WRONLY | O_CREAT）
      const data = 'Stage模型下的文件存储示例';
      await fileio.write(fd, data);
      await fileio.close(fd);
      console.log('文件写入成功');
    } catch (error) {
      console.error('文件写入失败:', error);
    }
  }

  // 文件读取
  async readFromFile() {
    try {
      const filesDir = await this.context.getFilesDir(); 
      const filePath = `${filesDir}/example.txt`;
      const fd = await fileio.open(filePath, 0o100); // 0o100表示读取模式（O_RDONLY）
      const buffer = new ArrayBuffer(1024);
      const bytesRead = await fileio.read(fd, buffer);
      const data = new TextDecoder('utf-8').decode(buffer.slice(0, bytesRead));
      await fileio.close(fd);
      console.log('文件内容:', data);
    } catch (error) {
      console.error('文件读取失败:', error);
    }
  }

  build() {
    Column() {
      Button('写入文件').onClick(() => this.writeToFile())
      Button('读取文件').onClick(() => this.writeToFile())
    }
  }
}
```


 **上下文获取原则**  
 组件内直接使用`this.context`（继承自`Component`的上下文属性）。  
 `UIAbility`中使用`this.context`（代表当前Ability的上下文）。  
 避免使用任何以`featureAbility`开头的旧版API。



