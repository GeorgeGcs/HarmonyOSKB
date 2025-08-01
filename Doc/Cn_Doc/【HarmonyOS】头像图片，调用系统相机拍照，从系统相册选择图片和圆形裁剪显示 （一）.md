## 【HarmonyOS】头像图片，调用系统相机拍照，从系统相册选择图片和圆形裁剪显示 （一）

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## Demo效果展示：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/f2001654e5464637a4b5ad85b29eb6c6b1862.png)

## 方案思路：

使用**photoAccessHelper**实现系统相册选择图片的功能。此API可在无需用户授权的情况下，通过系统的安全相册组件访问用户所有的相册内容。

使用**startAbilityForResult**实现跳转到系统相机，进行拍照后，返回当前应用的功能。需要注意的是**want参数中callBundleName一定要为当前应用的包名，否则会导致返回过来的图片uri参数，没有操作权限。**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/29682a0840e34b618fd3fb3b71b276b9b1862.png)

使用Image的**borderRadius**展示圆形图片，进行裁剪展示。实际图片还是为矩形。

手势放大缩小，滑动图片进行圆形裁剪的效果，参见第二篇文章。

## Demo示例代码：

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
    // 拉起拍照功能
    let want: Want = {
      "action": 'ohos.want.action.imageCapture',
      "parameters": {
        supportMultiMode: supportMultiMode,
        // 回调包名很重要，若不匹配将无法获取返回图片Uri的操作权限
        callBundleName: "com.example.persontest"
      }
    };
    // 获取图片uri
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
    // 拉起相册，选择图片
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
      // 读取图片为buffer
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      this.photoSize = fs.statSync(file.fd).size;
      console.info(this.TAG, 'Photo Size: ' + this.photoSize);
      let buffer = new ArrayBuffer(this.photoSize);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      // 解码成PixelMap
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
        Text("点击拍照")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.thirdPartyCall(false);
          })

        Text("相册选择")
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getPictureFromAlbum();
          })

        Image(this.pixel)
          .width('100%')
          .aspectRatio(1)

        Text("图片裁剪")
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

