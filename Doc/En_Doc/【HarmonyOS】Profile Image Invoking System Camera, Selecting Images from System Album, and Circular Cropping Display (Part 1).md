## 【HarmonyOS 5】Profile Image: Invoking System Camera, Selecting Images from System Album, and Circular Cropping Display (Part 1)  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications （Financial Management#  


### Solution Approach  

1. **System Album Image Selection**: Use `photoAccessHelper` to implement album selection. This API allows accessing the user's album via the system's secure album component without requiring explicit user authorization.  

2. **System Camera Invocation**: Use `startAbilityForResult` to jump to the system camera and return to the app after capturing a photo. **Note**: The `callBundleName` parameter in the `want` must match the app's package name; otherwise, the returned image URI will lack operation permissions.  

3. **Circular Cropping Display**: Use Image's `borderRadius` property to crop and display images in a circular shape. The actual image remains rectangular.  


### Demo Code Example  

```dart
import { common, Want } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';

@Entry
@Component
struct Index {
  private TAG: string = "imageTest";
  @State pixel: image.PixelMap | undefined = undefined;
  @State photoSize: number = 0;
  @State isCrop: boolean = false;
  context: common.UIAbilityContext | undefined = (getContext(this) as common.UIAbilityContext);
  savePath: string = getContext().filesDir;

  private async thirdPartyCall(supportMultiMode: boolean) {
    this.isCrop = false;
    console.log("thirdPartyCall savaPath=" + this.savePath);
    // Launch camera function
    let want: Want = {
      "action": 'ohos.want.action.imageCapture',
      "parameters": {
        supportMultiMode: supportMultiMode,
        // Critical: Must match the app's bundle name to access the returned image URI
        callBundleName: "com.example.persontest"
      }
    };
    // Get image URI
    if (this.context) {
      let result: common.AbilityResult = await this.context.startAbilityForResult(want);
      let params = result?.want?.parameters as Record<string, string | number>
      let imagePathSrc = params?.resourceUri as string;
      console.info(this.TAG, 'thirdPartyCall imagePathSrc= ' + imagePathSrc);
      console.info(this.TAG, 'thirdPartyCall params= ' + JSON.stringify(params));
      await this.getImage(imagePathSrc);
    }
  }

  private async getPictureFromAlbum() {
    this.isCrop = false;
    // Launch album for image selection
    let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(PhotoSelectOptions);
    let albumPath = photoSelectResult.photoUris[0];
    console.info(this.TAG, 'getPictureFromAlbum albumPath= ' + albumPath);
    await this.getImage(albumPath);
  }

  private async getImage(path: string) {
    console.info(this.TAG, 'getImage path: ' + path);
    try {
      // Read image as buffer
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      this.photoSize = fs.statSync(file.fd).size;
      console.info(this.TAG, 'Photo Size: ' + this.photoSize);
      let buffer = new ArrayBuffer(this.photoSize);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      // Decode to PixelMap
      const imageSource = image.createImageSource(buffer);
      console.log(this.TAG, 'imageSource: ' + JSON.stringify(imageSource));
      this.pixel = await imageSource.createPixelMap({});
    } catch (e) {
      console.info(this.TAG, 'getImage e: ' + JSON.stringify(e));
    }
  }

  private cropImage(){
    this.isCrop = true;
    // this.pixel?.crop({x: 0, y: 0, size: { height: 100, width: 100 } });
  }

  build() {
    Scroll(){
      Column() {
        Text("Click to Take Photo")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.thirdPartyCall(false);
          })

        Text("Select from Album")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getPictureFromAlbum();
          })

        Image(this.pixel)
          .width('100%')
          .aspectRatio(1)

        Text("Crop Image")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.cropImage();
          })

        if(this.isCrop){
          Image(this.pixel)
            .width('100%')
            .aspectRatio(1)
            .borderRadius(200)
        }

      }
      .height(3000)
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}
```
