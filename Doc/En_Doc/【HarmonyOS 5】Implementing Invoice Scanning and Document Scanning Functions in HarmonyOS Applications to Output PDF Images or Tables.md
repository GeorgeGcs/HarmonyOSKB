## 【HarmonyOS 5】Implementing Invoice Scanning and Document Scanning Functions in HarmonyOS Applications to Output PDF Images or Tables  

\## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Preface  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_5db2475a.png 'image.png')  

**Figure (1-1)**  

HarmonyOS's **DocumentScanner Control** is a core scenario-based visual service provided by the **AI Vision Kit**, designed to help developers quickly implement mobile document digitization.  

**Key Capabilities:**  
- Scan contracts, invoices, meeting notes, and save as PDFs for sharing.  
- Capture classroom PPTs or book chapters as images for archiving.  
- Quickly recognize table data to reduce manual entry costs.  

**Supported Devices:**  
Phones/tablets running HarmonyOS 5.0 or higher (**emulators not supported**).  


### 二、What Functions Does DocumentScanner Provide?  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_438a67b5.png 'image.png')  

**Figure (1-2)**  

The DocumentScanner control enables shooting documents and converting them into high-definition scans:  

1. **Document Scanning:**  
   - Automatically crops and enhances photos taken with the device camera.  
   - Supports saving and sharing in **JPEG image** or **PDF format** (see Figure 1-1).  

2. **Table Recognition:**  
   - Captures photos or recognizes images containing tables.  
   - Generates **editable table documents** (see Figure 1-2).  


### 三、How to Use DocumentScanner?  

#### 1. Import Dependencies:  
```dart  
import { DocType, DocumentScanner, DocumentScannerConfig, SaveOption, FilterId, ShootingMode, EditTab, DocumentScannerResultCallback } from "@kit.VisionKit";  
```  

#### 2. Configure the Scan Configuration Object:  
Define scan parameters (e.g., shooting mode, recognition type, filters).  

| **Parameter**           | **Type**         | **Optional** | **Description**                                                                 |  
|------------------------|------------------|--------------|-----------------------------------------------------------------------------|  
| `maxShotCount`         | `number`         | Yes          | Maximum number of photos (range: `[1,50]`, default: `1`).                  |  
| `supportType`          | `DocType[]`      | No           | Supported recognition types (document/table, default: `[DocType.DOC]`; some devices only support documents). |  
| `isGallerySupported`   | `boolean`        | Yes          | Enable gallery selection (default: `true`).                                |  
| `defaultFilterId`      | `FilterId`       | Yes          | Initial filter (original/black-white/enhanced, default: `STRENGTHEN`).       |  
| `editTabs`             | `EditTab[]`      | Yes          | Edit function buttons (rotate/delete/reshoot, default: all displayed).               |  
| `defaultShootingMode`  | `ShootingMode`   | Yes          | Shooting mode (auto/manual, default: `MANUAL`).                          |  
| `isShareable`          | `boolean`        | Yes          | Enable sharing (default: `true`).                                     |  
| `saveOptions`          | `SaveOption[]`   | Yes          | Save formats (JPG/PDF/EXCEL, default: `[JPG, EXCEL]`).                   |  
| `originalUris`         | `string[]`       | Yes          | Initial image URIs (for directly jumping to the edit page, max length 50, must meet size specifications). |  

```dart  
private docScanConfig = new DocumentScannerConfig();  

setDocScanConfig() {  
  this.docScanConfig.supportType = [DocType.DOC, DocType.SHEET];  
  this.docScanConfig.isGallerySupported = true;  
  this.docScanConfig.editTabs = [];  
  this.docScanConfig.maxShotCount = 3;  
  this.docScanConfig.defaultFilterId = FilterId.ORIGINAL;  
  this.docScanConfig.defaultShootingMode = ShootingMode.MANUAL;  
  this.docScanConfig.isShareable = true;  
  this.docScanConfig.originalUris = [];  
}  
```  

#### 3. Add DocumentScanner to the UI Layout:  
Assign the configured `scannerConfig` and handle the `onResult` callback, which returns URIs upon successful scanning.  

| **Parameter** | **Type**       | **Description**                                                                 |  
|---------------|----------------|-----------------------------------------------------------------------------|  
| `code`        | `number`       | Status codes:<br>`-1`=Cancelled/<br>`200`=Success/<br>`1008601001`=Invalid URI (5.0.5+). |  
| `saveType`    | `SaveOption`   | Save format (JPG/PDF/EXCEL).                                                   |  
| `uris`        | `string[]`     | Generated file URIs (scanned results or table documents).                          |  

```dart  
// Document Scanner  
DocumentScanner({  
  scannerConfig: this.docScanConfig,  
  onResult: (code: number, saveType: SaveOption, uris: string[]) => {  
    hilog.info(0x0001, TAG, `result code: ${code}, save: ${saveType}`);  
    if (code === -1) {  
      this.pathStack?.pop();  
    }  
    uris.forEach(uriString => {  
      hilog.info(0x0001, TAG, `uri: ${uriString}`);  
    });  
    this.docImageUris = uris;  
  }  
})  
.size({ width: '100%', height: '100%' });  
```  


