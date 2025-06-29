## 【HarmonyOS 5】应用实现APP国际化多语言切换

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 前言

在鸿蒙中应用国际化处理，与Android和IOS基本一致，都是通过JSON配置不同的语言文本内容。在UI展示时，使用JSON配置的字段key进行调用，系统选择对应语言文本内容。

## 跟随系统多语言切换

最常见的处理，只需要配置不同语言的JSON配置，以最常见的中英文举例：
我们需要先在资源文件对应的语言json文本string配置表中，进行key，val的配置：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/d107ee8e3fc245a293709f2ab09a6fd8b1862.png)

zh_CN为中文，en_US为英文，base-element中的string.json是默认配置。默认配置是必填，只要你创建了对应语言文件夹，没有在默认配置对应字段节点，系统就会提示报错：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/af0c58ccc8b945e69a5c2353e32b10e8b1862.png)

如下图所示，配置好字段文本内容：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/f0cf5b8f3c96436c84ac38d21b8795eab1862.png)

当我们配置好字段，只需要在UI中进行引用即可：

```dart
$r("app.string.xxx");
例如：
$r("app.string.test_content");
```

## 创建语言资源文件夹

1.在资源文件夹resources右键如下图所示，新增资源文件夹

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/619c0e8231ee42b5985184e2ecd3a338b1862.png)

2.在显示的弹框中选择Locale，点击右侧按钮，显示语言和地区

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/04b8a9ebc8a648458b38f1e89d87a013b1862.png)

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/9223787cb99e45a79f7be9550252e9dfb1862.png)

3.以英语为例，在语言列表，使用英文输入法可以触发筛选搜索框，选择对应该的语言和地区，点击OK即可生成。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/020399aef9ff4eb9a0c40a6cebc7faa0b1862.png)

## APP独立多语言切换

当我们需要APP应用的语言独立于系统，不跟随系统语言设置进行改变。例如系统是中文，设置应用为英文的需求。这时我们需要设置应用优先语言来实现该效果：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/ba0d4ef225d64fefb628b51597f65566b1862.png)

语言ID列表见文章最下方。

```dart
try {
  i18n.System.setAppPreferredLanguage("zh"); // 设置应用偏好语言为zh-Hans
} catch(error) {
  let err: BusinessError = error as BusinessError;
  console.error(`call System.setAppPreferredLanguage zh failed, error code: ${err.code}, message: ${err.message}.`);
}
```

**DEMO示例：**
启动页测试代码

```dart
import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State message: string | Resource = $r("app.string.test_content");

  build() {
    Column() {
      Text(this.message).fontSize(50)

      Text("切换中文").fontSize(50)
      .onClick(()=>{
        // 设置语言偏好
        try {
          i18n.System.setAppPreferredLanguage("zh"); // 设置应用偏好语言为zh-Hans
        } catch(error) {
          let err: BusinessError = error as BusinessError;
          console.error(`call System.setAppPreferredLanguage zh failed, error code: ${err.code}, message: ${err.message}.`);
        }
      })

      Text("切换英文").fontSize(50)
        .onClick(()=>{
          // 设置语言偏好
          try {
            i18n.System.setAppPreferredLanguage("en");
          } catch(error) {
            let err: BusinessError = error as BusinessError;
            console.error(`call System.setAppPreferredLanguage en                                                                                                                                                                                                                                                                                                                       failed, error code: ${err.code}, message: ${err.message}.`);
          }
        })
    }
    .height('100%')
    .width('100%')
  }
}
```

英文：

```dart
{
  "string": [
    {
      "name": "module_desc",
      "value": "module description"
    },
    {
      "name": "EntryAbility_desc",
      "value": "description"
    },
    {
      "name": "EntryAbility_label",
      "value": "label"
    },
    {
      "name": "test_content",
      "value": "English"
    }
  ]
}
```

中文：

```dart
{
  "string": [
    {
      "name": "module_desc",
      "value": "模块描述"
    },
    {
      "name": "EntryAbility_desc",
      "value": "描述"
    },
    {
      "name": "EntryAbility_label",
      "value": "标签"
    },
    {
      "name": "test_content",
      "value": "中文"
    }
  ]
}
```

默认：

```dart
{
  "string": [
    {
      "name": "module_desc",
      "value": "模块描述"
    },
    {
      "name": "EntryAbility_desc",
      "value": "描述"
    },
    {
      "name": "EntryAbility_label",
      "value": "标签"
    },
    {
      "name": "test_content",
      "value": "中文"
    }
  ]
}
```

**多语言国际化国家ID列表：**

[【有道云笔记】国家ID列表](https://note.youdao.com/s/PMcEowXL)

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/04ab1b711de946479eb416352ab85c47b1862.png)

