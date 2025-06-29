## 【HarmonyOS 5】Detailed Explanation of VisionKit Face Liveness Detection  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  

## I. What is VisionKit Face Liveness Detection?  

VisionKit is a scenario-based visual service toolkit provided by HarmonyOS.  

Huawei integrates common solutions, which typically require third-party applications to use SDKs, in the HarmonyOS system in the form of Kits to facilitate rapid development and empowerment for third-party applications.  

VisionKit includes the interactiveLiveness function interface for face liveness detection. As the name suggests, face liveness detection is mainly used to detect whether the current person is a real person rather than a photo, silicone mask, or AI-simulated video.  

Although this algorithm interface has passed the CECA (China Financial Certification Authority) certification, the official recommendation is to add additional security measures before using this face detection interface, and it is not recommended to directly use it in high-risk payment and financial scenarios. It is recommended for use in low-risk scenarios such as login, attendance, and real-name authentication.  

**Note**: Face liveness detection does not support emulators or previewers.  

For details, refer to the official interfaces:  
<https://developer.huawei.com/consumer/cn/doc/harmonyos-references/vision-interactive-liveness>  
<https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/vision-interactiveliveness>  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_d011cd35.png 'image.png')  


## II. How to Use Face Liveness Detection?  

The face liveness detection function interactiveLiveness, available from version 5.0.0 (API 12), can be imported via the @kit.VisionKit module. It supports the interactive live detection mode (INTERACTIVE_MODE), with the number of actions configurable as 3 or 4, including 6 actions such as nodding, opening the mouth, and blinking.  

Configure detection modes, jump paths, voice announcements, and other parameters through InteractiveLivenessConfig, and provide startLivenessDetection and getInteractiveLivenessResult interfaces to resist photo and video fraud. It is suitable for identity verification scenarios and requires applying for the ohos.permission.CAMERA permission. For error codes, refer to the Vision Kit error code documentation.  

Vision Kit Error Code Documentation:  
<https://developer.huawei.com/consumer/cn/doc/harmonyos-references/vision-error-code>  

**1. Core Interface for Invoking the Face Page:**  
interactiveLiveness.startLivenessDetection, which requires configuring config to set face modes, actions, etc.  

(1) Promise mode: Only returns the jump result (boolean).  

```typescript
interactiveLiveness.startLivenessDetection(routerOptions).then((DetectState: boolean) => {
  hilog.info(0x0001, "LivenessCollectionIndex", `Succeeded in jumping.`);
}).catch((err: BusinessError) => {
  hilog.error(0x0001, "LivenessCollectionIndex", `Failed to jump. Code：${err.code}，message：${err.message}`);
})
```  

(2) Promise + callback mode: Returns both the jump result and detection result (only applicable to BACK_MODE).  

```typescript
interactiveLiveness.startLivenessDetection(routerOptions, (err: BusinessError, result: interactiveLiveness.InteractiveLivenessResult | undefined) => {
  if(err.code !== 0 && !result) {
    hilog.error(0x0001, "LivenessCollectionIndex", `Failed to detect. Code：${err.code}，message：${err.message}`);
    return;
  }
  hilog.info(0x0001, 'LivenessCollectionIndex', `Succeeded in detecting result：${result}`);
})
```  

**2. InteractiveLivenessConfig Configuration Interface:**  
To invoke face liveness detection, this configuration object must be filled in for related settings. For parameters, refer to the following table:  

1. **DetectionMode**  
   | Name                | Value                   | Description           |  
   | ----------------- | ------------------- | ------------ |  
   | SILENT_MODE      | "SILENT_MODE"      | Silent liveness detection (not yet supported) |  
   | INTERACTIVE_MODE | "INTERACTIVE_MODE" | Action liveness detection (default mode) |  

