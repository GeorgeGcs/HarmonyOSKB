import { componentSnapshot } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { fileIo, fileUri } from "@kit.CoreFileKit"

@Entry
@Component
struct Index {
  @State imageUrl: Resource = $r('app.media.startIcon')
  @State studyPath: Resource = $r('app.media.icon_harmonyos')
  @State CurrentImage:string = '1'
  @State CurrentIndex:number = 0
  @State SecondImageUrl:string = ''
  @State SecondStudyPath:string = ''


  async snapshot() {
    // 1. 截图
    const pixelMap = await componentSnapshot.get(this.CurrentImage)
    // 2. 获取图片二进制数据
    const imagePacker = image.createImagePacker()
    // format 图片类型  quality 图片质量，原图100
    const arrayBuffer = await imagePacker.packing(pixelMap, { format: "image/png", quality: 98 })
    // 3. 存储在应用下
    const ctx = getContext(this)
    const path = ctx.cacheDir + '/' + Date.now() + '.jpg'
    // 打开一个未创建的图片，让他具备创建和读写能力
    const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    //fileUri.getUriFromPath这个的区别 “file：//com.cmt.cmtopdr/path”
    if (this.CurrentImage == '0') {
      this.SecondImageUrl = fileUri.getUriFromPath(path)
    } else {
      this.SecondStudyPath = fileUri.getUriFromPath(path)
    }
    // 写入沙箱
    fileIo.writeSync(file.fd, arrayBuffer)
    fileIo.closeSync(file.fd)
    // ====================================================
  }



  build() {
    Column(){
      List() {
        ForEach([this.imageUrl, this.studyPath], (item: string, index: number) => {
          ListItem() {
            // 上部分
            Column() {
              Image(item)
                .width(240)
                .height(220)
                .objectFit(ImageFit.Contain)
                .margin({ top: 5 })
            }
            .margin({ top: 60 })
            .height(300)
            .width(240)
            .backgroundColor(Color.White)

          }
          .id(index + "") // 用变量控制
          .margin({ right: 20 })

        })

      }
      .onScrollIndex((start: number, end: number, center: number) => {
        console.log('开始' + start, '结束' + end, '中间' + center)
        this.CurrentIndex = center
        if (this.CurrentIndex == 0) {
          this.CurrentImage = '0'
        } else {
          this.CurrentImage = '1'
        }
      })
      .padding({ left: 20 })
      .height(585)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)


      Button('截图')
        .onClick(()=>{
          // 截图方法
          this.snapshot()
        })

      // 展示保存在沙箱图片
      Row(){
        Image(this.SecondImageUrl)
          .width(100)
          .height(100)
        Image(this.SecondStudyPath)
          .width(100)
          .height(100)
      }
    }
    .height('100%')
    .width('100%')
  }
}