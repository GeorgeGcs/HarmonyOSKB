## 【HarmonyOS】头像裁剪之手势放大缩小，平移，双击缩放控制（三）

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

**一、DEMO效果图：**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/79c27d0231d047c99db7b84bdefb09e4b1862.png)

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/be7f060e1f7b4d1d9408373ce233106eb1862.png)

**二、开发思路：**
使用矩阵变换控制图片的放大缩小和平移形态。

通过监听点击手势**TapGesture**，缩放手势**PinchGesture**，拖动手势**PanGesture**进行手势操作的功能实现。

通过对矩阵变换参数mMatrix的赋值，将矩阵变换参数赋值给image控件。实现手势操作和图片操作的同步。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/54dac87a5e554e7a9bc6ac6426c8b0f7b1862.png)

该参数拥有四维坐标，只需要通过手势操作调整四个参数即可实现。通过.transform(this.mMatrix)赋值给image控件。

通过image的.onComplete(this.onLoadImgComplete)函数回调，获取图片控件的宽高和内容宽高等参数。以此为基准，手势操作调整的都是这些值。

**三、DEMO示例代码：**

```dart
import router from '@ohos.router';
import { CropMgr, ImageInfo } from '../manager/CropMgr';
import { image } from '@kit.ImageKit';
import Matrix4 from '@ohos.matrix4';
import FS from '@ohos.file.fs';

export class LoadResult {
  width: number = 0;
  height: number = 0;
  componentWidth: number = 0;
  componentHeight: number = 0;
  loadingStatus: number = 0;
  contentWidth: number = 0;
  contentHeight: number = 0;
  contentOffsetX: number = 0;
  contentOffsetY: number = 0;
}



@Entry
@Component
export struct CropPage {
  private TAG: string = "CropPage";

  private mRenderingContextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private mCanvasRenderingContext2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.mRenderingContextSettings);

  // 加载图片
  @State mImg: PixelMap | undefined = undefined;
  // 图片矩阵变换参数
  @State mMatrix: object = Matrix4.identity()
    .translate({ x: 0, y: 0 })
    .scale({ x: 1, y: 1});

  @State mImageInfo: ImageInfo = new ImageInfo();

  private tempScale = 1;
  private startOffsetX: number = 0;
  private startOffsetY: number = 0;

  aboutToAppear(): void {
    console.log(this.TAG, "aboutToAppear start");
    let temp = CropMgr.Ins().mSourceImg;
    console.log(this.TAG, "aboutToAppear temp: " + JSON.stringify(temp));
    this.mImg = temp;
    console.log(this.TAG, "aboutToAppear end");
  }

  private getImgInfo(){
    return this.mImageInfo;
  }

  onClickCancel = ()=>{
    router.back();
  }

  onClickConfirm = async ()=>{
    if(!this.mImg){
      console.error(this.TAG, " onClickConfirm mImg error null !");
      return;
    }

    // 存当前裁剪的图
	// ...
    router.back();
  }

  /**
   * 复制图片
   * @param pixel
   * @returns
   */
  async copyPixelMap(pixel: PixelMap): Promise<PixelMap> {
    const info: image.ImageInfo = await pixel.getImageInfo();
    const buffer: ArrayBuffer = new ArrayBuffer(pixel.getPixelBytesNumber());
    await pixel.readPixelsToBuffer(buffer);
    const opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      size: { height: info.size.height, width: info.size.width }
    };
    return image.createPixelMap(buffer, opts);
  }

  /**
   * 图片加载回调
   */
  private onLoadImgComplete = (msg: LoadResult) => {
    this.getImgInfo().loadResult = msg;
    this.checkImageScale();
  }

  /**
   * 绘制画布中的取景框
   */
  private onCanvasReady = ()=>{
    if(!this.mCanvasRenderingContext2D){
      console.error(this.TAG, "onCanvasReady error mCanvasRenderingContext2D null !");
      return;
    }
    let cr = this.mCanvasRenderingContext2D;
    // 画布颜色
    cr.fillStyle = '#AA000000';
    let height = cr.height;
    let width = cr.width;
    cr.fillRect(0, 0, width, height);

    // 圆形的中心点
    let centerX = width / 2;
    let centerY = height / 2;
    // 圆形半径
    let radius = Math.min(width, height) / 2 - px2vp(100);
    cr.globalCompositeOperation = 'destination-out'
    cr.fillStyle = 'white'
    cr.beginPath();
    cr.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    cr.fill();

    cr.globalCompositeOperation = 'source-over';
    cr.strokeStyle = '#FFFFFF';
    cr.beginPath();
    cr.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    cr.closePath();

    cr.lineWidth = 1;
    cr.stroke();
  }

  build() {
    RelativeContainer() {
      // 黑色底图
      Row().width("100%").height("100%").backgroundColor(Color.Black)

      // 用户图
      Image(this.mImg)
        .objectFit(ImageFit.Contain)
        .width('100%')
        .height('100%')
        .transform(this.mMatrix)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onComplete(this.onLoadImgComplete)

      // 取景框
      Canvas(this.mCanvasRenderingContext2D)
        .width('100%')
        .height('100%')
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .backgroundColor(Color.Transparent)
        .onReady(this.onCanvasReady)
        .clip(true)
        .backgroundColor("#00000080")

      Row(){
        Button("取消")
          .size({
            width: px2vp(450),
            height: px2vp(200)
          })
          .onClick(this.onClickCancel)

        Blank()

        Button("确定")
          .size({
            width: px2vp(450),
            height: px2vp(200)
          })
          .onClick(this.onClickConfirm)
      }
      .width("100%")
      .height(px2vp(200))
      .margin({ bottom: px2vp(500) })
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Bottom },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .justifyContent(FlexAlign.Center)

    }
    .width("100%").height("100%")
    .priorityGesture(
      // 点击手势
      TapGesture({
        // 点击次数
        count: 2,
        // 一个手指
        fingers: 1
      }).onAction((event: GestureEvent)=>{
        console.log(this.TAG, "TapGesture onAction start");
        if(!event){
          return;
        }
        if(this.getImgInfo().scale != 1){
          this.getImgInfo().scale = 1;
          this.getImgInfo().offsetX = 0;
          this.getImgInfo().offsetY = 0;
          this.mMatrix = Matrix4.identity()
            .translate({
              x: this.getImgInfo().offsetX,
              y: this.getImgInfo().offsetY
            })
            .scale({
              x: this.getImgInfo().scale,
              y: this.getImgInfo().scale
            })
        }else{
          this.getImgInfo().scale = 2;
          this.mMatrix = Matrix4.identity()
            .translate({
              x: this.getImgInfo().offsetX,
              y: this.getImgInfo().offsetY
            })
            .scale({
              x: this.getImgInfo().scale,
              y: this.getImgInfo().scale
            })
        }

        console.log(this.TAG, "TapGesture onAction end");
      })
    )
    .gesture(GestureGroup(
      GestureMode.Parallel,
      // 缩放手势
      PinchGesture({
        // 两指缩放
        fingers: 2
      })
        .onActionStart(()=>{
          console.log(this.TAG, "PinchGesture onActionStart");
          this.tempScale = this.getImgInfo().scale;
        })
        .onActionUpdate((event)=>{
          console.log(this.TAG, "PinchGesture onActionUpdate" + JSON.stringify(event));
          if(event){
            this.getImgInfo().scale = this.tempScale * event.scale;
            this.mMatrix = Matrix4.identity()
              .translate({
                x: this.getImgInfo().offsetX,
                y: this.getImgInfo().offsetY
              })
              .scale({
                x: this.getImgInfo().scale,
                y: this.getImgInfo().scale
              })
          }
        })
        .onActionEnd(()=>{
          console.log(this.TAG, "PinchGesture onActionEnd");
 
        })
      ,
      // 拖动手势
      PanGesture()
        .onActionStart(()=>{
          console.log(this.TAG, "PanGesture onActionStart");
          this.startOffsetX = this.getImgInfo().offsetX;
          this.startOffsetY = this.getImgInfo().offsetY;
      })
        .onActionUpdate((event)=>{
          console.log(this.TAG, "PanGesture onActionUpdate" + JSON.stringify(event));
          if(event){
            let distanceX: number = this.startOffsetX + vp2px(event.offsetX) / this.getImgInfo().scale;
            let distanceY: number = this.startOffsetY + vp2px(event.offsetY) / this.getImgInfo().scale;
            this.getImgInfo().offsetX = distanceX;
            this.getImgInfo().offsetY = distanceY;
            this.mMatrix = Matrix4.identity()
              .translate({
                x: this.getImgInfo().offsetX,
                y: this.getImgInfo().offsetY
              })
              .scale({
                x: this.getImgInfo().scale,
                y: this.getImgInfo().scale
              })
          }
        })
        .onActionEnd(()=>{
          console.log(this.TAG, "PanGesture onActionEnd");
        })
    ))
  }
}
```