### Source Code Example  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a5d6543b.png 'image.png')  

#### MainPage.ets - Scan Entry Page  
```dart  
import { NavPathStack } from '@ohos.router';  
import { DocDemoPage } from './DocDemoPage'; // Import scan implementation page  

@Entry  
@Component  
struct MainPage {  
  // Navigation stack for page management  
  private pathStack: NavPathStack = new NavPathStack();  

  build() {  
    Navigation(this.pathStack) {  
      Column({ space: 20 }) {  
        // Title  
        Text('Document Scanning Demo').fontSize(24).fontWeight(500);  

        // Scan button  
        Button('Start Document Scanning', { type: ButtonType.Capsule, stateEffect: true })  
          .width('60%')  
          .height(50)  
          .onClick(() => {  
            // Navigate to scan page  
            this.pathStack.pushPath({ name: 'documentScanner' });  
          });  
      }  
      .justifyContent(FlexAlign.Center)  
      .width('100%')  
      .height('100%');  
    }  
    .navDestination(this.PageMap)  
    .mode(NavigationMode.Stack)  
    .title('Document Scanning Example');  
  }  
}  
```  

#### DocDemoPage.ets - Scan Function Implementation and Result Display  
```dart  
import {  
  DocType, DocumentScanner, DocumentScannerConfig,  
  SaveOption, FilterId, ShootingMode, EditTab  
} from "@kit.VisionKit";  
import { hilog, LogLevel } from '@ohos.hilog'; // Logging utility  

const TAG = 'DocScannerDemo'; // Log tag  

@Entry  
@Component  
export struct DocDemoPage {  
  @State scanResults: string[] = []; // Store scan result URIs  
  private pathStack: NavPathStack | null = null;  

  // Scan configuration  
  private docScanConfig = new DocumentScannerConfig();  

  // Initialize scan parameters when the page loads  
  aboutToAppear() {  
    this.docScanConfig.supportType = [DocType.DOC, DocType.SHEET]; // Support document and table recognition  
    this.docScanConfig.maxShotCount = 3; // Maximum 3 photos  
    this.docScanConfig.isGallerySupported = true; // Allow gallery selection  
    this.docScanConfig.defaultFilterId = FilterId.STRENGTHEN; // Default enhance filter  
    this.docScanConfig.defaultShootingMode = ShootingMode.MANUAL; // Manual shooting mode  
    this.docScanConfig.editTabs = [EditTab.ROTATE_TAB, EditTab.RESHOOT_TAB]; // Show rotate and reshoot buttons  
    this.docScanConfig.saveOptions = [SaveOption.JPG, SaveOption.PDF, SaveOption.EXCEL]; // Support three save formats  
    this.docScanConfig.isShareable = true; // Enable sharing  
  }  

  build() {  
    NavDestination({ name: 'documentScanner' }) {  
      Stack() {  
        // Scan results display area  
        Column() {  
          if (this.scanResults.length > 0) {  
            Text('Scan Results').fontSize(18).fontWeight(500).margin({ top: 20 });  
            Grid() {  
              ForEach(this.scanResults, (uri, index) => {  
                // Display thumbnails (click to preview; simplified to log output in this example)  
                Image(uri)  
                  .objectFit(ImageFit.Contain)  
                  .width(150)  
                  .height(150)  
                  .margin(10)  
                  .onClick(() => hilog.info(LogLevel.INFO, TAG, `Preview Image: ${uri}`));  
              })  
              .columnsTemplate('1fr 1fr') // Two-column layout  
              .rowGap(10)  
              .columnGap(10);  
          }  
        }  
        .width('100%')  
        .padding(20);  

        // Document scanner control  
        DocumentScanner({  
          scannerConfig: this.docScanConfig,  
          onResult: (code: number, saveType: SaveOption, uris: string[]) => {  
            hilog.info(LogLevel.INFO, TAG, `Scan Result: code=${code}, format=${SaveOption[saveType]}`);  
            switch (code) {  
              case 200: // Success  
                this.scanResults = uris; // Update results list  
                hilog.info(LogLevel.INFO, TAG, `Save Paths: ${uris.join(', ')}`);  
                break;  
              case -1: // User cancelled  
                this.pathStack.pop(); // Return to previous page  
                break;  
              case 1008601001: // Invalid URI (supported in 5.0.5+)  
                hilog.error(LogLevel.ERROR, TAG, 'Incoming image specifications do not meet requirements');  
                break;  
            }  
          }  
        })  
        .size({ width: '100%', height: '100%' })  
        .margin({ top: 80 }); // Leave space for results display  
      }  
      .width('100%')  
      .height('100%')  
      .hideTitleBar(true); // Hide navigation bar  
      .onReady((context: NavDestinationContext) => {  
        this.pathStack = context?.pathStack;  
      });  
    }  
  }  
}  
```  


### **Notes**  
#### Requirements for `originalUris` Images:  
- **Single side length**: 224px ≤ length/width ≤ 8000px.  
- **Area**: ≤ 6000×8000 px².  
- **Aspect ratio**: ≤ 3 (i.e., longest side/shortest side ≤ 3).