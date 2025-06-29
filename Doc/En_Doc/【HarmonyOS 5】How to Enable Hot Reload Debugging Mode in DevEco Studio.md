# 【HarmonyOS 5】How to Enable Hot Reload Debugging Mode in DevEco Studio  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Management#  


## 一、Preface  

### Hot Reload Debugging  
Hot reload is designed to solve the problem of long compilation times for large projects and low daily development efficiency. For example, when debugging application layouts or modifying small UI properties, recompiling the entire project each time can be time-consuming.  

### Official Performance Metrics:  
- In projects with 10,000 lines of ArkTS code, Hot Reload is over 70% faster than full compilation.  
- In projects with over 100,000 lines of ArkTS code, Hot Reload is over 50% faster than full compilation.  

### Basic Principle (as shown in the figure below):  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_c7f74086.png 'image.png')  

Hot reload includes two processes: **incremental patch building** and **patch applying**.  
- **Incremental Patch Building**: After modifying code, only the changed parts are incrementally built into a patch package, not a full compilation, saving significant time.  
- **Patch Applying**: Replaces and updates corresponding methods/files at runtime, then reloads them into the application. This process has two modes based on the scenario:  
  - **Hot Fix**: Modifications take effect without restarting the application (ability), preserving the current state (variables, page position, etc.).  
  - **Cold Fix**: Requires restarting the application (ability) for modifications to take effect.  

Whether a restart is needed depends on whether the modified methods/properties can be refreshed. Some lifecycles (e.g., global variables) are initialized only at application startup and persist throughout its lifecycle.  


## 二、Steps to Enable Hot Reload Debugging  

### 1. Configure the Launch File for Hot Reload Mode  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_c97229fb.png 'image.png')  
Switch from the ordinary "entry" to the "entry with H" option.  


### 2. Trigger the Hot Reload Button  
After launching with an emulator or physical device, the hot reload button will appear:  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_5960a599.png 'image.png')  
Click this "H" button to trigger Hot Reload after modifying UI code.  


### 3. Configure Shortcuts for Immediate Hot Reload  
To trigger Hot Reload automatically on code save (Ctrl+S):  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_82a25dae.png 'image.png')  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_c70293c2.png 'image.png')  
1. Go to **File > Settings**, select **Tools > Actions on Save**.  
2. Check **Perform hot reload** and click OK.  
3. Modify code and press **Ctrl + S** to trigger Hot Reload.  


## 三、Hot Reload Debugging Effect  
https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/1806dfd030f14fea954e80f2bba1b092~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAgR2VvcmdlR2Nz:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMTIzOTkwNDg0NzkzMDY1NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1750253355&x-orig-sign=QFQ5Oxj%2B6SwrCrE3%2BnG5isSd%2FUA%3D