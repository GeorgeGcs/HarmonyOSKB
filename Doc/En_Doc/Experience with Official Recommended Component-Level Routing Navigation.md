## 【HarmonyOS 5】 Experience with Official Recommended Component-Level Routing Navigation  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

Recently, during an application architecture update, I gained deep insights into routing concepts. For the past two years since developing OpenHarmony, I've primarily used `router` routing and `window` controls for module navigation. The page logic was highly coupled and cumbersome.  

With API iterations, Huawei now officially recommends using `Navigation` to replace `router`. The key advantage of `Navigation` lies in its **component-level** positioning, contrasting with `router`'s **page-level** approach.  

1. **Flexibility**: Enables routing control over partial page components.  
2. **Navigation Management**: Supports removal operations, unlike `router` which only allows replacement without transition animations.  
3. **Adaptive Design**: Provides an auto-scaling container that supports split-screen layouts, ideal for foldable devices.  


### How to Use Navigation?  

`Navigation` is a container comprising three parts: the main container `Navigation`, subpage container `NavDestination`, and navigation operator `NavPathStack`.  


#### (1) Create Main Page  

```dart
@Entry
@Component
struct MainPage {
  @State message: string = 'Hello World';
  // Create a page stack and pass to Navigation
  pageStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pageStack) {
      // Page layout
      Row() {
        Column() {
          Text(this.message)
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
            .onClick(()=>{
              // Navigate to sub-page
              this.pageStack.pushDestination({
                name: "OnePage",
              }, false); // false disables transition animation (enabled by default)
            })
        }
        .width('100%')
      }
      .height('100%')
    }
    // Modes: Auto (default), Stack, Split
    .mode(NavigationMode.Stack)
  }
}
```  


#### (2) Create Subpage  

```dart
// Subpage entry builder
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


#### (3) Configure Routing Table  

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

**Critical Note (said three times):** The routing table must be configured in `module.json5` for navigation to work.  

```dart
{
  "module" : {
    "routerMap": "$profile:route_map"
  }
}
```  

*Starting from API version 12, Navigation supports dynamic routing via the system routing table. Each business module (HSP/HAR) must configure a `router_map.json` file. During navigation, the system dynamically loads modules, builds page components, and completes routing, achieving development-level module decoupling.*
