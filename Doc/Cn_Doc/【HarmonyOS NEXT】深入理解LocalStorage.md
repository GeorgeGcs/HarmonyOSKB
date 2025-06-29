## 【HarmonyOS NEXT】深入理解LocalStorage

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言

鸿蒙应用中关于状态管理的处理机制有很多。从状态装饰器@State @prop等，LocalStrong，AppStrong到首选项，再到数据库。内存到持久化。轻量级到重量级。全方位覆盖。

学习和记忆技术点，建议知其然，才能知其所以然。搞清楚定位，才能如指臂使。

首先LocalStorage是页面级的UI状态存储，用于在@Entry修饰的页面，及其子View之间的状态存储，数据同步更新。

***LocalStorage的读写操作是同步的，即当读取或写入LocalStorage时，程序会阻塞等待操作完成才会继续执行后续代码，所以不推荐频繁修改复杂对象。***

UI装饰器，实现数据link同步更新的操作在第二章，本章主要讲解逻辑数据存取操作。

## 二、逻辑类中使用LocalStorage进行数据存取

在逻辑类中使用LocalStorage基本就脱离了UI的绑定，我们的数据基本在逻辑运算中使用。不考虑UI的动态刷新和渲染。

使用LocalStorage进行数据存储，可以将数据存储单元控制在单个页面或者单个Ability为单元，进行分割保存。

当我们直接使用LocalStorage进行set，get操作，该实例的作用范围是@Entry修饰的单个页面，以及其子页面（当然你需要透传实例对象才能实现）。

如果我们将实例对象捆绑到stage舞台上，就可以达到在单Ability中共享一个LocalStorage实例对象，扩大其作用范围。

所以为了达到能在逻辑类中便捷的使用LocalStorage，我们是需要：

1.**将LocalStorage的实例绑定在舞台上。**
如果不绑定，该实例仅仅在一个@Entry装饰的组件和其所属的子组件（一个页面）中共享，如果希望其在多个视图中共享，可以在所属UIAbility中创建LocalStorage实例，并调用windowStage.loadContent。

2.**获取实例对象，使用setOrCreate 进行数据的存储。**
使用Share函数进行绑定在舞台上的LocalStorage实例对象获取。
使用setOrCreate 进行数据存储，如果propName已经在LocalStorage中存在，并且newValue和propName对应属性的值不同，则设置propName对应属性的值为newValue，否则状态变量不会通知UI刷新propName对应属性的值。

3.**使用get进行数据的获取，注意判空处理。**

## 三、DEMO示例：

Demo验证思路，使用localStorage在UIAbility中共享的能力。进行页面间共享实例对象。进行key-val数据存储和获取。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/fb46191615ce4933b85b5f4d701d5f19b1862.png)

```dart
import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

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

```dart
import { router } from '@kit.ArkUI';
import systemDateTime from '@ohos.systemDateTime';
import TestMgr from './TestMgr';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    let pageID: string = systemDateTime.getTime() + "";
    console.log("debugStorage", " pageID: " + pageID);
    TestMgr.Ins().setPageID(pageID);
    let tempID: string = TestMgr.Ins().getPageID();
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
        .onClick(()=>{
          router.pushUrl({
            url: "pages/Index2"
          })
        })
    }
    .height('100%')
    .width('100%')
  }
}
```

```dart
import TestMgr from './TestMgr';

@Entry
@Component
struct Index2 {
  @State message: string = 'Hello World222';

  aboutToAppear(): void {

    let tempID: string = TestMgr.Ins().getPageID();
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

```dart

export default class TestMgr{

  private static mTestMgr: TestMgr | undefined = undefined;

  public static Ins(): TestMgr {
    if(TestMgr.mTestMgr){
      return TestMgr.mTestMgr;
    }else{
      TestMgr.mTestMgr = new TestMgr();
      return TestMgr.mTestMgr;
    }
  }

  public getPageID(){
    let storage = LocalStorage.getShared();
    let temp: string = storage.get("pageID") ?? "";
    return temp;
  }

  public setPageID(pageID: string){
    let storage = LocalStorage.getShared();
    storage.setOrCreate("pageID", pageID);
  }

}
```

