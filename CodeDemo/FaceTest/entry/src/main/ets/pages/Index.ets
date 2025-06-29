import { interactiveLiveness } from '@kit.VisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

@Entry
@Component
struct FaceLivenessDemo {
  @State userGrant: boolean = false // 权限状态
  @State detectionResult: string = "" // 检测结果展示
  //  actionCount: number = interactiveLiveness.ActionsNumber.THREE_ACTION; // 动作数量（3或4）
  // @State speechEnabled: boolean = true // 语音播报开关
  // // 表示人脸活体检测完成后使用router.back返回到上一页。
  // @State routeMode: string = interactiveLiveness.RouteRedirectionMode.BACK_MODE; // 跳转模式

  // 权限申请逻辑
  private async requestPermissions() {
    const context = getContext() as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const results = await atManager.requestPermissionsFromUser(context, ["ohos.permission.CAMERA"]);
    this.userGrant = results.authResults.every(status => status === 0);
  }

  // 检测配置生成
  private generateDetectionConfig(): interactiveLiveness.InteractiveLivenessConfig {
    let routerOptions: interactiveLiveness.InteractiveLivenessConfig= {
      // actionsNum: actionsNum,
      isSilentMode: interactiveLiveness.DetectionMode.INTERACTIVE_MODE
    };
    return routerOptions;
    return {
      // 表示的是人脸活体检测模式，默认动作活体检测模式。
      // INTERACTIVE_MODE表示动作活体检测模式。
      isSilentMode: interactiveLiveness.DetectionMode.INTERACTIVE_MODE,

      // 表示动作活体检测的动作数量，数量范围3或4个，默认3个动作。随机生成，规则如下：
      //
      // 当actionsNum=3时，[眨眼，注视]组合中的动作元素不会同时存在并且相邻的动作元素不会相同。
      //
      // 当actionsNum=4时，眨眼动作元素有且仅有1次，注视动作元素最多出现1次，[眨眼，注视]组合中的动作元素不会相邻，相邻的动作元素不会相同。
      //
      // 该参数只有当isSilentMode是INTERACTIVE_MODE的时候有效。
      // actionsNum: interactiveLiveness.ActionsNumber.THREE_ACTION, //this.actionCount as interactiveLiveness.ActionsNumber,
      // // 表示人脸活体检测成功后跳转的页面路径。如果不填，系统有默认的检测成功页面。
      // // successfulRouteUrl: "pages/result/success", // 自定义成功跳转路径（需提前创建页面）
      //
      // // 表示人脸活体检测失败后跳转的页面路径。如果不填，系统有默认的检测失败页面。
      // // failedRouteUrl: "pages/result/fail", // 自定义失败跳转路径（需提前创建页面）
      //
      // routeMode: interactiveLiveness.RouteRedirectionMode.BACK_MODE, //this.routeMode as interactiveLiveness.RouteRedirectionMode, // 跳转模式

      // // 语音播报的开关。
      // //
      // // true表示开启语音播报。
      // // false表示关闭语音播报。
      // // 默认开启语音播报。
      // speechSwitch: true, //this.speechEnabled, // 语音播报控制

      // 挑战值。仅用于安全摄像头场景（对应initializeAttestContext方法中的“userData”字段）的活体检测。
      //
      // 使用安全摄像头场景的前提需要开通Device Security服务。
      //
      // 长度范围是16-128之间（challenge传空或者undefined表示不使用安全摄像头）。
      // challenge: "自定义挑战值1234567890abcdef", // 安全摄像头场景可选

      // 是否设置隐私模式。
      //
      // true：设置隐私模式。
      // false：不设置隐私模式。
      // 默认值为false。
      // isPrivacyMode: true // 隐私模式需额外权限 当设置隐私模式时，需要申请ohos.permission.PRIVACY_WINDOW权限。
    };
  }

