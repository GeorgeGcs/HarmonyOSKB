
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct EventHubTestPage {

  // --------------- EventHub
  private context = getContext(this) as common.UIAbilityContext;
  private eventHub: common.EventHub | null = null;
  private EVENT_TAG: string = "TEST";

  private emitByEventHub(){
    this.eventHub = this.context.eventHub;
    this.eventHub.emit(this.EVENT_TAG, "测试数据EventHub");

    // EventHubMgr.Ins().emit(EventTag.SendTest, "测试数据EventHub");
  }

  /**
   * EventHub事件回调
   */
  callbackByEventHub = (content: string)=>{
    promptAction.showToast({
      message: JSON.stringify(content)
    });
  }

  private registerByEventHub = ()=>{
    this.eventHub?.on(this.EVENT_TAG, this.callbackByEventHub);

    // EventHubMgr.Ins().on(EventTag.SendTest, this.callbackByEventHub);
  }

  private unRegisterByEventHub = ()=>{
    this.eventHub?.off(this.EVENT_TAG, this.callbackByEventHub);

    // EventHubMgr.Ins().off(EventTag.SendTest, this.callbackByEventHub);
  }

  onEmitEvent = ()=>{
    this.emitByEventHub();
  }

  onRegisterEvent = ()=>{
    this.registerByEventHub();
  }

  onUnRegisterEvent = ()=>{
    this.unRegisterByEventHub();

  }

  aboutToAppear(): void {
    this.registerByEventHub();
  }

  aboutToDisappear(): void {
    this.unRegisterByEventHub();
  }


  /**
   * 统一样式封装
   */
  @Styles ButtonStyle(){
    .width(px2vp(350))
    .height(px2vp(200))
    .margin({ top: px2vp(66) })
  }

  build() {
    Column(){
      Button("发送事件")
        .ButtonStyle()
        .onClick(this.onEmitEvent)

      Button("监听事件")
        .ButtonStyle()
        .onClick(this.onRegisterEvent)

      Button("取消事件")
        .ButtonStyle()
        .onClick(this.onUnRegisterEvent)

    }.size({
      width: "100%",
      height: "100%"
    })
    .justifyContent(FlexAlign.Center)
  }
}