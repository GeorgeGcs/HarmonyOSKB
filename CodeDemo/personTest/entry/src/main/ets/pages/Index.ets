// 导入媒体库工具包中的照片访问助手模块
import { photoAccessHelper } from '@kit.MediaLibraryKit';
// 导入图像工具包
import { image } from '@kit.ImageKit';
// 导入核心文件操作工具包，并将其重命名为fs
import { fileIo as fs } from '@kit.CoreFileKit';
// 导入ArkUI路由模块
import { router } from '@kit.ArkUI';
// 导入相机选择器模块
import { cameraPicker as picker } from '@kit.CameraKit';
// 导入相机模块
import { camera } from '@kit.CameraKit';
// 导入基础服务工具包中的业务错误类
import { BusinessError } from '@kit.BasicServicesKit';
// 导入自定义的裁剪管理器类
import { CropMgr } from '../manager/CropMgr';

// 模拟个人中心，头像裁剪功能DEMO首页
@Entry
@Component
struct Index {
  // 定义一个标签字符串，用于日志输出的标识
  private TAG: string = "imageTest";

  // 定义一个响应式状态变量，用于存储用户选择或拍摄的图片像素图，初始值为undefined
  @State mUserPixel: image.PixelMap | undefined = undefined;
  // 定义一个响应式状态变量，用于存储裁剪后的图片像素图，初始值为undefined
  @State mTargetPixel: image.PixelMap | undefined = undefined;

