【HarmonyOS】鸿蒙应用实现调用系统地图导航或路径规划

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 前言

在涉及地图业务中，调用地图导航和路径规划是三方应用中较为常见的功能。

若只是子业务需要地图导航效果，整个APP内部集成地图去实现导航或者路径规划，会造成SDK集成冗余。毕竟很重。

所以该效果一般会调用系统地图，来显示当前坐标和目标坐标的路径规划或者实时导航。

鸿蒙系统提供了一种极其简单的调用方式，默认是自己当前的坐标为基础，

**需要注意的是，国内的坐标系是GCJ02坐标系，国外才是wgs84坐标系。**

## 示例效果

**地图导航：**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/5b9cf565575d4e199716d00590dc95e8b1862.png)

**路径规划：**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/369db94bc28644fb982fca7b0a1ad8aab1862.png)

## DEMO示例

系统地图应用的包名为：
'com.huawei.hmos.maps.app'

```dart
import { common, Want } from '@kit.AbilityKit';

@Entry
@Component
struct Index {


  aboutToAppear(): void {

  }

  StartNavi = ()=>{
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes', // 路径规划
      // uri: 'maps://navigation', // 导航
      parameters: {
      	// 接入方业务名或包名，Link请求来源。
        linkSource: 'com.example.navitest',
        destinationLatitude: 40.0382556,
        destinationLongitude: 116.3144536,
        // 终点Poi ID，如果有，优先使用（Map Kit返回的Poi信息含Poi ID）。
        destinationPoiId: '906277887815706098',
        destinationName: '北京清河高铁站',
        vehicleType: 0 // 交通出行工具。0-驾车， 1-步行， 2-骑行。默认驾车
      }
    }

    let context = getContext(this) as common.UIAbilityContext;
    context.startAbility(petalMapWant);
  }

  build() {
    RelativeContainer() {
      Text("唤起导航")
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(this.StartNavi)
    }
    .height('100%')
    .width('100%')
  }
}
```

**wgs84坐标系转化为gcj02:**

```dart
import { map, mapCommon } from '@kit.MapKit';

let wgs84Position: mapCommon.LatLng = {
  latitude: 30,
  longitude: 118
};
let gcj02Position: mapCommon.LatLng =
  map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
```

