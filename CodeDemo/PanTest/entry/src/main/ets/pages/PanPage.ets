import { HandwriteComponent, HandwriteController} from '@kit.Penkit';
import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';

@Entry
@Component
struct PanPage {

  private TAG: string = "PanPage";
  private controller: HandwriteController = new HandwriteController();
  private initPath: string = "";

  aboutToAppear() {

    let context = getContext(this) as common.UIAbilityContext;
    let pathDir: string = context.filesDir;
    let filePath: string = pathDir + '/PanTest';
    try {
      let res = fs.accessSync(filePath);
      if (res) {
        console.info("file exists");
      } else {
        console.info("file not exists");
        fs.mkdirSync(filePath);
      }
    } catch(error) {
      console.error(this.TAG, "accessSync failed with error message: " + JSON.stringify(error));
    }

    this.initPath = filePath;
    try {
      // 加载时设置保存动作完成后的回调。
      this.controller.onLoad(this.callback);
    }catch (err) {
      console.error(this.TAG, "onLoad err: " + JSON.stringify(err));
    }
  }

  // 手写文件内容加载完毕渲染上屏后的回调,通知接入用户,可在此处进行自定义行为
  callback = () => {
    // 自定义行为,例如文件加载完毕后展示用户操作指导
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.TopStart }) {
        HandwriteComponent({
          handwriteController: this.controller,
          onInit: () => {
            // 画布初始化完成时的回调。此时可以调用接口加载和显示笔记内容
            this.controller?.load(this.initPath);
          },
          onScale: (scale: number) => {
            // 画布缩放时的回调方法，将返回当前手写控件的缩放比例，可在此处进行自定义行为。
          }
        })
        Button("save")
          .onClick(async () => {
            // 需根据应用存储规则，获取到手写文件保存的路径，此处仅为实例参考
            const path = getContext(this).filesDir + '/aa';
            await this.controller?.save(path);
          })
      }
      .width('100%')
    }
    .height('100%')
  }

}