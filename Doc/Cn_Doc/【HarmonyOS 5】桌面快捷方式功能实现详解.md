# 【HarmonyOS 5】桌面快捷方式功能实现详解

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言

在移动应用开发中，如何让用户快速触达核心功能，是目前很常见的功能之一。

鸿蒙系统提供的\*\*桌面快捷方式（Shortcuts）\*\*功能，允许开发者为应用内常用功能创建直达入口，用户通过长按应用图标即可快速启动特定功能，大幅减少操作层级。

本文将结合地图导航场景，详细解析鸿蒙快捷方式的实现原理与开发流程。结合华为官方开源示例 [DesktopShortcut](https://gitee.com/harmonyos_samples/DesktopShortcut.git) 展开，该示例基于HarmonyOS 5.0实现，完整演示了地图导航场景的快捷方式开发流程。

## 二、需求分析与示例工程介绍

以地图应用为例，用户日常高频使用“回家”“去公司”等导航功能。传统流程需先打开应用、搜索目的地、再启动导航。通过快捷方式，可实现：

1.  **长按应用图标**，在快捷方式列表中直接点击“回家”或“去公司”；
2.  **拖动快捷方式到桌面**，通过独立图标一键启动导航。\
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_8ca1a98d.png 'image.png')

### 工程目录介绍

    ├── entry/src/main/ets                  
    │  ├── entryability                         
    │  │  └── EntryAbility.ets                  // 核心逻辑：处理快捷方式参数并跳转页面
    │  └── pages                                
    │     ├── GoCompany.ets                     // 公司导航页面（@Entry装饰）
    │     ├── GoHouse.ets                       // 回家导航页面（@Entry装饰）
    │     └── Index.ets                         // 应用首页
    ├── entry/src/main/resources                
    │  └── base/profile                         
    │     └── shortcuts_config.json             // 快捷方式元数据配置
    └── module.json5                             // 模块配置文件，关联快捷方式

## 三、快捷方式功能实现步骤

### 1、 核心配置文件

**（1）shortcuts\_config.json**：定义快捷方式的元数据，包括ID、名称、图标及目标跳转信息。

```json
{
  "shortcuts": [
    {
      "shortcutId": "id_go_company",
      "label": "$string:go_company",        // 对应resources/base/element/string.json中的字符串资源
      "icon": "$media:icon_company",        // 对应resources/base/media目录下的图标文件
      "wants": [
        {
          "bundleName": "com.example.desktopshortcut", // 应用包名（需与module.json5一致）
          "moduleName": "entry",                        // 模块名（固定为entry）
          "abilityName": "EntryAbility",               // 目标Ability（入口Ability）
          "parameters": { "page": "GoCompany" }         // 自定义参数：标识目标页面
        }
      ]
    },
    {
      "shortcutId": "id_go_house",
      "label": "$string:go_home",
      "icon": "$media:icon_home",
      "wants": [
        {
          "bundleName": "com.example.desktopshortcut",
          "moduleName": "entry",
          "abilityName": "EntryAbility",
          "parameters": { "page": "GoHouse" } //  `parameters`键名可自定义（示例中使用`page`而非前文的`shortCutKey`），需与代码逻辑保持一致。
        }
      ]
    }
  ]
}
```

**（2）module.json5**：声明快捷方式配置文件的引用，关联至应用模块。

```json
{
  "module": {
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "skills": [
          {
            "entities": ["entity.system.home"],
            "actions": ["ohos.want.action.home"]
          }
        ],
        "metadata": [
          {
            "name": "ohos.ability.shortcuts",
            "resource": "$profile:shortcuts_config" // 引用profile目录下的配置文件
          }
        ]
      }
    ]
  }
}
```

**（3）关键字段说明**

| 字段         | 说明                                           |
| ---------- | -------------------------------------------- |
| shortcutId | 唯一标识（长度≤63字节），如id\_company。                  |
| label      | 显示名称（支持资源索引），如\$string:Go\_to\_the\_Company。 |
| icon       | 图标资源索引，如\$media:company。                     |
| wants      | 目标跳转信息，包含包名、模块名、Ability名称及自定义参数（parameters）。 |

### 2、快捷入口跳转逻辑

```typescript
import router from '@ohos.router';

export default class EntryAbility extends Ability {
  private context: UIAbilityContext | undefined;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    super.onCreate(want, launchParam);
    this.context = this.getContext();
    // 首次启动时加载首页
    router.pushUrl({
      url: 'pages/Index',
      context: this.context
    });
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    const page = want.parameters?.page; // 提取快捷方式传递的参数
    if (page && this.context) {
      router.pushUrl({
        url: `pages/${page}`, // 动态拼接页面路径
        context: this.context
      });
    }
  }
}
```

## 注意

1.  **快捷方式数量**：仅支持跳转至UIAbility入口页面，最多配置4个。

2.  **参数校验**：\
    在onNewWant中增加参数非空校验，避免因快捷方式参数缺失导致应用崩溃：
    ```typescript
    if (!page || !this.context) {
      hilog.error(0x0000, 'Shortcut', 'Invalid parameters or context');
      return;
    }
    ```

3.  **卡片**：可展示动态内容，支持跳转至非入口页面。
