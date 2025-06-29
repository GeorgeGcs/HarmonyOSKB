## 【HarmonyOS 5】金融应用开发鸿蒙组件实践

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、鸿蒙生态观察
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_25448501.png 'image.png')

**2024 年 1 月 18 日：**
发布 原生鸿蒙操作系统星河版，面向开发者开放申请，余承东宣布鸿蒙生态设备数达 8 亿台；建设银行、邮储银行等完成鸿蒙原生应用 Beta 版本开发。

**2024 年 10 月 22 日：**
HarmonyOS NEXT（鸿蒙 5.0） 发布，这是中国首个全栈自研操作系统，彻底脱离安卓，流畅度显著提升，标志中国在操作系统领域取得突破性进展。11 月 26 日，华为 Mate70 系列与 Mate X6 发布，到手即可升级原生鸿蒙系统。

**2025 年 3 月：**
原生鸿蒙正式版发布，HarmonyOS 5，发布Pura X 首款全面搭载 HarmonyOS 5 的阔折叠手机。

**2025 年 5 月：**
鸿蒙 PC 发布，从内核重构操作系统，由鸿蒙底座、生态和体验三大核心板块组成，实现国产操作系统在 PC 领域的重要突破。

根据 2025 年 5 月的信息，鸿蒙系统的设备装机量已超过 10 亿台。
国内鸿蒙化应用越来越多，外资例如汇丰，渣打今年都已启动鸿蒙项目。
从 BOSS 直聘、猎聘等平台信息来看，鸿蒙相关岗位丰富，薪资可观。

## 二、鸿蒙特性助力金融应用

**TEE**
Trusted Execution Environment，可信执行环境。
在主处理器中的一个安全区域，确保各种敏感数据在一个可信环境中被存储、处理和受到保护。

TEE为授权安全软件，也称为“可信应用”提供一个安全的执行环境，通过实施保护、保密性、完整性和数据访问权限确保端到端的安全。

**人脸活体检测**
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_fb784e96.png 'image.png')

华为提供活体检测安全组件，方便三方应用集成。