2. **ActionsNumber**  
   | Name            | Value | Description                                       |  
   | ------------- | ----- | ---------------------------------------- |  
   | ONE_ACTION   | 1     | Random 1 action (not yet supported)                       |  
   | TWO_ACTION   | 2     | Random 2 actions (not yet supported)                       |  
   | THREE_ACTION | 3     | Random 3 actions ([blink, gaze] not present simultaneously and not adjacent, adjacent actions not repeated)        |  
   | FOUR_ACTION  | 4     | Random 4 actions (blink only 1 time, gaze at most 1 time, [blink, gaze] not adjacent, adjacent actions not repeated) |  

3. **RouteRedirectionMode**  
   | Name            | Value         | Description                               |  
   | ------------- | --------- | -------------------------------- |  
   | BACK_MODE    | "back"    | After detection, call router.back to return to the previous page          |  
   | REPLACE_MODE | "replace" | After detection, call router.replaceUrl to jump (default mode) |  

4. **InteractiveLivenessConfig**  
   | Name                 | Type                   | Required/Optional | Description                                              |  
   | ------------------ | -------------------- | -------- | ----------------------------------------------- |  
   | isSilentMode       | DetectionMode        | Required    | Detection mode (default INTERACTIVE_MODE)                       |  
   | actionsNum         | ActionsNumber        | Optional    | Number of actions (3 or 4, default 3)                           |  
   | successfulRouteUrl | string               | Optional    | Successful detection jump path (uses system default page if not filled)                            |  
   | failedRouteUrl     | string               | Optional    | Failed detection jump path (uses system default page if not filled)                            |  
   | routeMode          | RouteRedirectionMode | Optional    | Jump mode (default REPLACE_MODE)                           |  
   | challenge          | string               | Optional    | Security camera scenario challenge value (16-128 bits, empty value means not used)                     |  
   | speechSwitch       | boolean              | Optional    | Voice announcement switch (default on)                                    |  
   | isPrivacyMode      | boolean              | Optional    | Privacy mode (requires applying for ohos.permission.PRIVACY_WINDOW permission, default off) |  

The configuration object for face liveness detection requires isSilentMode, with other properties optional:  

```typescript
import { interactiveLiveness } from '@kit.VisionKit';

let isSilentMode = "INTERACTIVE_MODE" as interactiveLiveness.DetectionMode;
let routeMode = "replace" as interactiveLiveness.RouteRedirectionMode;
let actionsNum = 3 as interactiveLiveness.ActionsNumber;
let routerOptions: interactiveLiveness.InteractiveLivenessConfig = {
  isSilentMode: isSilentMode,
  routeMode: routeMode,
  actionsNum: actionsNum,
  failedRouteUrl: "pages/FailPage",
  successfulRouteUrl: "pages/SuccessPage"
}
```  

**3. getInteractiveLivenessResult to Obtain Face Liveness Detection Results:**  
After successfully invoking face liveness detection, use this interface to obtain detection results. The result content is as follows:  

| Name                 | Type             | Read-Only | Optional | Description                                                                                                                    |  
| ------------------ | -------------- | ---- | ---- | --------------------------------------------------------------------------------------------------------------------- |  
| livenessType       | LivenessType   | Yes  | No   | Liveness detection mode, values include:<br>- `0` (INTERACTIVE_LIVENESS, action liveness detection)<br>- `1` (SILENT_LIVENESS, silent liveness detection, not yet supported)<br>- `2` (NOT_LIVENESS, non-live) |  
| mPixelMap          | image.PixelMap | Yes  | Yes  | The most characteristic live image returned after successful detection (such as a feature map including face key points), no data when detection fails.                                                                           |  
| securedImageBuffer | ArrayBuffer    | Yes  | Yes  | Secure stream data (encrypted image feature data) returned in security camera scenarios, no data in non-security scenarios.                                                                               |  
| certificate        | Array<string>  | Yes  | Yes  | Certificate chain returned in security camera scenarios (used to verify the legitimacy of the secure stream), no data in non-security scenarios.                                                                                |  

