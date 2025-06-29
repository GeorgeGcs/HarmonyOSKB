// 从 '../pages/CropPage' 模块中导入 LoadResult 类型
import { LoadResult } from '../pages/CropPage';

/**
 * 用于存储图片相关信息的类
 */
export class ImageInfo {
  // 图片的缩放比例，初始值为 1，表示不进行缩放
  scale: number = 1;
  // 图片在 X 轴方向的偏移量，初始值为 0
  offsetX: number = 0;
  // 图片在 Y 轴方向的偏移量，初始值为 0
  offsetY: number = 0;
  // 图片加载信息，使用从 '../pages/CropPage' 导入的 LoadResult 类型，并初始化为一个新的 LoadResult 实例
  loadResult: LoadResult = new LoadResult();
  // 取景框的宽度和高度（正圆形对应的矩形），初始值为 1000
  frameWidthHeight: number = 1000;
}

/**
 * 裁剪管理器类，负责管理裁剪相关的操作和数据
 */
export class CropMgr {
  // 静态变量，用于存储 CropMgr 类的单例实例，初始值为 null
  static mCropMgr: CropMgr | null = null;

  /**
   * 获取 CropMgr 类的单例实例
   * 如果实例已经存在，则直接返回；如果不存在，则创建一个新的实例并返回
   */
  static Ins() {
    if (CropMgr.mCropMgr) {
      return CropMgr.mCropMgr;
    }
    CropMgr.mCropMgr = new CropMgr();
    return CropMgr.mCropMgr;
  }

  // 源图片的像素图，初始值为 undefined
  public mSourceImg: PixelMap | undefined = undefined;
  // 图片的 URI 地址，初始值为空字符串
  public uri: string = "";

  // 保存裁剪后的图片的像素图，初始值为 undefined
  public mTargetImg: PixelMap | undefined = undefined;

  /**
   * 销毁裁剪管理器实例，将相关数据重置为初始状态
   */
  public setDestroy() {
    // 将裁剪后的图片像素图置为 undefined
    this.mTargetImg = undefined;
    // 将源图片像素图置为 undefined
    this.mSourceImg = undefined;
    // 将单例实例置为 null
    CropMgr.mCropMgr = null;
  }
}