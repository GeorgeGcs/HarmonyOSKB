// 导入所需模块
import { safetyDetect } from '@kit.DeviceSecurityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';


@Entry
@Component
struct deviceCheckTestPage {

  private TAG: string = "DeviceCheckTestPage";
  // 存储检测结果
  @State resultMsg: string = '未检测';
  @State detailMsg: string = '';

  // 生成随机nonce（示例方法，实际需从服务器获取）
  private generateNonce(): string {
    // 示例中使用本地随机生成（仅用于演示）
    // 实际开发必须从应用服务器动态获取，确保每次请求唯一性
    return 'imEe1PCRcjGkBCAhOCh6ImADztOZ8ygxlWRs' // 从服务器生成的随机的nonce值
  }

  // 系统完整性检测函数
  private async checkSystemIntegrity() {
    try {
      console.info(this.TAG, '开始检测系统完整性')
      // 获取nonce（示例：本地生成，实际需从服务器获取）
      const nonce = this.generateNonce();

      // 构建检测请求
      const req: safetyDetect.SysIntegrityRequest = {
        nonce: nonce
      };

      // 调用检测接口
      const response = await safetyDetect.checkSysIntegrity(req);
      console.info(this.TAG, '检测结果：%{public}s', response.result)

      // 处理结果
      this.processResult(response);
    } catch (error) {
      const err = error as BusinessError;
      console.info(this.TAG, '检测结果：%{public}s', '检测失败：%{public}d %{public}s', err.code, err.message)
      this.showPrompt('检测失败' + `错误码：${err.code}\n${err.message}`);
    }
  }

  // 结果处理函数
  private processResult(response: safetyDetect.SysIntegrityResponse) {
    // SysIntegrityResponse - result
    // nonce：调用checkSysIntegrity接口时传入的nonce字符串。
    //
    // timestamp：服务器生成的时间戳。
    //
    // hapBundleName：您应用的包名。
    //
    // hapCertificateSha256：您应用的签名证书SHA256摘要。
    //
    // basicIntegrity：系统完整性检测的结果，true表示检测结果完整，false表示存在风险。
    //
    // appId：您应用的appid。
    //
    // detail：可选字段，当basicIntegrity结果为false时，该字段将提供存在风险的原因，

    // JWS格式的系统完整性检测结果。JWS内容详见《Device Security Kit开发指南》中的系统完整性检测开发步骤。
    let result = response.result;

    // jailbreak：设备被越狱。
    // emulator：非真实设备。
    // attack：设备被攻击。
    this.resultMsg = `系统完整性：${response ? '安全' : '风险'}`;
    if (!result) {
      // this.detailMsg = `风险原因：${detail.join('、')}`;
    } else {
      this.detailMsg = '无具体风险信息';
    }

    this.showPrompt('检测完成' + `${this.resultMsg}\n${this.detailMsg}`);
  }

  // 提示框函数
  private showPrompt(message: string) {
    promptAction.showToast({
      message: message
    })
  }

  build() {
    Column() {
      Text('系统完整性检测Demo')
        .fontSize(20)
        .fontWeight(500)
        .margin(10);

      Button('开始检测')
        .width('90%')
        .height(48)
        .backgroundColor('#007DFF')
        .fontColor('white')
        .onClick(() => this.checkSystemIntegrity())
        .margin(20);

      Text(this.resultMsg)
        .fontSize(16)
        .fontWeight(400)
        .margin({ bottom: 5 });

      Text(this.detailMsg)
        .fontSize(14)
        .fontColor('#666')
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5');
  }
}