## 【HarmonyOS 5】Laya游戏如何鸿蒙构建发布详解

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言

LayaAir引擎是国内最强大的全平台引擎之一，当年H5小游戏火的时候，腾讯入股了腊鸭。我还在游戏公司的时候，17年曾经开发使用腊鸭的H5小游戏，很怀念当年和腊鸭同事一起解决问题的时光。

从使用TypeScript开发语言，到界面组件封装，再到全平台发布，腊鸭走过的路与鸿蒙很相似。很多设计理念也很贴近。作为基础开源，定制商业化的全平台引擎，腊鸭在H5引擎市场上的占有率相当高。

Layabox成立于2014年，旗下的开源引擎产品LayaAir发布于2016年，已拥有超百万的全球开发者，是HTML5与小游戏领域的3D龙头引擎。

除了H5 3D小游戏，腊鸭也可以通过2D引擎开发H5应用或者H5 2D小游戏。

鸿蒙作为一个崭新的操作系统，H5小游戏和H5应用的助力可以极大丰富其生态。并且腊鸭的开发和学习入门上手较为简单，也可以为小游戏和H5开发小伙伴，在鸿蒙市场，带来广阔的未来前景。

今天本文主要讲解腊鸭的背景，腊鸭开发环境安装和鸿蒙构建发布。

## 二、LayaAir环境安装

[官方环境搭建文章，点击跳转](https://www.layaair.com/#/doc)

LayaAir分为游戏引擎和编码工具两个部分。最早当年是自研的IDE一起负责了，后来将编码环境切换为了VSCode。

所以现在我们的Laya环境首先需要安装[LayaAirIDE](https://layaair.com/#/engineDownload)和[VSCode](https://code.visualstudio.com/Download)。

之后因为Laya开发的编程语言是TypeScript，所以需要安装Node开发环境，并且要install TSC，用于将TS代码转化为JS代码。最后Laya的代码都是js代码。

```dart
npm install -g typescript

```

浏览器是方便调试，可选择安装。若是Window系统，使用自带的Edge浏览也可。或者安装[GoogleChrome](https://www.google.cn/intl/zh-CN/chrome/)

下图是安装完LayaAirIDE之后，选择2D示例项目创建打开后的效果：
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_f4dc3d29.png 'image.png')
**

## 三、鸿蒙构建发布

点击文件-构建发布，选择鸿蒙NEXT，在右侧基本无需修改，点击下方的构建鸿蒙NEXT即可。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a05f2929.png 'image.png')

渲染模式这里，我考虑到鸿蒙对于web是有单独的渲染进程，所以没有选择OpenGL。选择的WebGL。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_de20ef23.png 'image.png')

点击构建发布后，等待进度条完成，时间较长。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_f2f49f3b.png 'image.png')

进度条完成后，如上图所示，会出现鸿蒙项目代码，点击箭头位置就可以到源码项目处。再使用DevEco Studio进行鸿蒙项目自动签名，运行就可运行Laya小游戏。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a8e2aeb5.png 'image.png')

上图就是Laya的2D示例项目在鸿蒙手机中运行效果的静态截图。目前自动构建的鸿蒙SDK还是API11，我尝试动手i修改为API2或者API17，项目均会报错。还是等待后续官方升级吧。目前看整体效果还是很不错。

根据构建后的鸿蒙项目，我们通过Index入口文件可以发现，官方和Laya合作，新增了很多配套的自定义Component组件，例如：LayaEditBox，LayaWebview，TextInputDialog。

