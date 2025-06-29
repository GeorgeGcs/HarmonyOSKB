## 【HarmonyOS 5】Detailed Explanation of the makeObserved Interface  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  

## I. What is the makeObserved Interface?  

The `makeObserved` interface (available since API version 12) converts non-observable data into observable data. It applies to scenarios involving third-party package classes, classes decorated with `@Sendable`, objects returned by `JSON.parse`, and collections like `collections.Array`, `Set`, or `Map`.  

- **Unsupported Types**: `undefined`, `null`, V1 state decorators (`@State`/`@Prop`), and already observed data (to avoid double proxying).  
- **Primary Use Case**: Designed for **V2 usage scenarios** to address observation requirements not covered by `@Trace`/`@ObservedV2`, such as making JSON objects from network requests observable in the UI.  

**Note**: If you can use `@State` (V1) to solve the problem, there's no need to use `makeObserved`.  


## II. How to Use makeObserved?  

**(1) Interface Invocation**  
Import `UIUtils` from `@kit.ArkUI` and invoke the interface. Ensure your input parameters are supported for observation:  

```typescript
import { UIUtils } from '@kit.ArkUI';

class UserInfo {
  id: number = 0;
}

let observedInfo: UserInfo = UIUtils.makeObserved(new UserInfo()); 
```  

**(2) Supported Scenarios**  
1. **Third-Party SDK Data Classes** (when UI observation is needed but `@Trace` cannot be added manually):  
   *Example*: See the basic usage above.  

2. **Classes Decorated with `@Sendable`** (since dynamic property modification is prohibited):  

```typescript
import { taskpool } from '@kit.ArkTS';
import { UIUtils } from '@kit.ArkUI';

// Define a @Sendable class (supports thread transfer)
@Sendable
class UserInfo {
  userId: number = 0;
  username: string = 'Guest';
  score: number = 0;
  isOnline: boolean = false;

  constructor(userId: number, username: string) {
    this.userId = userId;
    this.username = username;
  }
}

// Concurrent task: Simulate data processing (e.g., network request)
@Concurrent
function processDataInThread(userId: number): UserInfo {
  let result = new UserInfo(userId, 'Loading...');
  setTimeout(() => {
    result.score = Math.floor(Math.random() * 100);
    result.isOnline = true;
  }, 1000);
  return result;
}

@Entry
@ComponentV2
struct SendableMakeObservedDemo {
  // Observable data in the main thread: Wrap @Sendable object with makeObserved
  @Local observedUser: UserInfo = UIUtils.makeObserved(new UserInfo(-1, '未登录'));

  build() {
    Column({ space: 20 })
      .width('100%')
      .padding(30) {
        
        Text('@Sendable + makeObserved Demo')
          .fontSize(24)
          .fontWeight(500)
        
        // Display user information
        Text(`User ID: ${this.observedUser.userId}`)
          .fontSize(18)
        
        Text(`Username: ${this.observedUser.username}`)
          .fontSize(18)
        
        Text(`Score: ${this.observedUser.score}`)
          .fontSize(18)
        
        Text(`Status: ${this.observedUser.isOnline ? 'Online' : 'Offline'}`)
          .fontSize(18)
        
        // Button to trigger thread task
        Button('Load User Data (Thread Processing)')
          .onClick(() => {
            taskpool.execute(processDataInThread, 1001).then((user: UserInfo) => {
              // Wrap the @Sendable object from the thread as observable
              this.observedUser = UIUtils.makeObserved(user);
            });
          })
        
        // Button to modify data locally
        Button('Increase Score')
          .onClick(() => {
            this.observedUser.score += 10; // Triggers UI refresh
          })
      }
  }
}
```  

3. **Anonymous Objects from `JSON.parse`** (typically network response data):  

```typescript
import { UIUtils } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';

interface UserData {
  name: string;
  age: number;
  email: string;
}

@Entry
@ComponentV2
struct JsonMakeObservedDemo {
  private rawJson: string = '{"name": "Alice", "age": 25, "email": "alice@example.com"}';
  @Local observedData: UserData = UIUtils.makeObserved(JSON.parse(this.rawJson) as UserData);

  build() {
    Column({ space: 30 })
      .width('100%')
      .padding(30) {
        
        Text('JSON Observable Data Demo')
          .fontSize(24)
          .fontWeight(500)
        
        Text(`Name: ${this.observedData.name}`)
          .fontSize(18)
        
        Text(`Age: ${this.observedData.age}`)
          .fontSize(18)
        
        Text(`Email: ${this.observedData.email}`)
          .fontSize(18)
        
        Button('Change Name to "Bob"')
          .onClick(() => {
            this.observedData.name = 'Bob'; // Triggers UI refresh
          })
        
        Button('Increase Age')
          .onClick(() => {
            this.observedData.age++; // Triggers UI refresh
          })
        
        Button('Reset Data')
          .onClick(() => {
            this.observedData = UIUtils.makeObserved(JSON.parse(this.rawJson) as UserData);
          })
      }
  }
}
```  


## III. Important Notes  

1. **`getTarget` Issue**:  
   Modifying properties via `getTarget()` (original object) does **not** trigger UI updates. Always operate on the **proxy object**.  

2. **Compatibility Error**:  
   Mixing `makeObserved` with V1 decorators (e.g., `@State`) throws exceptions. Use V2 decorators (`@Local`, `@Provide`, etc.) instead.