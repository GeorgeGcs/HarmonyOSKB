import { common } from "@kit.AbilityKit";

/**
 * EventHub管理类
 */
export class EventHubMgr {
  private static mEventHubMgr: EventHubMgr | null = null;
  private context = getContext(this) as common.UIAbilityContext;
  private eventHub: common.EventHub | null = null;

  public static Ins(){
    if(!EventHubMgr.mEventHubMgr){
      EventHubMgr.mEventHubMgr = new EventHubMgr();
    }
    return EventHubMgr.mEventHubMgr;
  }

  public emit(event: string, ...args: Object[]){
    this.eventHub = this.context.eventHub;
    this.eventHub.emit(event, ...args);
  }

  public on(event: string, callback: Function){
    this.eventHub = this.context.eventHub;
    this.eventHub.on(event, callback);
  }

  public off(event: string, callback?: Function){
    this.eventHub = this.context.eventHub;
    this.eventHub.off(event, callback);
  }
}