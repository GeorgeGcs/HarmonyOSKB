【HarmonyOS 5】HarmonyOS Page and Component Lifecycle Functions

##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Wealth Management#

In HarmonyOS Next 5.1 and later versions, the lifecycle system presents a multi-level structure, covering the complete process from application startup to destruction. The lifecycles of each level are both independent and interrelated:
App level: Creation and destruction of application processes
Application level: Lifecycle of the application's global context
Ability level: Lifecycle of application functional units
  Page level: Lifecycle of components decorated with @Entry
  Component level: Lifecycle of custom components

## I. Overview of the Lifecycle System

| Level | Core Function | Typical Scenarios (Financial Applications) |
|-------|--------------|--------------------------------------------|
| App Process | Manages the creation and destruction of application processes | Loads encryption modules when the process starts; clears sensitive caches before destruction |
| Application | Global resource initialization and configuration management | Initializes global encryption services; registers crash monitoring |
| Ability | Window and lifecycle management of functional units | The financial homepage Ability loads user asset data |
| Page (@Entry) | Page-level UI display and interaction state management | Refreshes balances when the transfer page is displayed; saves unfinished forms when hidden |
| Component (@Component) | Rendering and resource release of independent UI units | Unsubscribes from real-time data when the market component is destroyed |

## II. Detailed Explanation of Lifecycles at All Levels

### 1. Component Lifecycle (@Component)
Custom components are the smallest UI units, and their lifecycles focus on the complete process of "rendering-interaction-destruction". The 5.1+ version adds the onWillDestroy callback to enhance resource cleaning capabilities.

| Lifecycle Function | Trigger Timing | Application in Financial Scenarios |
|---------------------|----------------|-------------------------------------|
| build() | When the component is first rendered or its state (@State) is updated | Builds UI structures (e.g., market cards, transaction buttons); time-consuming operations are not allowed |
| onDidBuild() | After build execution is completed | Initializes component private data (e.g., calculates card sizes to adapt to layouts) |
| onReady() | When the component is mounted to the render tree (DOM information can be obtained) | Starts animations within the component (e.g., scrolling effect of amount numbers) |
| onWillDestroy() | Before the component is about to be removed from the render tree (new in 5.1+) | Cancels timers within the component (e.g., countdown timers); unbinds event listeners |
| onDestroy() | When the component is completely destroyed | Releases system resources occupied by the component (e.g., image caches, temporary variables) |

### 2. Page Lifecycle (@Entry)
A page is a special component decorated with @Entry. It inherits the component lifecycle and adds page-level interaction-related functions, serving as the direct carrier of users' visual perception.

| Lifecycle Function | Trigger Timing | Application in Financial Scenarios |
|---------------------|----------------|-------------------------------------|
| (Inherits component lifecycle) | - | Same as component lifecycle, with additional page-specific logic |
| onPageShow() | When the page switches to the foreground (e.g., switching back from the background) | Refreshes real-time market data; verifies the validity of user sessions |
| onPageHide() | When the page switches to the background (e.g., navigating to another page) | Pauses market push; saves unsubmitted transaction forms |
| onBackPress() | When the user clicks the back button (physical/virtual) | Intercepts back navigation (e.g., prompts "Transaction incomplete, do you want to leave?") |
| onWindowStageShow() | When the window where the page is located is displayed | Restores window-level interactions (e.g., enables gesture password input) |
| onWindowStageHide() | When the window where the page is located is hidden | Disables window-level interactions (e.g., pauses fingerprint recognition monitoring) |

### 3. Ability Lifecycle (Stage Model)
An Ability is a functional unit of an application (e.g., "Homepage" and "Transaction" are independent Abilities). Its lifecycle revolves around the creation and destruction of the window stage (WindowStage), serving as the carrier for UI display.

