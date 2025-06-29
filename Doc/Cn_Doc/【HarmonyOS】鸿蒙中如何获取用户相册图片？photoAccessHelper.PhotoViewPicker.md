## 【HarmonyOS】鸿蒙中如何获取用户相册图片？photoAccessHelper.PhotoViewPicker

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 鸿蒙中获取用户相册的方式介绍

上一篇文章提到华为的隐私安全策略，目前几篇文章的思路是介绍Android和IOS中常见的访问用户信息的API，来对比给大家看，鸿蒙中的获取方式。

获取相册是我们最常见的操作了，目前华为是不提倡APP访问用户所有相册资源。说实话，我在使用IOS手机时，就喜欢权限设置里带的访问选择图片功能。不像安卓一样，获取用户授权后，APP就能访问到用户相册所有的图片。而是用户勾选开发给APP的图片，APP只能访问这些。这是IOS的做法。当然IOS也保留了，和Android类似的所有图片开放权限。

而华为鸿蒙中的效果，类似于Android调用系统相册，用户勾选后，将图片传递给APP的效果。在这个逻辑之上，鸿蒙封装了相册安全组件。我们通过调用API的属性设置，可以将相册组件做条件筛选。例如二维码，条码，身份证等等。

## 代码讲解

**photoAccessHelper** 是系统提供给我们访问用户相册的系统API，通过这个接口集，我们能创建相册以及访问、修改相册中的媒体数据信息等。

**PhotoViewPicker**是其子API，提供图库选择器对象，用来支撑选择图片/视频等用户场景。

**PhotoSelectOptions**图库选择选项设置对象。通过该对象的设置属性进行赋值，满足我们对图库选择器的一些个性化定制。（当然它是有基类，我们就不展开了）

值得注意的是，目前API更多很快。photoAccessHelper的形式，已经是官方推荐调用选择相册的API。逐步不维护原先picker【picker.PhotoViewPicker(context)】的形式了。目前picker的调用在beta1最新系统中，效果是很差的。首先会打开一个白色底图的空白界面，然后弹出相册组件。也不支持条件筛选功能，例如条码那些。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/22519f3144544177a9754b23a0a1a56a.png)

```dart
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 相册图片选择
 */
@Entry
@Component
struct AlbumSelectPage {

  private TAG: string = "AlbumSelectPage";

  onClickSelectPhoto = ()=>{
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      // 设置筛选过滤条件
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      // 选择用户选择数量
      PhotoSelectOptions.maxSelectNumber = 1;
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
```

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/a9d2820b377246949ed85c6800d46144b1862.png)

