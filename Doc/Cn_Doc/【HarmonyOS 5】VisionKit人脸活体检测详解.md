## 【HarmonyOS 5】VisionKit人脸活体检测详解

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、VisionKit人脸活体检测是什么？

VisionKit是HamronyOS提供的场景化视觉服务工具包。

华为将常见的解决方案，通常需要三方应用使用SDK进行集成。华为以Kit的形式集成在HarmoyOS系统中，方便三方应用快速开发和赋能。

而VisionKit中包含人脸活体检测的功能接口interactiveLiveness 。人脸活体检测见名知意，主要是为了检测当前人是否为活人本人，而不是照片，硅胶面具，AI视频仿真的可能。

虽然该算法接口已通过中金金融（CECA）认证。但是官方还是建议添加额外的安全措施后，在使用该人脸检测接口，尽量不要直接使用在高风险性的支付和金融场景中。推荐在低危险场景，例如登录，考勤，实名认证等业务场景进行使用。

需要注意的是\*\*，人脸活体检测，不支持模拟器和预览器。\*\*

详情参见官方接口：
<https://developer.huawei.com/consumer/cn/doc/harmonyos-references/vision-interactive-liveness>
<https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/vision-interactiveliveness>
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_d011cd35.png 'image.png')


## 二、人脸活体检测如何使用？

人脸活体检测功能interactiveLiveness ，起始版本为 5.0.0 (API12)，可通过@kit.VisionKit模块导入，支持动作活体检测模式（INTERACTIVE\_MODE），动作数量可配置为 3 或 4 个，包含点头、张嘴、眨眼等 6 种动作。

通过InteractiveLivenessConfig配置检测模式、跳转路径、语音播报等参数，提供startLivenessDetection和getInteractiveLivenessResult接口，能抵御照片、视频等GJ，适用于身份验证场景，需申请ohos.permission.CAMERA相机权限，错误码可参考 Vision Kit 错误码文档。

Vision Kit 错误码文档
<https://developer.huawei.com/consumer/cn/doc/harmonyos-references/vision-error-code>

**1. 核心接口为人脸页面唤起接口：**
interactiveLiveness.startLivenessDetection，该接口需要配置config进行设置人脸的模式，动作等操作。

(1) Promise 方式：仅返回跳转结果（boolean）。

```dart

interactiveLiveness.startLivenessDetection(routerOptions).then((DetectState: boolean) => {
  hilog.info(0x0001, "LivenessCollectionIndex", `Succeeded in jumping.`);
}).catch((err: BusinessError) => {
  hilog.error(0x0001, "LivenessCollectionIndex", `Failed to jump. Code：${err.code}，message：${err.message}`);
})
```

(2) Promise + 回调方式：同时返回跳转结果和检测结果（仅适用于 BACK\_MODE）。

```dart

interactiveLiveness.startLivenessDetection(routerOptions, (err: BusinessError, result: interactiveLiveness.InteractiveLivenessResult | undefined) => {
  if(err.code !== 0 && !result) {
    hilog.error(0x0001, "LivenessCollectionIndex", `Failed to detect. Code：${err.code}，message：${err.message}`);
    return;
  }
  hilog.info(0x0001, 'LivenessCollectionIndex', `Succeeded in detecting result：${result}`);
})
```

**2. InteractiveLivenessConfig配置接口：**
调用人脸活体检测，需要填入该配置对象，进行相关设置，参数见以下表格：

1.  **检测模式（DetectionMode）**
    | 名称                | 值                   | 说明           |
    | ----------------- | ------------------- | ------------ |
    | SILENT\_MODE      | "SILENT\_MODE"      | 静默活体检测（暂未支持） |
    | INTERACTIVE\_MODE | "INTERACTIVE\_MODE" | 动作活体检测（默认模式） |

2.  **动作数量（ActionsNumber）**
    | 名称            | 值 | 说明                                       |
    | ------------- | - | ---------------------------------------- |
    | ONE\_ACTION   | 1 | 随机1个动作（暂未支持）                             |
    | TWO\_ACTION   | 2 | 随机2个动作（暂未支持）                             |
    | THREE\_ACTION | 3 | 随机3个动作（\[眨眼，注视]不同时存在且不相邻，相邻动作不重复）        |
    | FOUR\_ACTION  | 4 | 随机4个动作（眨眼仅1次，注视最多1次，\[眨眼，注视]不相邻，相邻动作不重复） |

