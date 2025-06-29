import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { EventHubUtils } from '../utils/EventHubUtils';

export class CameraMgr {
  private TAG: string = "CameraMgr";

  private static mCameraMgr: CameraMgr | null = null;

  private mCameraInput: camera.CameraInput | undefined = undefined;
  private mPreviewOutput: camera.PreviewOutput | undefined = undefined;

  private mPhotoSession: camera.PhotoSession | undefined = undefined;
  private mPhotoOutput: camera.PhotoOutput | undefined = undefined;

  private mVideoSession: camera.VideoSession | undefined = undefined;
  private mVideoOutput: camera.VideoOutput | undefined = undefined;
  private mAvRecorder: media.AVRecorder | undefined = undefined;

  private mFile: fs.File | null = null;

  private mImageUrl: string = "";
  private mImageArrayBuffer: ArrayBuffer | null = null;

  public static Ins(): CameraMgr {
    if (CameraMgr.mCameraMgr) {
      return CameraMgr.mCameraMgr
    }
    CameraMgr.mCameraMgr = new CameraMgr();
    return CameraMgr.mCameraMgr
  }

  public getImageUrl(){
    return this.mImageUrl;
  }

  public getImageAB(){
    return this.mImageArrayBuffer;
  }

  /**
   * 初始化相机
   * @param baseContext
   * @param surfaceId
   */
  public async initCamera(baseContext: common.Context, surfaceId: string) {
    // 创建CameraManager对象
    let cameraManager: camera.CameraManager = camera.getCameraManager(baseContext);
    if (!cameraManager) {
      console.error(this.TAG, "camera.getCameraManager error");
      return;
    }
    // 监听相机状态变化
    cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      if (err !== undefined && err.code !== 0) {
        console.error(this.TAG, 'cameraStatus with errorCode = ' + err.code);
        return;
      }
      console.info(`camera : ${cameraStatusInfo.camera.cameraId}`);
      console.info(`status: ${cameraStatusInfo.status}`);
    });

    // 获取相机列表
    let cameraArray: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    if (cameraArray.length <= 0) {
      console.error(this.TAG, "cameraManager.getSupportedCameras error");
      return;
    }

    for (let index = 0; index < cameraArray.length; index++) {
      console.info('cameraId : ' + cameraArray[index].cameraId); // 获取相机ID
      console.info('cameraPosition : ' + cameraArray[index].cameraPosition); // 获取相机位置
      console.info('cameraType : ' + cameraArray[index].cameraType); // 获取相机类型
      console.info('connectionType : ' + cameraArray[index].connectionType); // 获取相机连接类型
    }

    // 创建相机输入流
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      // 配置后置摄像头
      cameraInput = cameraManager.createCameraInput(cameraArray[0]);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to createCameraInput errorCode = ' + err.code);
    }
    if (cameraInput === undefined) {
      return;
    }
    this.mCameraInput = cameraInput;
    // 监听cameraInput错误信息
    let cameraDevice: camera.CameraDevice = cameraArray[0];
    cameraInput.on('error', cameraDevice, (error: BusinessError) => {
      console.error(this.TAG, `Camera input error code: ${error.code}`);
    })

    // 打开相机
    await cameraInput.open();

    // 获取支持的模式类型
    let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(cameraArray[0]);
    let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
    if (!isSupportPhotoMode) {
      console.error(this.TAG, 'photo mode not support');
      return;
    }
    // 获取相机设备支持的输出流能力
    let cameraOutputCap: camera.CameraOutputCapability =
      cameraManager.getSupportedOutputCapability(cameraArray[0], camera.SceneMode.NORMAL_PHOTO);
    if (!cameraOutputCap) {
      console.error(this.TAG, "cameraManager.getSupportedOutputCapability error");
      return;
    }
    console.info("outputCapability: " + JSON.stringify(cameraOutputCap));

    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    if (!previewProfilesArray) {
      console.error(this.TAG, "createOutput previewProfilesArray == null || undefined");
    }

    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;
    if (!photoProfilesArray) {
      console.error(this.TAG, "createOutput photoProfilesArray == null || undefined");
    }

    // 创建预览输出流
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfilesArray[0], surfaceId);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to create the PreviewOutput instance. error code: ${err.code}`);
    }
    if (previewOutput === undefined) {
      return;
    }
    this.mPreviewOutput = previewOutput;
    // 监听预览输出错误信息
    previewOutput.on('error', (error: BusinessError) => {
      console.error(this.TAG, `Preview output error code: ${error.code}`);
    });

    // 创建拍照输出流
    let photoOutput: camera.PhotoOutput | undefined = undefined;
    try {
      photoOutput = cameraManager.createPhotoOutput(photoProfilesArray[0]);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to createPhotoOutput errorCode = ' + err.code);
    }
    if (photoOutput === undefined) {
      return;
    }

    this.mPhotoOutput = photoOutput;
    //调用上面的回调函数来保存图片
    this.setPhotoOutput();

    //创建会话
    let photoSession: camera.PhotoSession | undefined = undefined;
    try {
      photoSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to create the session instance. errorCode = ' + err.code);
    }
    if (photoSession === undefined) {
      return;
    }
    this.mPhotoSession = photoSession;
    // 监听session错误信息
    photoSession.on('error', (error: BusinessError) => {
      console.error(this.TAG, `Capture session error code: ${error.code}`);
    });

    // 开始配置会话
    try {
      photoSession.beginConfig();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to beginConfig. errorCode = ' + err.code);
    }

    // 向会话中添加相机输入流
    try {
      photoSession.addInput(cameraInput);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to addInput. errorCode = ' + err.code);
    }

    // 向会话中添加预览输出流
    try {
      photoSession.addOutput(previewOutput);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to addOutput(previewOutput). errorCode = ' + err.code);
    }

    // 向会话中添加拍照输出流
    try {
      photoSession.addOutput(photoOutput);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to addOutput(photoOutput). errorCode = ' + err.code);
    }

    // 提交会话配置
    await photoSession.commitConfig();

    // 启动会话
    await photoSession.start().then(() => {
      console.info('Promise returned to indicate the session start success.');
    });
    // 判断设备是否支持闪光灯
    let flashStatus: boolean = false;
    try {
      flashStatus = photoSession.hasFlash();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to hasFlash. errorCode = ' + err.code);
    }
    console.info('Returned with the flash light support status:' + flashStatus);

    if (flashStatus) {
      // 判断是否支持自动闪光灯模式
      let flashModeStatus: boolean = false;
      try {
        let status: boolean = photoSession.isFlashModeSupported(camera.FlashMode.FLASH_MODE_AUTO);
        flashModeStatus = status;
      } catch (error) {
        let err = error as BusinessError;
        console.error(this.TAG, 'Failed to check whether the flash mode is supported. errorCode = ' + err.code);
      }
      if (flashModeStatus) {
        // 设置自动闪光灯模式
        try {
          photoSession.setFlashMode(camera.FlashMode.FLASH_MODE_AUTO);
        } catch (error) {
          let err = error as BusinessError;
          console.error(this.TAG, 'Failed to set the flash mode. errorCode = ' + err.code);
        }
      }
    }

    // 判断是否支持连续自动变焦模式
    let focusModeStatus: boolean = false;
    try {
      let status: boolean = photoSession.isFocusModeSupported(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
      focusModeStatus = status;
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to check whether the focus mode is supported. errorCode = ' + err.code);
    }

    if (focusModeStatus) {
      // 设置连续自动变焦模式
      try {
        photoSession.setFocusMode(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
      } catch (error) {
        let err = error as BusinessError;
        console.error(this.TAG, 'Failed to set the focus mode. errorCode = ' + err.code);
      }
    }

    // 获取相机支持的可变焦距比范围
    let zoomRatioRange: Array<number> = [];
    try {
      zoomRatioRange = photoSession.getZoomRatioRange();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to get the zoom ratio range. errorCode = ' + err.code);
    }
    if (zoomRatioRange.length <= 0) {
      return;
    }
    // 设置可变焦距比
    try {
      photoSession.setZoomRatio(zoomRatioRange[0]);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, 'Failed to set the zoom ratio value. errorCode = ' + err.code);
    }


  }

  /**
   * 相机拍照
   */
  public capturePhoto() {
    let photoCaptureSetting: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH, // 设置图片质量高
      rotation: camera.ImageRotation.ROTATION_0 // 设置图片旋转角度0
    }
    // 使用当前拍照设置进行拍照
    this.mPhotoOutput?.capture(photoCaptureSetting, (err: BusinessError) => {
      if (err) {
        console.error(this.TAG, `Failed to capture the photo ${err.message}`);
        return;
      }
      console.info('Callback invoked to indicate the photo capture request success.');
    });
  }

  /**
   * 销毁相机
   */
  public async destroyCamera() {

    // 需要在拍照结束之后调用以下关闭摄像头和释放会话流程，避免拍照未结束就将会话释放。
    // 停止当前会话
    await this.mPhotoSession?.stop();

    // 释放相机输入流
    await this.mCameraInput?.close();

    // 释放预览输出流
    await this.mPreviewOutput?.release();

    // 释放拍照输出流
    await this.mPhotoOutput?.release();

    // 释放会话
    await this.mPhotoSession?.release();

    // 会话置空
    this.mPhotoSession = undefined;
  }

  /**
   * 设置相机拍照回调
   */
  public setPhotoOutput() {
    // 设置回调之后，调用photoOutput的capture方法，就会将拍照的buffer回传到回调中
    this.mPhotoOutput?.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
      console.info('getPhoto start');
      console.info(`err: ${JSON.stringify(errCode)}`);
      if (errCode || photo === undefined) {
        console.error(this.TAG, 'getPhoto failed');
        return;
      }
      let imageObj = photo.main;
      imageObj.getComponent(image.ComponentType.JPEG, (errCode: BusinessError, component: image.Component): void => {
        console.info('getComponent start');
        if (errCode || component === undefined) {
          console.error(this.TAG, 'getComponent failed');
          return;
        }
        let buffer: ArrayBuffer;
        if (component.byteBuffer) {
          buffer = component.byteBuffer;
        } else {
          console.error(this.TAG, 'byteBuffer is null');
          return;
        }
        this.mImageArrayBuffer = buffer;
        // let pathDir = getContext().filesDir;
        // let filePath = pathDir + "/test.txt";
        // let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        // let str: string = "hello, world";
        // let writeLenStr = fs.writeSync(file.fd, str);
        // console.info(this.TAG, "write data to file succeed and size is:" + writeLenStr);
        // fs.closeSync(file);

        // let fileDir = getContext().getApplicationContext().filesDir;
        // // 创建图片目录
        // let fileSavePath = fileDir + "/image/";
        // let res = fs.accessSync(fileSavePath);
        // if(res){
        //   fs.mkdirSync(fileSavePath, true);
        // }
        // fileSavePath = fileSavePath  + new Date().getTime() + ".png";
        // //  fileUri: file://com.test.cameratest/data/storage/el2/base/filesimage1732782332425.png

        let pathDir = getContext().filesDir;
        let fileSavePath = pathDir + "/test.jpg";
        console.log(this.TAG, "getVideoUrl fileSavePath: " + fileSavePath);

        let fd: number = 0;
        try {
          let targetFile = fs.openSync(fileSavePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
          fd = targetFile.fd;
          this.mImageUrl = fileUri.getUriFromPath(targetFile.path)
        } catch (e) {
          console.error(this.TAG, "targetFile openSync: " + JSON.stringify(e));
        }

        let writeLen = fs.writeSync(fd, buffer);
        console.info(this.TAG, "write data to file succeed and size is:" + writeLen);
        fs.closeSync(fd);
        // buffer处理结束后需要释放该资源，如果未正确释放资源会导致后续拍照获取不到buffer
        imageObj.release();

        EventHubUtils.getEventHub().emit("saveImage");
      });
    });
  }


  private getVideoUrl(): number {
    let fileDir = getContext().getApplicationContext().filesDir;
    // 创建图片目录
    let fileSavePath = fileDir + "image";
    let res = fs.accessSync(fileSavePath);
    if(res){
      fs.mkdirSync(fileSavePath, true);
    }
    fileSavePath = fileSavePath  + new Date().getTime() + ".mp4";
    console.log(this.TAG, "getVideoUrl fileSavePath: " + fileSavePath);
    let targetFile = fs.openSync(fileSavePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    let fd = targetFile.fd;
    fs.closeSync(fd);
    return fd;
  }


  /**
   * 初始化视频相机
   * @param context
   * @param surfaceId
   * @returns
   */
  public async initVideoCamera(context: common.Context, surfaceId: string): Promise<void> {
    console.log(this.TAG, "initVideoCamera start");
    // 创建CameraManager对象
    let cameraManager: camera.CameraManager = camera.getCameraManager(context);
    if (!cameraManager) {
      console.error(this.TAG, "camera.getCameraManager error");
      return;
    }
    console.log(this.TAG, "cameraManager");

    // 监听相机状态变化
    cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      if (err !== undefined && err.code !== 0) {
        console.error(this.TAG, 'cameraStatus with errorCode = ' + err.code);
        return;
      }
      console.info(`camera : ${cameraStatusInfo.camera.cameraId}`);
      console.info(`status: ${cameraStatusInfo.status}`);
    });

    // 获取相机列表
    let cameraArray: Array<camera.CameraDevice> = [];
    try {
      cameraArray = cameraManager.getSupportedCameras();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `getSupportedCameras call failed. error code: ${err.code}`);
    }

    if (cameraArray.length <= 0) {
      console.error(this.TAG, "cameraManager.getSupportedCameras error");
      return;
    }
    console.log(this.TAG, "cameraArray.length: " + cameraArray.length);

    // 获取支持的模式类型
    let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(cameraArray[0]);
    let isSupportVideoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_VIDEO) >= 0;
    if (!isSupportVideoMode) {
      console.error(this.TAG, 'video mode not support');
      return;
    }
    console.log(this.TAG, "isSupportVideoMode: " + isSupportVideoMode);

    // 获取相机设备支持的输出流能力
    let cameraOutputCap: camera.CameraOutputCapability =
      cameraManager.getSupportedOutputCapability(cameraArray[0], camera.SceneMode.NORMAL_VIDEO);
    if (!cameraOutputCap) {
      console.error(this.TAG, "cameraManager.getSupportedOutputCapability error")
      return;
    }
    console.log(this.TAG, "outputCapability: " + JSON.stringify(cameraOutputCap));

    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    if (!previewProfilesArray) {
      console.error(this.TAG, "createOutput previewProfilesArray == null || undefined");
    }

    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;
    if (!photoProfilesArray) {
      console.error(this.TAG, "createOutput photoProfilesArray == null || undefined");
    }

    let videoProfilesArray: Array<camera.VideoProfile> = cameraOutputCap.videoProfiles;
    if (!videoProfilesArray) {
      console.error(this.TAG, "createOutput videoProfilesArray == null || undefined");
    }
    // videoProfile的宽高需要与AVRecorderProfile的宽高保持一致，并且需要使用AVRecorderProfile锁支持的宽高
    let videoSize: camera.Size = {
      width: 640,
      height: 480
    }
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      return profile.size.width === videoSize.width && profile.size.height === videoSize.height;
    });
    if (!videoProfile) {
      console.error(this.TAG, 'videoProfile is not found');
      return;
    }
    console.log(this.TAG, "videoProfile: " + JSON.stringify(videoProfile));

    // 配置参数以实际硬件设备支持的范围为准
    let aVRecorderProfile: media.AVRecorderProfile = {
      audioBitrate: 48000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: 2000000,
      videoCodec: media.CodecMimeType.VIDEO_AVC,
      videoFrameWidth: videoSize.width,
      videoFrameHeight: videoSize.height,
      videoFrameRate: 30
    };
    console.log(this.TAG, "aVRecorderProfile: " + JSON.stringify(aVRecorderProfile));

    // let options: photoAccessHelper.CreateOptions = {
    //   title: Date.now().toString()
    // };
    // let accessHelper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    // console.log(this.TAG, "-----------1 ");
    // try {
      // TODO 此接口在未申请相册管理模块权限'ohos.permission.WRITE_IMAGEVIDEO'时，可以使用安全控件创建媒体资源
    //   let videoUri: string = await accessHelper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', options);
    //   console.log(this.TAG, "-----------2 ");
    //
    //   this.mFile = fs.openSync(videoUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    //   console.log(this.TAG, "-----------3 ");
    // } catch (e) {
    //   console.log(this.TAG, "-----------e: " + JSON.stringify(e));
    // }

    // let tempUrl = `fd://${this.mFile?.fd.toString()}`;

    let tempUrl = `fd://${ this.getVideoUrl().toString()}`;
    console.log(this.TAG, "tempUrl: " + tempUrl);

    let aVRecorderConfig: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: aVRecorderProfile,
      url: tempUrl, // 文件需先由调用者创建，赋予读写权限，将文件fd传给此参数，eg.fd://45--file:///data/media/01.mp4
      rotation: 0, // 合理值0、90、180、270，非合理值prepare接口将报错
      location: { latitude: 30, longitude: 130 }
    };
    console.log(this.TAG, "aVRecorderConfig: " + JSON.stringify(aVRecorderConfig));

    let avRecorder: media.AVRecorder | undefined = undefined;
    try {
      avRecorder = await media.createAVRecorder();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `createAVRecorder call failed. error code: ${err.code}`);
    }

    if (avRecorder === undefined) {
      return;
    }
    console.log(this.TAG, "avRecorder init" );
    this.mAvRecorder = avRecorder;

    try {
      await avRecorder.prepare(aVRecorderConfig);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `prepare call failed. error code: ${err.code}`);
    }
    console.log(this.TAG, "avRecorder prepare" );

    let videoSurfaceId: string | undefined = undefined; // 该surfaceID用于传递给相机接口创造videoOutput
    try {
      videoSurfaceId = await avRecorder.getInputSurface();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `getInputSurface call failed. error code: ${err.code}`);
    }
    if (videoSurfaceId === undefined) {
      return;
    }
    console.log(this.TAG, "videoSurfaceId: " + videoSurfaceId );

    // 创建VideoOutput对象
    let videoOutput: camera.VideoOutput | undefined = undefined;
    try {
      videoOutput = cameraManager.createVideoOutput(videoProfile, videoSurfaceId);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to create the videoOutput instance. error: ${JSON.stringify(err)}`);
    }
    if (videoOutput === undefined) {
      return;
    }
    console.log(this.TAG, "videoOutput done ");
    this.mVideoOutput = videoOutput;
    // 监听视频输出错误信息
    videoOutput.on('error', (error: BusinessError) => {
      console.error(this.TAG, `Preview output error code: ${error.code}`);
    });

    //创建会话
    let videoSession: camera.VideoSession | undefined = undefined;
    try {
      videoSession = cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to create the session instance. error: ${JSON.stringify(err)}`);
    }
    if (videoSession === undefined) {
      return;
    }
    this.mVideoSession = videoSession;
    // 监听session错误信息
    videoSession.on('error', (error: BusinessError) => {
      console.error(this.TAG, `Video session error code: ${error.code}`);
    });

    // 开始配置会话
    try {
      videoSession.beginConfig();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to beginConfig. error: ${JSON.stringify(err)}`);
    }

    // 创建相机输入流
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraArray[0]);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to createCameraInput. error: ${JSON.stringify(err)}`);
    }
    if (cameraInput === undefined) {
      return;
    }
    this.mCameraInput = cameraInput;
    // 监听cameraInput错误信息
    let cameraDevice: camera.CameraDevice = cameraArray[0];
    cameraInput.on('error', cameraDevice, (error: BusinessError) => {
      console.error(this.TAG, `Camera input error code: ${error.code}`);
    });

    // 打开相机
    try {
      await cameraInput.open();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to open cameraInput. error: ${JSON.stringify(err)}`);
    }

    // 向会话中添加相机输入流
    try {
      videoSession.addInput(cameraInput);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to add cameraInput. error: ${JSON.stringify(err)}`);
    }

    // 创建预览输出流
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfilesArray[0], surfaceId);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to create the PreviewOutput instance. error: ${JSON.stringify(err)}`);
    }

    if (previewOutput === undefined) {
      return;
    }
    // 向会话中添加预览输出流
    try {
      videoSession.addOutput(previewOutput);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to add previewOutput. error: ${JSON.stringify(err)}`);
    }

    // 向会话中添加录像输出流
    try {
      videoSession.addOutput(videoOutput);
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `Failed to add videoOutput. error: ${JSON.stringify(err)}`);
    }

    // 提交会话配置
    try {
      await videoSession.commitConfig();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `videoSession commitConfig error: ${JSON.stringify(err)}`);
    }

    // 启动会话
    try {
      await videoSession.start();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `videoSession start error: ${JSON.stringify(err)}`);
    }
    console.log(this.TAG, " initVideoCamera end");
  }

  /**
   * 开始录像
   */
  public async startRecord(){
    // 启动录像输出流
    this.mVideoOutput?.start((err: BusinessError) => {
      if (err) {
        console.error(this.TAG, `Failed to start the video output. error: ${JSON.stringify(err)}`);
        return;
      }
      console.info('Callback invoked to indicate the video output start success.');
    });
    // 开始录像
    try {
      await this.mAvRecorder?.start();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `avRecorder start error: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 停止录像
   */
  public async stopRecorder(){
    // 停止录像输出流
    this.mVideoOutput?.stop((err: BusinessError) => {
      if (err) {
        console.error(this.TAG, `Failed to stop the video output. error: ${JSON.stringify(err)}`);
        return;
      }
      console.info('Callback invoked to indicate the video output stop success.');
    });
    // 停止录像
    try {
      await this.mAvRecorder?.stop();
    } catch (error) {
      let err = error as BusinessError;
      console.error(this.TAG, `avRecorder stop error: ${JSON.stringify(err)}`);
    }
  }

  public async destroyVideoCamera(){

    // 停止当前会话
    await this.mVideoSession?.stop();

    // 关闭文件
    fs.closeSync(this.mFile);

    // 释放相机输入流
    await this.mCameraInput?.close();

    // 释放预览输出流
    await this.mPreviewOutput?.release();

    // 释放录像输出流
    await this.mVideoOutput?.release();

    // 释放会话
    await this.mVideoSession?.release();

    // 会话置空
    this.mVideoSession = undefined;
  }
}

