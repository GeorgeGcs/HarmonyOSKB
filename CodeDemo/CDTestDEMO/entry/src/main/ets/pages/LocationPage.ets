import { abilityAccessCtrl } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct LocationPage {

  private TAG: string = "LocationPage";

  /**
   * 定位回调
   */
  private locationChange: (err: BusinessError, location: geoLocationManager.Location) => void = (err, location) => {
    if (err) {
      //
      console.log(this.TAG, " locationChanger: err=: " + JSON.stringify(err))
    }
    if (location) {
      let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
        'latitude': location.latitude, // 表示纬度信息，正值表示北纬，负值表示南纬。取值范围为-90到90。仅支持WGS84坐标系。
        'longitude': location.longitude, // 表示经度信息，正值表示东经，负值表是西经。取值范围为-180到180。仅支持WGS84坐标系。
        // 指定返回位置信息的最大个数。取值范围为大于等于0，推荐该值小于10。默认值是1。
        'maxItems': 1
      };

      // 逆地址编码转化，获取地址位置描述
      geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, (err, data) => {
        if (data) {
          hilog.info(0x00000, 'getAddressesFromLocation: data=', JSON.stringify(data));
          if (data[0].locality !== undefined) {
            let local = data[0].locality.replace(/"/g, '').slice(0, -1);
            let currentLocal = data[0].locality.replace(/"/g, '').slice(0, -1);
            console.log(this.TAG, " local: " + local + " currentLocal: " + currentLocal)
          }
        }
      });
    }
  };

  onClickGetLocation = ()=>{
    // 请求用户同意权限
    abilityAccessCtrl.createAtManager().requestPermissionsFromUser(getContext(), [
      'ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']).then(() => {
      // 获取当前位置
      geoLocationManager.getCurrentLocation(this.locationChange);

    });
  }


  build() {
    RelativeContainer() {
      Text("获取当前定位信息")
        .id('LocationPageHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(this.onClickGetLocation)
    }
    .height('100%')
    .width('100%')
  }
}