```dart
// 导入人脸识别功能模块
import { interactiveLiveness } from '@kit.VisionKit';
// 导入业务错误处理模块
import { BusinessError } from '@kit.BasicServicesKit';
// 导入日志记录模块
import { hilog } from '@kit.PerformanceAnalysisKit';
// 导入权限控制相关模块
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
// 导入提示框组件
import { promptAction } from '@kit.ArkUI';
// 导入应用包管理模块
import { bundleManager } from '@kit.MDMKit';

/**
 * 人脸活体检测页面组件
 * 提供相机权限申请和交互式人脸活体检测功能
 */
@Entry
@Component
struct FaceLivenessPage {

  // 记录用户是否已授予相机权限的状态
  @State userGrant: boolean = false;

  /**
   * 向用户申请相机权限
   * @returns 权限申请结果数组，0表示授权成功
   */
  private async reqPermissionsFromUser(): Promise<number[]> {
    // 获取当前UI上下文
    let context = getContext() as common.UIAbilityContext;
    // 创建权限管理实例
    let atManager = abilityAccessCtrl.createAtManager();
    // 发起相机权限申请
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
    return grantStatus.authResults;
  }

  /**
   * 处理相机权限申请流程
   */
  private async requestCameraPermission() {
    // 获取权限申请结果
    let grantStatus = await this.reqPermissionsFromUser();
    // 遍历结果检查是否授权成功
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // 授权成功，更新状态并提示用户
        this.userGrant = true;
        promptAction.showToast({
          message: "授权成功!"
        });
      }
    }
  }

  /**
   * 权限申请按钮点击事件处理函数
   */
  onClickPermission = () => {
    this.requestCameraPermission();
  }

  /**
   * 人脸活体检测按钮点击事件处理函数
   */
  onClickFaceLiv = () => {
    // 检查是否有相机权限
    if (!this.userGrant) {
      promptAction.showToast({
        message: "无相机权限！"
      });
      return;
    }

    // 配置活体检测模式为交互式
    let isSilentMode = "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode;
    // 配置需要完成的动作数量为3个
    let actionsNum = 3 as interactiveLiveness.ActionsNumber;
    // 配置活体检测参数
    let routerOptions: interactiveLiveness.InteractiveLivenessConfig = {
      actionsNum: actionsNum,         // 动作数量
      isSilentMode: isSilentMode,     // 检测模式
      routeMode: "back" as interactiveLiveness.RouteRedirectionMode // 检测完成后返回方式
    };
    
    // 启动人脸活体检测
    interactiveLiveness.startLivenessDetection(routerOptions, (err: BusinessError, result: interactiveLiveness.InteractiveLivenessResult | undefined) => {
      if (err.code !== 0 && !result) {
        // 检测失败，记录错误日志
        hilog.error(0x0001, "LivenessCollectionIndex", `Failed to detect. Code：${err.code}，message：${err.message}`);
        return;
      }
      // 检测成功，记录结果日志并提示用户
      hilog.info(0x0001, 'LivenessCollectionIndex', `Succeeded in detecting result：${JSON.stringify(result)}`);
      promptAction.showToast({
        message: JSON.stringify(result)
      });
    });
  }

  /**
   * 定义按钮通用样式
   */
  @Styles commonText() {
    .width(px2vp(600))      // 设置宽度
    .height(px2vp(120))     // 设置高度
    .backgroundColor(Color.Blue) // 设置背景色
    .borderRadius(15)       // 设置圆角
  }

  /**
   * 组件UI构建函数
   */
  build() {
    Column() {
      // 权限申请按钮
      Text("请求相机权限")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()           // 应用通用样式
        .onClick(this.onClickPermission) // 绑定点击事件
        .margin({
          bottom: px2vp(60)     // 设置底部边距
        })

      // 人脸检测按钮
      Text("人脸活体检测")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()           // 应用通用样式
        .onClick(this.onClickFaceLiv)   // 绑定点击事件

    }
    .height('100%')           // 设置高度为全屏
    .width('100%')            // 设置宽度为全屏
    .justifyContent(FlexAlign.Center) // 垂直居中对齐
    .backgroundColor(Color.Black)     // 设置背景色
  }
}
```

**图片筛选**
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_3d157fc7.png 'image.png')

隐私安全提升，比业内Android和IOS更加保护用户隐私与安全。

```dart
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 相册图片选择
 */
@Entry
@Component
struct AlbumPage {

  private TAG: string = "AlbumPage";

  onClickSelectPhoto = ()=>{
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // 设置筛选过滤条件
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      // 选择用户选择数量
      PhotoSelectOptions.maxSelectNumber = 1;
      // 添加图片目标筛选类型
      let recommendOptions: photoAccessHelper.RecommendationOptions = {
        recommendationType: photoAccessHelper.RecommendationType.ID_CARD | photoAccessHelper.RecommendationType.BANK_CARD | photoAccessHelper.RecommendationType.QR_CODE
      }
      PhotoSelectOptions.recommendationOptions = recommendOptions;
      // 实例化图片选择器
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      // 唤起安全相册组件
      photoPicker.select(PhotoSelectOptions, (err: BusinessError, PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (err) {
          console.error(this.TAG, "onClickSelectPhoto photoPicker.select error:" + JSON.stringify(err));
          return;
        }
        // 用户选择确认后，会回调到这里。
        console.info(this.TAG, "onClickSelectPhoto photoPicker.select successfully:" + JSON.stringify(PhotoSelectResult));
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(this.TAG, "onClickSelectPhoto photoPicker.select catch failed:" + JSON.stringify(err));
    }
  }

  build() {
    Row(){
      Button('点击唤起相册选择')
        .onClick(this.onClickSelectPhoto)
    }
    .justifyContent(FlexAlign.Center)
    .size({
      width: "100%",
      height: "100%"
    })
  }
}

```

