@Entry
@Component
struct Index {
  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 中间标题文字
      Text('标题文字')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      // 左边返回按钮
      Button('←')
        .position({ x: 10, y: 5 })
        .onClick(() => {
          console.log('返回按钮被点击')
        })

      // 右边问号帮助按钮
      Button('?')
        .position({ x: "88%", y: 5 })
        .onClick(() => {
          console.log('帮助按钮被点击')
        })
    }
    .width('100%')
    .height(50)
    .backgroundColor('#F0F0F0')
  }
}
