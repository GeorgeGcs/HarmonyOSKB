@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Text(this.message)
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}