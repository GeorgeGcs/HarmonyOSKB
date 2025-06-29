## 【HarmonyOS】Avatar Cropping with Gesture Zooming, Panning, and Double-Tap Control (Part 3)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  

### I. DEMO Effect Images  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/79c27d0231d047c99db7b84bdefb09e4b1862.png)  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/be7f060e1f7b4d1d9408373ce233106eb1862.png)  


### II. Development Approach  

1. **Matrix Transformation Control**: Use matrix transformations to handle image zooming and panning.  
2. **Gesture Listening**: Implement gesture operations by listening for:  
   - `TapGesture` (click gestures)  
   - `PinchGesture` (pinch-to-zoom gestures)  
   - `PanGesture` (pan gestures)  
3. **Matrix Parameter Assignment**: Assign matrix transformation parameters to the `image` component to synchronize gesture operations with image changes.  

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/54dac87a5e554e7a9bc6ac6426c8b0f7b1862.png)  

The matrix parameter uses a 4D coordinate system. Adjust the four parameters through gesture operations and apply them to the image via `.transform(this.mMatrix)`.  

Use the image's `onComplete(this.onLoadImgComplete)` callback to obtain the image component's width/height and content parameters as the basis for gesture adjustments.  


### III. DEMO Code Example  

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

  // Loaded image
  @State mImg: PixelMap | undefined = undefined;
  // Image matrix transformation parameters
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

    // Save the current cropped image
	// ...
    router.back();
  }

  /**
   * Copy pixel map
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
   * Image load callback
   */
  private onLoadImgComplete = (msg: LoadResult) => {
    this.getImgInfo().loadResult = msg;
    this.checkImageScale();
  }

  /**
   * Draw the viewfinder in the canvas
   */
  private onCanvasReady = ()=>{
    if(!this.mCanvasRenderingContext2D){
      console.error(this.TAG, "onCanvasReady error mCanvasRenderingContext2D null !");
      return;
    }
    let cr = this.mCanvasRenderingContext2D;
    // Canvas color
    cr.fillStyle = '#AA000000';
    let height = cr.height;
    let width = cr.width;
    cr.fillRect(0, 0, width, height);

    // Center point of the circle
    let centerX = width / 2;
    let centerY = height / 2;
    // Circle radius
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
      // Black background
      Row().width("100%").height("100%").backgroundColor(Color.Black)

      // User image
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

      // Viewfinder
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
        Button("Cancel")
          .size({
            width: px2vp(450),
            height: px2vp(200)
          })
          .onClick(this.onClickCancel)

        Blank()

        Button("Confirm")
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
      // Tap gesture
      TapGesture({
        // Tap count
        count: 2,
        // Single finger
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
      // Pinch gesture
      PinchGesture({
        // Two-finger pinch
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
      // Pan gesture
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