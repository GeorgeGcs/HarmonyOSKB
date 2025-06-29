import { common } from '@kit.AbilityKit';

export class EventHubUtils {

  private static mEventHub: common.EventHub | null = null;

  /**
   * 获取事件通知实例
   * @returns
   */
  public static getEventHub(){
    // 封装唯一性。因为在不同window中会导致获取的eventhub 不是一个。
    if(!EventHubUtils.mEventHub){
      let context = getContext() as common.UIAbilityContext;
      EventHubUtils.mEventHub = context.eventHub;
      console.log("EventHubUtils", "EventIns mEventHub done !");
    }
    return EventHubUtils.mEventHub;
  }
}
