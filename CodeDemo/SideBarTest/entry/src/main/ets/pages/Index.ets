// xxx.ets
@Entry
@Component
struct Index {
  normalIcon: Resource = $r("app.media.startIcon")
  selectedIcon: Resource = $r("app.media.foreground")
  @State arr: number[] = [1, 2, 3]
  @State current: number = 1;

  // 侧边栏是否显示
  @State isShowSideBar: boolean = false;

  build() {
    SideBarContainer(SideBarContainerType.Embed) {
      Column() {
        ForEach(this.arr, (item: number) => {
          Column({ space: 5 }) {
            Image(this.current === item ? this.selectedIcon : this.normalIcon).width(64).height(64)
            Text("Index0" + item)
              .fontSize(25)
              .fontColor(this.current === item ? '#0A59F7' : '#999')
              .fontFamily('source-sans-pro,cursive,sans-serif')
          }
          .onClick(() => {
            this.current = item
          })
        }, (item: string) => item)
      }.width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundColor('#19000000')

      Column() {
        Text('SideBarContainer content text1').fontSize(25)
        Text('SideBarContainer content text2').fontSize(25)
      }
      .margin({ top: 50, left: 20, right: 30 })
    }
    .controlButton({
      icons: {
        hidden: $r('app.media.background'),
        shown: $r('app.media.background'),
        switching: $r('app.media.background')
      }
    })
    .sideBarWidth(150)
    .minSideBarWidth(50)
    .maxSideBarWidth(300)
    .minContentWidth(0)
    .onChange((value: boolean) => {
      console.info('status:' + value);
      this.isShowSideBar = value;
    })
    .divider({ strokeWidth: '1vp', color: Color.Gray, startMargin: '4vp', endMargin: '4vp' })
  }
}