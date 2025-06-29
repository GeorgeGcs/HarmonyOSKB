// 导入鸿蒙路由模块，用于页面之间的导航
import router from '@ohos.router';
// 导入自定义的裁剪管理器类和图片信息类，用于管理图片裁剪相关的数据和操作
import { CropMgr, ImageInfo } from '../manager/CropMgr';
// 导入图像工具包，包含与图像操作相关的方法和属性
import { image } from '@kit.ImageKit';
// 导入矩阵类，用于图像的变换操作，如平移、缩放、旋转等
import Matrix4 from '@ohos.matrix4';
// 导入文件系统模块，用于文件的读取、写入等操作
import FS from '@ohos.file.fs';

// 定义加载结果类，用于存储图片加载的相关信息，如图片的宽高、组件的宽高、加载状态等
export class LoadResult {
  // 图片的宽度
  width: number = 0;
  // 图片的高度
  height: number = 0;
  // 组件的宽度
  componentWidth: number = 0;
  // 组件的高度
  componentHeight: number = 0;
  // 加载状态，表示图片加载的进度或是否加载成功等
  loadingStatus: number = 0;
  // 内容的宽度
  contentWidth: number = 0;
  // 内容的高度
  contentHeight: number = 0;
  // 内容在 X 轴的偏移量
  contentOffsetX: number = 0;
  // 内容在 Y 轴的偏移量
  contentOffsetY: number = 0;
}

/**
 * 定义裁剪页面组件，负责页面的 UI 展示和相关逻辑处理
 */
@Entry
@Component
export struct CropPage {
  // 定义标签字符串，用于日志输出的标识，方便在控制台中定位和排查问题
  private TAG: string = "CropPage";

