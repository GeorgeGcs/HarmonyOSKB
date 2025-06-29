# 【HarmonyOS 5】Practical Implementation of HarmonyOS Components for Financial Applications  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


## 一、Observation of the HarmonyOS Ecosystem  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_25448501.png 'image.png')  

**January 18, 2024:**  
The native HarmonyOS Galaxy Edition was released, open for developers to apply. Yu Chengdong announced that the number of HarmonyOS ecosystem devices reached 800 million; China Construction Bank, Postal Savings Bank, etc., completed the development of the Beta version of native HarmonyOS applications.  

**October 22, 2024:**  
HarmonyOS NEXT (HarmonyOS 5.0) was released as China's first fully self-developed operating system, completely脱离 (detached from) Android, with significantly improved fluency, marking a breakthrough in China's operating system field. On November 26, the Huawei Mate70 series and Mate X6 were released, which could be upgraded to the native HarmonyOS system upon purchase.  

**March 2025:**  
The official version of native HarmonyOS, HarmonyOS 5, was released, along with the Pura X, the first foldable phone fully equipped with HarmonyOS 5.  

**May 2025:**  
HarmonyOS for PC was released,重构 (reconstructed) from the kernel. It consists of three core components: the HarmonyOS base, ecosystem, and experience, achieving an important breakthrough for domestic operating systems in the PC field.  

According to information in May 2025, the number of devices with the HarmonyOS system has exceeded 1 billion.  
More and more domestic applications are being HarmonyOS-ified, and foreign institutions such as HSBC and Standard Chartered have launched HarmonyOS projects this year.  
According to information on platforms like BOSS直聘 and Liepin, HarmonyOS-related positions are abundant and well-paid.  


## 二、HarmonyOS Features Empowering Financial Applications  

### Trusted Execution Environment (TEE)  
TEE is a secure area in the main processor that ensures various sensitive data is stored, processed, and protected in a trusted environment.  

TEE provides a secure execution environment for authorized security software, also known as "trusted applications," ensuring end-to-end security through protection, confidentiality, integrity, and data access control.  


### Face Liveness Detection  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_fb784e96.png 'image.png')  

