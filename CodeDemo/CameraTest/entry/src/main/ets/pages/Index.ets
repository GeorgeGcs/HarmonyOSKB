import { CameraMgr } from '../mgr/CameraMgr'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { EventHubUtils } from '../utils/EventHubUtils';
import { promptAction } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct Index {

  private TAG: string = "Index-CameraTest";

  @State userGrant: boolean = false // 是否已申请相机权限
  @State surfaceId: string = '' // xComponent组件生成id
  private mXComponentController: XComponentController = new XComponentController();

  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED,
    text: SaveDescription.SAVE_IMAGE,
    buttonType: ButtonType.Capsule
  }

  aboutToAppear(): void {
    EventHubUtils.getEventHub().on("saveImage", this.saveImage);

    this.requestCameraPermission();
  }

  aboutToDisappear(): void {
    EventHubUtils.getEventHub().off("saveImage", this.saveImage);
  }

  onPageShow(): void {
    console.log(this.TAG, "onPageShow");
  }

  saveImage = async ()=>{
    promptAction.showToast({
      message: "拍照成功"
    })
  }

  // 用户申请权限
  private async reqPermissionsFromUser(): Promise<number[]> {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA', "ohos.permission.MICROPHONE"]);
    return grantStatus.authResults;
  }

  private async requestCameraPermission() {
    let grantStatus = await this.reqPermissionsFromUser();
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        this.userGrant = true;
      }
    }
  }



  build() {
    Column() {
      if(this.userGrant){
        XComponent({
          id: 'componentId',
          type: XComponentType.SURFACE,
          controller: this.mXComponentController
        }).onLoad(()=>{
          this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
          // 初始化录像相机
          // CameraMgr.Ins().initVideoCamera(getContext(), this.surfaceId);
          CameraMgr.Ins().initCamera(getContext(), this.surfaceId);
        })
          .height('90%')
          .width('100%')
      }
      Button("拍照").onClick(()=>{
        CameraMgr.Ins().capturePhoto();
      })

      SaveButton(this.saveButtonOptions) // 创建安全控件按钮
        .onClick(async (event, result: SaveButtonOnClickResult) => {
          if (result == SaveButtonOnClickResult.SUCCESS) {
            try {
              // let fileUri = "file://com.test.cameratest" + CameraMgr.Ins().getImageUrl();
              let fileUri = CameraMgr.Ins().getImageUrl();
              // 需要确保fileUri对应的资源存在
              // let fileUri = 'file://com.test.cameratest/data/storage/el2/ba se/haps/entry/files/test.jpg';
              // let fileUri = 'file://com.example.temptest/data/storage/el2/base/haps/entry/files/test.jpg';

              console.info(this.TAG, 'SaveButton fileUri: ' + fileUri);

              // let fileArrayBuffer = CameraMgr.Ins().getImageAB();
              let context = getContext();
              let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);

              // let uri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
              // let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
              // await fileIo.write(file.fd, fileArrayBuffer);
              // await fileIo.close(file.fd);

              let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest = photoAccessHelper.MediaAssetChangeRequest.createVideoAssetRequest(context, fileUri);
              console.info(this.TAG, 'assetChangeRequest done');
              await phAccessHelper.applyChanges(assetChangeRequest);
              console.info(this.TAG, 'SaveButton createAsset successfully, uri: ' + assetChangeRequest.getAsset().uri);
              promptAction.showToast({
                message: "保存成功"
              })
            } catch (err) {
              console.error(this.TAG, `create asset failed with error: ${err.code}, ${err.message}`);
            }
          } else {
            console.error(this.TAG, 'SaveButtonOnClickResult create asset failed');
          }
        })
    }
    .height('100%')
    .width('100%')

  }
}