## 【HarmonyOS 5】Detailed Explanation of HarmonyOS mPaaS  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  


## I. What is mPaaS?  

**mPaaS is the abbreviation for Mobile Platform as a Service**, namely a **mobile development platform**.  

The Ant Mobile Development Platform mPaaS integrates Alipay's technological capabilities, providing end-to-end one-stop solutions for mobile application development, testing, operation, and maintenance. With more than a decade of technical accumulation and iteration, it possesses mature and efficient capabilities.  

It can effectively enhance the interactive experience of apps, ensure app compliance and security, and assist enterprises in achieving business growth with refined operation and marketing scenario capabilities.  

Mobile development platforms similar to mPaaS include JD mPaaS, etc. Essentially, these are business profit points created by the middle-platform departments of large tech companies. As the foundational department for business in large companies, the middle platform almost always develops the underlying frameworks for all apps within the same ecosystem. Against this backdrop, it is a natural progression to provide **general solutions for commercial use** externally.  

This article will elaborate on the integration, tool usage, and initialization process of mPaaS in HarmonyOS development, combining official documentation.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_02e950c2.png 'image.png')  


## II. Main Functions and Advantages of mPaaS  

**Containerization technology, plugin-based architecture, hotfix capabilities, dynamic deployment**:  


### 1. Containerization Technology: Unifying Application Runtime Environments  

mPaaS abstracts the runtime environments of native applications (iOS/Android) into a unified container through **containerization technology**, achieving the following capabilities:  

- **Cross-platform compatibility**:  
  The container layer shields the underlying differences of iOS, Android, and HarmonyOS systems, allowing business code (such as H5, mini-programs, Flutter, etc.) to run in a unified environment, reducing cross-platform development costs.  
- **Dynamic loading mechanism**:  
  The container supports dynamic loading of plugins, pages, resources, etc., enabling function updates without reapplying. For example:  
  - Loading new H5 pages or mini-program modules;  
  - Dynamically replacing static resources like images and fonts.  
- **Sandbox isolation**:  
  Provides independent runtime sandboxes for each business module, ensuring data isolation and resource non-interference between modules, thereby enhancing application stability and security.  

**Differences in containerization technology between HarmonyOS mPaaS and Android/iOS platforms:**  

| **Feature**         | **HarmonyOS mPaaS**                  | **Traditional Android/iOS mPaaS**                          |  
| ----------------- | ------------------------------- | ------------------------------------------------ |  
| **Underlying container technology** | Based on ArkTS componentization + Stage model      | Based on WebView (Android/iOS) or native containers (such as React Native) |  
| **Dynamic loading granularity**  | In units of HAP/Ability               | In units of plugins (such as JS Bundle, Native modules)            |  
| **Isolation mechanism**       | Process/thread isolation based on HarmonyOS system       | Sandbox based on WebView or custom Native containers               |  
| **Hot update method**       | Dynamic update via HAP packages (requires system permissions)    | Update via JS script injection or Native code replacement (such as Android Dex loading) |  
| **Performance overhead**      | Lower (ArkTS compiled into Native code)        | Higher (WebView or cross-language bridging)                     |  


### 2. Plugin-based Architecture: Modular Development and Hot Deployment  

mPaaS adopts a **plugin-based architecture**, splitting applications into **host containers** and **independent plugins** (such as functional modules and business components). Core mechanisms include:  

- **Dynamic plugin loading**:  
  The host container dynamically loads plugins at runtime, enabling new functions without restarting the application. For example:  
  - E-commerce apps can dynamically load the "live broadcast" plugin without releasing a new version;  
  - Financial apps can dynamically update the logic of the "payment" module.  
- **Plugin lifecycle management**:  
  The container manages the lifecycle of plugins (loading, initialization, activation, destruction, etc.), ensuring reasonable resource release and avoiding memory leaks.  
- **Inter-plugin communication mechanism**:  
  Provides a unified message bus (such as EventBus), supporting safe and efficient communication between plugins to decouple module dependencies.  

