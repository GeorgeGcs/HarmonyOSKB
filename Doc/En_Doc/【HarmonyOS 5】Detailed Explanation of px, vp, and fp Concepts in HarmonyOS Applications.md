## 【HarmonyOS 5】Detailed Explanation of px, vp, and fp Concepts in HarmonyOS Applications  

\## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Preface  
Most current HarmonyOS developers transition from front-end or traditional mobile development backgrounds to HarmonyOS application development.  

Front-end developers are familiar with development paradigms but may feel uncomfortable with work processes and development methods. The biggest differences between mobile application development and front-end development lie in **UI adaptation and performance optimization**.  

Today, we will analyze the UI adaptation specifications and tips in HarmonyOS.  


### 二、What Are vp, px, and fp in HarmonyOS?  
Developers new to HarmonyOS are familiar with pixels (px) but may be confused about vp and fp, only knowing they are required by code specifications or technical guidance:  

**"Use fp for font sizes and vp for UI values; never use pixels (px) to set controls in UI."**  

However, the underlying principles are not well understood.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-14/fbf04c2ba78341cabb27ff081bad0fac.png 'image.png')  

Let's elaborate on the reasons behind this.  

#### 1. vp (Virtual Pixel)  
The concept of vp is simple: **vp is a screen density-related pixel that converts to physical screen pixels based on screen pixel density, maintaining a logical proportional value**.  

Since vp does not deform across multiple devices, it ensures consistent visual dimensions. When HarmonyOS API interfaces lack unit specifications, the default unit is vp, indicating it is the officially recommended unit.  

#### 2. fp (Font Pixel)  
Similar to vp, **fp adapts to screen density changes and scales with system font size settings**, serving as a dedicated unit for font pixels in HarmonyOS.  

#### 3. px (Pixel)  
Pixels (px) are familiar to mobile developers. Design prototypes and UI renderings typically use px units, which are often converted to dp for proportional use. In HarmonyOS development, to adapt to various devices and screen pixel densities, concepts similar to dp exist—namely, vp and fp.  

In HarmonyOS application development, similar to Android, adapting to multiple device types (including foldables) is essential. One of HarmonyOS's features is **flexible multi-device adaptation**, requiring a single codebase to fit various device displays. Thus, using screen pixel units (px) for UI values is not recommended: different device screen pixel densities would cause UI layout distortion if px were used.  

**Conclusion**: Use vp for component values and fp for font sizes in HarmonyOS application development.  

#### How to Convert px to vp or fp?  
Why convert? Design tools still use px units, so we must convert design values. The official provides convenient conversion functions: `px2vp` and `px2fp`.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-14/d2f1e10f7c8040dfb174c1b2da5d0773.png 'image.png')  

Note the latest API updates: Directly using `vp2px/px2vp/fp2px/px2fp/lpx2px/px2lpx` may cause UI context ambiguity. It is recommended to use `getUIContext()` to obtain a `UIContext` instance and then use instance-bound interfaces like `UIContext.px2vp`.  

Code example:  
```dart  
// Recommended: this.getUIContext().px2vp()  
.width(px2vp(200))  
```  


### 三、UI Development Specification References  

1. **UI Design Communication**: Before designers slice images from renderings, developers should confirm: slicing styles, whether icons are hollow, whether icons have white edges, icon dimensions, etc.  

2. **Image Resource Review**: After designers provide sliced images, developers should verify their validity to avoid rework, ensuring they meet development requirements.  

3. **Control Dimensions**: Convert px dimensions to vp using `px2vp(value: number): number`.  

4. **Font Sizes**: Convert px dimensions to fp using `px2fp(value: number): number`.  

5. **Colors**: Prefer existing enumeration formats (e.g., `Color.Black`, `Color.White`). For custom colors, use 16-digit hexadecimal notation provided by UI designers (e.g., `'#FFFFFF'`).  

6. **UI Self-Testing**: Developers should self-test dimensions against renderings and conduct UI joint debugging after verification.  

7. **UI Joint Debugging**: Developers submit the APP UI for testing. Designers obtain functional interface screenshots through the pipeline, compare them with renderings, and verify dynamic multi-device interaction effects after static validation.