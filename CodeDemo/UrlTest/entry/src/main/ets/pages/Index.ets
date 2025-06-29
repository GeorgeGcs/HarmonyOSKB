import { safetyDetect } from '@kit.DeviceSecurityKit'
import { promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'


@Entry
@Component
struct Index {
  @State inputUrl: string = ''  // URL输入值
  @State result: string = ''    // 检测结果文本
  @State isChecking: boolean = false  // 检测状态
  @State threatType: safetyDetect.UrlThreatType | null = null  // 威胁类型（对应文档枚举值）

  // 检测URL风险（真实接口调用）
  async checkUrlSecurity() {
    if (!this.isValidUrl(this.inputUrl)) {
      this.showToast('请输入有效的URL（需包含http/https）');
      return;
    }

    this.isChecking = true;
    const TAG = 'UrlThreatDemo';
    const req: safetyDetect.UrlCheckRequest = { urls: [this.inputUrl] };  // 文档要求的请求格式

    try {
      // 调用文档中的checkUrlThreat接口
      const response: safetyDetect.UrlCheckResponse = await safetyDetect.checkUrlThreat(req);

      this.threatType = response.results[0]?.threat;

      // 枚举值解析结果
      this.result = `检测结果：\nURL：${this.inputUrl}\n风险类型：${this.getThreatName(this.threatType)}`;

      // 拦截钓鱼/恶意软件链接
      if (this.threatType === safetyDetect.UrlThreatType.PHISHING || this.threatType === safetyDetect.UrlThreatType.MALWARE) {
        this.showToast(`检测到${this.getThreatName(this.threatType)}，已禁止访问！`);
        // 此处可添加实际拦截逻辑（如阻止页面跳转）
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(TAG, `接口调用失败：Code=${error.code}, Msg=${error.message}`);
      this.result = `检测失败：${error.message}`;
    } finally {
      this.isChecking = false;
    }
  }

  // URL格式校验
  private isValidUrl(url: string): boolean {
    const pattern = /^(https?:\/\/)/;
    return pattern.test(url);
  }

  // 获取威胁类型名称（对应文档枚举值）
  private getThreatName(threat: safetyDetect.UrlThreatType): string {
    switch (threat) {
      case safetyDetect.UrlThreatType.NORMAL: return 'NORMAL（正常）';
      case safetyDetect.UrlThreatType.PHISHING: return 'PHISHING（钓鱼网站）';
      case safetyDetect.UrlThreatType.MALWARE: return 'MALWARE（恶意软件）';
      default: return 'OTHERS（其他风险）';
    }
  }

  // 提示框
  private showToast(msg: string) {
    promptAction.showToast({
      message: msg
    });
  }

  build() {
    Column({ space: 24 }) {
      // 标题
      Text('URL恶意性检测')
        .fontSize(28)
        .fontWeight(500)
        .margin({ top: 40 })

      // URL输入框
      TextInput({
        text: this.inputUrl,
        placeholder: '请输入URL（如https://example.com）'
      })
        .fontSize(16)
        .padding(12)
        .margin({ top: 24 })
        .border({ width: 1, color: '#E0E0E0' })
        .borderRadius(8)
        .onChange((value) => this.inputUrl = value)

      // 检测按钮（带状态控制）
      Button(this.isChecking ? '检测中...' : '开始检测')
        .fontSize(16)
        .padding(12)
        .margin({ top: 24 })
        .width('70%')
        .backgroundColor(this.isChecking ? '#D0D0D0' : '#007DFF')
        .fontColor('white')
        .borderRadius(24)
        .touchable(this.isChecking)
        .onClick(() => this.checkUrlSecurity())

      // 结果展示区域
      Text(this.result)
        .fontSize(14)
        .lineHeight(22)
        .margin({ top: 24 })
        .padding(16)
        .width('90%')
        .border({ width: 1, color: this.getResultBorderColor() })
        .borderRadius(8)
        .flexGrow(1)

    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }

  // 根据威胁类型获取边框颜色（交互优化）
  private getResultBorderColor(): string {
    if (this.threatType === safetyDetect.UrlThreatType.NORMAL) return '#4CAF50'; // 绿色
    if ([safetyDetect.UrlThreatType.PHISHING, safetyDetect.UrlThreatType.MALWARE].includes(this.threatType ?? safetyDetect.UrlThreatType.NORMAL))
      return '#FF4444'; // 红色
    return '#FF9800'; // 橙色（其他风险）
  }
}