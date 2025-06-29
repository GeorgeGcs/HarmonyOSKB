## 【HarmonyOS】深入理解@Observed装饰器和@ObjectLink装饰器：嵌套类对象属性变化

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#

## 前言

之前就Observed和ObjectLink写过一篇讲解博客[【HarmonyOS】 多层嵌套对象通过@ObjectLink和@Observed实现渲染更新处理！](https://blog.csdn.net/superherowupan/article/details/139396715)

其中就@Observe监听类的使用，@ObjectLink进行数据传递进行了讲解。但是其中有些细节没有展开讲，**对使用可能会有误解**，所以新增一篇详细讲述。

## 特性明确

对于@ObjectLink和@Observed，**我们一般理解为对嵌套对象进行属性监听的一组状态管理标签。**
该组标签的诞生是为了解决嵌套对象or数组套数组，数组套对象等等，这种类似数据结构的监听问题，以便于ArkUI框架监听，来实现数据变化，UI渲染。

但是我们使用时，需要明确其作用范围，这样就可以避免一些奇怪的bug。

**使用@ObjectLink和@Observed只能监听嵌套后的一级对象属性以及基类属性，无法监听子级及其以下的对象属性。**

该结论以我上一篇博客举例，可以点击跳转到该博客，将DEMO示例代码copy下来，边看讲解，边操作DEMO效果更容易理解。

在列表操作数据变化时，我们即操作了一级属性，也操作了二级和三级属性，进行了数值修改。

if判断包裹的select属性为@ObjuectLink直接监听的对象一级属性，如果我们操作了该属性数值变化，就会导致UI刷新。所以if语句块下方的index和content内容变化也能刷新到UI。

该效果可参见前三个Item，点击后就无效果。只有后三个点击后才会有UI刷新。

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/436a0a2d04f24d8ea24e2c0bfa23f927b1862.png)

如此情况如何解决呢？其实**嵌套深层次数据结构监听问题，已反馈给华为官方**。他们还在开发中，目前V2接口已经可实现嵌套深层次的监听问题。

**@ObservedV2装饰器和@Trace装饰器：类属性变化观测**，但是新的状态管理标签，还未开发完成，目前不推荐使用，因为不是最终版，随时会变化。

目前该问题的解决方案是：

1.进行二次拆分，继续往下监听对象，这样就可以实现多层数据监听。

但是如果嵌套层数过多，每一层都这样拆分，太过去繁琐。所以我推荐第二种方式，即：

2.对监听层的属性对象，进行操作赋值，不对属性对象之下的属性进行单独赋值。

以我上一篇demo示例代码举例：

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/e51b9855406843eea4b5c948d1853586b1862.png)

当然了，还有一种最简单的方式就是，每次你改变嵌套数据时，监听层有属性也会变化，那UI就会及时刷新。如我DEMO示例一样，正常情况下，我们的Select属性是一定会改变，那UI就会及时刷新。

## DEMO示例

以下DEMO示例验证过程【使用@ObjectLink和@Observed只能监听嵌套后的一级对象属性以及基类属性，无法监听子级及其以下的对象属性】

![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/393e3605d18b40319bf8c7017b4d3b21b1862.png)