```dart
import laya from 'liblaya.so'
import { ContextType } from '@ohos/libSysCapabilities'
import { TextInputInfo } from '@ohos/libSysCapabilities/src/main/ets/components/EditBox'
import { TextInputDialogEntity } from '@ohos/libSysCapabilities'
import { WebViewInfo } from '@ohos/libSysCapabilities/src/main/ets/components/webview/WebViewMsg'
import { VideoPlayerInfo } from '@ohos/libSysCapabilities/src/main/ets/components/videoplayer/VideoPlayer'
import { WorkerMsgUtils } from '@ohos/libSysCapabilities/src/main/ets/utils/WorkerMsgUtils'
import { WorkerManager } from '../workers/WorkerManager'
import { LayaEditBox } from '../components/LayaEditBox'
import { LayaWebview } from '../components/LayaWebview'
import { LayaVideoPlayer } from '../components/LayaVideoPlayer'
import { TextInputDialog } from '../components/TextInputDialog'
import { GlobalContext, GlobalContextConstants } from "@ohos/libSysCapabilities"
import { NapiHelper } from "@ohos/libSysCapabilities/src/main/ets/napi/NapiHelper"
import { Dialog } from "@ohos/libSysCapabilities"
import deviceInfo from '@ohos.deviceInfo';
import promptAction from '@ohos.promptAction'
import process from '@ohos.process';
import { LayaHttpClient } from '@ohos/libSysCapabilities/src/main/ets/system/network/LayaHttpClient'

const nativePageLifecycle: laya.CPPFunctions = laya.getContext(ContextType.JSPAGE_LIFECYCLE);
NapiHelper.registerUIFunctions();

let layaWorker = WorkerManager.getInstance().getWorker();
@Entry
@Component
struct Index {
  xcomponentController: XComponentController = new XComponentController();
  // EditBox
  @State editBoxArray: TextInputInfo[] = [];
  private editBoxIndexMap: Map<number, TextInputInfo> = new Map;
  // WebView
  @State webViewArray: WebViewInfo[] = [];
  private webViewIndexMap: Map<number, number> = new Map;
  // videoPlayer
  @State videoPlayerInfoArray: VideoPlayerInfo[] = [];
  private videoPlayerIndexMap: Map<number, VideoPlayerInfo> = new Map;

  // videoPlayer
  @State layaHttpClientArray: LayaHttpClient[] = [];
  private layaHttpClientIndexMap: Map<number, LayaHttpClient> = new Map;

  private pro = new process.ProcessManager();
  private m_nBackPressTime = 0;
  // textInputDialog
  showMessage: TextInputDialogEntity = new TextInputDialogEntity('');
  dialogController: CustomDialogController = new CustomDialogController({
    builder: TextInputDialog({
      showMessage: this.showMessage
    }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    customStyle: true,
  })
  // PanGesture
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Up | PanDirection.Down });

  onPageShow() {
    console.log('[LIFECYCLE-Page] onPageShow');
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_EDIT_BOX_ARRAY, this.editBoxArray);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_EDIT_BOX_INDEX_MAP, this.editBoxIndexMap);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_WORKER, layaWorker);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_WEB_VIEW_ARRAY, this.webViewArray);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_WEB_VIEW_INDEX_MAP, this.webViewIndexMap);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_VIDEO_PLAYER_ARRAY, this.videoPlayerInfoArray);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_VIDEO_PLAYER_INDEX_MAP, this.videoPlayerIndexMap);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_DIALOG_CONTROLLER, this.dialogController);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_SHOW_MESSAGE, this.showMessage);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_HTTP_CLIENT_ARRAY, this.layaHttpClientArray);
    GlobalContext.storeGlobalThis(GlobalContextConstants.LAYA_HTTP_CLIENT_INDEX_MAP, this.layaHttpClientIndexMap);
    nativePageLifecycle.onPageShow();
    Dialog.setTitle(getContext(this).resourceManager.getStringSync($r('app.string.Dialog_Title').id));
  }

  onPageHide() {
    console.log('[LIFECYCLE-Page] onPageHide');
    nativePageLifecycle.onPageHide();
  }

  onBackPress() {
    console.log('[LIFECYCLE-Page] onBackPress');
    layaWorker.postMessage({ type: "exit" });
    let curtm = Date.now();
    let MaxDelay = 3500;
    if (this.m_nBackPressTime == 0 || (this.m_nBackPressTime > 0 && curtm - this.m_nBackPressTime > MaxDelay)) {
      this.m_nBackPressTime = Date.now();
      promptAction.showToast({
        message: $r('app.string.text_backpress_toast'),
        duration: 1000
      });
    } else {
      this.pro.exit(0);
    }
    return true;
  }

  onMouseWheel(eventType: string, scrollY: number) {
    // layaWorker.postMessage({ type: "onMouseWheel", eventType: eventType, scrollY: scrollY });
  }

  build() {
    // Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
    Stack() {
      XComponent({
        id: 'xcomponentId',
        type: 'surface',
        libraryname: 'laya',
        controller: this.xcomponentController
      })
        .focusable(true)
        .gesture(
          PanGesture(this.panOption)
            .onActionStart(() => {
              this.onMouseWheel("actionStart", 0);
            })
            .onActionUpdate((event: GestureEvent) => {
              if (deviceInfo.deviceType === '2in1') {
                this.onMouseWheel("actionUpdate", event.offsetY);
              }
            })
            .onActionEnd(() => {
              this.onMouseWheel("actionEnd", 0);
            })
        )
        .onLoad((context) => {
          console.log('[laya] XComponent.onLoad Callback');
          layaWorker.postMessage({
            type: "abilityContextInit",
            context: GlobalContext.loadGlobalThis(GlobalContextConstants.LAYA_ABILITY_CONTEXT)
          });
          layaWorker.postMessage({ type: "onXCLoad", data: "XComponent" });
          layaWorker.onmessage = WorkerMsgUtils.recvWorkerThreadMessage;
        })
        .onDestroy(() => {
        })
      ForEach(this.editBoxArray, (item: TextInputInfo) => {
        LayaEditBox({ textInputInfo: item });
      }, (item: TextInputInfo) => item.viewTag.toString())

      ForEach(this.webViewArray, (item: WebViewInfo) => {
        LayaWebview({ viewInfo: item })
      }, (item: WebViewInfo) => item.uniqueId.toString())

      ForEach(this.videoPlayerInfoArray, (item: VideoPlayerInfo) => {
        LayaVideoPlayer({ videoPlayerInfo: item })
      }, (item: VideoPlayerInfo) => item.viewTag.toString())

    }
    .width('100%')
    .height('100%')
  }
}

```