  // 创建渲染上下文设置对象，设置为支持硬件加速，用于提高画布渲染的性能
  private mRenderingContextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  // 创建 2D 画布渲染上下文对象，用于在画布上绘制图形和图像
  private mCanvasRenderingContext2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.mRenderingContextSettings);

  // 用于存储加载的图片像素图，初始值为 undefined，在图片加载完成后赋值
  @State mImg: PixelMap | undefined = undefined;
  // 用于存储图片矩阵变换参数，定义了图片的平移和缩放初始状态
  @State mMatrix: object = Matrix4.identity()
    .translate({ x: 0, y: 0 })
    .scale({ x: 1, y: 1 });

  // 用于存储图片信息的对象，包含图片的各种属性和加载结果等信息
  @State mImageInfo: ImageInfo = new ImageInfo();

  // 临时缩放比例，在处理手势缩放操作时使用
  private tempScale = 1;
  // 起始偏移量 X，用于记录图片在 X 轴的初始位置
  private startOffsetX: number = 0;
  // 起始偏移量 Y，用于记录图片在 Y 轴的初始位置
  private startOffsetY: number = 0;

  // 页面即将出现时的生命周期函数，用于初始化数据或执行一些准备工作
  aboutToAppear(): void {
    console.log(this.TAG, "aboutToAppear start");
    // 从裁剪管理器中获取源图片
    let temp = CropMgr.Ins().mSourceImg;
    console.log(this.TAG, "aboutToAppear temp: " + JSON.stringify(temp));
    // 将源图片赋值给 mImg
    this.mImg = temp;
    console.log(this.TAG, "aboutToAppear end");
  }

  // 获取图片信息的方法，返回存储图片信息的对象
  private getImgInfo() {
    return this.mImageInfo;
  }

  // 点击取消按钮的回调函数，用于导航返回上一页
  onClickCancel = () => {
    router.back();
  }

  // 点击确认按钮的回调函数，处理图片裁剪和相关操作
  onClickConfirm = async () => {
    // 如果图片未加载，打印错误信息并返回，防止后续操作出现空指针异常
    if (!this.mImg) {
      console.error(this.TAG, " onClickConfirm mImg error null !");
      return;
    }

    // 获取图片信息中的加载结果
    let loadResult = this.getImgInfo().loadResult;
    // 获取图片信息
    let imgInfo = this.getImgInfo();

    // 计算图片适配控件时的宽度缩放比例
    let widthScale = loadResult.componentWidth / loadResult.width;
    // 计算图片适配控件时的高度缩放比例
    let heightScale = loadResult.componentHeight / loadResult.height;
    // 取宽度和高度缩放比例的最小值作为适配缩放比例
    let adaptScale = Math.min(widthScale, heightScale);

    // 计算经过两次缩放（适配控件、手势）后图片的实际显示宽度
    let totalScale = adaptScale * imgInfo.scale;
    // 计算经过两次缩放后图片的实际显示宽度
    let showWidth = loadResult.width * totalScale;
    // 计算经过两次缩放后图片的实际显示高度
    let showHeight = loadResult.height * totalScale;
    // 计算图片在 X 轴的显示位置
    let imageX = (loadResult.componentWidth - showWidth) / 2;
    // 计算图片在 Y 轴的显示位置
    let imageY = (loadResult.componentHeight - showHeight) / 2;
    // 计算图片左上角坐标
    let showX = imageX + this.getImgInfo().offsetX * this.getImgInfo().scale;
    // 计算图片右上角坐标
    let showY = imageY + this.getImgInfo().offsetY * this.getImgInfo().scale;
    // 计算取景框的左上角 X 坐标
    let frameX = (loadResult.componentWidth - this.getImgInfo().frameWidthHeight) / 2;
    // 计算取景框的左上角 Y 坐标
    let frameY = (loadResult.componentHeight - this.getImgInfo().frameWidthHeight) / 2;

    // 计算裁剪区域的 X 坐标
    let x = (frameX - showX) / totalScale;
    // 计算裁剪区域的 Y 坐标
    let y = (frameY - showY) / totalScale;

    // 以只读模式打开图片文件
    let file = FS.openSync(CropMgr.Ins().uri, FS.OpenMode.READ_ONLY);
    // 根据文件描述符创建图像源对象
    let imageSource: image.ImageSource = image.createImageSource(file.fd);
    // 定义解码选项，设置为可编辑和指定像素格式
    let decodingOptions: image.DecodingOptions = {
      editable: true,
      desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
    }
    // 根据解码选项创建像素图对象
    let temp = await imageSource.createPixelMap(decodingOptions);

    // 复制像素图
    let pm: PixelMap = await this.copyPixelMap(temp);
    // 释放临时像素图资源，防止内存泄漏
    temp.release();

    // 定义裁剪区域
    let region: image.Region = {
      x: x,
      y: y,
      size: {
        width: this.getImgInfo().frameWidthHeight / totalScale,
        height: this.getImgInfo().frameWidthHeight / totalScale
      }
    };
    // 同步裁剪像素图
    pm.cropSync(region);
    // 将裁剪后的像素图保存到裁剪管理器中
    CropMgr.Ins().mTargetImg = pm;
    // 导航返回上一页
    router.back();
  }

  /**
   * 复制图片的方法，用于复制像素图
   * @param pixel 要复制的像素图
   * @returns 复制后的像素图
   */
  async copyPixelMap(pixel: PixelMap): Promise<PixelMap> {
    // 获取像素图的图像信息
    const info: image.ImageInfo = await pixel.getImageInfo();
    // 创建与像素图字节数相同的 ArrayBuffer
    const buffer: ArrayBuffer = new ArrayBuffer(pixel.getPixelBytesNumber());
    // 将像素图的像素数据读取到 ArrayBuffer 中
    await pixel.readPixelsToBuffer(buffer);
    // 定义创建像素图的初始化选项
    const opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      size: { height: info.size.height, width: info.size.width }
    };
    // 根据 ArrayBuffer 和初始化选项创建新的像素图并返回
    return image.createPixelMap(buffer, opts);
  }

  // 图片加载完成的回调函数，处理加载结果并检查图片比例
  private onLoadImgComplete = (msg: LoadResult) => {
    // 将加载结果赋值给图片信息中的加载结果
    this.getImgInfo().loadResult = msg;
    // 检查并调整图片的缩放和位置
    this.checkImageScale();
  }

  // 画布准备好的回调函数，用于绘制取景框
  private onCanvasReady = () => {
    // 如果画布渲染上下文为空，打印错误信息并返回
    if (!this.mCanvasRenderingContext2D) {
      console.error(this.TAG, "onCanvasReady error mCanvasRenderingContext2D null !");
      return;
    }
    // 获取画布渲染上下文
    let cr = this.mCanvasRenderingContext2D;
    // 设置填充颜色
    cr.fillStyle = '#AA000000';
    // 获取画布高度
    let height = cr.height;
    // 获取画布宽度
    let width = cr.width;
    // 填充画布
    cr.fillRect(0, 0, width, height);

    // 计算圆形取景框的中心点 X 坐标
    let centerX = width / 2;
    // 计算圆形取景框的中心点 Y 坐标
    let centerY = height / 2;
    // 计算圆形取景框的半径
    let radius = Math.min(width, height) / 2 - px2vp(100);
    // 设置圆形取景框的半径为取景框宽度的一半
    radius = px2vp(this.getImgInfo().frameWidthHeight) / 2;
    // 设置全局合成操作模式
    cr.globalCompositeOperation = 'destination-out';
    // 设置填充颜色为白色
    cr.fillStyle = 'white';
    // 开始绘制路径
    cr.beginPath();
    // 绘制圆形路径
    cr.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    // 填充路径
    cr.fill();

    // 设置全局合成操作模式
    cr.globalCompositeOperation ='source-over';
    // 设置描边颜色
    cr.strokeStyle = '#FFFFFF';
    // 开始绘制路径
    cr.beginPath();
    // 绘制圆形路径
    cr.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    // 关闭路径
    cr.closePath();

    // 设置描边宽度
    cr.lineWidth = 1;
    // 绘制描边
    cr.stroke();
  }

  // 检查图片比例的方法，用于调整图片的缩放和位置，使其符合取景框的要求
  private checkImageScale() {
    // 获取图片信息中的偏移量 X
    let offsetX = this.getImgInfo().offsetX;
    // 获取图片信息中的偏移量 Y
    let offsetY = this.getImgInfo().offsetY;
    // 获取图片信息中的缩放比例
    let scale = this.getImgInfo().scale;
    console.log(this.TAG, " checkImageScale offsetX: " + offsetX + " offsetY: " + offsetY + " scale: " + scale);

    // 获取图片信息中的加载结果
    let loadResult = this.getImgInfo().loadResult;

    // 计算图片适配控件时的宽度缩放比例
    let widthScale = loadResult.componentWidth / loadResult.width;
    // 计算图片适配控件时的高度缩放比例
    let heightScale = loadResult.componentHeight / loadResult.height;
    // 取宽度和高度缩放比例的最小值作为适配缩放比例
    let adaptScale = Math.min(widthScale, heightScale);
    console.log(this.TAG, " checkImageScale adaptScale: " + adaptScale + " widthScale: " + widthScale + " heightScale: " + heightScale);

    // 计算经过两次缩放（适配控件、手势）后图片的实际显示宽度
    let showWidth = loadResult.width * adaptScale * this.getImgInfo().scale;
    // 计算经过两次缩放后图片的实际显示高度
    let showHeight = loadResult.height * adaptScale * this.getImgInfo().scale;
    // 计算图片在 X 轴的显示位置
    let imageX = (loadResult.componentWidth - showWidth) / 2;
    // 计算图片在 Y 轴的显示位置
    let imageY = (loadResult.componentHeight - showHeight) / 2;
    console.log(this.TAG, " checkImageScale imageX: " + imageX + " imageY: " + imageY);

    // 获取取景框的宽度
    let frameNum = this.getImgInfo().frameWidthHeight;
    // 计算取景框的左上角 X 坐标
    let frameX = (loadResult.componentWidth - frameNum) / 2;
    // 计算取景框的左上角 Y 坐标
    let frameY = (loadResult.componentHeight - frameNum) / 2;
    console.log(this.TAG, " checkImageScale frameX: " + frameX + " frameY: " + frameY);

    // 计算图片左上角坐标
    let showX = imageX + offsetX * scale;
    // 计算图片右上角坐标
    let showY = imageY + offsetY * scale;
    console.log(this.TAG, " checkImageScale showX: " + showX + " showY: " + showY);

    // 如果图片缩放后大小不足以填满取景框，调整图片
    if (frameNum > showWidth || frameNum > showHeight) {
      // 计算 X 轴方向的缩放比例
      let xScale = frameNum / showWidth;
      // 计算 Y 轴方向的缩放比例
      let yScale = frameNum / showHeight;
      // 取 X 轴和 Y 轴缩放比例的最大值作为新的缩放比例
      let newScale = Math.max(xScale, yScale);
      // 更新图片信息中的缩放比例
      this.getImgInfo().scale = this.getImgInfo().scale * newScale;
      // 更新图片的 X 坐标
      showX *= newScale;
      // 更新图片的 Y 坐标
      showY *= newScale;
    }
    console.log(this.TAG, " checkImageScale showX: " + showX + " showY: " + showY);

    // 调整 X 轴方向位置，使图像填满取景框
    if (showX > frameX) {
      showX = frameX;
    } else if (showX + showWidth < frameX + frameNum) {
      showX = frameX + frameNum - showWidth;
    }

    // 调整 Y 轴方向位置，使图像填满取景框
    if (showY > frameY) {
      showY = frameY;
    } else if (showY + showHeight < frameY + frameNum) {
      showY = frameY + frameNum - showHeight;
    }
    // 更新图片信息中的偏移量 X
    this.getImgInfo().offsetX = (showX - imageX) / scale;
    // 更新图片信息中的偏移量 Y
    this.getImgInfo().offsetY = (showY - imageY) / scale;
    console.log(this.TAG, " checkImageScale offsetX: " + offsetX + " offsetY: " + offsetY);

    // 更新图片的矩阵变换参数
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

  // 组件构建函数，用于定义组件的 UI 结构
  build() {
    // 创建相对容器，作为页面的整体布局容器
    RelativeContainer() {
      // 创建行容器，设置宽度和高度为 100%，背景颜色为黑色，作为页面的背景
      Row().width("100%").height("100%").backgroundColor(Color.Black)

      // 显示用户图片，设置对象适配方式为包含，宽度和高度为 100%，应用矩阵变换，并且在图片加载完成时调用 onLoadImgComplete 回调函数
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

      // 创建画布，设置宽度和高度为 100%，背景颜色为透明，应用相关规则和事件处理，用于绘制取景框等
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
        this.checkImageScale();
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
          this.checkImageScale();
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
          this.checkImageScale();
        })
    ))
  }
}