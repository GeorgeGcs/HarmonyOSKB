## 【HarmonyOS】鸿蒙系统中应用权限等级介绍、定义、申请授权讲解

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#


针对权限等级，相对于主体来说，会有不同的细分概念。

**一、权限APL等级：**
首先在鸿蒙系统中，对于权限本身，分为三个等级：**normal，system_basic，system_core**。

1.普通应用为normal，可以访问相机，WIFI信息等资源

2.特殊应用为system_basic，可以访问例如用户身份认证等资源。

3.系统应用为system_core，所有系统资源都可访问。

该权限等级的划分原则是，授予的权限对用户隐私以及操作系统带来的风险程度。

**二、授权方式**
对于系统授权给应用的方式不同，分为两种授权**system_grant、user_grant**：
1. system_grant（系统授权），只要应用配置了，系统默认会授权。
2. user_grant（用户授权），应用需要配置，并且要在对应功能调用前主动申请，让用户抉择是否授权。

**三、访问控制列表ACL**
针对以上介绍，有一种场景需要解决，即：低APL等级的应用，某个业务场景需要使用高等级的权限。此时就需要ACL这种机制，为该应用，对于受限的权限单独开放绿色通道，可以访问。

如果应用涉及获取受限权限，在应用发布上架时，应用市场（AGC）将根据应用的使用场景审核是否可以使用对应的受限权限。如不符合，应用的上架申请将被驳回。

受限开放的权限通常是不允许三方应用申请的。如果有特殊场景需要使用，请提供相关申请材料到应用市场（AGC）申请相应权限证书。

整个过程很麻烦，建议使用Picker/控件等替代方案。

**四、一般应用Normal等级，权限申请处理路径：**

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/403340bd3daa4c5490c7679f753a6b31b1862.png)

**五、权限申请代码示例：**

**1. 首先我们需要在配置中对权限进行声明，以马达振动和相机权限为例：**

在对应模块的module.json5配置中，添加requestPermissions节点和对应权限的配置：

```dart

{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "phone",
      "tablet",
      "2in1"
    ],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:EntryAbility_desc",
        "icon": "$media:layered_image",
        "label": "$string:EntryAbility_label",
        "startWindowIcon": "$media:startIcon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": [
              "entity.system.home"
            ],
            "actions": [
              "action.system.home"
            ]
          }
        ]
      }
    ],
    // 在对应模块的module.json5配置中，添加requestPermissions节点和对应权限的配置：
    "requestPermissions": [
      {
      	// 马达振动作为系统权限，不需要用户授权同意
        "name": "ohos.permission.VIBRATE"
      },
      {
  		// 相机权限为用户权限，需要用户授权同意。所以要对权限使用的原因和场景进行描述。
        "name": "ohos.permission.CAMERA",
        "reason": "$string:Camera_reason",
        "usedScene": {
          "when": "always"
        }
      }
    ]
  }
}
```

-------------

***具体权限对应的分类参见：[应用权限列表](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/permissions-for-all-V5?catalogVersion=V5) 如果不能访问说明不是白名单账户。***

---------------------

**2.用户授权的权限在功能使用前，需要进行授权申请。**

传统应用开发请求权限时，特别是Android，一般是在应用启动时进行申请。这种方式用户体验很差，自从IOS要求应用在用户不授权时，也能使用其他非授权功能的政策后。

目前应用授权的主流方式，已从应用开屏贴脸找用户要权限。进化为，点击启用某个业务功能时再授权。例如调用相机时，一般会从唤起相机功能的入口按钮处进行授权申请，用户不同意就不让用户进入，并且tips提示用户。

-----------

***注意：主动申请用户判定是否授权时，若用户拒绝了该授权。之后应用再申请该权限，默认就会返回失败。需要通知用户去设置界面，给该权限授权。就不能通过弹框的形式直接处理了，此时授权场景已经转交给系统。***

---------------

```dart
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

/**
 * 权限工具
 */
export class PermissionsUtil{

  static async reqPermissionsFromUser(): Promise<number[]> {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
    return grantStatus.authResults;
  }

  /**
   * 申请相机权限
   * @returns 
   */
  static async requestCameraPermission() {
    let grantStatus = await PermissionsUtil.reqPermissionsFromUser()
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        return true;
      }
    }
    return false;
  }
}
```

```dart
import { PermissionsUtil } from '../../utils/PermissionsUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

/**
 * 多层嵌套刷新渲染
 */
@Entry
@Component
struct permissionPage {

  private TAG: string = "permissionPage";

  private showToast(content: string){
    try {
      promptAction.showToast({
        message: content,
        duration: 2000
      });
    } catch (error) {
      let message = (error as BusinessError).message
      let code = (error as BusinessError).code
      console.error(this.TAG, `showToast args error code is ${code}, message is ${message}`);
    };
  }

  onClickCamera = async ()=>{
    console.log(this.TAG, " onClickCamera");
    let isUserGrant: boolean = await PermissionsUtil.requestCameraPermission();
    if(isUserGrant){
      this.showToast("用户同意授权");
    }else{
      this.showToast("用户拒绝授权");
    }
  }

  build() {
    Row(){
      Button("调用相机")
        .fontSize(px2vp(42))
        .size({
          width: px2vp(350),
          height: px2vp(200)
        })
        .onClick(this.onClickCamera)
    }
    .size({
      width: "100%",
      height: "100%"
    })
    .justifyContent(FlexAlign.Center)
  }
}
```

