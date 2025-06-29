import { ArrayList, HashMap } from '@kit.ArkTS'
import { BleDeviceInfo } from '../bean/BleDeviceInfo'
import { promptAction } from '@kit.ArkUI';
import { EventHubUtils } from '../utils/EventHubUtils';
import { BLEMgr } from '../mgr/BLEMgr';

@Entry
@Component
struct ScanResultPage {

  private mBLEMgr: BLEMgr = new BLEMgr();
  private mCacheMap: HashMap<string, string> = new HashMap();
  @State connStr: string = "";
  @State optionSelect: number = -1;

  aboutToAppear(): void {
    EventHubUtils.getEventHub().on("ScanRes", this.onScanRes);
    EventHubUtils.getEventHub().on("ConnStateChange", this.onConnStateChange);

  }

  aboutToDisappear(): void {
    EventHubUtils.getEventHub().off("ScanRes", this.onScanRes);
    EventHubUtils.getEventHub().off("ConnStateChange", this.onConnStateChange);
  }

  onConnStateChange = (state: string)=>{
    if(state == "CONNECTING"){
      this.connStr = "连接中";
    }else if(state == "CONNECTED"){
      this.connStr = "已连接";
      // 进行设备的服务查询
      this.mBLEMgr.discoverServices();
    }else if(state == "DISCONNECTING"){
      this.connStr = "断开中";
    }else{
      this.connStr = "断开连接";
      setTimeout(()=>{
        this.optionSelect = -1;
      }, 2000);
    }
  }

  onScanRes = (info: BleDeviceInfo)=>{
    let deviceId: string = info.DeviceData?.deviceId ?? "";
    if(!this.mCacheMap.hasKey(deviceId)){
      this.mCacheMap.set(deviceId, deviceId);
      this.mListDeviceInfo.push(info);
    }
  }

  @State mListDeviceInfo: Array<BleDeviceInfo> = new Array();

  @Builder ListView(){
    List() {
      ForEach(this.mListDeviceInfo, (item: BleDeviceInfo, index: number) => {
        ListItem() {
          Column(){
            Text("设备ID: " + item.DeviceData?.deviceId).fontSize(px2fp(52)).fontColor(Color.White).width('100%')
            Text("设备名: " + item.DeviceData?.deviceName).fontSize(px2fp(52)).fontColor(Color.White).width('100%')
            Text("RSSI: " + item.DeviceData?.rssi).fontSize(px2fp(52)).fontColor(Color.White).width('100%')
            Text(item.DeviceData?.connectable ? "连接状态: 可连接" : "连接状态: 不可连接").fontSize(px2fp(52)).fontColor(Color.White).width('100%')
            if(this.optionSelect == index){
              Row(){
                Button(this.connStr).backgroundColor(Color.Yellow).fontColor(Color.Blue)
                  .onClick(()=>{
                    // 断开
                    AlertDialog.show({
                      title:"BLE断开",
                      message:"是否选择" + item.DeviceData?.deviceName + "进行BLE断开？",
                      autoCancel: true,
                      primaryButton: {
                        value:"确定",
                        action:()=>{
                          promptAction.showToast({ message: item.DeviceData?.deviceName + " 断开ing！"});
                          this.mBLEMgr.stopConnect();
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
                    });
                  })
                if(this.connStr == "已连接"){
                  Button("读取特征值").backgroundColor(Color.Yellow).fontColor(Color.Blue)
                    .onClick(()=>{
                      this.mBLEMgr.getClient().readCharacteristicValue();
                    }).margin({ left: px2vp(10) })

                  Button("读取描述").backgroundColor(Color.Yellow).fontColor(Color.Blue)
                    .onClick(()=>{
                      this.mBLEMgr.getClient().readDescriptorValue();
                    }).margin({ left: px2vp(10) })
                }
              }
              .width("100%")
            }
            Divider().height(px2vp(1)).width("100%")
          }
          .padding({
            left: px2vp(35),
            right: px2vp(35)
          })
          .width('100%')
          .height(px2vp(450))
          .justifyContent(FlexAlign.Start)
          .onClick(()=>{
            // 点击选择处理配对
            AlertDialog.show({
              title:"BLE连接",
              message:"是否选择" + item.DeviceData?.deviceName + "进行BLE连接？",
              autoCancel: true,
              primaryButton: {
                value:"确定",
                action:()=>{
                  promptAction.showToast({ message: item.DeviceData?.deviceName + " 连接ing！"});
                  this.mBLEMgr.startConnect(item.DeviceData?.deviceId);
                  this.optionSelect = index;
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
            });
          })
        }
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }
    .width('100%')
  }

  build() {
    Column() {
      this.ListView()
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Blue)
  }
}