```dart
import { ButtonModifier, TextModifier } from '@ohos.arkui.modifier';

let NextID: number = 1;

@Observed
class Bag {
  public id: number;
  public size: number;

  constructor(size: number) {
    this.id = NextID++;
    this.size = size;
  }
}

@Observed
class BagCopy {
  public id: number;
  public size: number;

  constructor(size: number) {
    this.id = NextID++;
    this.size = size;
  }
}

@Observed
class Cup {
  public id: number;
  public size: number;

  constructor(size: number) {
    this.id = NextID++;
    this.size = size;
  }
}

@Observed
class User {
  public bag: Bag;

  constructor(bag: Bag) {
    this.bag = bag;
  }
}

@Observed
class Book {
  public bookName: BookName;

  constructor(bookName: BookName) {
    this.bookName = bookName;
  }
}

@Observed
class BookName extends BagCopy {
  public nameSize: number;
  public cup: Cup;

  constructor(nameSize: number) {
    // 调用父类方法对nameSize进行处理
    super(nameSize);
    this.nameSize = nameSize;
    this.cup = new Cup(nameSize);
  }
}

@Component
struct ViewA {
  label: string = 'ViewA';
  @ObjectLink bag: Bag;

  private mTextCommonStyle = new TextCommonStyle();
  private mButtonCommonStyle = new ButtonCommonStyle();

  build() {
    Column() {
      Text(`ViewA`)
        .attributeModifier(this.mTextCommonStyle)

      Text(`this.bag.size = ${this.bag.size}`)
        .attributeModifier(this.mTextCommonStyle)

      Button(`click this.bag.size add 1`)
        .attributeModifier(this.mButtonCommonStyle)
        .onClick(() => {
          this.bag.size += 1;
        })
    }
    .backgroundColor(Color.Blue)
  }
}

@Component
struct ViewC {
  label: string = 'ViewC1';
  @ObjectLink bookName: BookName;

  private mTextCommonStyle = new TextCommonStyle();
  private mButtonCommonStyle = new ButtonCommonStyle();

  build() {
    Row() {
      Column() {
        Text(`ViewC`)
          .attributeModifier(this.mTextCommonStyle)

        Text(`this.bookName.cup.size = ${this.bookName.cup.size}`)
          .attributeModifier(this.mTextCommonStyle)

        Button(`click this.bookName.cup.size add 1`)
          .attributeModifier(this.mButtonCommonStyle)
          .onClick(() => {
            // 当前监听对象的属性，如果是嵌套对象，则该嵌套对象的属性赋值，不会被框架监听到，UI不刷新
            this.bookName.cup.size += 1;
            console.log('this.bookName.size:' + this.bookName.size)
          })

        Divider().height(5)

        Text(`this.bookName.size = ${this.bookName.size}`)
          .attributeModifier(this.mTextCommonStyle)

        Button(`click this.bookName.size add 1`)
          .attributeModifier(this.mButtonCommonStyle)
          .onClick(() => {
            // 当前监听对象的基类属性被修改，依旧可以被监听到，UI会刷新
            this.bookName.size += 1;
            console.log('this.bookName.size:' + this.bookName.size)
          })

      }
      .width(320)
      .backgroundColor(Color.Red)
    }
  }
}

class TextCommonStyle implements AttributeModifier<TextModifier> {
  applyNormalAttribute(instance: TextModifier): void {
    instance
      .fontColor('#ffffffff')
      .backgroundColor('#ff3d9dba')
      .width(320)
      .height(50)
      .borderRadius(25)
      .margin(10)
      .textAlign(TextAlign.Center)
  }
}

class ButtonCommonStyle implements AttributeModifier<ButtonModifier> {
  applyNormalAttribute(instance: ButtonModifier): void {
    instance
      .width(320)
      .backgroundColor('#ff17a98d')
      .margin(10)
  }
}

@Entry
@Component
@Preview
struct ViewB {
  @State user: User = new User(new Bag(0));
  @State child: Book = new Book(new BookName(0));

  build() {
    Scroll(){
      Column() {
        ViewA({ bag: this.user.bag })
          .width(320)
        ViewC({ bookName: this.child.bookName })
          .width(320)
        Button(`ViewB: this.child.bookName.size add 10`)
          .width(320)
          .backgroundColor('#ff17a98d')
          .margin(10)
          .onClick(() => {
            this.child.bookName.size += 10
            console.log('this.child.bookName.size:' + this.child.bookName.size)
          })
        Button(`ViewB: this.user.bag = new Bag(10)`)
          .width(320)
          .backgroundColor('#ff17a98d')
          .margin(10)
          .onClick(() => {
            this.user.bag = new Bag(10);
          })
        Button(`ViewB: this.user = new User(new Bag(20))`)
          .width(320)
          .backgroundColor('#ff17a98d')
          .margin(10)
          .onClick(() => {
            this.user = new User(new Bag(20));
          })
      }
    }
  }
}
```

