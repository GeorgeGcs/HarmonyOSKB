import { promptAction } from '@kit.ArkUI' // 导入系统API
import { IconView } from './IconView' // 导入自定义组件

@Entry // 装饰器，代表入口和界面的意思。
@Component // 装饰器，代表组件
struct Index {

  // 重写build接口进行界面或者组件布局的编写，与传统命令式编程不同，这里和Flutter类似，鱼鳞排版的布局搭建
  build() {
    // 堆叠容器控件
    Stack({
      alignContent: Alignment.BottomEnd // 小括号内为Stack的属性设置
    }) { // 花括号内是包裹的子容器
      IconView().zIndex(1)

      Row() {
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.Blue)
      // 点击事件
      .onClick(() => {
        // 点击事件回调

        // 气泡
        promptAction.showToast({
          message: "点击！"
        })
      })

      Column(){
        Text("边距点击问题测试demo")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)

        TextInput({
          text: "测试文本",
          placeholder: "默认测试文本"
        })
          .backgroundColor(Color.Red)
      }

    }
    // 控件的属性，多是通过点的形式进行设置
    .height('100%')
    .width('100%')
  }
}