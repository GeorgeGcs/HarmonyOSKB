# 【HarmonyOS 5】Detailed Guide to Using Progress Bars in HarmonyOS  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications （Financial Management#  

## 一、Types of Progress Bars in HarmonyOS  

HarmonyOS's ArkUI framework provides developers with various types of progress bars, each with unique styles to meet different design needs. Here are several common progress bar types:  

1. **Linear Progress Bar**: This is the most common progress bar style, displaying progress in a straight line. Starting from API version 9, when the component height is greater than the width, it adapts to vertical display; when the height and width are equal, it remains horizontally displayed.  

2. **Ring Progress Bar (without Scale)**: This progress bar is circular, showing progress through gradual filling of a circular ring. The default foreground color is blue, and the default strokeWidth (progress bar width) is 2.0vp.  

3. **Scale Ring Progress Bar (with Scale)**: It displays a progress effect similar to clock scales. The progress display at the arc ends (head and tail) is the same as the Eclipse style, while the middle section shows a rectangular long bar similar to the Linear style. Starting from API version 9, when the outer scale overlaps, it automatically converts to a ring progress bar without scales.  

4. **Eclipse Progress Bar**: It displays a progress effect similar to the phases of the moon, changing from a crescent to a full moon.  

5. **Capsule Progress Bar**: The progress display at the arc ends (head and tail) is the same as the Eclipse style, and the middle section is the same as the Linear style. When the height is greater than the width, it adapts to vertical display.  


## 三、Creating and Configuring Progress Bars with ArkTS  

### （一）Creating a Progress Bar  

In ArkTS, we create a progress bar by calling the `Progress` interface. The basic syntax for creating a progress bar is as follows:  

```typescript
Progress({ value: number, total?: number, type?: ProgressType })
```  

### （二）Setting Progress Bar Styles  

When creating a progress bar, we can specify different progress bar types by setting the `ProgressType` enumeration type for the `type` optional parameter, achieving diversified styles. Here are setting examples for different types of progress bars:  

1. **Linear Progress Bar**:  

```typescript
Progress({ value: 50, total: 100, type: ProgressType.Linear })
```  

2. **Ring Progress Bar (without Scale)**:  

```typescript
Progress({ value: 30, total: 100, type: ProgressType.Ring })
```  

3. **Scale Ring Progress Bar (with Scale)**:  

```typescript
Progress({ value: 70, total: 100, type: ProgressType.ScaleRing })
```  

4. **Eclipse Progress Bar**:  

```typescript
Progress({ value: 10, total: 100, type: ProgressType.Eclipse })
```  

5. **Capsule Progress Bar**:  

```typescript
Progress({ value: 45, total: 100, type: ProgressType.Capsule })
```  

### （三）Dynamically Updating Progress  

One of the key functions of a progress bar is to dynamically update the progress during task execution, reflecting the real-time progress of the task.  

In the HarmonyOS Progress component, the progress update effect is achieved through the `value` and `total` attributes. The source code is as follows:  

Here, `value` sets the initial progress value, `total` sets the total progress length, and `type` determines the Progress style. If `type` is not set, the linear progress bar style is used by default.  

```typescript
Progress({ value: 24, total: 100, type: ProgressType.Linear })
```  

```typescript
import prompt from '@ohos.prompt';

@Entry
@Component
struct DownloadProgressBar {
  // Download progress, initial value is 0
  @State progress: number = 0;
  // Download status prompt information
  @State status: string = 'Waiting for download';

  // Simulated download function
  startDownload() {
    // Simulate the download process, use setInterval to update progress periodically
    let intervalId = setInterval(() => {
      this.progress += 10;
      if (this.progress >= 100) {
        this.status = 'Download completed';
        clearInterval(intervalId);
        prompt.showToast({ message: 'Download completed' });
      } else {
        this.status = `Downloading, progress: ${this.progress}%`;
      }
    }, 1000);
  }

  build() {
    Column({ space: 20 }) {
      Text('Download Progress Bar Example')
        .fontSize(20)
        .fontWeight(FontWeight.Bold);

      Progress({ value: this.progress, total: 100 })
        .width('90%')
        .height(20);

      Text(this.status)
        .fontSize(16);

      Button('Start Download')
        .width('60%')
        .height(40)
        .backgroundColor(Color.Blue)
        .fontColor(Color.White)
        .onClick(() => {
          this.startDownload();
        });
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }
}
```