3.  **跳转模式（RouteRedirectionMode）**
    | 名称            | 值         | 说明                               |
    | ------------- | --------- | -------------------------------- |
    | BACK\_MODE    | "back"    | 检测完成后调用router.back返回上一页          |
    | REPLACE\_MODE | "replace" | 检测完成后调用router.replaceUrl跳转（默认模式） |

4.  **配置项（InteractiveLivenessConfig）**
    | 名称                 | 类型                   | 必填/可选 | 说明                                              |
    | ------------------ | -------------------- | ----- | ----------------------------------------------- |
    | isSilentMode       | DetectionMode        | 必填    | 检测模式（默认INTERACTIVE\_MODE）                       |
    | actionsNum         | ActionsNumber        | 可选    | 动作数量（3或4，默认3）                                   |
    | successfulRouteUrl | string               | 可选    | 检测成功跳转路径（未填则用系统默认页面）                            |
    | failedRouteUrl     | string               | 可选    | 检测失败跳转路径（未填则用系统默认页面）                            |
    | routeMode          | RouteRedirectionMode | 可选    | 跳转模式（默认REPLACE\_MODE）                           |
    | challenge          | string               | 可选    | 安全摄像头场景挑战值（16-128位，空值表示不使用）                     |
    | speechSwitch       | boolean              | 可选    | 语音播报开关（默认开启）                                    |
    | isPrivacyMode      | boolean              | 可选    | 隐私模式（需申请ohos.permission.PRIVACY\_WINDOW权限，默认关闭） |

人脸活体检测的配置项对象除了isSilentMode是必填，其他属性均为可选：

```dart
import { interactiveLiveness } from '@kit.VisionKit';

let isSilentMode = "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode;
let routeMode = "replace" as interactiveLiveness.RouteRedirectionMode;
let actionsNum = 3 as interactiveLiveness.ActionsNumber;
let routerOptions: interactiveLiveness.InteractiveLivenessConfig= {
  isSilentMode: isSilentMode,
  routeMode: routeMode,
  actionsNum: actionsNum,
  failedRouteUrl: "pages/FailPage",
  successfulRouteUrl: "pages/SuccessPage"
}
```

**3. getInteractiveLivenessResult获取人脸活体检测结果：**
在调用人脸活体检测成功后，可通过该接口获取检测结果。结果内容如下表格所示：

| 名称                 | 类型             | 只读 | 可选 | 说明                                                                                                                    |
| ------------------ | -------------- | -- | -- | --------------------------------------------------------------------------------------------------------------------- |
| livenessType       | LivenessType   | 是  | 否  | 活体检测模式，值包括：<br>- `0`（INTERACTIVE\_LIVENESS，动作活体检测）<br>- `1`（SILENT\_LIVENESS，静默活体检测，暂未支持）<br>- `2`（NOT\_LIVENESS，非活体） |
| mPixelMap          | image.PixelMap | 是  | 是  | 检测成功后返回的最具有活体特征的图片（如包含人脸关键点的特征图），检测失败时无此数据。                                                                           |
| securedImageBuffer | ArrayBuffer    | 是  | 是  | 安全摄像头场景下返回的安全流数据（加密后的图像特征数据），非安全场景无此数据。                                                                               |
| certificate        | Array<string>  | 是  | 是  | 安全摄像头场景下返回的证书链（用于验证安全流的合法性），非安全场景无此数据。                                                                                |

```dart
let successResult = interactiveLiveness.getInteractiveLivenessResult();
successResult.then(data => {
  hilog.info(0x0001, "LivenessCollectionIndex", `Succeeded in detecting.`);
}).catch((err: BusinessError) => {
  hilog.error(0x0001, "LivenessCollectionIndex", `Failed to detect. Code：${err.code}，message：${err.message}`);
})
```

## 三、DEMO源码示例

