
// 导入必要的模块
import { AttributeUpdater } from '@kit.ArkUI';

// 自定义 AttributeUpdater 类
class TextAttributeUpdater extends AttributeUpdater<TextAttribute, TextInterface> {
  // 初始化设置组件样式
  initializeModifier(instance: TextAttribute): void {
    instance.fontSize(16)
      .fontColor(Color.Yellow)
  }

  // 定义正常态更新属性函数
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(20)
      .fontColor(Color.Blue)
  }

}

// 页面组件
@Entry
@Component
struct AttUpdateTestPage {
  private textUpdater: TextAttributeUpdater = new TextAttributeUpdater();

  build() {
    Column({ space: 50 }) {
      // 使用 AttributeUpdater 的 Text 组件
      Text("默认文本-hot reload-hot reload-hot reload")
        .attributeModifier(this.textUpdater)
        .width('100%')
        .textAlign(TextAlign.Center)

      // 按钮用于触发属性更新
      Button('更新属性')
        .onClick(() => {
          this.textUpdater.attribute?.fontColor(Color.Red);
          this.textUpdater.updateConstructorParams("修改文本内容");
        })
        .width('100%')
    }
    .width('100%')
    .padding({ top: 100 })
  }
}