| Lifecycle Function | Trigger Timing | Application in Financial Scenarios |
|---------------------|----------------|-------------------------------------|
| onCreate(want, launchParam) | When the Ability is first created | Initializes Ability-level resources (e.g., user Token storage) |
| onWindowStageCreate(windowStage) | When the window stage is created | Loads pages (e.g., loads transaction page UI); sets window properties (e.g., disables screenshots) |
| onWindowStageActive() | When the window gains focus (e.g., user switches back) | Restores Ability interactions (e.g., enables button click events) |
| onWindowStageInactive() | When the window loses focus (e.g., user switches away) | Pauses Ability interactions (e.g., disables input box editing) |
| onWindowStageDestroy() | When the window stage is destroyed | Releases window resources (e.g., destroys custom pop-ups) |
| onDestroy() | When the Ability is destroyed | Clears Ability-level data (e.g., removes temporary transaction caches) |

### 4. Application Lifecycle
The Application is the global context of the application, managing resources shared by all Abilities. Its lifecycle runs through the entire process from application startup to destruction.

| Lifecycle Function | Trigger Timing | Application in Financial Scenarios |
|---------------------|----------------|-------------------------------------|
| onCreate() | When the application is first started | Initializes global services (e.g., network request interceptors, encryption tools) |
| onDestroy() | When the application process is destroyed | Clears global resources (e.g., closes database connections, unregisters push services) |
| onConfigurationUpdated(config) | When system configurations change (e.g., screen rotation) | Adapts to horizontal/vertical screen layouts (e.g., redraws market charts after rotation) |
| onTrimMemory(level) | When the system runs out of memory (level indicates urgency) | Releases non-essential resources (e.g., clears non-core market caches) |

### 5. App Process Lifecycle
The App process is the carrier for application operation. Its lifecycle is strongly related to system process management and forms the foundation of all level lifecycles.

| State | Trigger Timing | Relationship with Other Lifecycles |
|-------|----------------|-------------------------------------|
| Startup | User clicks the icon/awakened by another application | Triggers Application.onCreate() → Ability.onCreate() |
| Running | At least one Ability is active | All level lifecycles respond normally (e.g., page switching, interactions) |
| Termination | User exits/system reclaims memory | Triggers Ability.onDestroy() → Application.onDestroy() |

## III. Lifecycle Calling Sequence (Complete Process)
Taking the "launching the homepage" of a financial application as an example, the triggering sequence of each lifecycle is as follows:

App process starts → Application.onCreate() (initializes encryption services)
→ Ability.onCreate() (loads user Token)
→ Ability.onWindowStageCreate() (loads homepage UI)
→ Ability.onWindowStageActive() (window gains focus)
→ Page build() (draws homepage layout)
→ Page onDidBuild() (initializes market data)
→ Page onWindowStageShow() (window is displayed)
→ Page onReady() (binds real-time market listeners)
→ Page onPageShow() (refreshes user assets)

## IV. Code Examples (5.1+ Version, Adapted to Financial Scenarios)

### 1. Component and Page Lifecycle (Market Card Component + Homepage)

