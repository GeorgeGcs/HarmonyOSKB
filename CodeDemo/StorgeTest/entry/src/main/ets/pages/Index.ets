import { router } from '@kit.ArkUI';
import systemDateTime from '@ohos.systemDateTime';
import TestMgr from './TestMgr';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    let pageID: string = systemDateTime.getTime() + "";
    console.log("debugStorage", "Index aboutToAppear pageID: " + pageID);
    TestMgr.Ins().setPageID(pageID);
    let tempID: string = TestMgr.Ins().getPageID();
    console.log("debugStorage", "Index aboutToAppear tempID: " + tempID);

    Environment.envProp("languageCode", "en");
  }

  onPageShow(): void {
    let tempID: string = TestMgr.Ins().getPageID();
    console.log("debugStorage", " Index onPageShow tempID: " + tempID);
  }

  build() {
    Column() {
      Blank()
      Text("跳转到下一页面").fontSize(50)
        .onClick(()=>{
          router.pushUrl({
            url: "pages/Index2"
          })
        })
      Blank()
      Text("跳转到另外Ability").fontSize(50)
        .onClick(()=>{
          let wantInfo: Want = {
            deviceId: '', // deviceId为空表示本设备
            bundleName: 'com.test.storegetest', // com.example.scantest
            moduleName: '', // moduleName非必选 entry
            abilityName: 'TestAbility',
            parameters: {
              // 自定义信息
              info: '来自EntryAbility Page_UIAbilityComponentsInteractive页面'
            },
          };
          // context为调用方UIAbility的UIAbilityContext
          this.context.startAbility(wantInfo).then(() => {
            console.info("debugStorage", 'startAbility success.');
          }).catch((error: BusinessError) => {
            console.error("debugStorage", 'startAbility failed: ' + JSON.stringify(error));
          });
        })
      Blank()
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}