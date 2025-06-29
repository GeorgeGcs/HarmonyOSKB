**【HarmonyOS 5】Imitating Personal Center Avatar: Camera Capture, Gallery Selection, and Circular Cropping Display (Part 2)**  

**#HarmonyOS Development Capabilities**  
**#HarmonyOS SDK Application Services**  
**#HarmonyOS Financial Applications (Financial Management)**  



### Solution Approach:  
1. **Camera Integration**: Use CameraKit to capture photos and retrieve image URLs for processing.  
2. **Cropping View**: Implement a canvas-based viewfinder with support for:  
   - Gesture-based dragging and zooming.  
   - Crop calculations (detailed in Part 3).  


### Demo Code:  
**Main UI Interface**  
```dart  
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { router } from '@kit.ArkUI';
import { cameraPicker as picker } from '@kit.CameraKit';
import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CropView } from './CropView';

@Entry
@Component
struct Index {
  private TAG: string = "imageTest";

  @State mUserPixel: image.PixelMap | undefined = undefined;
  @State mTargetPixel: image.PixelMap | undefined = undefined;

  /**
   * Capture photo with camera
   */
  private async getPictureFromCamera(){
    try {
      let pickerProfile: picker.PickerProfile = {
        // Camera position
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: picker.PickerResult = await picker.pick(
        getContext(),
        [picker.PickerMediaType.PHOTO],
        pickerProfile
      );
      console.log(this.TAG, "the pick pickerResult is:" + JSON.stringify(pickerResult));
      // Process only on success
      if(pickerResult && pickerResult.resultCode == 0){
        await this.getImageByPath(pickerResult.resultUri);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `the pick call failed. error code: ${err.code}`);
    }
  }

  /**
   * Select photo from album
   */
  private async getPictureFromAlbum() {
    let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;

    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(PhotoSelectOptions);
    let albumPath = photoSelectResult.photoUris[0];
    console.info(this.TAG, 'getPictureFromAlbum albumPath= ' + albumPath);
    await this.getImageByPath(albumPath);
  }

  /**
   * Get image PixelMap
   * @param path
   */
  private async getImageByPath(path: string) {
    console.info(this.TAG, 'getImageByPath path: ' + path);
    try {
      // Read image to buffer
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      let photoSize = fs.statSync(file.fd).size;
      console.info(this.TAG, 'Photo Size: ' + photoSize);
      let buffer = new ArrayBuffer(photoSize);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      // Decode to PixelMap
      const imageSource = image.createImageSource(buffer);
      console.log(this.TAG, 'imageSource: ' + JSON.stringify(imageSource));
      this.mUserPixel = await imageSource.createPixelMap({});
    } catch (e) {
      console.info(this.TAG, 'getImage e: ' + JSON.stringify(e));
    }
  }

  build() {
    Scroll(){
      Column() {
        Text("Take Photo")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getPictureFromCamera();
          })

        Text("Select from Album")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getPictureFromAlbum();
          })

        Image(this.mUserPixel)
          .objectFit(ImageFit.Fill)
          .width('100%')
          .aspectRatio(1)

        Text("Crop Image")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.cropImage();
            // router.pushUrl({
            //   url: "pages/crop"
            // })
          })

        CropView({ mImg: $mUserPixel })
          .width('100%')
          .aspectRatio(1)

        Text("Cropped Result")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)

        Image(this.mTargetPixel)
            .width('100%')
            .aspectRatio(1)
            .borderRadius(200)

      }
      .height(3000)
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }

  private async cropImage(){
    if(!this.mUserPixel){
      return;
    }
    let cp = await this.copyPixelMap(this.mUserPixel);
    let region: image.Region = { x: 0, y: 0, size: { width: 400, height: 400 } };
    cp.cropSync(region);
  }

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
}
```  

**CropView Component**  
```dart  
interface LoadResult {
  width: number;
  height: number;
  componentWidth: number;
  componentHeight: number;
  loadingStatus: number;
  contentWidth: number;
  contentHeight: number;
  contentOffsetX: number;
  contentOffsetY: number;
}

@Component
export struct CropView {
  private TAG: string = "CropView";

  private mRenderingContextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private mCanvasRenderingContext2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.mRenderingContextSettings);

  @Link mImg: PixelMap;

  private onLoadImgComplete = (msg: LoadResult) => {
    // Handle image load completion
  }

  private onCanvasReady = ()=>{
    if(!this.mCanvasRenderingContext2D){
      console.error(this.TAG, "onCanvasReady error mCanvasRenderingContext2D null !");
      return;
    }
    let cr = this.mCanvasRenderingContext2D;
    // Canvas background
    cr.fillStyle = '#AA000000';
    let height = cr.height;
    let width = cr.width;
    cr.fillRect(0, 0, width, height);

    // Circular viewfinder
    let centerX = width / 2;
    let centerY = height / 2;
    let radius = Math.min(width, height) / 2 - 100;
    
    // Cut out circular area
    cr.globalCompositeOperation = 'destination-out';
    cr.fillStyle = 'white';
    cr.beginPath();
    cr.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    cr.fill();

    // Draw circular border
    cr.globalCompositeOperation = 'source-over';
    cr.strokeStyle = '#FFFFFF';
    cr.beginPath();
    cr.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    cr.closePath();
    cr.lineWidth = 1;
    cr.stroke();
  }

  build() {
    Stack() {
      // Black background
      Row().width("100%").height("100%").backgroundColor(Color.Black)

      // User image
      Image(this.mImg)
        .objectFit(ImageFit.Fill)
        .width('100%')
        .aspectRatio(1)
        .onComplete(this.onLoadImgComplete)

      // Viewfinder overlay
      Canvas(this.mCanvasRenderingContext2D)
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .onReady(this.onCanvasReady)
        .clip(true)
        .backgroundColor("#00000080")
    }.width("100%").height("100%")
  }
}
```  

*(Note: The code structure and technical terms are maintained according to HarmonyOS SDK conventions. All URLs and resource references are preserved as in the original Chinese version.)*
