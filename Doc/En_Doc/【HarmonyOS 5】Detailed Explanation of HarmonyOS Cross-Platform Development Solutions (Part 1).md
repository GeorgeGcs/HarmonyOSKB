# 【HarmonyOS 5】Detailed Explanation of HarmonyOS Cross-Platform Development Solutions (Part 1)  

## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Why Do We Need HarmonyOS Cross-Platform Development Solutions?  
2025 marks a critical development period for the HarmonyOS ecosystem. According to data from the recent **2025 HDC**, the number of native HarmonyOS applications has grown from 2,000 in 2024 to **5,000**, the installation volume of the HarmonyOS version of WeChat has exceeded **120 million**, and the Ministry of Public Security's traffic management system has completed adaptation for **300 cities nationwide**.  

A report by the OS Testing Laboratory of the China Academy of Information and Communications Technology states that the response delay of the HarmonyOS system is less than **10ms** (industrial-level deterministic latency), the security attack surface is only **1/1000 of Linux**, and the microkernel codebase is **100,000 lines**, far smaller than Android's **27 million lines of kernel code**.  

These figures confirm that the HarmonyOS ecosystem has entered a rapid growth phase, with explosive demand for enterprise-level application development.  

However, although there are 8 million registered HarmonyOS application developers, most are初级 (junior), with few **mid-to-senior developers** and even fewer **architect-level experts**.  

Moreover, business migration costs are high. If all applications are developed natively for HarmonyOS, the maintenance cost for multiple platforms alone is extremely high. Therefore, **enterprises prefer cross-platform solutions for HarmonyOS development**.  

Of course, based on data analysis, I始终 believe (always believe) that cross-platform development solutions are less efficient than native development. However, the choice of solution depends on the team's technical accumulation, personnel reserves, business complexity, and historical debt. Therefore, **there is no best solution, only the most suitable one**.  

**However, if developing a new APP from scratch, I recommend native HarmonyOS development, as it has the fewest pitfalls. The main development path of HarmonyOS offers the best support for native development, which is beyond doubt.**  

ArkUI-X supports writing one codebase for HarmonyOS, Android, and iOS, but it is not yet mature, and I have not used it, so this series of articles does not organize content on this. If there are ArkUI-X experts, welcome to communicate.  


### 二、Common Eight HarmonyOS Cross-Platform Solutions  
The following is a table presenting the eight HarmonyOS cross-platform development solutions, categorized by solution name, owning entity, core positioning, technical characteristics, and ecological/performance highlights:  


#### 1、Comparison Table of HarmonyOS Cross-Platform Development Solutions  
| **Solution Name** | **Owning Entity**       | **Core Positioning**                     | **Technical Characteristics**                                                                 | **Ecological/Performance Highlights**                                                                 |  
|-------------------|------------------------|-----------------------------------------|-------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|  
| Flutter           | Google                 | Cross-platform UI framework             | The earliest community adaptation for HarmonyOS<br>- Connects to HarmonyOS system services through the embedding layer<br>- Supports dual rendering engines: Skia/Impeller | Released version 3.22.0-ohos, deeply integrated with HarmonyOS NEXT API16                         |  
| React Native      | Meta                   | JavaScript cross-platform framework     | Based on JavaScript bridging with native components<br>- Mature hot reload mechanism                      | Community-maintained HarmonyOS adaptation version<br>- Over 30 community applications have adopted the HarmonyOS adaptation version                    |  
| uni-app x         | DCloud                 | One-code multi-terminal operation framework | Based on Vue syntax<br>- Supports compilation into native HarmonyOS applications                               | Thousands of special plugins for HarmonyOS Next<br>- Well-known e-commerce enterprises have implemented applications                          |  
| KMP/CMP           |                        | Kotlin Multiplatform solution           | Logic layer Kotlin code reuse<br>- Independent UI layer implementation for each platform                       | Typical implementations: Tencent Kuikly, ovCompose                                              |  
| Taro              | JD.com                 | Cross-terminal and cross-framework solution | Supports developing multi-terminal applications with React syntax<br>- C-API version significantly improves rendering performance               | JD.com's native HarmonyOS applications are developed using Taro                                        |  
| Hippy             | Meituan                | Open-source cross-platform framework      | - Based on JavaScript engine<br>- Bridge mode similar to React Native                                 | Limited HarmonyOS support                                                                     |  
| ovCompose         | Tencent                | Compose Multiplatform ecological solution | - Adopts Jetpack Compose syntax<br>- Adapts to HarmonyOS UI system                                     |                                                                                             |  
| Kuikly            | Tencent                | Kotlin Multiplatform cross-terminal framework | Based on Kotlin Multiplatform architecture                                            | - Kotlin/Native solution achieves FCP in 122ms, 6 times faster than React Native                   |  

