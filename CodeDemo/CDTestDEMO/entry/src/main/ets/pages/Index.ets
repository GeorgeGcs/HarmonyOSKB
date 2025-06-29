import { router } from '@kit.ArkUI'


@Entry
@Component
struct Index {

  onClickAlbum = ()=>{
    router.pushUrl({
      url: "pages/AlbumPage"
    })
  }

  onClickFace = ()=>{
    router.pushUrl({
      url: "pages/FaceLivenessPage"
    })
  }

  onClickScan = ()=>{
    router.pushUrl({
      url: "pages/ScanPage"
    })
  }

  onClickNAVI= ()=>{
    router.pushUrl({
      url: "pages/NAVIPage"
    })
  }

  onClickLocation = ()=>{
    router.pushUrl({
      url: "pages/LocationPage"
    })
  }

  @Styles commonText(){
    .width(px2vp(600))
    .height(px2vp(120))
    .backgroundColor(Color.Blue)
    .borderRadius(15)
    .margin({
      bottom: px2vp(60)
    })
  }

  build() {
    Column(){
      Text("人脸活体检测DEMO")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()
        .onClick(this.onClickFace)

      Text("相册筛选DEMO")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()
        .onClick(this.onClickAlbum)

      Text("扫一扫DEMO")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()
        .onClick(this.onClickScan)

      Text("系统导航DEMO")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()
        .onClick(this.onClickNAVI)

      Text("安全定位DEMO")
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .commonText()
        .onClick(this.onClickLocation)

    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Black)
  }


}