```dart
import { interactiveLiveness } from '@kit.VisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

@Entry
@Component
struct FaceLivenessDemo {
  @State userGrant: boolean = false // 权限状态
  @State detectionResult: string = "" // 检测结果展示
  @State actionCount: interactiveLiveness.ActionsNumber = interactiveLiveness.ActionsNumber.THREE_ACTION; // 动作数量（3或4）
  @State speechEnabled: boolean = true // 语音播报开关
  // 表示人脸活体检测完成后使用router.back返回到上一页。
  @State routeMode: interactiveLiveness.RouteRedirectionMode = interactiveLiveness.RouteRedirectionMode.BACK_MODE; // 跳转模式

  // 权限申请逻辑
  private async requestPermissions() {
    const context = getContext() as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const results = await atManager.requestPermissionsFromUser(context, ["ohos.permission.CAMERA"]);
    this.userGrant = results.authResults.every(status => status === 0);
  }

  // 检测配置生成
  private generateDetectionConfig(): interactiveLiveness.InteractiveLivenessConfig {
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
      actionsNum: this.actionCount,
      // 表示人脸活体检测成功后跳转的页面路径。如果不填，系统有默认的检测成功页面。
      // successfulRouteUrl: "pages/result/success", // 自定义成功跳转路径（需提前创建页面）

      // 表示人脸活体检测失败后跳转的页面路径。如果不填，系统有默认的检测失败页面。
      // failedRouteUrl: "pages/result/fail", // 自定义失败跳转路径（需提前创建页面）

      routeMode: this.routeMode, // 跳转模式

      // 语音播报的开关。
      //
      // true表示开启语音播报。
      // false表示关闭语音播报。
      // 默认开启语音播报。
      speechSwitch: this.speechEnabled, // 语音播报控制

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

    const config = this.generateDetectionConfig();

    try {
      const jumpSuccess = await interactiveLiveness.startLivenessDetection(config);
      if (jumpSuccess) {
        hilog.info(0x0001, "Detection", "跳转检测页面成功");
        // 检测完成后获取结果（需在返回页面时调用）
        const result = await interactiveLiveness.getInteractiveLivenessResult();
        this.processResult(result);
      }
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0001, "Detection", `检测失败: 错误码${error.code}, 信息${error.message}`);
      this.detectionResult = `检测异常：错误码${error.code}`;
    }
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
        status = "检测到非活体（照片/视频GJ）";
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

        Button("3个动作")
          .backgroundColor(this.actionCount === 3 ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => this.actionCount = 3)

        Button("4个动作")
          .backgroundColor(this.actionCount === 4 ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => this.actionCount = 4)
      }

      // 语音播报开关
      Toggle({ type: ToggleType.Checkbox, isOn: this.speechEnabled })
        .onChange((isOn: boolean)=>{
          this.speechEnabled = isOn;
        })

      // 跳转模式选择
      Row({ space: 20 }) {
        Text("跳转模式:")
          .fontSize(16)

        Button("替换页面")
          .backgroundColor(this.routeMode === "replace" ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => {
            this.routeMode = interactiveLiveness.RouteRedirectionMode.REPLACE_MODE;
          })

        Button("返回上页")
          .backgroundColor(this.routeMode === "back" ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => {
            this.routeMode = interactiveLiveness.RouteRedirectionMode.BACK_MODE;
          })
      }

      // 启动检测按钮
      Button("开始人脸活体检测")
        .fontSize(20)
        .padding(16)
        .backgroundColor(Color.Orange)
        .onClick(() => this.startDetection())

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
```

## 注意：

**1. 人脸活体检测支持两种模式**
INTERACTIVE\_MODE（动作活体检测）：默认模式，需用户完成 3 或 4 个随机动作（如眨眼、点头等），通过动作组合验证活体，规则限制避免相邻动作重复或特定组合（如眨眼和注视不相邻）。
SILENT\_MODE（静默活体检测）：暂未支持，无需用户做动作，通过其他技术（如微表情、光线反射）检测活体。

**2. 配置人脸活体检测的动作数量和跳转逻辑**
通过InteractiveLivenessConfig中的actionsNum配置，可选值为 3（默认）或 4，3 个动作时（眨眼，注视） 不同时存在且不相邻，4 个动作时眨眼仅 1 次，注视最多 1 次。
通过routeMode配置跳转模式（BACK\_MODE 返回上一页或 REPLACE\_MODE 替换跳转，默认 REPLACE\_MODE）。
successfulRouteUrl和failedRouteUrl设置成功 / 失败后的自定义跳转路径（未填则用系统默认页面）。

**3. 常见错误及处理：**
201（Permission denied）：未申请ohos.permission.CAMERA权限

1008301002（Route switching failed）：路由配置错误，检查successfulRouteUrl/failedRouteUrl路径是否正确，或routeMode是否与页面路由匹配。

1008302000-1008302004（检测相关错误）：检测过程中算法初始化失败、超时或动作不符合规则，可通过回调或 Promise 的 catch 捕获错误码，提示用户重新检测并检查动作合规性。
