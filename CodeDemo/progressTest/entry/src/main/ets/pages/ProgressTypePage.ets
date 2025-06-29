import prompt from '@ohos.prompt';

@Entry
@Component
struct ProgressTypePage {
  // 线性进度条的进度值
  @State linearProgress: number = 50;
  // 环形无刻度进度条的进度值
  @State ringProgress: number = 30;
  // 环形有刻度进度条的进度值
  @State scaleRingProgress: number = 70;
  // 椭圆形进度条的进度值
  @State eclipseProgress: number = 10;
  // 胶囊进度条的进度值
  @State capsuleProgress: number = 45;

  build() {
    Column({ space: 20 }) {
      Text('HarmonyOS 进度条示例')
        .fontSize(20)
        .fontWeight(FontWeight.Bold);

      // 线性进度条
      Text('线性进度条')
        .fontSize(16)
        .fontWeight(FontWeight.Medium);
      Progress({ value: this.linearProgress, total: 100, type: ProgressType.Linear })
        .width('90%')
        .height(20);

      // 环形无刻度进度条
      Text('环形无刻度进度条')
        .fontSize(16)
        .fontWeight(FontWeight.Medium);
      Progress({ value: this.ringProgress, total: 100, type: ProgressType.Ring })
        .width(100)
        .height(100);

      // 环形有刻度进度条
      Text('环形有刻度进度条')
        .fontSize(16)
        .fontWeight(FontWeight.Medium);
      Progress({ value: this.scaleRingProgress, total: 100, type: ProgressType.ScaleRing })
        .width(100)
        .height(100);

      // 椭圆形进度条
      Text('椭圆形进度条')
        .fontSize(16)
        .fontWeight(FontWeight.Medium);
      Progress({ value: this.eclipseProgress, total: 100, type: ProgressType.Eclipse })
        .width(100)
        .height(100);

      // 胶囊进度条
      Text('胶囊进度条')
        .fontSize(16)
        .fontWeight(FontWeight.Medium);
      Progress({ value: this.capsuleProgress, total: 100, type: ProgressType.Capsule })
        .width('90%')
        .height(20);
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }
}