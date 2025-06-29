## 【HarmonyOS】Invoke System Map Navigation or Route Planning in HarmonyOS Applications  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

### Preface  

In map-related services, invoking navigation and route planning is a common requirement for third-party apps. Instead of integrating a heavy map SDK for sub-features, it's more efficient to leverage the system's built-in map capabilities.  

HarmonyOS provides a simple API to invoke navigation or route planning from the current location to a destination.  

**Note:** China uses the GCJ02 coordinate system, while international regions use WGS84.  


### Example Demonstration  

**Map Navigation:**  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/5b9cf565575d4e199716d00590dc95e8b1862.png)  

**Route Planning:**  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/369db94bc28644fb982fca7b0a1ad8aab1862.png)  


### DEMO Code  

The package name of the system map app is:  
`'com.huawei.hmos.maps.app'`  


```dart
import { common, Want } from '@kit.AbilityKit';

@Entry
@Component
struct Index {

  aboutToAppear(): void {
    // Initialization code
  }

  StartNavi = ()=>{
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes', // Route planning
      // uri: 'maps://navigation', // Navigation
      parameters: {
        // Business name or package name of the calling app
        linkSource: 'com.example.navitest',
        destinationLatitude: 40.0382556,
        destinationLongitude: 116.3144536,
        // Destination POI ID (if available, overrides coordinates)
        destinationPoiId: '906277887815706098',
        destinationName: 'Beijing Qinghe High-Speed Railway Station',
        vehicleType: 0 // Transportation mode. 0-Driving, 1-Walking, 2-Cycling. Default is driving
      }
    }

    let context = getContext(this) as common.UIAbilityContext;
    context.startAbility(petalMapWant);
  }

  build() {
    RelativeContainer() {
      Text("Launch Navigation")
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


**Convert WGS84 to GCJ02 Coordinates:**  

```dart
import { map, mapCommon } from '@kit.MapKit';

let wgs84Position: mapCommon.LatLng = {
  latitude: 30,
  longitude: 118
};
let gcj02Position: mapCommon.LatLng =
  map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
```