## 【HarmonyOS 5】HarmonyOS Web Component and Inline Webpage Bidirectional Communication DEMO Example  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  

## I. Preface  

In ArkUI development, the Web component (Web) allows developers to embed webpages within applications, enabling hybrid development scenarios.  

This article will detail how to achieve bidirectional communication between ArkUI and embedded webpages through WebviewController via a complete DEMO, covering core technical points for ArkUI to call webpage JS and webpages to call ArkUI objects.  


## II. Bidirectional Communication Implementation Principle  

**1. Bidirectional Communication Concept**  
Web to ArkUI (reverse communication) registers ArkUI objects to the webpage's window object through registerJavaScriptProxy, allowing webpages to call ArkUI exposed methods via window.xxx.  

ArkUI to Web (forward communication) executes webpage JS code through runJavaScript, supporting callbacks to obtain return values and enabling native code to call webpage functions.  

**2. Bidirectional Communication Flowchart**  
ArkUI                          Web  
┌──────────────┐              ┌──────────────┐  
│  registerJS   ├─────────────▶ window\.objName  │  
│  (Reverse Registration)    │              ├──────────────┤  
├──────────────┤              │  call test()  │  
│  runJavaScript├─────────────▶ execute JS code │  
│  (Forward Invocation)    │              ├──────────────┤  
└──────────────┘              └──────────────┘  


## III. Bidirectional Communication Implementation Steps  

**1. ArkUI Defines Objects Callable by Webpages**  
Create a TestObj class declaring methods allowable for webpage calls (whitelist mechanism):  

```typescript
class TestObj {
  // Method 1 callable by webpages: Returns a string
  test(): string {
    return "ArkUI Web Component";
  }

  // Method 2 callable by webpages: Prints logs
  toString(): void {
    console.log('Web Component toString');
  }

  // Method 3 callable by webpages: Receives messages from webpages
  receiveMessageFromWeb(message: string): void {
    console.log(`Received from web: ${message}`);
  }
}
```  

**2. ArkUI Component Core Code**  
Initialize the controller and state:  

```typescript
@Entry
@Component
struct WebComponent {
  // Webview controller
  controller: webview.WebviewController = new webview.WebviewController();
  // ArkUI object registered to the webpage
  @State testObj: TestObj = new TestObj();
  // Registration name (webpage accesses via window.[name])
  @State regName: string = 'objName';
  // Receives data returned by the webpage
  @State webResult: string = '';

  build() { /* Component layout and interaction logic */ }
}
```  

Layout and interaction buttons with three core function buttons:  

```typescript
Column() {
  // Displays data returned by the webpage
  Text(`Web Returned Data: ${this.webResult}`).fontSize(16).margin(10);

  // 1. Register ArkUI object to the webpage
  Button('Register to Window')
    .onClick(() => {
      this.controller.registerJavaScriptProxy(
        this.testObj,  // ArkUI object
        this.regName,  // Webpage access name
        ["test", "toString", "receiveMessageFromWeb"]  // Whitelist of allowable methods
      );
    })

  // 2. ArkUI calls webpage JS
  Button('Call Webpage Function')
    .onClick(() => {
      this.controller.runJavaScript(
        'webFunction("Hello from ArkUI!")',  // Executes webpage JS code
        (error, result) => {  // Callback handles return value
          if (!error) this.webResult = result || 'No return value';
        }
      );
    })

  // 3. Web component loading
  Web({ src: $rawfile('index.html'), controller: this.controller })
    .javaScriptAccess(true)  // Enables JS interaction permissions
    .onPageEnd(() => {  // Triggers when page loading completes
      // Automatically calls webpage test function after page loads
      this.controller.runJavaScript('initWebData()');
    })
}
```  

**3. registerJavaScriptProxy practically binds the ArkUI object to the webpage window to achieve reverse communication.**  

```typescript
registerJavaScriptProxy(
  obj: Object,        // Object defined in ArkUI
  name: string,       // Name for webpage access (e.g., window.name)
  methods: string[]   // Whitelist of allowable methods (strict method name matching)
);
```  


## Source Code Example  

The complete code has been uploaded to the Gitee repository—welcome to download and debug! If you have any questions, feel free to leave a message in the comments section for交流～  

**Project Structure**  
├── xxx.ets          # ArkUI component code  
└── index.html       # Inline webpage file  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_79ac184f.png 'image.png')  


### WebViewPage.ets  

```typescript
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

class TestObj {
  constructor() {
  }

  test(): string {
    return "ArkUI Web Component";
  }

  toString(): void {
    console.log('Web Component toString');
  }

  receiveMessageFromWeb(message: string): void {
    console.log(`Received message from web: ${message}`);
  }
}

@Entry
@Component
struct WebViewPage {
  controller: webview.WebviewController = new webview.WebviewController();
  @State testObjtest: TestObj = new TestObj();
  @State name: string = 'objName';
  @State webResult: string = '';

  build() {
    Column() {
      Text(this.webResult).fontSize(20)
      Button('refresh')
        .onClick(() => {
          try {
            this.controller.refresh();
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('Register JavaScript To Window')
        .onClick(() => {
          try {
            this.controller.registerJavaScriptProxy(this.testObjtest, this.name, ["test", "toString", "receiveMessageFromWeb"]);
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('deleteJavaScriptRegister')
        .onClick(() => {
          try {
            this.controller.deleteJavaScriptRegister(this.name);
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('Send message to web')
        .onClick(() => {
          try {
            this.controller.runJavaScript(
              'receiveMessageFromArkUI("Hello from ArkUI!")',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
                  return;
                }
                console.info(`Message sent to web result: ${result}`);
              }
            );
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('Get data from web')
        .onClick(() => {
          try {
            this.controller.runJavaScript(
              'getWebPageData()',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
                  return;
                }
                if (result) {
                  this.webResult = result;
                  console.info(`Data from web: ${result}`);
                }
              }
            );
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Web({ src: $rawfile('index.html'), controller: this.controller })
        .javaScriptAccess(true)
        .onPageEnd(e => {
          try {
            this.controller.runJavaScript(
              'test()',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
                  return;
                }
                if (result) {
                  this.webResult = result;
                  console.info(`The test() return value is: ${result}`);
                }
              }
            );
            if (e) {
              console.info('url: ', e.url);
            }
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
        .width("100%")
        .height("50%")
    }
    .width("100%")
    .height("100%")
    .backgroundColor(Color.Black)
  }
}
```  


### index.html  

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Communication</title>
</head>

<body>
<button onclick="callArkUIMethod()">Call ArkUI Method</button>
<button onclick="sendMessageToArkUI()">Send message to ArkUI</button>
<div id="messageFromArkUI"></div>
<script>
    function callArkUIMethod() {
        const result = window.objName.test();
        console.log("Result from ArkUI: ", result);
    }

    function sendMessageToArkUI() {
        window.objName.receiveMessageFromWeb('Hello from web!');
    }

    function receiveMessageFromArkUI(message) {
        const messageDiv = document.getElementById('messageFromArkUI');
        messageDiv.textContent = `Received message from ArkUI: ${message}`;
    }

    function getWebPageData() {
        return "Data from web page";
    }

    function test() {
        return "Test function result from web";
    }
</script>
</body>

</html>
```  


## Notes  

Call deleteJavaScriptRegister(name) when the component is destroyed to avoid memory leaks:  

```typescript
onDestroy() {
  this.controller.deleteJavaScriptRegister(this.regName);
}
```