```typescript
let successResult = interactiveLiveness.getInteractiveLivenessResult();
successResult.then(data => {
  hilog.info(0x0001, "LivenessCollectionIndex", `Succeeded in detecting.`);
}).catch((err: BusinessError) => {
  hilog.error(0x0001, "LivenessCollectionIndex", `Failed to detect. Code：${err.code}，message：${err.message}`);
})
```  


## III. DEMO Source Code Example  

```typescript
import { interactiveLiveness } from '@kit.VisionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

@Entry
@Component
struct FaceLivenessDemo {
  @State userGrant: boolean = false // Permission status
  @State detectionResult: string = "" // Detection result display
  @State actionCount: interactiveLiveness.ActionsNumber = interactiveLiveness.ActionsNumber.THREE_ACTION; // Number of actions (3 or 4)
  @State speechEnabled: boolean = true // Voice announcement switch
  // Indicates returning to the previous page using router.back after face liveness detection is completed.
  @State routeMode: interactiveLiveness.RouteRedirectionMode = interactiveLiveness.RouteRedirectionMode.BACK_MODE; // Jump mode

  // Permission application logic
  private async requestPermissions() {
    const context = getContext() as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    const results = await atManager.requestPermissionsFromUser(context, ["ohos.permission.CAMERA"]);
    this.userGrant = results.authResults.every(status => status === 0);
  }

  // Detection configuration generation
  private generateDetectionConfig(): interactiveLiveness.InteractiveLivenessConfig {
    return {
      // Represents the face liveness detection mode, default action liveness detection mode.
      // INTERACTIVE_MODE represents the action liveness detection mode.
      isSilentMode: interactiveLiveness.DetectionMode.INTERACTIVE_MODE,

      // Represents the number of actions for action liveness detection, with a range of 3 or 4, default 3 actions. Randomly generated with the following rules:
      //
      // When actionsNum=3, actions in the [blink, gaze] combination will not exist simultaneously, and adjacent actions will not be the same.
      //
      // When actionsNum=4, the blink action occurs exactly once, the gaze action occurs at most once, actions in the [blink, gaze] combination are not adjacent, and adjacent actions are not the same.
      //
      // This parameter is only valid when isSilentMode is INTERACTIVE_MODE.
      actionsNum: this.actionCount,
      // Represents the page path to jump to after successful face liveness detection. If not filled, the system has a default successful detection page.
      // successfulRouteUrl: "pages/result/success", // Custom successful jump path (page needs to be created in advance)

      // Represents the page path to jump to after failed face liveness detection. If not filled, the system has a default failed detection page.
      // failedRouteUrl: "pages/result/fail", // Custom failed jump path (page needs to be created in advance)

      routeMode: this.routeMode, // Jump mode

      // Voice announcement switch.
      //
      // true indicates enabling voice announcement.
      // false indicates disabling voice announcement.
      // Voice announcement is enabled by default.
      speechSwitch: this.speechEnabled, // Voice announcement control

      // Challenge value. Only used for liveness detection in security camera scenarios (corresponding to the "userData" field in the initializeAttestContext method).
      //
      // Using security camera scenarios requires enabling the Device Security service.
      //
      // The length range is between 16-128 (challenge passed as empty or undefined means not using a security camera).
      // challenge: "自定义挑战值1234567890abcdef", // Optional for security camera scenarios

      // Whether to set privacy mode.
      //
      // true: Set privacy mode.
      // false: Do not set privacy mode.
      // The default value is false.
      // isPrivacyMode: true // Privacy mode requires additional permissions. When setting privacy mode, apply for the ohos.permission.PRIVACY_WINDOW permission.
    };
  }

  // Start detection
  private async startDetection() {
    if (!this.userGrant) {
      this.detectionResult = "Please apply for camera permission first";
      return;
    }

    const config = this.generateDetectionConfig();

    try {
      const jumpSuccess = await interactiveLiveness.startLivenessDetection(config);
      if (jumpSuccess) {
        hilog.info(0x0001, "Detection", "Successfully jumped to the detection page");
        // Obtain the result after detection is completed (needs to be called when returning to the page)
        const result = await interactiveLiveness.getInteractiveLivenessResult();
        this.processResult(result);
      }
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0001, "Detection", `Detection failed: error code ${error.code}, message ${error.message}`);
      this.detectionResult = `Detection exception: error code ${error.code}`;
    }
  }

  // Result processing
  private processResult(result: interactiveLiveness.InteractiveLivenessResult) {
    let status = "";
    let livenessType = result.livenessType;
    switch (livenessType) {
      case 0: // Action liveness detection successful
        status = "Liveness detection passed";
        // Process feature images or secure data here
        break;
      case 2: // Non-live
        status = "Non-live detected (photo/video fraud)";
        break;
      default:
        status = "Detection result exception";
    }
    this.detectionResult = status;
  }

  build() {
    Column({ space: 40 })
    {
      // Permission application button
      Button(this.userGrant ? "Permission authorized" : "Apply for camera permission")
        .fontSize(18)
        .margin(10)
        .padding(12)
        .backgroundColor(this.userGrant ? Color.Green : Color.Blue)
        .onClick(() => this.requestPermissions())

      // Action count selection
      Row({ space: 20 }) {
        Text("Number of actions:")
          .fontSize(16)

        Button("3 actions")
          .backgroundColor(this.actionCount === 3 ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => this.actionCount = 3)

        Button("4 actions")
          .backgroundColor(this.actionCount === 4 ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => this.actionCount = 4)
      }

      // Voice announcement switch
      Toggle({ type: ToggleType.Checkbox, isOn: this.speechEnabled })
        .onChange((isOn: boolean) => {
          this.speechEnabled = isOn;
        })

      // Jump mode selection
      Row({ space: 20 }) {
        Text("Jump mode:")
          .fontSize(16)

        Button("Replace page")
          .backgroundColor(this.routeMode === "replace" ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => {
            this.routeMode = interactiveLiveness.RouteRedirectionMode.REPLACE_MODE;
          })

        Button("Return to previous page")
          .backgroundColor(this.routeMode === "back" ? Color.Blue : Color.White)
          .border({ width: 1, color: Color.Gray })
          .onClick(() => {
            this.routeMode = interactiveLiveness.RouteRedirectionMode.BACK_MODE;
          })
      }

      // Start face liveness detection button
      Button("Start face liveness detection")
        .fontSize(20)
        .padding(16)
        .backgroundColor(Color.Orange)
        .onClick(() => this.startDetection())

      // Result display
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


## Notes:  

**1. Two supported modes for face liveness detection**  
- INTERACTIVE_MODE (action liveness detection): The default mode requires the user to complete 3 or 4 random actions (such as blinking, nodding, etc.), verifying liveness through action combinations with rules to avoid repeated adjacent actions or specific combinations (e.g., blinking and gazing are not adjacent).  
- SILENT_MODE (silent liveness detection): Not yet supported, detects liveness through other technologies (such as micro-expressions, light reflection) without user actions.  

**2. Configuring the number of actions and jump logic for face liveness detection**  
- Configure via actionsNum in InteractiveLivenessConfig, with optional values 3 (default) or 4. For 3 actions, [blink, gaze] do not exist simultaneously and are not adjacent; for 4 actions, blink occurs only once, gaze at most once.  
- Configure the jump mode via routeMode (BACK_MODE to return to the previous page or REPLACE_MODE to replace the jump, default REPLACE_MODE).  
- Set custom jump paths for success/failure via successfulRouteUrl and failedRouteUrl (uses system default pages if not filled).  

**3. Common errors and handling:**  
- 201 (Permission denied): ohos.permission.CAMERA permission not applied.  
- 1008301002 (Route switching failed): Incorrect route configuration. Check if successfulRouteUrl/failedRouteUrl paths are correct or if routeMode matches page routing.  
- 1008302000-1008302004 (detection-related errors): Algorithm initialization failure, timeout, or actions not conforming to rules during detection. Catch error codes via callbacks or Promise's catch, prompt the user to re-detect, and check action compliance.