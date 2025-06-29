import { TextModifier } from '@kit.ArkUI'

/**
 * 文本控件通用样式
 */
export class CommonTextModifier implements AttributeModifier<TextModifier> {
  applyNormalAttribute(instance: TextModifier): void {
    instance.fontSize(px2fp(50))
      .fontColor(Color.White)
      .width(px2vp(300))
      .height(px2vp(100))
      .backgroundColor(Color.Blue)
      .textAlign(TextAlign.Center)
      .margin({
        top: px2vp(100)
      })
      .border({
        width: px2vp(2),
        color: Color.Blue,
        radius: px2vp(50)
      })
  }
}