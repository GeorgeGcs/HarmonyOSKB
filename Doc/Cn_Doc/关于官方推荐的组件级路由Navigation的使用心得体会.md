## 【HarmonyOS】关于官方推荐的组件级路由Navigation的使用心得体会

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

最近经历了一次应用架构更新，对于路由的概念有了深刻的认识。从两年前开发OpenHarmony开始，基本都是使用router路由和window窗口来控制模块之间的切换。整个页面逻辑的控制非常耦合，并且笨重不变。

随着API的迭代更新，目前华为官方推荐使用Navigaiton来替换router。

Navigaiton这个东西，方便就方便于它的定位，组件级别。而我们的老东西router是页面级别。

1. 灵活性一目了然，我们可以将页面一部分组件，进行路由控制切换。
2. 并且我们可以对路由的删除进行管理，而router是没有remove只能替换，并且替换路由函数，是强制没有页面转场动画的效果。
3. 最大的优势在于系统提供了自动扩容的容器控件，并且支持分栏效果，在折叠屏手机上的适配会非常方便。

## Navigation如何使用？

首先Navigation是个容器，并不是直接对标router一样来使用的。我们可以理解成，这家伙是个变形金刚，它是由三部分组成，首先是主页面容器**Navigation**，其次是子页面容器**NavDestination**，之后才是对标router的操作对象**NavPathStack**

**（1）创建主页界面**

```dart
@Entry
@Component
struct MainPage {
  @State message: string = 'Hello World';
  // 创建一个页面栈对象并传入Navigation
  pageStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pageStack) {
      // 页面布局
      Row() {
        Column() {
          Text(this.message)
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
            .onClick(()=>{
              // 跳转到子页面
              this.pageStack.pushDestination({
                name: "OnePage",
              }, false); //该false表示不需要转场动画，默认是有的
            })
        }
        .width('100%')
      }
      .height('100%')
    }
    // 分为三种模式，（默认）自动NavigationMode.Auto，单页面NavigationMode.Stack和分栏NavigationMode.Split
    .mode(NavigationMode.Stack)

  }
}
```

**（2）创建子页界面**

```dart

// 跳转页面入口函数
@Builder
export function OnePageBuilder() {
  OnePage()
}

@Entry
@Component
struct OnePage {
  private TAG: string = "OnePage";
  @State message: string = 'Hello World';
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Row() {
        Column() {
          Text(this.message)
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
      }
      .height('100%')
    }.onShown(()=>{
      console.log(this.TAG, "OnePage onShown");
    })
     .onReady((context: NavDestinationContext) => {
         this.pathStack = context.pathStack;
    })
  }
}
```

**（3）配置路由表**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/5abf35485b5945cd8c44271047260d86b1862.png)

```dart
{
  "routerMap": [
    {
      "name": "OnePage",
      "pageSourceFile": "src/main/ets/pages/Navigation/OnePage.ets",
      "buildFunction": "OnePageBuilder",
      "data": {
        "description" : "this is PageOne"
      }
    }
  ]
}
```

**特别注意的是，需要配置路由表的路径到module.json5里面，要不然跳转不了。
特别注意的是，需要配置路由表的路径到module.json5里面，要不然跳转不了。
特别注意的是，需要配置路由表的路径到module.json5里面，要不然跳转不了。主要的话说三遍！**

```dart
{
  "module" : {
    "routerMap": "$profile:route_map"
  }
}
```

*从API version 12开始，Navigation支持使用系统路由表的方式进行动态路由。各业务模块（HSP/HAR）中需要独立配置router_map.json文件，在触发路由跳转时，应用只需要通过NavPactStack提供的路由方法，传入需要路由的页面配置名称，此时系统会自动完成路由模块的动态加载、页面组件构建，并完成路由跳转，从而实现了开发层面的模块解耦。*

