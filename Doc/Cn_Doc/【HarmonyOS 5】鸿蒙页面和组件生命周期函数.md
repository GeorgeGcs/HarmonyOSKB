## 【HarmonyOS 5】鸿蒙页面和组件生命周期函数
##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

在 HarmonyOS Next 5.1 及以上版本中，生命周期体系呈现多层次结构，涵盖从应用启动到销毁的完整流程，各层级生命周期既独立又相互关联：
App 级：应用进程的创建与销毁
Application 级：应用全局上下文的生命周期
Ability 级：应用功能单元的生命周期
 页面级：被 @Entry 装饰的组件生命周期
 组件级：自定义组件的生命周期
## 一、生命周期体系总览
| 层级         | 核心作用                                  | 典型场景（金融类应用）                          |
|--------------|-------------------------------------------|-------------------------------------------------|
| App进程      | 管理应用进程的创建与销毁                  | 进程启动时加载加密模块，销毁前清理敏感缓存       |
| Application  | 全局资源初始化与配置管理                  | 初始化全局加密服务、注册崩溃监控                |
| Ability      | 功能单元的窗口与生命周期管理              | 金融首页Ability加载用户资产数据                |
| 页面（@Entry） | 页面级UI展示与交互状态管理                | 转账页面显示时刷新余额，隐藏时保存未完成表单    |
| 组件（@Component） | 独立UI单元的渲染与资源释放                | 行情组件销毁时取消实时数据订阅                  |


### 二、各层级生命周期详解

#### 1. 组件生命周期（@Component）
自定义组件是UI的最小单元，生命周期聚焦于“渲染-交互-销毁”的完整流程，5.1+版本新增`onWillDestroy`回调，强化资源清理能力。

| 生命周期函数       | 触发时机                          | 金融场景应用                                  |
|--------------------|-----------------------------------|-----------------------------------------------|
| `build()`          | 组件首次渲染或状态（@State）更新时 | 构建UI结构（如行情卡片、交易按钮），不可执行耗时操作 |
| `onDidBuild()`     | `build`执行完毕后                 | 初始化组件私有数据（如计算卡片尺寸适配布局）    |
| `onReady()`        | 组件挂载到渲染树（可获取DOM信息）  | 启动组件内动画（如金额数字滚动效果）            |
| `onWillDestroy()`  | 组件即将从渲染树移除前（5.1+新增） | 取消组件内定时器（如倒计时器）、解绑事件监听    |
| `onDestroy()`      | 组件完全销毁时                    | 释放组件占用的系统资源（如图片缓存、临时变量）  |


#### 2. 页面生命周期（@Entry）
页面是被`@Entry`装饰的特殊组件，继承组件生命周期的同时，新增页面级交互相关函数，是用户视觉感知的直接载体。

| 生命周期函数         | 触发时机                          | 金融场景应用                                  |
|----------------------|-----------------------------------|-----------------------------------------------|
| （继承组件生命周期） | -                                 | 同组件生命周期，新增页面专属逻辑               |
| `onPageShow()`       | 页面切换至前台（如从后台切回）    | 刷新实时行情数据、验证用户会话有效性          |
| `onPageHide()`       | 页面切换至后台（如跳转至其他页面）| 暂停行情推送、保存未提交的交易表单            |
| `onBackPress()`      | 用户点击返回按钮（物理/虚拟）     | 拦截返回（如提示“交易未完成，是否离开？”）    |
| `onWindowStageShow()`| 页面所在窗口显示时                | 恢复窗口级交互（如启用手势密码输入）          |
| `onWindowStageHide()`| 页面所在窗口隐藏时                | 禁用窗口级交互（如暂停指纹识别监听）          |


#### 3. Ability生命周期（Stage模型）
Ability是应用的功能单元（如“首页”“交易”均为独立Ability），其生命周期围绕窗口舞台（WindowStage）的创建与销毁，是UI展示的载体。

