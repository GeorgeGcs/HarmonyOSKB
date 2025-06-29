import { access } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BlueToothMgr } from '../manager/BlueToothMgr';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { connection } from '@kit.ConnectivityKit';
import { map } from '@kit.ConnectivityKit';
import { pbap } from '@kit.ConnectivityKit';
import { HashMap } from '@kit.ArkTS';
import { DeviceInfo } from '../info/DeviceInfo';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {

  private TAG: string = "BlueToothTest";

  // 扫描状态定时器
  private mNumInterval: number = -1;
  // 当前设备蓝牙名
  @State mCurrentDeviceName: string = "";
  // 蓝牙状态
  @State @Watch('onChangeBlueTooth') isStartBlueTooth: boolean = false;
  // 蓝牙扫描状态
  @State @Watch('onChangeBlueTooth') isStartScan: boolean = false;
  // 当前蓝牙权限
  @State userGrant: boolean = false;
  // 扫描到设备名
  @State mMapDevice: HashMap<string, DeviceInfo> = new HashMap();
  // ui展现的设备列表
  @State mListDeviceInfo: Array<DeviceInfo> = new Array();

  async aboutToAppear() {
    await this.requestBlueToothPermission();

    let state = access.getState();
    console.log(this.TAG, "getState state: " + state);
    if(state == 2){
      this.isStartBlueTooth = true;
      console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
    }else{
      this.isStartBlueTooth = false;
      console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
    }
  }

  private onChangeBlueTooth(){
    if(!this.isStartBlueTooth){
      this.mMapDevice = new HashMap();
      return;
    }
    // // 当前设备的蓝牙可发现状态
    // try {
    //   let res: boolean = connection.isBluetoothDiscovering();
    //   console.info(this.TAG, 'isBluetoothDiscovering: ' + res);
    // } catch (err) {
    //   console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    // }
    //
    // // 访问信息相关功能
    // try {
    //   let mapMseProfile = map.createMapMseProfile();
    //   console.info(this.TAG, 'MapMse success:' + JSON.stringify(mapMseProfile));
    // } catch (err) {
    //   console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    // }
    //
    // // 访问电话簿相关功能
    // try {
    //   let pbapServerProfile = pbap.createPbapServerProfile();
    //   console.info(this.TAG, 'pbapServer success:' + JSON.stringify(pbapServerProfile));
    // } catch (err) {
    //   console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    // }
    //
    // try {
    //   connection.on('bluetoothDeviceFind', (data: Array<string>)=> {
    //     // console.info(this.TAG, 'data length' + JSON.stringify(data));
    //     // // 获取扫描可配对的设备列表
    //     // this.mListDevice = data;
    //   });
    //   connection.startBluetoothDiscovery();
    // } catch (err) {
    //   console.error(this.TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    // }

    this.mCurrentDeviceName = BlueToothMgr.Ins().getCurrentDeviceName();
  }

  // 用户申请权限
  async reqPermissionsFromUser(): Promise<number[]> {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.ACCESS_BLUETOOTH']);
    return grantStatus.authResults;
  }

  // 用户申请蓝牙权限
  async requestBlueToothPermission() {
    let grantStatus = await this.reqPermissionsFromUser();
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        this.userGrant = true;
        promptAction.showToast({ message: "蓝牙授权成功！"});
      }else{
        promptAction.showToast({ message: "蓝牙授权失败！"});
      }
    }
  }

  setBlueToothScan = ()=>{
    if(!this.isStartScan){
      promptAction.showToast({ message: "开启扫描！"});
      BlueToothMgr.Ins().startScanDevice((data: Array<string>)=>{
        let deviceId: string = data[0];
        if(this.mMapDevice.hasKey(deviceId)){
          // 重复设备，丢弃不处理
        }else{
          // 添加到表中
          let deviceInfo: DeviceInfo = new DeviceInfo();
          deviceInfo.deviceId = deviceId;
          deviceInfo.deviceName = BlueToothMgr.Ins().getDeviceName(deviceId);
          deviceInfo.deviceClass = BlueToothMgr.Ins().getDeviceClass(deviceId);
          this.mMapDevice.set(deviceId, deviceInfo);
          this.mListDeviceInfo = this.mListDeviceInfo.concat(deviceInfo);
        }
      });
      this.mMapDevice.clear();
      this.mListDeviceInfo = [];
      // 开启定时器
      this.mNumInterval = setInterval(()=>{
        let discovering = BlueToothMgr.Ins().isCurrentDiscovering();
        if(!discovering){
          this.closeScanDevice();
        }
      }, 1000);
      this.isStartScan = true;
    }else{
      promptAction.showToast({ message: "关闭扫描！"});
      BlueToothMgr.Ins().stopScanDevice();
      this.closeScanDevice();
    }
  }

  private closeScanDevice(){
    clearInterval(this.mNumInterval);
    this.isStartScan = false;
  }

  setBlueToothState = ()=>{
    try {
      if(!this.isStartBlueTooth){
        // 开启蓝牙
        BlueToothMgr.Ins().setBlueToothAccess(true, (state: access.BluetoothState) => {
          console.log(this.TAG, "getState setBlueToothAccessTrue: " + state);
          if(state == access.BluetoothState.STATE_ON){
            this.isStartBlueTooth = true;
            promptAction.showToast({ message: "开启蓝牙！"});
            console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
          }
        });
      }else{
        BlueToothMgr.Ins().setBlueToothAccess(false, (state: access.BluetoothState) => {
          console.log(this.TAG, "getState setBlueToothAccessFalse: " + state);
          if(state == access.BluetoothState.STATE_OFF){
            this.isStartBlueTooth = false;
            promptAction.showToast({ message: "关闭蓝牙！"});
            console.log(this.TAG, "getState isStartBlueTooth: " + this.isStartBlueTooth);
          }
        });
      }
    } catch (err) {
      console.error(this.TAG,'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  private isLog(){
    console.log(this.TAG, "isLog isStartBlueTooth: " + this.isStartBlueTooth);
    return true;
  }

  build() {
    Column() {
      if(this.userGrant){
        if(this.isLog()){
          Text("当前蓝牙设备信息:\n " + this.mCurrentDeviceName)
            .fontSize(px2fp(80))
            .margin({ top: px2vp(100) })
            .fontWeight(FontWeight.Bold)

          Text(this.isStartBlueTooth ? "蓝牙状态: 开启" : "蓝牙状态: 关闭")
            .fontSize(px2fp(80))
            .margin({ top: px2vp(100) })
            .fontWeight(FontWeight.Bold)
            .onClick(this.setBlueToothState)

          Text(this.isStartScan ? "蓝牙扫描: 开启ing" : "蓝牙扫描: 关闭")
            .margin({ top: px2vp(100) })
            .fontSize(px2fp(80))
            .fontWeight(FontWeight.Bold)
            .onClick(this.setBlueToothScan)

          this.ListView()
        }
      }
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }

  @Builder ListView(){
    List() {
      ForEach(this.mListDeviceInfo, (item: DeviceInfo, index: number) => {
        ListItem() {
          Column(){
            Row() {
              Text("设备ID: " + item.deviceId).fontSize(px2fp(42)).fontColor(Color.Black)
              Blank()
              Text("设备名: " + item.deviceName).fontSize(px2fp(42)).fontColor(Color.Black)
            }
            .width('100%')
            Text(item.deviceClass).fontSize(px2fp(42)).fontColor(Color.Black)
          }
          .width('100%')
          .height(px2vp(200))
          .justifyContent(FlexAlign.Start)
          .onClick(()=>{
            // 点击选择处理配对
            AlertDialog.show({
              title:"选择配对",
              message:"是否选择该设备进行蓝牙配对？",
              autoCancel: true,
              primaryButton: {
                value:"确定",
                action:()=>{
                  promptAction.showToast({ message: item.deviceName + "配对ing！"});
                  BlueToothMgr.Ins().pairDevice(item.deviceId);
                }
              },
              secondaryButton: {
                value:"取消",
                action:()=>{
                  promptAction.showToast({ message: "取消！"});
                }
              },
              cancel:()=>{
                promptAction.showToast({ message: "取消！"});
              }
            })
          })
        }
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }
    .width('100%')
  }
}