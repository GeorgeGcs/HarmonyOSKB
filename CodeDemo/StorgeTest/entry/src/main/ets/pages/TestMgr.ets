
export default class TestMgr{

  private static mTestMgr: TestMgr | undefined = undefined;

  public static Ins(): TestMgr {
    if(TestMgr.mTestMgr){
      return TestMgr.mTestMgr;
    }else{
      TestMgr.mTestMgr = new TestMgr();
      return TestMgr.mTestMgr;
    }
  }

  public getPageID(){
    let storage = LocalStorage.getShared();
    let temp: string = storage.get("pageID") ?? "";
    return temp;
  }

  public setPageID(pageID: string){
    let storage = LocalStorage.getShared();
    storage.setOrCreate("pageID", pageID);
  }

}