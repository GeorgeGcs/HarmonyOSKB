import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {

  /**
   * 统一样式封装
   */
  @Styles ButtonStyle(){
    .width(px2vp(600))
    .height(px2vp(200))
    .margin({ top: px2vp(66) })
  }

  build() {
    Column(){
      Button("点击跳转EventHub测试页面")
        .ButtonStyle()
        .onClick(()=>{
          router.pushUrl({
            url: "pages/EventHubTestPage",
          })
        })

      Button("点击跳转Emitter测试页面")
        .ButtonStyle()
        .onClick(()=>{
          router.pushUrl({
            url: "pages/EmitterTestPage",
          })
        })

    }
    .size({
      width: "100%",
      height: "100%"
    })
    .justifyContent(FlexAlign.Center)
  }
}