  /**
   * 拍照获取图片
   */
  private async getPictureFromCamera(){
    try {
      // 定义相机选择器的配置文件
      let pickerProfile: picker.PickerProfile = {
        // 相机的位置，设置为后置摄像头
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      // 调用相机选择器的pick方法，传入上下文、媒体类型（照片）和配置文件，返回选择结果
      let pickerResult: picker.PickerResult = await picker.pick(
        getContext(),
        [picker.PickerMediaType.PHOTO],
        pickerProfile
      );
      // 打印选择结果到控制台
      console.log(this.TAG, "the pick pickerResult is:" + JSON.stringify(pickerResult));
      // 如果选择结果存在且结果码为0（表示成功），则调用getImageByPath方法处理图片
      if(pickerResult && pickerResult.resultCode == 0){
        await this.getImageByPath(pickerResult.resultUri);
      }
    } catch (error) {
      // 将错误转换为业务错误类型
      let err = error as BusinessError;
      // 打印错误信息到控制台
      console.error(this.TAG, `the pick call failed. error code: ${err.code}`);
    }
  }

  /**
   * 相册选择图片
   */
  private async getPictureFromAlbum() {
    // 创建一个照片选择选项对象
    let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    // 设置选择的媒体类型为图片
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    // 设置最大选择数量为1张图片
    PhotoSelectOptions.maxSelectNumber = 1;
    // // 设置推荐选项，这里设置为二维码或条形码类型
    PhotoSelectOptions.recommendationOptions = {
      recommendationType: photoAccessHelper.RecommendationType.QR_OR_BAR_CODE
    }
    // 创建一个照片选择器对象
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    // 调用选择器的select方法，传入选择选项，返回选择结果
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(PhotoSelectOptions);
    // 获取选择的第一张图片的URI
    let albumPath = photoSelectResult.photoUris[0];
    // 打印选择的图片路径到控制台
    console.info(this.TAG, 'getPictureFromAlbum albumPath= ' + albumPath);
    // 调用getImageByPath方法处理选择的图片
    await this.getImageByPath(albumPath);
  }

  /**
   * 通过相册组件，自定义相册界面。
   */
  private getPictureFromAlbumComponent(){
    router.pushUrl({
      url: "pages/AlbumTestPage"
    })
  }

  /**
   * 获取图片pixelMap
   * @param path 图片的路径
   *
   */
  private async getImageByPath(path: string) {
    // 打印图片路径到控制台
    console.info(this.TAG, 'getImageByPath path: ' + path);
    // 设置裁剪管理器的URI为当前图片路径
    CropMgr.Ins().uri = path;
    try {
      // 以只读模式同步打开图片文件
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      // 获取图片文件的大小
      let photoSize = fs.statSync(file.fd).size;
      // 打印图片大小到控制台
      console.info(this.TAG, 'Photo Size: ' + photoSize);
      // 创建一个与图片大小相同的ArrayBuffer
      let buffer = new ArrayBuffer(photoSize);
      // 同步读取文件内容到ArrayBuffer中
      fs.readSync(file.fd, buffer);
      // 同步关闭文件
      fs.closeSync(file);
      // 使用ArrayBuffer创建一个图像源对象
      const imageSource = image.createImageSource(buffer);
      // 打印图像源信息到控制台
      console.log(this.TAG, 'imageSource: ' + JSON.stringify(imageSource));
      // 从图像源创建一个像素图对象，并赋值给mUserPixel
      this.mUserPixel = await imageSource.createPixelMap({});
    } catch (e) {
      // 打印错误信息到控制台
      console.info(this.TAG, 'getImage e: ' + JSON.stringify(e));
    }
  }

  // 页面显示时触发的生命周期函数
  onPageShow(): void {
    // 如果裁剪管理器中有目标图片
    let img = CropMgr.Ins().mTargetImg;
    if(img){
      // 将目标图片赋值给mTargetPixel
      this.mTargetPixel = img;
    }
  }

  aboutToDisappear(): void {
    // 调用裁剪管理器的销毁方法
    CropMgr.Ins().setDestroy();
  }

  @Styles borderCommonStyle(){
    .borderColor(Color.Black)
    .border({
      width: 3,        // 边框宽度
      color: Color.Black,  // 边框颜色
      style: BorderStyle.Solid  // 边框样式（实线）
    })
    .padding(10)
    .margin({
      top: px2vp(30)
    })
  }

  // 组件构建函数，用于定义组件的UI结构
  build() {
    // 创建一个可滚动视图
    Scroll(){
      // 在滚动视图中创建一个列布局
      Column() {
        // 创建一个文本组件，显示“点击拍照”
        Text("点击拍照")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .borderCommonStyle()
            // 点击文本时调用getPictureFromCamera方法
          .onClick(() => {
            this.getPictureFromCamera();
          })

        // 创建一个文本组件，显示“相册选择”
        Text("相册弹框选择")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
            // 点击文本时调用getPictureFromAlbum方法
          .onClick(() => {
            this.getPictureFromAlbum();
          })
          .borderCommonStyle()

        Text("相册组件选择")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
            // 点击文本时调用getPictureFromAlbumComponent方法
          .onClick(() => {
            this.getPictureFromAlbumComponent();
          })
          .borderCommonStyle()

        // 创建一个图像组件，显示用户选择或拍摄的图片
        Image(this.mUserPixel)
          .objectFit(ImageFit.Fill)
          .width('100%')
          .aspectRatio(1)
          .borderCommonStyle()

        // 创建一个文本组件，显示“图片裁剪”
        Text("跳转图片裁剪界面")
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .borderCommonStyle()
            // 点击文本时进行以下操作
          .onClick(() => {
            // 将用户选择或拍摄的图片赋值给裁剪管理器的源图片
            CropMgr.Ins().mSourceImg = this.mUserPixel;
            // 跳转到裁剪页面
            router.pushUrl({
              url: "pages/CropPage",
            })
          })

        // 创建一个文本组件，显示“图片裁剪-本地”
        Text("本地直接图片裁剪")
          .borderCommonStyle()
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
            // 点击文本时调用cropImage方法
          .onClick(() => {
            this.cropImage();
          })

        // 创建一个文本组件，显示“裁剪效果”
        Text("裁剪效果如下所示")
          .fontSize(40)
          .fontWeight(FontWeight.Bold)

        // 创建一个图像组件，显示裁剪后的图片
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

  /**
   * 本地裁剪图片
   */
  private async cropImage(){
    // 打印裁剪开始信息到控制台
    console.info(this.TAG, 'cropImage 1');
    // 如果用户没有选择或拍摄图片，则直接返回
    if(!this.mUserPixel){
      return;
    }
    // 打印裁剪继续信息到控制台
    console.info(this.TAG, 'cropImage 2');
    // 这里注释掉了复制像素图的操作，直接使用原像素图
    // let cp = await this.copyPixelMap(this.mUserPixel);
    let cp =this.mUserPixel;
    // 打印裁剪继续信息到控制台
    console.info(this.TAG, 'cropImage 3');
    // 定义裁剪区域
    let region: image.Region = { x: 0, y: 0, size: { width: 400, height: 400 } };
    // 打印裁剪区域信息到控制台
    console.info(this.TAG, 'cropImage 4');
    // 同步裁剪像素图
    cp.cropSync(region);
    // 打印裁剪完成信息到控制台
    console.info(this.TAG, 'cropImage 5');
    // 将裁剪后的像素图赋值给mTargetPixel
    this.mTargetPixel = cp;
    // 打印裁剪结果赋值信息到控制台
    console.info(this.TAG, 'cropImage 6');
  }

  /**
   * 复制像素图
   * @param pixel 要复制的像素图
   * @returns 复制后的像素图
   */
  async copyPixelMap(pixel: image.PixelMap): Promise<image.PixelMap> {
    // 获取像素图的图像信息
    const info: image.ImageInfo = await pixel.getImageInfo();
    // 创建一个与像素图字节数相同的ArrayBuffer
    const buffer: ArrayBuffer = new ArrayBuffer(pixel.getPixelBytesNumber());
    // 将像素图的像素数据读取到ArrayBuffer中
    await pixel.readPixelsToBuffer(buffer);
    // 定义创建像素图的初始化选项
    const opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      size: { height: info.size.height, width: info.size.width }
    };
    // 使用ArrayBuffer和初始化选项创建一个新的像素图并返回
    return image.createPixelMap(buffer, opts);
  }

}