Huawei provides a liveness detection security component for easy integration by third-party applications.  
```dart
// Import face recognition function module
import { interactiveLiveness } from '@kit.VisionKit';
// Import business error handling module
import { BusinessError } from '@kit.BasicServicesKit';
// Import logging module
import { hilog } from '@kit.PerformanceAnalysisKit';
// Import permission control related modules
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
// Import prompt box component
import { promptAction } from '@kit.ArkUI';
// Import application package management module
import { bundleManager } from '@kit.MDMKit';

/**
 * Face liveness detection page component
 * Provides camera permission application and interactive face liveness detection functions
 */
@Entry
@Component
struct FaceLivenessPage {

  // Record whether the user has granted camera permission
  @State userGrant: boolean = false;

  /**
   * Apply for camera permission from the user
   * @returns Permission application result array, 0 indicates successful authorization
   */
  private async reqPermissionsFromUser(): Promise<number[]> {
    // Get the current UI context
    let context = getContext() as common.UIAbilityContext;
    // Create a permission management instance
    let atManager = abilityAccessCtrl.createAtManager();
    // Initiate camera permission application
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
    return grantStatus.authResults;
  }

  /**
   * Process the camera permission application flow
   */
  private async requestCameraPermission() {
    // Get the permission application result
    let grantStatus = await this.reqPermissionsFromUser();
    // Iterate through the results to check if authorization was successful
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // Authorization successful, update the status and prompt the user
        this.userGrant = true;
        promptAction.showToast({
          message: "Authorization successful!"
        });
      }
    }
  }

  /**
   * Click event handler for the permission application button
   */
  onClickPermission = () => {
    this.requestCameraPermission();
  }

  /**
   * Click event handler for the face liveness detection button
   */
  onClickFaceLiv = () => {
    // Check if there is camera permission
    if (!this.userGrant) {
      promptAction.showToast({
        message: "No camera permission!"
      });
      return;
    }

    // Configure the liveness detection mode as interactive
    let isSilentMode = "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode;
    // Configure the number of actions to be completed as 3
    let actionsNum = 3 as interactiveLiveness.ActionsNumber;
    // Configure liveness detection parameters
    let routerOptions: interactiveLiveness.InteractiveLivenessConfig = {
      actionsNum: actionsNum,         // Number of actions
      isSilentMode: isSilentMode,     // Detection mode
      routeMode: "back" as interactiveLiveness.RouteRedirectionMode // Return method after detection
    };
    
    // Start face liveness detection
    interactiveLiveness.startLivenessDetection(routerOptions, (err: BusinessError, result: interactiveLiveness.InteractiveLivenessResult | undefined) => {
      if (err.code !== 0 && !result) {
        // Detection failed, record the error log
        hilog.error(0x0001, "LivenessCollectionIndex", `Detection failed. Code：${err.code}，message：${err.message}`);
        return;
      }
      // Detection successful, record the result log and prompt the user
      hilog.info(0x0001, 'LivenessCollectionIndex', `Detection succeeded, result：${JSON.stringify(result)}`);
      promptAction.showToast({
        message: JSON.stringify(result)
      });
    });
  }

  /**
   * Define common button styles
   */
  @Styles commonText() {
    .width(px2vp(600))      // Set width
    .height(px2vp(120))     // Set height
    .backgroundColor(Color.Blue) // Set background color
    .borderRadius(15)       // Set rounded corners
  }

  /**
   * Component UI construction function
   */
  build() {
    Column() {
      // Permission application button
      Text("Request Camera Permission")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()           // Apply common style
        .onClick(this.onClickPermission) // Bind click event
        .margin({
          bottom: px2vp(60)     // Set bottom margin
        })

      // Face detection button
      Text("Face Liveness Detection")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()           // Apply common style
        .onClick(this.onClickFaceLiv)   // Bind click event

    }
    .height('100%')           // Set height to full screen
    .width('100%')            // Set width to full screen
    .justifyContent(FlexAlign.Center) // Vertically center alignment
    .backgroundColor(Color.Black)     // Set background color
  }
}
```  

### Image Screening  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_3d157fc7.png 'image.png')  