**扫一扫**
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_18ebba9c.png 'image.png')

系统提供安全扫码控件，简单几句代码即可集成扫码界面与解析。
扫码界面内完整集成图库选取，闪光灯补光，图片扫码，实时扫码。

```dart
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


```

## 三、开发问题定位和解决方案分享

## 鸿蒙开发经验分享

**1、如何高效的学习鸿蒙？**
所谓知其然，才能知其所以然，先进行鸿蒙整体概念的入门和学习，了解鸿蒙相关的专有名词是非常重要。

**1.1、专有名词介绍：**
**鸿蒙**
特指HarmonyOS与OpenHarmony，前者是商业鸿蒙，是华为公司使用和维护的系统。后者是HW开源给开放原子基金协会的系统，任何人遵守开源协议，都可以使用和改造的系统。

HarmonyOS虽然基座是OpenHarmony，但是上层功能和使用差异也还是有的。两者虽然近似，但是并非一个东西。
两者区别详情参见：OpenHarmony和HarmonyOS区别与共性

**鸿蒙相关公司**
目前使用和维护开源鸿蒙OpenHarmony成长的公司有很多，例如深开鸿，润开鸿，鸿湖万联，开鸿智谷，九联开鸿等。开源鸿蒙的现在使用方向很多，例如电网，工业，物联，矿产等等。
商业鸿蒙，是华为公司自己进行迭代和维护与使用。

**鸿蒙北向和南向**
特指，北向应用开发，南向设备开发。设备开发多是基于开源鸿蒙。北向分OpenHarmony应用开发和HarmonyOS应用开发。

**鸿蒙双框架和单框架**
在 HarmonyOS NEXT 发布之前，华为手机运行的是 “双框架” 系统。其架构逻辑是鸿蒙和安卓框架共同存在，但底层基础服务仍以鸿蒙为核心，也被称为 “杂交系统”。单框架：以 HarmonyOS NEXT 为代表，是纯血鸿蒙系统，底座全线自研，去掉了传统的安卓开放源代码项目（AOSP）代码，只支持鸿蒙内核及鸿蒙系统的应用

**鸿蒙HDE**
华为开发者专家（HUAWEI DEVELOPER EXPERTS），经过华为官方认证。他们是华为开放能力的实践领袖，肩负着技术布道、知识赋能等责任，会在各大技术社区解答用户有关华为开发能力的相关问题，定期在社交媒体上进行线上分享，也常在线下以讲师身份分享关于华为最新技术趋势讲解。

**2、建立鸿蒙知识框架**
我向来建议大家，建立鸿蒙的学习框架，首先了解鸿蒙是什么，能做什么，都有什么功能。新特性是什么？与Android和IOS的区别在哪？

只有充分解构学习目标之后，才能更有动力，更有方向的去学习鸿蒙。

综上所述，现在我们来看官方的文档，就明白如何去学习使用了。

版本说明，是鸿蒙迭代版本的详细说明，从这里我们可以了解到，鸿蒙最新的技术迭代方向，和某些老技术废弃的原因。及时调整自己的学习方向和开发方案。

指南作为开发功能的概述，会有完整的demo代码片段，当你需要更详细的接口文档时，就需要点击API参考进行查看。

最佳实践和FAQ作为开发方案的技术范本和常规问题规避，可以理解为踩坑文档。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_2f3ed199.png 'image.png')

**鸿蒙快速迭代如何不掉队？**
因为鸿蒙在快速成长，API迭代速度很快。很多组件，路由管理，状态装饰器都在快速进化中。有的就被废弃了，需要快速学习新的方案。所以对持续学习的要求很高。

建议进行知识框架的搭建，例如通过思维导图，个人知识库，定期学习官方文档进行知识的迭代。在工作开发中，经常自我总结，归纳鸿蒙相关的技能和解决方案。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_11870ace.png 'image.png')

