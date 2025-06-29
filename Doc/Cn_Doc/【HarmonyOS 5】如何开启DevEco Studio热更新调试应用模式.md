【HarmonyOS 5】如何开启DevEco Studio热更新调试应用模式

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 一、前言：

**热更新调试**
主要是为了解决大工程项目编译的时间过长，日常开发调试效率过低的问题。比如调试应用布局的开发，修改一些界面小属性，每次都需要重新编译整个项目，会费事费力。

**官方给的数据指标如下：**
在万行级ArkTS代码项目中，Hot Reload修改生效速度能够比全量构建生效速度快70%以上，而在十万行级以上ArkTS代码项目中，Hot Reload修改生效速度能够比全量构建生效速度快50%以上。

**基本原理如下图所示：**
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_c7f74086.png 'image.png')

**热更新包括调试增量补丁构建及补丁修复两个过程。**

顾名思义，增量补丁构建是在开发者修改代码后，仅对代码的修改部分进行增量产物构建并打成补丁包，而不是漫长的全量编译，这一过程能够节省开发者大量的时间。

而补丁修复则是替换并更新运行时中对应方法或文件并重载到应用中，最后重新构建界面渲染树，根据生效场景不同，又可分为热修复和冷修复，热修复就是在补丁包完成修复后无需重启应用(ability)即可使修改生效，并可保持应用当前的运行状态，如变量、页面位置等，而冷修复则是需要重启应用(ability)才可使修改生效。

是否需要重启主要取决于修改的方法或属性是否能够被重新刷新，即有些方法或属性的生命周期只会在启动应用时初始化，并在应用的整个生命周期中保持，如全局变量。

## 二、热更新调试设置步骤：

1.需要配置启动文件为热更新调试的模式：
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_c97229fb.png 'image.png')

从普通的entry，切换为带H的entry。

2.之后使用模拟器或者真机进行启动后，就会显示热更新的按钮：
**![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_5960a599.png 'image.png')
**
此时你进行代码UI的修改之后，点击这个H按钮，就可以触发Hot Reload热更新。

3.为了更快捷触发热更新效果，即Ctrl+S保存代码修改后，就触发。需要配置快捷键：
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_82a25dae.png 'image.png')

![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_c70293c2.png 'image.png')
需要先在菜单栏点击File > Settings，选择Tools > Actions on Save，勾选Perform hot reload，点击OK完成设置。修改代码后通过快捷键Ctrl + S即可触发Hot Reload。

## 三、热更新调试效果如下：
https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/1806dfd030f14fea954e80f2bba1b092~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAgR2VvcmdlR2Nz:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMTIzOTkwNDg0NzkzMDY1NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1750253355&x-orig-sign=QFQ5Oxj%2B6SwrCrE3%2BnG5isSd%2FUA%3D