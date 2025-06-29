

@Entry
@Component
struct InputTestPage {

  build() {
    Column() {
      Image($r("app.media.icon_harmonyos"))
        .size({
          width: px2vp(600),
          height: px2vp(200)
        })
      Row(){
        TextInput({
          placeholder: "请输入"
        })
          // 只支持应用内复制。
          .copyOption(CopyOptions.InApp)
      }
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}

