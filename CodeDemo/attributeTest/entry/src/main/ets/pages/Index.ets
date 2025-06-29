import { AttributeUpdater } from '@ohos.arkui.modifier'

/**
 * AttributeUpdater定义
 */
class MyButtonUpdate extends AttributeUpdater<ButtonAttribute> {
  // 首次绑定时触发initializeModifier方法，进行属性初始化
  initializeModifier(instance: ButtonAttribute): void {
    instance
      .width('50%')
      .height(30)

  }
}

/**
 * AttributeModifier定义
 */
class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  isDark: boolean = false

  applyNormalAttribute(instance: ButtonAttribute): void {
    if (this.isDark) {
      instance.backgroundColor(Color.Blue)
    } else {
      instance.backgroundColor(Color.Red)
    }
  }
}

@Entry
@Component
struct Index {
  // AttributeUpdater 虽然继承于AttributeModifier需要使用，但是自带更新属性的能力
  update: MyButtonUpdate = new MyButtonUpdate();

  // AttributeModifier需要使用@State进行数据绑定，控件才能支持动态更新。
  // @State modifier: MyButtonModifier = new MyButtonModifier();

  build() {
    Row() {
      Column() {
        Button("Button")
          // .attributeModifier(this.modifier)
          .attributeModifier(this.update)
          .onClick(() => {
            // this.modifier.isDark = !this.modifier.isDark

            // 通过attribute，直接修改组件属性，并立即触发组件属性更新
            this.update.attribute?.width('100%').fontSize(52);
          })
      }
      .width('100%')
    }
    .height('100%')
    .backgroundColor(Color.Red);
  }
}
