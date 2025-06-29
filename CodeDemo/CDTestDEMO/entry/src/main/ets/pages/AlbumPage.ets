import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 相册图片选择
 */
@Entry
@Component
struct AlbumPage {

  private TAG: string = "AlbumPage";

  onClickSelectPhoto = ()=>{
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // 设置筛选过滤条件
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      // 选择用户选择数量
      PhotoSelectOptions.maxSelectNumber = 1;
      // 添加图片目标筛选类型
      let recommendOptions: photoAccessHelper.RecommendationOptions = {
        recommendationType: photoAccessHelper.RecommendationType.ID_CARD | photoAccessHelper.RecommendationType.BANK_CARD | photoAccessHelper.RecommendationType.QR_CODE
      }
      PhotoSelectOptions.recommendationOptions = recommendOptions;
      // 实例化图片选择器
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      // 唤起安全相册组件
      photoPicker.select(PhotoSelectOptions, (err: BusinessError, PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (err) {
          console.error(this.TAG, "onClickSelectPhoto photoPicker.select error:" + JSON.stringify(err));
          return;
        }
        // 用户选择确认后，会回调到这里。
        console.info(this.TAG, "onClickSelectPhoto photoPicker.select successfully:" + JSON.stringify(PhotoSelectResult));
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(this.TAG, "onClickSelectPhoto photoPicker.select catch failed:" + JSON.stringify(err));
    }
  }

  build() {
    Row(){
      Button('点击唤起相册选择')
        .onClick(this.onClickSelectPhoto)
    }
    .justifyContent(FlexAlign.Center)
    .size({
      width: "100%",
      height: "100%"
    })
  }
}
