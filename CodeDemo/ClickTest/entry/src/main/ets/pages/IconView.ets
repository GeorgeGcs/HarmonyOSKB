
@Component
export struct IconView{

  aboutToAppear(): void {
    this.getUIContext().getComponentSnapshot().createFromBuilder(()=>{

    })
  }
  build() {
    Stack(){

    }.margin({
      bottom: 110
    })
    .size({
      width: 200,
      height: 200
    })
    .backgroundColor(Color.Black)
  }
}