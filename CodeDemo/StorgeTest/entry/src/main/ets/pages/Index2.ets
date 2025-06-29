import TestMgr from './TestMgr';
import systemDateTime from '@ohos.systemDateTime';

@Entry
@Component
struct Index2 {

  aboutToAppear(): void {
    let tempID: string = TestMgr.Ins().getPageID();
    console.log("debugStorage", " Index2 aboutToAppear tempID: " + tempID);
  }

  onPageShow(): void {
    let tempID: string = TestMgr.Ins().getPageID();
    console.log("debugStorage", " Index2 onPageShow tempID: " + tempID);
  }

  build() {
    Column() {
      Blank()
      Text("存储Store").fontSize(50)
        .onClick(()=>{
          let pageID: string = systemDateTime.getTime() + "";
          console.log("debugStorage", " Text pageID: " + pageID);
          TestMgr.Ins().setPageID(pageID);
        })
      Blank()
      Text("获取Store").fontSize(50)
        .onClick(()=>{
          let tempID: string = TestMgr.Ins().getPageID();
          console.log("debugStorage", " Text tempID: " + tempID);
        })
      Blank()
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}