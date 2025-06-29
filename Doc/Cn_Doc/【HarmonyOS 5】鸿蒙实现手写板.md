## 【HarmonyOS 5】鸿蒙实现手写板

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

### 一、前言

**实现一个手写板功能，基本思路如下：**

创建一个可交互的组件，用户在屏幕上触摸并移动手指时，会根据触摸的位置动态生成路径，并使用黑色描边绘制在屏幕上。当用户按下屏幕时，记录按下点的坐标作为路径的起点。当用户移动手指时，不断记录移动点的坐标，通过线段连接起来形成路径。

**功能效果图如下所示：**
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_3e7bfbf2.png 'image.png')


### 二、方案思路

系统提供了非常便捷的画线组件Path。该组件将画布和画线功能合二为一。提供了简洁的画线组件。

**详情参见，官方组件API文档链接**：[Path-图形绘制-ArkTS组件-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者 ](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-drawing-components-path)【<https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-drawing-components-path】>

**Path该组件的使用思路很简单，如下代码所示：**

```javascript
      Path()
        .commands(this.pathCommands) // 设置SVG路径描述字符串
        .strokeWidth(5) // 设置路径的描边宽度为 5
        .fill("none") // 设置路径的填充颜色为无
        .stroke(Color.Black) // 设置路径的描边颜色为黑色
        .height('100%')
        .width('100%')
```

**1. 将组件的宽高设置需要展示的画布区域大小。**

height和width为百分之百。

**2. 设置线的样式颜色和宽度。**

stroke为Color.Black，strokeWidth为5

**3. 设置绘制闭合的填充区域的颜色。**

fill为none

若你修改了fill有填充色，就会得到如下的效果：
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_004a56cc.png 'image.png')


因为该效果并非手写板的需求，所以需要设置fill为none，不要填充色。

**4. 设置SVG路径描述字符串。**

该组件最核心的属性。它的值是字符串大概是这样的：

```javascript
M225.99999999999997 409.99999999999994 L225.99999999999997 409.99999999999994

```

**首先我们先了解SVG 路径描述符是干嘛的？**

SVG 路径描述符是用于定义矢量图形路径的一组命令，在使用Path组件绘制图形时发挥关键作用，可创建各种复杂的自定义形状。主要作用如下：

 
**（1）构建基础图形：**

通过M（moveto）命令确定起始点，配合L（lineto）、H（horizontal lineto）、V（vertical lineto）等命令绘制直线段，能构建出三角形、矩形等基础图形。例如commands('M0 20 L50 50 L50 100 Z')定义了一个起始于（0，20），通过绘制两条直线段，最后用Z（closepath）命令关闭路径形成的三角形 。

**（2）绘制曲线图形：**

借助C（curveto）、S（smooth curveto）、Q（quadratic Belzier curve）、T（smooth quadratic Belzier curveto）等命令，能绘制不同类型的贝塞尔曲线，实现复杂的曲线图形绘制。像C100 100 250 100 250 200可绘制一条从当前点到（250, 200）点的三次贝塞尔曲线，用于创建诸如花瓣、波浪线等曲线形状。

**（3）绘制椭圆弧：**

A（elliptical Arc）命令用于从当前点到指定点绘制椭圆弧，通过设置椭圆的半径、旋转角度以及其他标志位，能绘制各种椭圆形状的部分弧线，比如绘制饼图的扇区。
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_7dc41209.png 'image.png')

**而在手写板场景中，SVG 路径描述符仅使用M（moveto）和L（lineto）命令就能实现主要功能。**
原因在于手写板的核心需求是实时记录并呈现用户绘制的轨迹。M命令用于确定绘制轨迹的起始点，每次用户触摸屏幕开始书写时，就相当于启动一个新的路径，M命令记录下这个起始坐标，如同在纸上确定第一笔的落点。L命令从当前点到指定坐标画一条线，在手写板中，随着用户手指的移动，不断获取移动过程中的坐标点，通过L命令依次连接这些点，就能形成连续的线条，精准地呈现出手写的笔迹。

**最终我们只需要在Path组件外添加onTouch事件**
记录用户的手指触摸事件，得到其x，y坐标，即可实现手写板的svg路径描述符：

```javascript
 // 处理触摸事件的方法
    onTouchEvent(event: TouchEvent) {
        // 根据触摸事件的类型进行不同的处理
        switch (event.type) {
            // 当触摸类型为按下时
            case TouchType.Down:
                // 在 pathCommands 中添加一个移动命令（M），并记录按下点的坐标
                this.pathCommands += 'M' + event.touches[0].x + ' ' + event.touches[0].y;
                break;
            // 当触摸类型为移动时
            case TouchType.Move:
                // 在 pathCommands 中添加一个线段命令（L），并记录移动点的坐标
                this.pathCommands += 'L' + event.touches[0].x + ' ' + event.touches[0].y;
                break;
            // 其他触摸类型，不做处理
            default:
                break;
        }
    }
```

**5. 当需要清空手写板。**

只需要对Path组件的commands属性设置为空字符串即可。

### 三、源码示例：

```javascript
@Entry
@Component
struct PathTestPage {

  @State pathCommands: string = "";

  private setPathCommands(str: string, event: TouchEvent){
    let x = event.touches[0].x;
    let y = event.touches[0].y;
    this.pathCommands += str + vp2px(x) + ' ' + vp2px(y);
    console.log("georgeDebug", " this.pathCommands: " + this.pathCommands);
  }

  onTouchEvent(event: TouchEvent){
    // event xy 单位：vp
    switch (event.type){
      case TouchType.Down:
        this.setPathCommands('M', event);
        break;

      case TouchType.Move:
        this.setPathCommands('L', event);
        break;
        default:
          break;
    }
  }

  build() {
    Stack({
      alignContent: Alignment.TopStart
    }){
      Path()
        .commands(this.pathCommands) // 设置SVG路径描述字符串
        .strokeWidth(5) // 设置路径的描边宽度为 5
        .fill("none") // 设置路径的填充颜色为无
        .stroke(Color.Black) // 设置路径的描边颜色为黑色
        .height('100%')
        .width('100%')
        .onTouch((event: TouchEvent)=>{
          this.onTouchEvent(event);
        })

      Button("清空绘制")
        .onClick(()=>{
          this.pathCommands = "";
        })
    }
    .height('100%')
    .width('100%')

  }
}

```

### 注意：

1.  因为path不能作为build的根节点，所以用容器组件row进行了包裹。

2.  onTouch得到的坐标xy单位为vp，而svg描述符的单位为vp，所以数值要做单位转化。否则会造成能画出东西， 但是坐标跟下笔的位置都缩小了。

3.  需要给path组件设置宽高，否则会不显示。

​