```typescript
// Custom component: Market card (@Component)
@Component
struct MarketCard {
  @State price: number = 0
  private timerId: number = -1

  build() {
    Column() {
      Text(`Real-time gold price: ${this.price.toFixed(2)} yuan/g`)
        .fontSize(16)
        .padding(10)
    }
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
  }

  // Starts market refresh after component mounting
  onReady() {
    console.log('Market card: Start listening to real-time prices')
    this.timerId = setInterval(() => {
      this.price += Math.random() * 2 - 1 // Simulate price fluctuations
    }, 3000)
  }

  // Cleans up timers before the component is removed from the render tree (new in 5.1+)
  onWillDestroy() {
    console.log('Market card: About to be destroyed, preparing to clean up resources')
  }

  // Stops refreshing when the component is completely destroyed
  onDestroy() {
    console.log('Market card: Destroyed, stop price monitoring')
    clearInterval(this.timerId) // Financial scenario: Timers must be cleaned up to avoid memory leaks
  }
}

// Page: Homepage (@Entry)
@Entry
@Component
struct HomePage {
  @State userBalance: number = 0

  build() {
    Column({ space: 20 }) {
      Text('My Assets')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      
      Text(`Total assets: ${this.userBalance.toFixed(2)} yuan`)
        .fontSize(18)
      
      MarketCard() // Introduce market card component
      
      Button('Go to Transaction')
        .onClick(() => router.pushUrl({ url: 'pages/TradePage' }))
    }
    .width('100%')
    .padding(16)
  }

  // Refreshes assets when the page is displayed (Financial scenario: Sensitive data updated in real-time)
  onPageShow() {
    console.log('Homepage displayed: Refresh user assets')
    this.fetchUserBalance() // Call interface to get the latest assets
  }

  // Saves unfinished operations when the page is hidden
  onPageHide() {
    console.log('Homepage hidden: Save browsing history')
    this.saveBrowseHistory()
  }

  // Handles back button clicks (physical/virtual)
  onBackPress(): boolean {
    console.log('Homepage back: Check for unsubmitted orders')
    if (this.hasUnfinishedOrder()) {
      // Financial scenario: Intercept back navigation when there are unfinished orders
      promptAction.showToast({ message: 'Transaction incomplete, do you want to leave?' })
      return true // Intercept system default back navigation
    }
    return false
  }

  // Simulates asset acquisition
  private fetchUserBalance() {
    // Actual scenario: Call encrypted interface to get data
    this.userBalance = 50000 + Math.random() * 10000
  }

  // Simulates saving browsing history
  private saveBrowseHistory() {
    // Actual scenario: Store in local database (needs encryption)
  }

  // Simulates checking for unfinished orders
  private hasUnfinishedOrder(): boolean {
    return false // Actual scenario: Judge based on local cache
  }
}
```

### 2. Ability Lifecycle (Homepage Ability)

```typescript
// EntryAbility.ts (Homepage Ability)
import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import { EncryptUtil } from '../common/EncryptUtil' // Financial scenario: Encryption tool class

export default class HomeAbility extends UIAbility {
  onCreate(want, launchParam) {
    console.log('Homepage Ability: Initialize, load user Token')
    // Financial scenario: Decrypt and load locally stored user Token
    EncryptUtil.init()
  }

  // Creates window stage and loads homepage
  onWindowStageCreate(windowStage: window.WindowStage) {
    console.log('Homepage Ability: Create window stage')
    // Financial scenario: Set window to be non-screenshotable (protect asset information)
    windowStage.getMainWindow((err, mainWindow) => {
      mainWindow.setWindowSecure(true)
    })
    // Load homepage
    windowStage.loadContent('pages/HomePage', (err, data) => {})
  }

  // Enables interactions when the window gains focus
  onWindowStageActive() {
    console.log('Homepage Ability: Window focused, enable button clicks')
  }

  // Pauses interactions when the window loses focus
  onWindowStageInactive() {
    console.log('Homepage Ability: Window unfocused, disable interactions')
  }

  // Cleans up resources when the window is destroyed
  onWindowStageDestroy() {
    console.log('Homepage Ability: Window destroyed, clean up encryption tools')
    EncryptUtil.destroy()
  }

  onDestroy() {
    console.log('Homepage Ability: Destroyed, clean up Token')
    // Financial scenario: Clear sensitive data in memory
  }
}
```

### 3. Application Lifecycle (Global Configuration)

```typescript
// app.ets (Application)
import AbilityStage from '@ohos.app.ability.AbilityStage';
import { CrashReporter } from '../common/CrashReporter' // Financial scenario: Crash monitoring

export default class MyApplication extends AbilityStage {
  onCreate() {
    console.log('Application: App started, initialize global services')
    // Financial scenario: Initialize crash monitoring (records abnormal transactions)
    CrashReporter.init()
  }

  // System configuration changes (e.g., screen rotation)
  onConfigurationUpdated(config) {
    console.log('Application: Configuration changed, adapt layout')
  }

  // Releases non-core resources when memory is low
  onTrimMemory(level) {
    console.log(`Application: Low memory (level ${level}), clean up market caches`)
    // Financial scenario: Retain transaction-related caches, clear historical market caches
  }

  onDestroy() {
    console.log('Application: App destroyed, clean up global resources')
    // Financial scenario: Close database connections, clear sensitive data in memory
    CrashReporter.destroy()
  }
}
```