The core of containerization technology in HarmonyOS mPaaS is the **componentization and isolation capabilities provided by the ArkTS language**, mainly reflected in HarmonyOS splitting application functions into independent **Abilities** (similar to Android's Activity/Fragment), each running in an independent sandbox environment:  

- **Resource isolation**:  
  UI rendering, memory usage, and data storage between Abilities are mutually isolated, preventing the entire application from abnormal behavior due to the crash of a single component.  
- **Dynamic loading**:  
  Abilities support on-demand loading, allowing specific functional modules to be activated without starting the entire application. For example:  
  ```typescript
  // Dynamically load and start a specified Ability  
  import abilityAccessCtrl from '@ohos.abilityAccessCtrl';  
  const aac = abilityAccessCtrl.createAbilityAccessCtrl();  
  aac.startAbility(request)  
    .then(() => console.log('Ability started successfully'))  
    .catch((err) => console.error(`Failed to start ability: ${err}`));  
  ```  

HarmonyOS's **Stage model** splits applications into **HAP (HarmonyOS Ability Package)**, each HAP can contain multiple Abilities:  

- **Independent deployment**:  
  HAP supports dynamic downloading and installation for hot updates of functions. For example:  
  ```json
  // Configure the HAP module in config.json  
  {  
    "module": {  
      "name": "entry",  
      "deviceTypes": ["phone"],  
      "reqPermissions": [],  
      "abilities": [...]  
    },  
    "subModules": [  
      {  
        "name": "feature-module",  
        "description": "Dynamic feature module",  
        "deliveryWithInstall": false, // Supports on-demand downloading  
        "installationFree": true  
      }  
    ]  
  }  
  ```  


### 3. Hotfix and Dynamization: Quickly Fixing On-line Issues  

mPaaS achieves rapid on-line issue fixing and function iteration through **hotfix** and **dynamic technology**. Underlying mechanisms include:  

- **Code hotfix**:  
  - **iOS**: Utilizes Objective-C's dynamic features (such as Method Swizzling) or Fishhook technology to replace incorrect function implementations at runtime;  
  - **Android**: Fixes bugs in Java/Kotlin code dynamically through class loading (Dexposed) or Native layer replacement (such as AndFix).  
  The fix package can be delivered via the cloud, taking effect without users reinstalling the app.  
- **Dynamic resource update**:  
  Supports dynamic updating of resources such as images, layout files (such as XML/JSON), and fonts. For example:  
  - Fixing UI display anomalies (such as incorrect button colors);  
  - Adjusting page layouts to adapt to new device models.  
- **Script-based dynamic logic**:  
  Supports embedding script languages such as JavaScript and Lua to achieve dynamic adjustment of business logic. For example:  
  - Dynamically modifying the interaction logic of H5 pages through JS scripts;  
  - Injecting script code into native pages to adjust business processes in real-time.  


### 4. Cloud-end Integration: Data-driven and Remote Configuration  

The mPaaS underlying layer deeply integrates with Alibaba Cloud services, achieving **real-time linkage between the client and the cloud**. Core mechanisms include:  

- **Remote Config**:  
  Dynamically delivers business parameters through the cloud configuration center. For example:  
  - Adjusting function switches (such as temporarily closing high-risk modules);  
  - Modifying operation strategies (such as adjusting activity rules and interface copy).  
  Configuration changes take effect in real-time without releasing a new version.  
- **A/B testing and gray release**:  
  Based on cloud分流 strategies, users are divided into different groups to test different function versions (such as interface styles and business logic), optimizing the user experience through data monitoring (such as click-through rate and crash rate).  
- **Logging and monitoring**:  
  The client collects runtime logs (such as crash stacks and performance indicators) in real-time and reports them to the cloud monitoring platform, supporting rapid positioning and analysis of on-line issues.  


### 5. Performance Optimization and Stability Assurance  

The mPaaS underlying layer integrates a series of **performance optimization and stability enhancement technologies**:  

- **Memory management**:  
  Isolates memory usage of different modules through the plugin-based architecture and sandbox mechanism, reducing memory leaks and OOM (Out of Memory) issues by optimizing automatic garbage collection (GC).  
- **Network optimization**:  
  Provides a unified network request framework, supporting connection pool reuse, HTTP/2 protocol, dynamic DNS resolution, etc., improving network request efficiency and stability.  
- **Offline package mechanism**:  
  Pre-downloads commonly used H5 pages and mini-program code to the local device, reducing dependence on the network and improving page loading speed, especially in weak network environments.  
- **Crash protection**:  
  Built-in Crash capture and recovery mechanisms monitor application crashes in real-time and quickly restore normal operation through hotfix technology.  


### 6. Security Mechanisms: Data and Communication Protection  

The mPaaS underlying layer attaches great importance to security. Core mechanisms include:  

- **Data encryption**:  
  Encrypts locally stored data (such as user privacy and configuration information), supporting encryption algorithms such as AES and RSA.  
- **Communication security**:  
  Adopts HTTPS two-way authentication (SSL Pinning) and anti-packet capture technology to ensure that data communicated between the client and the cloud is not tampered with or stolen.  
- **Application hardening**:  
  Integrates technology such as code obfuscation, anti-decompilation, and anti-debugging to enhance application security and resist malicious attacks.  


## III. Architectural Principle Analysis of mPaaS  

mPaaS in HarmonyOS does adopt containerization technology, but its implementation differs from traditional Android/iOS platforms, mainly based on HarmonyOS's **ArkTS language features**, **Stage model**, and **Ability componentization framework**. The specific analysis is as follows:  


## IV. How to Integrate mPaaS in HarmonyOS?  

[Click to access the official HarmonyOS NEXT integration documentation](https://help.aliyun.com/document_detail/2785332.html?spm=a2c4g.11186623.help-menu-49548.d_3_2_0.57e3aa7baWJNjw)  


### 1. Precondition Preparation  

1. **Development environment**: Install the latest HarmonyOS NEXT development environment, requiring support for API 12 and above.  
2. **Device requirements**: Prepare a real device or emulator with HarmonyOS 3.0.0.22 or above (emulator usage refers to official documentation).  
3. **Configuration file**: Create an application in the mPaaS console, download the HarmonyOS NEXT version `.config` configuration file, which needs to be renamed to `mpaas.config` and placed in the specified project directory.  


### 2. Key Operation Process  

1. **Configuration file processing**  
   Rename the downloaded `.config` file to `mpaas.config` and copy it to the `entry/resource/rawfile` directory of the main project to store key application configuration information.  

2. **Install the mppm tool**  
   mppm is an SDK management tool provided by mPaaS, supporting functions such as dependency installation, cache cleaning, and baseline management. Installation steps are as follows:  
   ```bash
   # Globally install mppm  
   npm install @alipay-inc/oh-mpaas-cli -g  
   # Check the version (current version is v2.0.0)  
   mppm -v  
   ```  
   **Note for Windows users**: Need to configure `npm-global` and `npm-global/bin` environment variables, which can be viewed via `npm config get prefix` for the default path.  

3. **Initialize the project**  
   Execute the `mppm init` command in the DevEco Studio terminal, and select the baseline version (such as 10.2.3) and components to install as prompted. After initialization, a `.mprc` file will be generated in the project root directory, recording baseline information (such as `"baseline":"10.2.3"`).  

4. **Obtain security images**  
   Generate security images through the mppm tool, requiring the application signature fingerprint (fingerprint) and appsecret:  
   ```bash
   mppm fetch-image --finger <fingerprint value> --secret <appsecret>  
   ```  
   **Fingerprint acquisition method**:  
   - **Certificate extraction**: Use the keytool tool to parse the `.cer` certificate file to obtain the SHA-256 value.  
   - **Code acquisition**: Call the HarmonyOS API `bundleManager.getBundleInfo` to obtain signature information.  
   - **bm command**: Query on a real device via `hdc shell bm dump -n <package name> | grep fing`.  


## V. Core Functions and Commands of the mppm Tool  

### 1. Tool Positioning and Function List  

As an SDK management tool, mppm is mainly used to simplify the dependency management of mPaaS components in HarmonyOS projects. Core functions include:  

- **Dependency installation**: Automatically executes `ohpm install` to install required dependencies for each module.  
- **Cache cleaning**: Clears `hvigor` and `oh_modules` caches (command: `mppm clean`; dependencies need to be resynchronized after execution).  
- **Baseline management**: Supports baseline upgrade (`mppm upgrade`), customized baseline installation (`mppm sdk --custom <baseline name>`), and manual synchronization (`mppm sync`, taking effect after modifying `.mprc`).  

### 2. Common Command Examples  

| **Operation Scenario**   | **Command**                        | **Description**                    |  
| ------------- | ------------------------------- | ----------------------------- |  
| Installing a customized baseline    | `mppm sdk --custom 10.2.3.isec`     | Installing a specified version of the customized baseline         |  
| Synchronizing the baseline version    | `mppm sync`                       | Updating project dependencies to the target baseline version based on the `.mprc` file |  
| Cleaning and reinstalling dependencies | `mppm clean && ohpm install`       | Solving dependency installation errors (such as ENOENT), requiring use with the ohpm command |  


## VI. mPaaS Initialization and Framework Integration  

### 1. Dependency Introduction and Configuration  

1. **Repository configuration**: Add the mPaaS repository address in the project `.ohpmrc`:  
   ```bash
   @mpaas:registry=https://mpaas-ohpm.oss-cn-hangzhou.aliyuncs.com/meta  
   ```  
2. **Core dependencies**: Add framework and C++ shared library dependencies in `oh-package.json5`:  
   ```json
   {  
     "dependencies": {  
       "@mpaas/framework": "0.0.2",   // Core framework dependency  
       "@mpaas/cpp-shared": "1.0.0"   // C++ shared library (non-repeating installation)  
     }  
   }  
   ```  


### 2. Framework Initialization Code Implementation  

1. **Create an AbilityStage component**: Create a new ArkTs file `EntryAbilityStage.ets` as the component container for the application.  
2. **Initialization logic**: Call `MPFramework.create(app)` in the `onCreate` callback of `AbilityStage` to initialize the framework:  
   ```typescript
   import { MPFramework } from '@mpaas/framework';  
   export default class EntryAbilityStage extends AbilityStage {  
     async onCreate() {  
       const app = this.context;  
       MPFramework.create(app); // Initialize the mPaaS framework  
       const instance = MPFramework.instance;  
       // Subsequent calls to APIs to obtain udid, set user ID, etc.  
     }  
   }  
   ```  
3. **Component registration**: Configure `srcEntry` to point to the initialization component path in `module.json5`:  
   ```json
   {  
     "module": {  
       "name": "entry",  
       "srcEntry": "./ets/EntryAbilityStage.ets"  
     }  
   }  
   ```  


### 3. Core API Usage  

- **Obtain device UDID**: `MPFramework.instance.udid` (asynchronous interface, requiring `await`).  
- **User identity management**: Set or obtain the user ID through `MPFramework.instance.userId`.  
- **Security information configuration**: Manage sensitive appSecret information through `MPFramework.instance.appSecret`.