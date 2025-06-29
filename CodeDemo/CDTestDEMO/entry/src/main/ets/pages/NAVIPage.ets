import { common, Want } from '@kit.AbilityKit';

@Entry
@Component
struct NAVIPage {

  StartNavi = ()=>{
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes', // 路径规划
      // uri: 'maps://navigation', // 导航
      parameters: {
        linkSource: 'com.example.navitest',
        destinationLatitude: 40.0382556,
        destinationLongitude: 116.3144536,
        destinationPoiId: '906277887815706098',
        destinationName: '清河火车站',
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