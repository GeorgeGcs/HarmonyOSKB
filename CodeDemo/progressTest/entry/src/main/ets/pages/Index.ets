import prompt from '@ohos.prompt';

@Entry
@Component
struct DownloadProgressBar {
  // 下载进度，初始值为 0
  @State progress: number = 0;
  // 下载状态提示信息
  @State status: string = '等待下载';

  // 模拟下载的函数
  startDownload() {
    // 模拟下载过程，使用 setInterval 定时更新进度
    let intervalId = setInterval(() => {
      this.progress += 10;
      if (this.progress >= 100) {
        this.status = '下载完成';
        clearInterval(intervalId);
        prompt.showToast({ message: '下载已完成' });
      } else {
        this.status = `下载中，进度: ${this.progress}%`;
      }
    }, 1000);
  }

  build() {
    Column({ space: 20 }) {
      Text('下载进度条示例')
        .fontSize(20)
        .fontWeight(FontWeight.Bold);

      Progress({ value: this.progress, total: 100 })
        .width('90%')
        .height(20);

      Text(this.status)
        .fontSize(16);

      Button('开始下载')
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