The above data is what I could search; empty cells indicate a lack of relevant information. If there are experts on ovCompose, welcome to communicate.  

Currently, my information channels confirm that Flutter, RN, and uni are relatively mature cross-platform solutions for HarmonyOS, and many large enterprises and central enterprises have used them in their APPs. Although the frameworks have many issues, they are continuously iterating and updated, with dedicated teams maintaining them, so the problems are manageable.  

JD.com's Taro has been compatible with OpenHarmony for adaptation, but only JD.com uses it (as far as I know; if there are other companies, welcome to comment). Moreover, JD.com's early HarmonyOS APPs were developed with Taro, but due to too many compatibility issues, they should have recently switched back to native development.  

#### 2、Three Categories of Cross-Platform Directions:  
**(1) Flutter and uni-app x**  
Currently, these technologies are mature and widely used, with rich community ecosystems.  

**(2) Kuikly**  
Achieves performance breakthroughs with Kotlin/Native technology but requires teams to have Kotlin development capabilities.  

**(3) Taro and React Native**  
More suitable for teams migrating from front-end technologies.  

These solutions have their own strengths in technical architecture, development experience, and performance, and subsequent articles will conduct in-depth comparisons from four dimensions: development efficiency, performance, ecology, and maintenance cost.  

I am most familiar with Flutter because I used Flutter technology to develop APPs at Tencent and BMW from 2021 to 2022. Although I later switched to OpenHarmony, I have continued to follow the Flutter community.  

As a cross-platform UI framework developed by Google, Flutter has outstanding support in the HarmonyOS community and is one of the earliest open-source cross-platform frameworks.  

Due to the flexible architectural design of Flutter, it is convenient to migrate to different platforms, with application cases such as LG's WebOS and Toyota's in-vehicle systems.  

Currently, the HarmonyOS version of Flutter has released version 3.22.0-ohos, which is deeply adapted to HarmonyOS NEXT API16, with significant improvements in stability and compatibility. From a technical implementation perspective, it connects to HarmonyOS system services by expanding the embedding layer and adjusts the engine layer to adapt to graphics, text rendering, and platform channel communication mechanisms. In terms of rendering support, it already supports Skia and Impeller rendering.  

