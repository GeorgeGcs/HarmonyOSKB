


// 自定义实现AttributeModifier多种状态接口
class MyModifier implements AttributeModifier<ButtonAttribute> {
  // 普通状态样式
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Black)
    instance.fontSize(20)
  }
  // 按下状态样式
  applyPressedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Red)
    instance.fontSize(14)
  }
  // 聚焦状态样式
  applyFocusedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Blue)
    instance.fontSize(18)
  }
  // 选择状态样式
  applySelectedAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Green)
    instance.fontSize(16)
  }
  // 禁用状态样式
  applyDisabledAttribute(instance: ButtonAttribute): void {
    instance.fontColor(Color.Gray)
    instance.fontSize(16)
  }
}

@Entry
@Component
struct AttTestPage {

  @State modifier: MyModifier = new MyModifier()
  @State isDisabled: boolean = false;
  @State isFocused: boolean = false;

  @State textContent: string = "默认文本内容";

  build() {
      Column() {
        // 测试文本组件
        Button(this.textContent)
          .attributeModifier(this.modifier)
          .width('100%')
          .height(50)
          .id("testButton")
          .onFocus(() => {
            // 聚焦事件
            this.textContent = "聚焦时的文本内容";
          })
          .onBlur(() => {
            // 失焦事件
          })
          .enabled(!this.isDisabled)
          .margin({
            bottom: 50
          })

        // 切换禁用状态按钮
        Button(this.isDisabled? '启用文本' : '禁用文本')
          .onClick(() => {
            this.isDisabled =!this.isDisabled;
            if(this.isDisabled){
              this.textContent = "禁用时的文本内容";
            }
          })
          .id("enableButton")
          .width('100%')
          .height(50)
          .margin({
            bottom: 50
          })

        // 切换选择状态按钮
        Button(this.isFocused? '设置聚焦' : '取消聚焦')
          .onClick(() => {
            this.isFocused =!this.isFocused;
            if(this.isFocused){
              this.getUIContext().getFocusController().requestFocus("testButton")
              this.textContent = "选择时的文本内容";
            }else{
              this.getUIContext().getFocusController().requestFocus("enableButton")
            }
          })
          .width('100%')
          .height(50)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)
  }
}