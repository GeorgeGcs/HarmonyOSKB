## 【HarmonyOS 5】Deep Dive into @Observed and @ObjectLink Decorators: Nested Class Object Property Changes  

**#HarmonyOS Development Capabilities**  
**#HarmonyOS SDK Application Services**  
**#HarmonyOS Financial Applications (Financial Management)**  


## Preface  
I previously wrote a blog explaining @Observed and @ObjectLink: [【HarmonyOS】Implementing Rendering Updates for Multi-Level Nested Objects with @ObjectLink and @Observed!](https://blog.csdn.net/superherowupan/article/details/139396715).  

The blog covered the use of @Observed for class listening and @ObjectLink for data passing. However, some details were not fully expanded, which may lead to misunderstandings in usage. Thus, this new article provides a detailed explanation.  


## Clarified Characteristics  
@ObjectLink and @Observed are generally understood as a set of state management decorators for listening to properties of nested objects. They were introduced to solve the problem of monitoring complex data structures like nested objects, arrays within arrays, or arrays within objects, enabling the ArkUI framework to listen for data changes and trigger UI rendering.  

However, it's crucial to understand their scope of action to avoid unexpected bugs:  
**@ObjectLink and @Observed can only monitor first-level object properties and base class properties of nested objects, not properties of child objects or deeper levels.**  

This conclusion is illustrated in my previous blog. You can click the link to copy the demo code, follow the explanation, and experiment with the demo for better understanding.  

When operating on list data changes, we may modify both first-level and deeper-level (second/third-level) properties. For example:  
- The `select` property wrapped in an if statement is a first-level property directly monitored by @ObjectLink. Modifying this property triggers UI refresh, so changes to `index` and `content` below the if block also reflect in the UI.  
- As shown in the first three items of the demo, clicking them has no effect, while the last three items trigger UI refresh.  


![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/436a0a2d04f24d8ea24e2c0bfa23f927b1862.png)  


To address this limitation (inability to monitor deep nested properties):  
- The issue has been reported to Huawei's official team, and they are developing a solution. The V2 interface now supports deep nested monitoring.  
- **@ObservedV2 decorator and @Trace decorator** enable observation of class property changes, but these new state management decorators are still under development and not recommended for use yet, as they may change before the final release.  


### Current Solutions:  
1. **Secondary splitting**: Continue to monitor objects at deeper levels, though this becomes cumbersome for excessive nesting.  
2. **Operate on the monitored layer's property objects**: Instead of modifying sub-properties directly, reassign the entire property object. For example:  


![image.png](https://api.nutpi.net/file/topic/2025-06-20/image/e51b9855406843eea4b5c948d1853586b1862.png)  


Alternatively, ensure that modifying deep nested data also triggers changes in the monitored layer's properties, which will refresh the UI. As shown in the demo, if the `select` property changes, the UI updates in real time.  


## Demo Example  
The following demo verifies that **@ObjectLink and @Observed can only monitor first-level object properties and base class properties of nested objects, not child-level properties**:  


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
    // Call the parent class method to handle nameSize
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
            // Modifying a nested object's property (cup.size) won't be detected by the framework, so UI doesn't refresh
            this.bookName.cup.size += 1;
            console.log('this.bookName.size:' + this.bookName.size)
          })

        Divider().height(5)

        Text(`this.bookName.size = ${this.bookName.size}`)
          .attributeModifier(this.mTextCommonStyle)

        Button(`click this.bookName.size add 1`)
          .attributeModifier(this.mButtonCommonStyle)
          .onClick(() => {
            // Modifying a base class property (size) of the monitored object is detected, triggering UI refresh
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
