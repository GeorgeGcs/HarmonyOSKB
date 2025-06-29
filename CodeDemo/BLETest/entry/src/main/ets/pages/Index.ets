import { CommonTextModifier } from '../common/CommonTextModifier'
import { BLEMgr } from '../mgr/BLEMgr';
import { promptAction, router } from '@kit.ArkUI';
import { PermissionsUtil } from '../utils/PermissionsUtil';

@Entry
@Component
struct Index {

  @State isOpenBluetooth: boolean = false;

  private mBLEMgr: BLEMgr = new BLEMgr();
  txtModifier: CommonTextModifier = new CommonTextModifier()

  async aboutToAppear() {
    let isHave: boolean = await PermissionsUtil.requestPermission();
    if(isHave){
      this.isOpenBluetooth = this.mBLEMgr.getBluetoothState();
    }else{
      this.toSysSettingPage();
    }
  }

  async onPageShow() {
    let isHave: boolean = await PermissionsUtil.requestPermission();
    if(isHave){
      this.isOpenBluetooth = this.mBLEMgr.getBluetoothState();
    }else{
      this.toSysSettingPage();
    }
  }

  private toSysSettingPage(){
    globalThis.sysContext.startAbility({
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',// com.huawei.hmos.settings.AppInfoAbility
      uri: 'application_info_entry', //application_settings   application_info_entry
      parameters: {
        pushParams: globalThis.sysContext.abilityInfo.bundleName // 应用包名com.example.tosettingdemo  'uiAbilityContext.abilityInfo.bundleName'
      }
    });
  }

  onClickStart = async ()=>{
    let isHave: boolean = await PermissionsUtil.requestPermission();
    if(isHave){
      this.mBLEMgr.startBluetooth((str: string)=>{
        let content: string = "";
        if (str == 'STATE_ON') {
          content = "蓝牙已开启";
        }else{
          content = "开启错误：" + str;
        }
        promptAction.showToast({
          message: content
        });
      });
    }else{
      this.toSysSettingPage();
    }
  }

  onClickClose = async ()=>{
    let isHave: boolean = await PermissionsUtil.requestPermission();
    if(isHave){
      this.mBLEMgr.closeBluetooth((str: string)=>{
        let content: string = "";
        if (str == 'STATE_OFF') {
          content = "蓝牙已关闭";
        }else{
          content = "关闭错误：" + str;
        }
        promptAction.showToast({
          message: content
        });
      });
    }else{
      this.toSysSettingPage();
    }
  }

  onClickStartAdv = ()=>{
    this.mBLEMgr.startAdvertising((advState: string)=>{
      let content: string = "";
      if(advState == "STARTED"){
        content = "广播已开启";
      }else{
        content = "广播错误：" + advState;
      }
      promptAction.showToast({
        message: content
      });
    });
  }

  onClickCloseAdv = ()=>{
    this.mBLEMgr.stopAdvertising((str: string)=>{
      promptAction.showToast({
        message: str
      });
    });
  }

  onClickStartScan = ()=>{
    this.mBLEMgr.startScan();
    router.pushUrl({
      url: "pages/ScanResultPage"
    })
  }

  onClickCloseScan = ()=>{
    this.mBLEMgr.stopScan();
  }

  onClickStartServer = ()=>{
    this.mBLEMgr.registerServer((res: string)=>{
      promptAction.showToast({
        message: res
      });
    });
  }

  onClickCloseServer = ()=>{
    this.mBLEMgr.unRegisterServer((res: string)=>{
      promptAction.showToast({
        message: res
      });
    });
  }

  @Builder LineView(){
    Line().width("100%").height(px2vp(2)).backgroundColor(Color.Black).margin({
      top: px2vp(100)
    })
  }

  build() {
    Column() {

      Column(){
        Text(this.isOpenBluetooth ? "蓝牙状态: 已开启" : "蓝牙状态: 已关闭")
        Text("蓝牙设备名：" + this.mBLEMgr.getCurrentDeviceName())
      }

      Text("开启蓝牙")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickStart)

      Text("关闭蓝牙")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickClose)

      this.LineView()

      Text("启动服务")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickStartServer)

      Text("关闭服务")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickCloseServer)

      Text("开启广播")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickStartAdv)

      Text("关闭广播")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickCloseAdv)

      this.LineView()

      Text("开启扫描")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickStartScan)

      Text("关闭扫描")
        .attributeModifier(this.txtModifier)
        .onClick(this.onClickCloseScan)

    }
    .height('100%')
    .width('100%')
  }
}



