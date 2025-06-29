import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  aboutToAppear(): void {

  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
          console.log("debugGeorge", "sub storage : ");
          hilog.info(0x0000, 'debugGeorge', "sub storage : ");
          let storage: LocalStorage = new LocalStorage();
          console.log("debugGeorge", "sub storage : " + storage.get('PropA'));
          hilog.info(0x0000, 'debugGeorge', "sub storage : " + storage.get('PropA'));
        })
    }
    .height('100%')
    .width('100%')
  }
}