#### 2、Development Data Comparison of Eight Solutions:  
To more intuitively compare these solutions, I have created a table analyzing four key dimensions: development efficiency, performance, ecological maturity, and maintenance cost:  
| Solution | Development Efficiency | Performance | Ecological Maturity | Maintenance Cost |  
|----------|------------------------|-------------|---------------------|------------------|  
| Flutter  | Need to learn Dart, syntax similar to JS, supported by DevEco Studio, theoretical 100% code reuse, requires HarmonyOS adaptation, supports hot reload | Fast startup, higher memory usage, high rendering performance with Skia or Impeller, rapid interaction response, platform call overhead | Active community, has HarmonyOS adaptation team, rich plugins but limited special-purpose ones, few cases, frequent updates | Moderate cost to learn Dart, suitable for experienced teams, need to track Flutter official updates for adaptation, high cross-platform consistency but requires additional HarmonyOS adaptation |  
| React Native | Uses JavaScript/TypeScript, low learning curve, community provides HarmonyOS support, mature toolchain, high code reuse rate, requires HarmonyOS adaptation, supports hot reload | Faster startup, moderate memory usage, native component rendering performance close to native, good interaction response, possible communication delay, TurboModule mechanism calls native code with better performance | Active community, has HarmonyOS adaptation version, rich plugins but limited special-purpose ones, over 30 application cases, relatively slow updates | Low learning cost, suitable for front-end teams, need to maintain HarmonyOS adaptation, good cross-platform consistency but with differences |  
| uni-app x | Uses Vue syntax and UTS language, low learning cost, comprehensive support from HBuilderX, one code runs on multiple terminals, extremely high code reuse rate, supports hot reload | Fast startup, low memory usage, native components + native rendering performance close to native, logic layer and view layer share native process for rapid response, direct native API calls with high efficiency | Supported by DCloud official, active community, thousands of plugins supporting HarmonyOS next, well-known e-commerce application cases, frequent updates | Low learning cost, suitable for Vue teams, official continuous maintenance, high cross-platform consistency |  
| KMP/CMP  | Need to master Kotlin, higher learning cost, good support from IntelliJ IDEA and Android Studio, high logic layer code reuse, separate UI layer implementation for each platform, supports hot reload | Kotlin/Native starts fast, Kotlin/JS is relatively slow, low memory usage, native-based rendering performance close to native, rapid interaction response, direct native API calls with high performance | Gradually active community, supported by enterprises like Tencent, KMP ecosystem gradually enriching but limited HarmonyOS-specific resources, large enterprises have application cases, moderate update frequency | High learning cost, suitable for Android or Kotlin teams, need to maintain multi-platform UI implementations, high logic layer consistency, UI layer needs separate implementation |  
| Taro     | Uses React syntax, low learning curve, good support from DevEco Studio and Taro CLI, one code adapts to multiple platforms, supports hot reload | Faster startup, moderate memory usage, C-API version significantly improves rendering performance, runtime logic sinks to C++ for rapid response, high efficiency via C++-side calls to ArkUI C++ API | Active community, supported by enterprises like JD.com, mature ecosystem with rich plugins, HarmonyOS support gradually improving, JD.com HarmonyOS application cases, frequent updates | Low learning cost, suitable for React teams, maintained by official and community, high cross-platform consistency |  
| ovCompose | Need to learn Compose DSL, certain cost, based on Android Studio and IntelliJ IDEA, good tool support, three-terminal one-code development, high code reuse rate, supports hot reload | Faster startup, moderate memory usage, good Skia rendering performance, good response but performance issues on HarmonyOS, good performance via NAPI for native code and CPP-side communication | Supported by Tencent official, community gradually forming, based on Compose Multiplatform with limited ecological resources, Tencent Video has application cases, moderate update frequency | Higher learning cost, suitable for Android or Kotlin teams, need to maintain multi-platform UI implementations, good cross-platform consistency but with differences |  
| Kuikly   | Uses Kotlin language, certain learning cost, provides special HarmonyOS debugging and build support and toolchain, supports one-code multi-terminal, high code reuse rate, supports hot reload | Kotlin/Native solution starts fast, page FCP takes only 122ms, 6 times faster than React Native, low memory usage, uses native OEM rendering with performance close to native, interaction response consistent with native, direct native API calls with high performance | Supported by Tencent official, community initially formed, built-in 30+ business UI components, community component platform under construction, multiple Tencent applications implemented, moderate update frequency | Higher learning cost, suitable for Android or Kotlin teams, maintained by Tencent official, high cross-platform consistency |  
| Hippy    | Uses JavaScript, low learning curve, relatively mature toolchain but limited HarmonyOS support, high code reuse rate, requires HarmonyOS adaptation, supports hot reload | Faster startup, moderate memory usage, good native rendering engine performance, good interaction response but possible communication delay, bridge mechanism calls native code with overhead | General community activity, limited HarmonyOS support, relatively limited ecosystem, few special plugins, few public cases, low update frequency | Low learning cost, suitable for front-end teams, community-maintained, good cross-platform consistency but with differences |  


### 三、Enterprise Real-World Demands for Cross-Platform Development  
According to HarmonyOS community data, enterprises face three core demands in HarmonyOS application development:  
1. **Cost Control**: 62% of enterprises hope to reduce development costs by more than 50% through cross-platform solutions  
2. **Multi-Terminal Adaptation**: 89% of applications need to support HarmonyOS, Android, and iOS simultaneously  
3. **Performance Balance**: Require both cross-platform efficiency and user experience close to native  

Therefore, large and medium-sized enterprises will prioritize cross-platform solutions. Which solution to choose is a key link in enterprise architecture decision-making, and subsequent series of articles will focus on in-depth analysis of Flutter and multi-solution comparisons.