| 生命周期函数               | 触发时机                          | 金融场景应用                                  |
|----------------------------|-----------------------------------|-----------------------------------------------|
| `onCreate(want, launchParam)` | Ability首次创建时                | 初始化Ability级资源（如用户Token存储）        |
| `onWindowStageCreate(windowStage)` | 窗口舞台创建时                | 加载页面（如加载交易页面UI）、设置窗口属性（如禁止截屏） |
| `onWindowStageActive()`     | 窗口获得焦点时（如用户切回）      | 恢复Ability交互（如启用按钮点击事件）          |
| `onWindowStageInactive()`   | 窗口失去焦点时（如用户切走）      | 暂停Ability交互（如禁用输入框编辑）            |
| `onWindowStageDestroy()`    | 窗口舞台销毁时                    | 释放窗口资源（如销毁自定义弹窗）              |
| `onDestroy()`               | Ability销毁时                    | 清理Ability级数据（如移除临时交易缓存）        |


#### 4. Application生命周期
Application是应用全局上下文，管理所有Ability共享的资源，生命周期贯穿应用从启动到销毁的全流程。

| 生命周期函数               | 触发时机                          | 金融场景应用                                  |
|----------------------------|-----------------------------------|-----------------------------------------------|
| `onCreate()`                | 应用首次启动时                    | 初始化全局服务（如网络请求拦截器、加密工具）  |
| `onDestroy()`               | 应用进程销毁时                    | 清理全局资源（如关闭数据库连接、注销推送服务）|
| `onConfigurationUpdated(config)` | 系统配置变化时（如屏幕旋转）    | 适配横竖屏布局（如行情图表旋转后重绘）        |
| `onTrimMemory(level)`       | 系统内存不足时（level表示紧急程度）| 释放非必要资源（如清除非核心行情缓存）        |


#### 5. App进程生命周期
App进程是应用运行的载体，其生命周期与系统进程管理强相关，是所有层级生命周期的基础。

| 状态   | 触发时机                          | 与其他生命周期的关联                          |
|--------|-----------------------------------|-----------------------------------------------|
| 启动   | 用户点击图标/被其他应用唤醒        | 触发`Application.onCreate()` → `Ability.onCreate()` |
| 运行   | 至少一个Ability处于活跃状态        | 各层级生命周期正常响应（如页面切换、交互）    |
| 终止   | 用户退出/系统回收内存              | 触发`Ability.onDestroy()` → `Application.onDestroy()` |


### 三、生命周期调用顺序（完整流程）
以金融类应用“启动首页”为例，各生命周期触发顺序如下：
```
App进程启动 → Application.onCreate()（初始化加密服务）
→ Ability.onCreate()（加载用户Token）
→ Ability.onWindowStageCreate()（加载首页UI）
→ Ability.onWindowStageActive()（窗口获焦）
→ 页面build()（绘制首页布局）
→ 页面onDidBuild()（初始化行情数据）
→ 页面onWindowStageShow()（窗口显示）
→ 页面onReady()（绑定实时行情监听器）
→ 页面onPageShow()（刷新用户资产）
```


### 四、代码示例（5.1+版本，金融场景适配）

