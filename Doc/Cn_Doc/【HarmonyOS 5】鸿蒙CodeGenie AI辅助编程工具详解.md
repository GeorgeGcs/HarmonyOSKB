## 【HarmonyOS 5】鸿蒙CodeGenie AI辅助编程工具详解

##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言

**1、CodeGenie是什么？**
**CodeGenie** （代码精灵）作为鸿蒙DevEco IDE自带的AI辅助编码工具。

**关于IDE版本和CodeGenie映射关系的问题：**
建议使用 DevEco Studio 5.0.3.403 及以上版本来使用 CodeGenie。在 DevEco Studio 5.0.4 Release 版本中，CodeGenie 已经作为自带插件可用，说明在该版本时 CodeGenie 已能较好地满足开发需求。

若使用非最新版本的DevEco Studio，可通过插件下载中心获取并使用相关功能。调用效果和自带是一样的，只是多了手动安装插件的步骤。

**2、CodeGenie有什么作用？**
**（1）智能知识问答：（详细步骤见章节三）**
开发者在开发过程中遇到问题，可通过IDE自带的该工具，进行AI文化回答的形式，获取相关知识解答。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_6fed4efb.png 'image.png')

**（2）ArkTS 代码生成：**
帮助开发者生成 ArkTS 代码，提高编码效率，减少手动编写代码的工作量。

通过问答的形式，生成代码示例源码（详细步骤见章节三）。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a76ce4e3.png 'image.png')
或者手动打开，代码生成功能，可以开发者编码时，自动提示。进入File > Settings >DevEco CodeGenie > Code Generation页面开启。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_1f15b975.png 'image.png')

根据快捷键操作，生成单行或者多行代码。开发者通过自动生成代码顶部的菜单栏进行确认或者取消操作。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_bcb172ee.png 'image.png')

| 操作                   | macOS          | Windows     |
| -------------------- | -------------- | ----------- |
| 触发多行代码生成             | Enter、Option+C | Enter、Alt+C |
| 触发单行代码生成             | Option+X       | Alt+X       |
| 采纳生成的代码              | Tab            | Tab         |
| 忽略生成的代码              | Esc            | Esc         |
| 查看上一个代码生成结果          | Option +\[     | Alt + \[    |
| 查看下一个代码生成结果          | Option + ]     | Alt + ]     |
| 重新生成代码内容（最多支持重新生成5次） | Option + R     | Alt + R     |
| 展示CodeGenie面板        | Option + U     | Alt + U     |

**（3）万能卡片生成：**
具备生成万能卡片的能力，方便开发者在应用开发中实现相关功能。
这个功能其实是将上面两个功能进行了结合，通过回答的形式，一步一步将卡片需求，AI编码助手进行开发完善。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_29c51477.png 'image.png')

## 二、在IDE中使用CodeGenie的菜单View（智能问答/代码生成）详细步骤

1、首先下载对应IDE版本（建议使用目前最新的IDE版本）
2、打开DevEco IDE后，手动点击右边的CodeGenie菜单（或者使用快捷键 Alt + U，mac是Option + U）
3、菜单显示效果如下图所示，右边为中文翻译效果。我们在第一次使用AI辅助编码工具时，CodeGenie需要进行协议的确认。我们点击勾选已阅读后。再点击登录。这里的登录和IDE右上角的登录是一样的效果，都是跳转到浏览器使用网页登录华为开发者账号。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_26341fd3.png 'image.png')

4、在我们登录之后，就会进入CodeGenie的主菜单界面。双击上方的标题栏，可以放大或者缩小菜单View布局。主界面主要由编码助手的介绍和知识问答与生成代码两个入门组成。

当我们点击两个入门其中一个后，最下方的输入栏位置就会显示对应的输入内容。此时我们在输入栏，输入对应的提示词后，AI就会生成对应的结果。是回答还是代码。切记要通过入门选择。

5、当我们的回答结束后，想切入到代码时，应该怎么办？只需要点击右下角的new chat（开启新会话即可）。代码切回答，同理。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_6b34c509.png 'image.png')

## 三、在IDE中使用CodeGenie的编译报错智能分析与代码智能解读

**1、编译报错智能分析**
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_bc1739cf.png 'image.png')

编译报错后，点击蓝色按钮提示，就会自动唤起AI编码助手的菜单View。对于编译错误信息进行解释。

**2、代码智能解读**
我使用的是DevEco Studio 5.0.5 Release。目前并没有官方文档提示：选中.ets文件或者.cpp文件中需要被解释的代码行或代码片段，右键选择CodeGeine > Explain Code，开始解读当前代码内容。

已经提工单了，后续有反馈结果在这里更新。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_9bb38747.png 'image.png')
