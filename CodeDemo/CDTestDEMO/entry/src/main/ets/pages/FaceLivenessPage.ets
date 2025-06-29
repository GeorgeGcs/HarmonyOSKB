
import { interactiveLiveness } from '@kit.VisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { bundleManager } from '@kit.MDMKit';

/**
 * 人脸活体检测
 */
@Entry
@Component
struct FaceLivenessPage {

  @State userGrant: boolean = false // 是否已申请相机权限

  // 用户申请权限
  private async reqPermissionsFromUser(): Promise<number[]> {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
    return grantStatus.authResults;
  }

  private async requestCameraPermission() {

    let grantStatus = await this.reqPermissionsFromUser();
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        this.userGrant = true;
        promptAction.showToast({
          message: "授权成功!"
        })
      }
    }
  }

  onClickPermission = ()=>{
    this.requestCameraPermission();
  }

  onClickFaceLiv = ()=>{

    if(!this.userGrant){
      promptAction.showToast({
        message: "无相机权限！"
      })
      return;
    }

    let isSilentMode = "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode;
    let actionsNum = 3 as interactiveLiveness.ActionsNumber;
    let routerOptions: interactiveLiveness.InteractiveLivenessConfig= {
      actionsNum: actionsNum,
      isSilentMode: isSilentMode,
      routeMode: "back" as interactiveLiveness.RouteRedirectionMode
    };
    interactiveLiveness.startLivenessDetection(routerOptions, (err: BusinessError, result: interactiveLiveness.InteractiveLivenessResult | undefined) => {
      if(err.code !== 0 && !result) {
        hilog.error(0x0001, "LivenessCollectionIndex", `Failed to detect. Code：${err.code}，message：${err.message}`);
        return;
      }
      hilog.info(0x0001, 'LivenessCollectionIndex', `Succeeded in detecting result：${JSON.stringify(result)}`);
      promptAction.showToast({
        message: JSON.stringify(result)
      })
    })
  }

  @Styles commonText(){
    .width(px2vp(600))
    .height(px2vp(120))
    .backgroundColor(Color.Blue)
    .borderRadius(15)
  }

  build() {
    Column(){
      Text("请求相机权限")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()
        .onClick(this.onClickPermission)
        .margin({
          bottom: px2vp(60)
        })

      Text("人脸活体检测")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()
        .onClick(this.onClickFaceLiv)

    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Black)
  }
}