#### 1. 组件与页面生命周期（行情卡片组件+首页页面）
```typescript
// 自定义组件：行情卡片（@Component）
@Component
struct MarketCard {
  @State price: number = 0
  private timerId: number = -1

  build() {
    Column() {
      Text(`实时金价：${this.price.toFixed(2)}元/g`)
        .fontSize(16)
        .padding(10)
    }
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
  }

  // 组件挂载后启动行情刷新
  onReady() {
    console.log('行情卡片：开始监听实时价格')
    this.timerId = setInterval(() => {
      this.price += Math.random() * 2 - 1 // 模拟价格波动
    }, 3000)
  }

  // 组件销毁前清理定时器（5.1+新增）
  onWillDestroy() {
    console.log('行情卡片：即将销毁，准备清理资源')
  }

  // 组件销毁时停止刷新
  onDestroy() {
    console.log('行情卡片：销毁，停止价格监听')
    clearInterval(this.timerId) // 金融场景：必须清理定时器，避免内存泄漏
  }
}

// 页面：首页（@Entry）
@Entry
@Component
struct HomePage {
  @State userBalance: number = 0

  build() {
    Column({ space: 20 }) {
      Text('我的资产')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      
      Text(`总资产：${this.userBalance.toFixed(2)}元`)
        .fontSize(18)
      
      MarketCard() // 引入行情卡片组件
      
      Button('去交易')
        .onClick(() => router.pushUrl({ url: 'pages/TradePage' }))
    }
    .width('100%')
    .padding(16)
  }

  // 页面显示时刷新资产（金融场景：敏感数据实时更新）
  onPageShow() {
    console.log('首页显示：刷新用户资产')
    this.fetchUserBalance() // 调用接口获取最新资产
  }

  // 页面隐藏时保存未完成操作
  onPageHide() {
    console.log('首页隐藏：保存浏览记录')
    this.saveBrowseHistory()
  }

  // 处理返回按钮（拦截退出，提示确认）
  onBackPress(): boolean {
    console.log('首页返回：检查是否有未提交订单')
    if (this.hasUnfinishedOrder()) {
      // 金融场景：未完成订单时拦截返回
      promptAction.showToast({ message: '有未完成订单，确认离开？' })
      return true // 拦截系统默认返回
    }
    return false
  }

  // 模拟资产获取
  private fetchUserBalance() {
    // 实际场景：调用加密接口获取数据
    this.userBalance = 50000 + Math.random() * 10000
  }

  // 模拟保存浏览记录
  private saveBrowseHistory() {
    // 实际场景：存入本地数据库（需加密）
  }

  // 模拟检查未完成订单
  private hasUnfinishedOrder(): boolean {
    return false // 实际场景：根据本地缓存判断
  }
}
```

#### 2. Ability生命周期（首页Ability）
```typescript
// EntryAbility.ts（首页Ability）
import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import { EncryptUtil } from '../common/EncryptUtil' // 金融场景：加密工具类

export default class HomeAbility extends UIAbility {
  onCreate(want, launchParam) {
    console.log('首页Ability：初始化，加载用户Token')
    // 金融场景：解密并加载本地存储的用户Token
    EncryptUtil.init()
  }

  // 创建窗口舞台，加载首页页面
  onWindowStageCreate(windowStage: window.WindowStage) {
    console.log('首页Ability：创建窗口舞台')
    // 金融场景：设置窗口不可截屏（保护资产信息）
    windowStage.getMainWindow((err, mainWindow) => {
      mainWindow.setWindowSecure(true)
    })
    // 加载首页页面
    windowStage.loadContent('pages/HomePage', (err, data) => {})
  }

  // 窗口获焦时启用交互
  onWindowStageActive() {
    console.log('首页Ability：窗口获焦，启用按钮点击')
  }

  // 窗口失焦时暂停交互
  onWindowStageInactive() {
    console.log('首页Ability：窗口失焦，禁用交互')
  }

  // 窗口销毁时清理资源
  onWindowStageDestroy() {
    console.log('首页Ability：窗口销毁，清理加密工具')
    EncryptUtil.destroy()
  }

  onDestroy() {
    console.log('首页Ability：销毁，清理Token')
    // 金融场景：清除内存中的敏感数据
  }
}
```

#### 3. Application生命周期（全局配置）
```typescript
// app.ets（Application）
import AbilityStage from '@ohos.app.ability.AbilityStage';
import { CrashReporter } from '../common/CrashReporter' // 金融场景：崩溃监控

export default class MyApplication extends AbilityStage {
  onCreate() {
    console.log('Application：应用启动，初始化全局服务')
    // 金融场景：初始化崩溃监控（记录异常交易）
    CrashReporter.init()
  }

  // 系统配置变化（如屏幕旋转）
  onConfigurationUpdated(config) {
    console.log('Application：配置变化，适配布局')
  }

  // 内存不足时释放非核心资源
  onTrimMemory(level) {
    console.log(`Application：内存不足（等级${level}），清理行情缓存`)
    // 金融场景：保留交易相关缓存，清除历史行情缓存
  }

  onDestroy() {
    console.log('Application：应用销毁，清理全局资源')
    // 金融场景：关闭数据库连接，清除内存中敏感数据
    CrashReporter.destroy()
  }
}
```


