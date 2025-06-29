## 【HarmonyOS 5】Detailed Explanation of Laya Game Building and Publishing for HarmonyOS  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  

## I. Preface  

LayaAir engine is one of the most powerful cross-platform engines in China. When H5 mini-games became popular, Tencent invested in Laya. When I was working in a game company in 2017, I developed H5 mini-games using Laya, and I still miss the time spent solving problems with Laya colleagues.  

From using TypeScript as the development language to interface component encapsulation and cross-platform publishing, Laya's journey is similar to that of HarmonyOS, with many design concepts closely aligned. As an open-source foundation with customized commercialization for cross-platform development, Laya holds a significant market share in the H5 engine sector.  

Founded in 2014, Layabox released its open-source engine product LayaAir in 2016, which now has over a million global developers, making it a leading 3D engine in the HTML5 and mini-game fields.  

In addition to H5 3D mini-games, Laya can also develop H5 applications or H5 2D mini-games through its 2D engine.  

As a new operating system, HarmonyOS can greatly enrich its ecosystem with the support of H5 mini-games and applications. Moreover, Laya's simple development and entry-level learning curve offer broad future prospects for mini-game and H5 developers in the HarmonyOS market.  

This article focuses on Laya's background, development environment installation, and HarmonyOS build and release processes.  


## II. LayaAir Environment Installation  

[Official environment setup article, click to jump](https://www.layaair.com/#/doc)  

LayaAir consists of two parts: the game engine and coding tools. Initially, it used a self-developed IDE, but later switched the coding environment to VSCode.  

Therefore, to set up the Laya environment, we first need to install [LayaAirIDE](https://layaair.com/#/engineDownload) and [VSCode](https://code.visualstudio.com/Download).  

Since Laya uses TypeScript as the programming language, we need to install the Node development environment and TSC (TypeScript Compiler) to convert TS code into JS code. Ultimately, Laya's code is in JavaScript.  

```bash
npm install -g typescript
```  

A browser is required for debugging (optional). For Windows systems, the built-in Edge browser can be used, or [Google Chrome](https://www.google.cn/intl/zh-CN/chrome/) can be installed.  

The following image shows the effect after creating and opening a 2D sample project using LayaAirIDE:  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_f4dc3d29.png 'image.png')  


## III. HarmonyOS Build and Release  

1. Click **File > Build & Release**, select **HarmonyOS NEXT**, make no changes to the right-side settings, and click **Build HarmonyOS NEXT**.  
   ![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a05f2929.png 'image.png')  

2. For the rendering mode, considering that HarmonyOS has a separate rendering process for the web, select **WebGL** instead of **OpenGL**.  
   ![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_de20ef23.png 'image.png')  

3. After clicking **Build & Release**, wait for the progress bar to complete (this may take some time).  
   ![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_f2f49f3b.png 'image.png')  

4. Once the progress bar is complete, the HarmonyOS project code will appear. Click the arrow to navigate to the source project, then use DevEco Studio to automatically sign the HarmonyOS project and run the Laya mini-game.  
   ![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a8e2aeb5.png 'image.png')  

The above image is a static screenshot of the Laya 2D sample project running on a HarmonyOS device. Currently, the automatically built HarmonyOS SDK uses API 11. Attempts to modify it to API 2 or API 17 result in errors, so we need to wait for official updates. The overall effect is promising.  

From the built HarmonyOS project's Index entry file, we can see that official collaboration with Laya has introduced many supporting custom Component components, such as `LayaEditBox`, `LayaWebview`, and `TextInputDialog`.  

```typescript
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