Privacy and security are enhanced, providing better protection for user privacy and security than industry-standard Android and iOS.  
```dart
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * Album image selection
 */
@Entry
@Component
struct AlbumPage {

  private TAG: string = "AlbumPage";

  onClickSelectPhoto = ()=>{
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // Set filtering conditions
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      // Set the number of selections
      PhotoSelectOptions.maxSelectNumber = 1;
      // Add target image filtering types
      let recommendOptions: photoAccessHelper.RecommendationOptions = {
        recommendationType: photoAccessHelper.RecommendationType.ID_CARD | photoAccessHelper.RecommendationType.BANK_CARD | photoAccessHelper.RecommendationType.QR_CODE
      }
      PhotoSelectOptions.recommendationOptions = recommendOptions;
      // Instantiate the image selector
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      //唤起安全相册组件 (唤起安全相册组件)
      photoPicker.select(PhotoSelectOptions, (err: BusinessError, PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (err) {
          console.error(this.TAG, "onClickSelectPhoto photoPicker.select error:" + JSON.stringify(err));
          return;
        }
        // After the user confirms the selection, the callback will be here.
        console.info(this.TAG, "onClickSelectPhoto photoPicker.select successfully:" + JSON.stringify(PhotoSelectResult));
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(this.TAG, "onClickSelectPhoto photoPicker.select catch failed:" + JSON.stringify(err));
    }
  }

  build() {
    Row(){
      Button('Click to唤起相册选择 (唤起相册选择)')
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

### Scan Functionality  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_18ebba9c.png 'image.png')  

The system provides a secure scanning control, allowing integration of the scanning interface and parsing with just a few lines of code.  
The scanning interface fully integrates gallery selection, flash fill light, image scanning, and real-time scanning.  
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
      // Successful scanning and parsing, QR code data
      console.info(this.TAG, " result: " + JSON.stringify(result));
      promptAction.showToast({
        message: result.originalValue
      });
    }).catch((error: BusinessError) => {
      // Scanning and parsing failed
      console.info(this.TAG, " error: " + JSON.stringify(error));
    });
  }

  build() {
    RelativeContainer() {
      Text("Jump to One-Click Scanning")
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


## 三、Development Issue Location and Solution Sharing  

### HarmonyOS Development Experience Sharing  

#### 1. How to Learn HarmonyOS Efficiently?  
As the saying goes, "knowing the why before the how," it is very important to first get started and learn about the overall concepts of HarmonyOS and understand HarmonyOS-related technical terms.  

#### 1.1 Introduction to Technical Terms:  
**HarmonyOS**  
Specifically refers to HarmonyOS and OpenHarmony. The former is the commercial HarmonyOS maintained by Huawei, while the latter is the system open-sourced by Huawei to the Open Atom Foundation, which anyone can use and modify in compliance with open-source agreements.  
Although HarmonyOS is based on OpenHarmony, there are still differences in upper-layer functions and usage. Details of the differences between the two: [Differences and Commonalities Between OpenHarmony and HarmonyOS](link).  

**HarmonyOS-Related Companies**  
There are currently many companies using and maintaining the open-source OpenHarmony, such as DeepOpenHarmony, RunOpenHarmony, Honghu Wanlian, Kaihong Zhigu, Jiulian Kaihong, etc. The current usage directions of open-source HarmonyOS are many, such as power grids, industry, IoT, mining, etc.  
Commercial HarmonyOS is iterated, maintained, and used by Huawei itself.  

**Northbound and Southbound of HarmonyOS**  
Specifically refers to northbound application development and southbound device development. Device development is mostly based on open-source HarmonyOS. Northbound development is divided into OpenHarmony application development and HarmonyOS application development.  

**Dual-Framework and Single-Framework of HarmonyOS**  
Before the release of HarmonyOS NEXT, Huawei phones ran a "dual-framework" system. The architectural logic was that both the HarmonyOS and Android frameworks coexisted, but the underlying basic services were still HarmonyOS-centric, also known as a "hybrid system."  
Single-framework: Represented by HarmonyOS NEXT, it is a pure HarmonyOS system with a fully self-developed base, removing the traditional Android Open Source Project (AOSP) code, and only supporting the HarmonyOS kernel and HarmonyOS applications.  

**HarmonyOS HDE**  
Huawei Developer Experts (HUAWEI DEVELOPER EXPERTS), certified by Huawei. They are practice leaders of Huawei's open capabilities, shouldering responsibilities such as technical preaching and knowledge empowerment. They answer users' questions about Huawei's development capabilities in major technical communities, regularly share online on social media, and often share lectures on Huawei's latest technology trends as instructors offline.  

#### 2. Establish a HarmonyOS Knowledge Framework  
I always recommend that everyone establish a learning framework for HarmonyOS, first understanding what HarmonyOS is, what it can do, what functions it has, what the new features are, and where the differences lie from Android and iOS.  

Only after fully deconstructing the learning goals can we have more motivation and direction to learn HarmonyOS.  

In summary, now when we look at the official documentation, we understand how to learn and use it.  

Version descriptions are detailed explanations of HarmonyOS iterations, from which we can understand the latest technical iteration directions of HarmonyOS and the reasons for deprecating certain old technologies, adjusting our learning directions and development solutions in a timely manner.  

Guides serve as overviews of development functions and include complete demo code snippets. When you need more detailed interface documentation, you need to click on API references to view them.  

Best practices and FAQs serve as technical templates and routine issue avoidance for development solutions, which can be understood as pitfall documentation.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_2f3ed199.png 'image.png')  

#### How to Keep Up with HarmonyOS's Rapid Iteration?  
Because HarmonyOS is growing rapidly, the API iteration speed is very fast. Many components, routing management, and state decorators are evolving rapidly, with some being deprecated, requiring quick learning of new solutions. Therefore, the requirement for continuous learning is very high.  

It is recommended to build a knowledge framework, such as through mind maps, personal knowledge bases, and regular learning of official documentation for knowledge iteration. In work and development, often summarize and归纳 (summarize) HarmonyOS-related skills and solutions.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_11870ace.png 'image.png')