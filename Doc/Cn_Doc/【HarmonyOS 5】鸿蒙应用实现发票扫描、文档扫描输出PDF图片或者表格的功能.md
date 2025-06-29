## 【HarmonyOS 5】鸿蒙应用实现发票扫描、文档扫描输出PDF图片或者表格的功能

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_5db2475a.png 'image.png')

**图（1-1）**

HarmonyOS 的 \*\* 文档扫描控件（DocumentScanner）\*\* 是 **AI Vision Kit** 提供的核心场景化视觉服务，旨在帮助开发者快速实现移动端文档数字化功能。

**其核心能力包括**：扫描合同、票据、会议记录并保存为 PDF 分享。拍摄课堂 PPT、书籍章节生成图片存档。快速识别表格数据，减少手动录入成本。

在HarmonyOS 5.0 及以上系统的手机 / 平板（**不支持模拟器**）。

## 二、DocumentScanner都具备什么功能？
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_438a67b5.png 'image.png')

**图（1-2）**

文档扫描控件提供拍摄文档并转换为高清扫描件的服务。

1.  使用手机拍摄文档，即可自动裁剪和优化，并支持**jpeg图片、PDF格式保存和分享**。如图（1-1）所示。
2.  支持拍摄拍照或图片识别表格，生成**表格文档**。如图（1-2）所示。

## 三、DocumentScanner怎么用？

**1. 导入依赖模块：**

```dart
import { DocType, DocumentScanner, DocumentScannerConfig, SaveOption, FilterId, ShootingMode, EditTab, DocumentScannerResultCallback } from "@kit.VisionKit";
```

**2. 配置扫描config对象：**
定义扫描参数（如拍摄模式、识别类型、滤镜等）。

| **名称**                | **类型**         | **可选** | **说明**                                      |
| --------------------- | -------------- | ------ | ------------------------------------------- |
| `maxShotCount`        | `number`       | 是      | 最大拍摄张数，范围`[1,50]`，默认`1`。                    |
| `supportType`         | `DocType[]`    | 否      | 支持的识别类型（文档/表格），默认`[DocType.DOC]`，部分机型仅支持文档。 |
| `isGallerySupported`  | `boolean`      | 是      | 是否支持从图库选图，默认`true`。                         |
| `defaultFilterId`     | `FilterId`     | 是      | 初始滤镜（原图/黑白/增强），默认增强（`STRENGTHEN`）。          |
| `editTabs`            | `EditTab[]`    | 是      | Tab栏功能按钮（旋转/删除/重拍），默认全部显示。                  |
| `defaultShootingMode` | `ShootingMode` | 是      | 拍摄模式（自动/手动），默认手动（`MANUAL`）。                 |
| `isShareable`         | `boolean`      | 是      | 是否支持分享，默认`true`。                            |
| `saveOptions`         | `SaveOption[]` | 是      | 保存格式（JPG/PDF/EXCEL），默认`[JPG, EXCEL]`。       |
| `originalUris`        | `string[]`     | 是      | 初始图片URI列表（用于直接跳转编辑页），最大长度50，需符合尺寸规格。        |

```dart
  private docScanConfig = new DocumentScannerConfig()

  setDocScanConfig() {
    this.docScanConfig.supportType = [DocType.DOC, DocType.SHEET]
    this.docScanConfig.isGallerySupported = true
    this.docScanConfig.editTabs = []
    this.docScanConfig.maxShotCount = 3
    this.docScanConfig.defaultFilterId = FilterId.ORIGINAL
    this.docScanConfig.defaultShootingMode = ShootingMode.MANUAL
    this.docScanConfig.isShareable = true
    this.docScanConfig.originalUris = []
  }

```

**3. UI布局中添加DocumentScanner**
将第二步配置创建好的scannerConfig对象进行赋值。
并且处理onResult回调，当扫描处理成功后会返回Uris。

| **参数名**    | **类型**       | **说明**                                                      |
| ---------- | ------------ | ----------------------------------------------------------- |
| `code`     | `number`     | 状态码：<br>`-1`=取消/<br>`200`=成功/<br>`1008601001`=URI无效（5.0.5+） |
| `saveType` | `SaveOption` | 保存格式（JPG/PDF/EXCEL）                                         |
| `uris`     | `string[]`   | 生成的文件URI列表（扫描结果或表格文档）                                       |

```dart
        //文档扫描
        DocumentScanner({
          scannerConfig: this.docScanConfig,
          onResult: (code: number, saveType: SaveOption, uris: string[]) => {
            hilog.info(0x0001, TAG, `result code: ${code}, save: ${saveType}`)
            if (code === -1) {
              this.pathStack?.pop()
            }
            uris.forEach(uriString => {
              hilog.info(0x0001, TAG, `uri: ${uriString}`)
            })
            this.docImageUris = uris
          }
        })
          .size({ width: '100%', height: '100%' })
```

