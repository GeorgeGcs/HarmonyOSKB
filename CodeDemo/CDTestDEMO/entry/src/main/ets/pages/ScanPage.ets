import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ScanPage {
  private TAG: string = "Index";

  private onToEasyScan = () => {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };
    scanBarcode.startScanForResult(getContext(this), options).then((result: scanBarcode.ScanResult) => {
      // 扫码解析成功，二维码数据
      console.info(this.TAG, " result: " + JSON.stringify(result));
      promptAction.showToast({
        message: result.originalValue
      });
    }).catch((error: BusinessError) => {
      // 扫码解析失败
      console.info(this.TAG, " error: " + JSON.stringify(error));
    });
  }

  build() {
    RelativeContainer() {
      Text("跳转一键扫码")
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(this.onToEasyScan)
    }
    .height('100%')
    .width('100%')
  }
}

