// xxx.ets
@Entry
@Component
struct Index {
  private TAG: string = "GeorgeDeBug";
  @State isShow: boolean = false
  @State sheetHeight: number = 300;

  @State isShowTest: boolean = false

  @Builder
  myBuilder() {
    Column() {
      Button("change height")
        .margin(10)
        .fontSize(20)
        .onClick(() => {
          this.sheetHeight = 500;
        })

      Button("Set Illegal height")
        .margin(10)
        .fontSize(20)
        .onClick(() => {
          this.sheetHeight = -1;
        })

      Button("close modal 1")
        .margin(10)
        .fontSize(20)
        .onClick(() => {
          this.isShow = false;
        })
    }
    .width('100%')
    .height('100%')

  }

  build() {
    Column() {
      Button("test")
        .onClick(() => {
          this.isShowTest = !this.isShowTest;
          console.info(this.TAG, 'Test button click')
        })
        .fontSize(20)
        .margin(10)

      if(this.isShowTest){
        Button("transition modal 1")
          .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
            console.info(this.TAG, 'Test Row isExpanding:' + isExpanding + ', currentRatio:' + currentRatio)
            if (isExpanding && currentRatio >= 1.0) {
              console.info(this.TAG, 'Test Row is fully visible.')
            }

            if (!isExpanding && currentRatio <= 0.0) {
              console.info(this.TAG, 'Test Row is completely invisible.')
            }
          })
          .onClick(() => {
            this.isShow = true
          })
          .fontSize(20)
          .margin(10)
          .bindSheet($$this.isShow, this.myBuilder(), {
            height: this.sheetHeight,
            backgroundColor: Color.Green,
            onWillAppear: () => {
              console.log("BindSheet onWillAppear.")
            },
            onAppear: () => {
              console.log("BindSheet onAppear.")
            },
            onWillDisappear: () => {
              console.log("BindSheet onWillDisappear.")
            },
            onDisappear: () => {
              console.log("BindSheet onDisappear.")
            }
          })
      }


    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}