import { BusinessError } from '@kit.BasicServicesKit';
import { rcp } from '@kit.RemoteCommunicationKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    const session = rcp.createSession();
    session.get("http://example.com/get").then((response) => {
      console.info(`Succeeded in getting the response ${response}`);
    }).catch((err: BusinessError) => {
      console.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
    });
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
        })
    }
    .height('100%')
    .width('100%')

  }




}
