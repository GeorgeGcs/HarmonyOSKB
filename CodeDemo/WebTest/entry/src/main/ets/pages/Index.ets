// @Entry
// @Component
// struct Index {
//   private inputValue: string = ''
//
//   build() {
//     Column({ space: 50 }) {
//       TextInput({ placeholder: '请输入数字' })
//         .placeholderColor(Color.Gray)
//         // .type(InputType.NUMBER_DECIMAL)
//         .maxLength(6)
//         .fontSize(19)
//         .inputFilter('^\\d{1,3}(\\.\\d{1,2})?$')
//         .onChange((value: string) => {
//           this.inputValue = value
//         })
//       Text(`输入的值: ${this.inputValue}`)
//     }
//     .width('100%')
//   }
// }
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  private inputValue: string = ''

  aboutToAppear(): void {
    let para: Record<string, number> = { 'PropA': 47 };
    let storage: LocalStorage = new LocalStorage(para);
    console.log("debugGeorge", "entry storage : " + storage.get('PropA'));
    hilog.info(0x0000, 'debugGeorge', "entry storage : " + storage.get('PropA'));
  }

  onClickTest = ()=>{

    let want: Want = {
      deviceId: '', // deviceId为空表示本设备
      bundleName: 'com.app.myapplication',
      abilityName: 'SubAbility'
    };
    let context = getContext(this) as common.UIAbilityContext;
    context.windowStage.
    try {
      context.startAbility(want, (err: BusinessError) => {
        if (err.code) {
          // 处理业务逻辑错误
          console.error(`startAbility failed, code is ${err.code}, message is ${err.message}`);
          return;
        }
        // 执行正常业务
        console.info('startAbility succeed');
      });
    } catch (err) {
      // 处理入参错误异常
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      console.error(`startAbility failed, code is ${code}, message is ${message}`);
    }
  }

  build() {
    Column({ space: 50 }) {
      Button("点击测试")
        .onClick(this.onClickTest)

      TextInput({ placeholder: '请输入数字' })
        .placeholderColor(Color.Gray)
        .type(InputType.NUMBER_DECIMAL)
        .maxLength(6)
        .fontSize(19)
        .onChange((value: string) => {
          // 定义正则表达式，用于匹配最大 3 位整数和 2 位小数
          const regex = /^\d{1,3}(\.\d{1,2})?$/
          if (regex.test(value)) {
            // 如果输入值符合正则表达式，更新输入值
            this.inputValue = value
          } else {
            // 如果不符合，截取之前符合的部分
            for (let i = value.length; i > 0; i--) {
              const subValue = value.slice(0, i)
              if (regex.test(subValue)) {
                this.inputValue = subValue
                break
              }
            }
          }
        })
      Text(`输入的值: ${this.inputValue}`)
    }
    .width('100%')
  }
}