## 源码示例分享
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a5d6543b.png 'image.png')

// MainPage.ets - 扫描入口页面

```dart

import { NavPathStack } from '@ohos.router';
import { DocDemoPage } from './DocDemoPage'; // 引入扫描实现页

@Entry
@Component
struct MainPage {
  // 导航栈管理页面跳转
  private pathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pathStack) {
      Column({ space: 20 }) {
        // 标题
        Text('文档扫描Demo').fontSize(24).fontWeight(500);
        
        // 扫描入口按钮
        Button('开始扫描文档', { type: ButtonType.Capsule, stateEffect: true })
          .width('60%')
          .height(50)
          .onClick(() => {
            // 跳转到扫描页面
            this.pathStack.pushPath({ name: 'documentScanner' });
          });
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%');
    }
	.navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .title('文档扫描示例');
  }
}
```

// DocDemoPage.ets - 扫描功能实现与结果展示

```dart

import { 
  DocType, DocumentScanner, DocumentScannerConfig, 
  SaveOption, FilterId, ShootingMode, EditTab 
} from "@kit.VisionKit";
import { hilog, LogLevel } from '@ohos.hilog'; // 日志工具

const TAG = 'DocScannerDemo'; // 日志标签

@Entry
@Component
export struct DocDemoPage {
  @State scanResults: string[] = []; // 保存扫描结果URI
  private pathStack: NavPathStack | null = null;

  // 扫描配置初始化
  private docScanConfig = new DocumentScannerConfig();

  // 页面加载时配置扫描参数
  aboutToAppear() {
    this.docScanConfig.supportType = [DocType.DOC, DocType.SHEET]; // 支持文档和表格识别
    this.docScanConfig.maxShotCount = 3; // 最多拍摄3张
    this.docScanConfig.isGallerySupported = true; // 允许从图库选图
    this.docScanConfig.defaultFilterId = FilterId.STRENGTHEN; // 默认增强滤镜
    this.docScanConfig.defaultShootingMode = ShootingMode.MANUAL; // 手动拍摄模式
    this.docScanConfig.editTabs = [EditTab.ROTATE_TAB, EditTab.RESHOOT_TAB]; // 显示旋转和重拍按钮
    this.docScanConfig.saveOptions = [SaveOption.JPG, SaveOption.PDF, SaveOption.EXCEL]; // 支持三种保存格式
    this.docScanConfig.isShareable = true; // 开启分享功能
  }

  build() {
    NavDestination({ name: 'documentScanner' }) {
      Stack() {
        // 扫描结果展示区域
        Column() {
          if (this.scanResults.length > 0) {
            Text('扫描结果').fontSize(18).fontWeight(500).margin({ top: 20 });
            Grid() {
              ForEach(this.scanResults, (uri, index) => {
                // 展示缩略图，点击可预览（示例中简化为日志输出）
                Image(uri)
                  .objectFit(ImageFit.Contain)
                  .width(150)
                  .height(150)
                  .margin(10)
                  .onClick(() => hilog.info(LogLevel.INFO, TAG, `预览图片：${uri}`));
              })
              .columnsTemplate('1fr 1fr') // 两行布局
              .rowGap(10)
              .columnGap(10);
          }
        }
        .width('100%')
        .padding(20);

        // 文档扫描控件主体
        DocumentScanner({
          scannerConfig: this.docScanConfig,
          onResult: (code: number, saveType: SaveOption, uris: string[]) => {
            hilog.info(LogLevel.INFO, TAG, `扫描结果：code=${code}, 格式=${SaveOption[saveType]}`);
            switch (code) {
              case 200: // 成功
                this.scanResults = uris; // 更新结果列表
                hilog.info(LogLevel.INFO, TAG, `保存路径：${uris.join(', ')}`);
                break;
              case -1: // 用户取消
                this.pathStack.pop(); // 返回上一页
                break;
              case 1008601001: // URI无效（5.0.5+支持）
                hilog.error(LogLevel.ERROR, TAG, '传入的图片规格不符合要求');
                break;
            }
          }
        })
        .size({ width: '100%', height: '100%' })
        .margin({ top: 80 }); // 留出结果展示区域空间
      }
      .width('100%')
      .height('100%')
      .hideTitleBar(true); // 隐藏导航栏
      .onReady((context: NavDestinationContext)=>{
      		this.pathStack = context?.pathStack;
    	})
  }
}
```

#### **注意**

**originalUris图片**

*   单边长度：224px ≤ 长/宽 ≤ 8000px。
*   宽高乘积：≤ 6000×8000 px²。
*   宽高比：≤ 3（即最长边/最短边 ≤ 3）。
