@Entry
@Component
struct PathTestPage {

  @State pathCommands: string = "";

  private setPathCommands(str: string, event: TouchEvent){
    let x = event.touches[0].x;
    let y = event.touches[0].y;
    this.pathCommands += str + vp2px(x) + ' ' + vp2px(y);
    console.log("georgeDebug", " this.pathCommands: " + this.pathCommands);
  }

  onTouchEvent(event: TouchEvent){
    // event xy 单位：vp
    switch (event.type){
      case TouchType.Down:
        this.setPathCommands('M', event);
        break;

      case TouchType.Move:
        this.setPathCommands('L', event);
        break;
        default:
          break;
    }
  }

  build() {
    Stack({
      alignContent: Alignment.TopStart
    }){
      Path()
        .commands(this.pathCommands) // 设置SVG路径描述字符串
        .strokeWidth(5) // 设置路径的描边宽度为 5
        .fill("none") // 设置路径的填充颜色为无
        .stroke(Color.Black) // 设置路径的描边颜色为黑色
        .height('100%')
        .width('100%')
        .onTouch((event: TouchEvent)=>{
          this.onTouchEvent(event);
        })

      Button("清空绘制")
        .onClick(()=>{
          this.pathCommands = "";
        })
    }
    .height('100%')
    .width('100%')

  }
}