  // 启动检测
  private async startDetection() {
    if (!this.userGrant) {
      this.detectionResult = "请先申请相机权限";
      return;
    }

     let config: interactiveLiveness.InteractiveLivenessConfig  = this.generateDetectionConfig();

    let isSilentMode = "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode;
    let actionsNum = 3 as interactiveLiveness.ActionsNumber;
    let routerOptions: interactiveLiveness.InteractiveLivenessConfig= {
      // actionsNum: actionsNum,
      isSilentMode: isSilentMode
    };

    interactiveLiveness.startLivenessDetection(routerOptions).then(async (DetectState: boolean) => {
      hilog.info(0x0001, "LivenessCollectionIndex", `Succeeded in jumping. DetectState: ` + DetectState);
      const result = await interactiveLiveness.getInteractiveLivenessResult();
      this.processResult(result);
    }).catch((err: BusinessError) => {
      hilog.error(0x0001, "LivenessCollectionIndex", `Failed to jump. Code：${err.code}，message：${err.message}`);
    })

    // try {
    //   const jumpSuccess = await interactiveLiveness.startLivenessDetection({
    //     isSilentMode: interactiveLiveness.DetectionMode.INTERACTIVE_MODE,
    //   });
    //   if (jumpSuccess) {
    //     hilog.info(0x0001, "Detection", "跳转检测页面成功");
    //     // 检测完成后获取结果（需在返回页面时调用）
    //     const result = await interactiveLiveness.getInteractiveLivenessResult();
    //     this.processResult(result);
    //   }
    // } catch (err) {
    //   const error = err as BusinessError;
    //   hilog.error(0x0001, "Detection", `检测失败: 错误码${error.code}, 信息${error.message}`);
    //   this.detectionResult = `检测异常：错误码${error.code}`;
    // }
  }

  // 结果处理
  private processResult(result: interactiveLiveness.InteractiveLivenessResult) {
    let status = "";
    let livenessType = result.livenessType;
    switch (livenessType) {
      case 0: // 动作活体检测成功
        status = "活体检测通过";
        // 可在此处处理特征图片或安全数据
        break;
      case 2: // 非活体
        status = "检测到非活体（照片/视频攻击）";
        break;
      default:
        status = "检测结果异常";
    }
    this.detectionResult = status;
  }

  build() {
    Column({ space: 40 })
    {
      // 权限申请按钮
      Button(this.userGrant ? "权限已授权" : "申请相机权限")
        .fontSize(18)
        .margin(10)
        .padding(12)
        .backgroundColor(this.userGrant ? Color.Green : Color.Blue)
        .onClick(() => this.requestPermissions())

      // 动作数量选择
      Row({ space: 20 }) {
        Text("动作数量:")
          .fontSize(16)

        // Button("3个动作")
        //   .backgroundColor(this.actionCount === 3 ? Color.Blue : Color.White)
        //   .border({ width: 1, color: Color.Gray })
        //   .onClick(() => this.actionCount = 3)
        //
        // Button("4个动作")
        //   .backgroundColor(this.actionCount === 4 ? Color.Blue : Color.White)
        //   .border({ width: 1, color: Color.Gray })
        //   .onClick(() => this.actionCount = 4)
      }

      // // 语音播报开关
      // Toggle({ type: ToggleType.Checkbox, isOn: this.speechEnabled })
      //   .onChange((isOn: boolean)=>{
      //     this.speechEnabled = isOn;
      //   })

      // 跳转模式选择
      Row({ space: 20 }) {
        Text("跳转模式:")
          .fontSize(16)

        // Button("替换页面")
        //   .backgroundColor(this.routeMode === "replace" ? Color.Blue : Color.White)
        //   .border({ width: 1, color: Color.Gray })
        //   .onClick(() => {
        //     this.routeMode = interactiveLiveness.RouteRedirectionMode.REPLACE_MODE;
        //   })
        //
        // Button("返回上页")
        //   .backgroundColor(this.routeMode === "back" ? Color.Blue : Color.White)
        //   .border({ width: 1, color: Color.Gray })
        //   .onClick(() => {
        //     this.routeMode = interactiveLiveness.RouteRedirectionMode.BACK_MODE;
        //   })
      }

      // 启动检测按钮
      Button("开始人脸活体检测")
        .fontSize(20)
        .padding(16)
        .backgroundColor(Color.Orange)
        .onClick(() => {
          this.startDetection()
        })

      // 结果显示
      Text(this.detectionResult)
        .fontSize(16)
        .margin({
          top: 30
        })
        .foregroundColor(this.detectionResult.includes("通过") ? Color.Green : Color.Red)
    }
    .width("100%")
    .height("100%")
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}