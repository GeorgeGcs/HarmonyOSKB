## 【HarmonyOS 5】Detailed Explanation of HarmonyOS CodeGenie AI-Assisted Programming Tool  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  

## I. Preface  

**1. What is CodeGenie?**  
**CodeGenie** (Code Genie) is an AI-assisted coding tool built into the HarmonyOS DevEco IDE.  

**IDE version and CodeGenie mapping:**  
It is recommended to use DevEco Studio 5.0.3.403 and above to use CodeGenie. In the DevEco Studio 5.0.4 Release version, CodeGenie is available as a built-in plugin, indicating that it can better meet development needs in this version.  

If using a non-latest version of DevEco Studio, you can obtain and use related functions through the plugin download center. The calling effect is the same as the built-in version, with an additional step of manually installing the plugin.  

**2. What is the role of CodeGenie?**  
**(1) Intelligent Q&A: (Detailed steps in Chapter III)**  
When developers encounter problems during development, they can use the tool built into the IDE to obtain relevant knowledge answers in the form of AI cultural answers.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_6fed4efb.png 'image.png')  

**(2) ArkTS code generation:**  
Helps developers generate ArkTS code, improving coding efficiency and reducing manual coding workload.  
Generate code example source code through a question-and-answer format (detailed steps in Chapter III).  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_a76ce4e3.png 'image.png')  
Or manually open the code generation function, which can automatically prompt when developers code. Go to File > Settings > DevEco CodeGenie > Code Generation page to enable it.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_1f15b975.png 'image.png')  

Generate single-line or multi-line code through shortcut operations. Developers confirm or cancel operations through the menu bar at the top of the automatically generated code.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_bcb172ee.png 'image.png')  

| Operation               | macOS          | Windows     |  
| --------------------- | -------------- | ----------- |  
| Trigger multi-line code generation        | Enter、Option+C | Enter、Alt+C |  
| Trigger single-line code generation        | Option+X       | Alt+X       |  
| Adopt generated code             | Tab            | Tab         |  
| Ignore generated code             | Esc            | Esc         |  
| View the previous code generation result     | Option +\[     | Alt + \[    |  
| View the next code generation result       | Option + ]     | Alt + ]     |  
| Regenerate code content (supports up to 5 regenerations) | Option + R     | Alt + R     |  
| Display the CodeGenie panel         | Option + U     | Alt + U     |  

**(3) Universal Card generation:**  
Has the ability to generate Universal Cards, facilitating developers to implement related functions in application development.  
This function actually combines the above two functions, and the AI coding assistant develops and improves the card requirements step by step through the form of answers.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_29c51477.png 'image.png')  


## II. Detailed Steps for Using CodeGenie's Menu View (Intelligent Q&A/Code Generation) in IDE  

1. First, download the corresponding IDE version (it is recommended to use the latest IDE version currently)  
2. After opening DevEco IDE, manually click the CodeGenie menu on the right (or use the shortcut key Alt + U, Option + U for mac)  
3. The menu display effect is as shown in the following figure, with the right side being the Chinese translation effect. When we use the AI-assisted coding tool for the first time, CodeGenie needs to confirm the agreement. We click to check that we have read it and then click Login. The login here has the same effect as the login in the upper right corner of the IDE, both of which jump to the browser to log in to the Huawei developer account using a web page.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_26341fd3.png 'image.png')  

4. After we log in, we will enter the main menu interface of CodeGenie. Double-clicking the title bar above can enlarge or reduce the menu View layout. The main interface is mainly composed of an introduction to the coding assistant and two entries for knowledge Q&A and code generation.  

When we click on one of the two entries, the corresponding input content will be displayed in the input bar at the bottom. At this time, after we enter the corresponding prompt in the input bar, the AI will generate the corresponding result. Whether it is an answer or code, remember to choose through the entry.  

5. When our answer ends and we want to switch to code, what should we do? Just click new chat in the lower right corner (start a new conversation). The same applies to switching from code to answer.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_6b34c509.png 'image.png')  


## III. Intelligent Analysis of Compilation Errors and Intelligent Interpretation of Code Using CodeGenie in IDE  

**1. Intelligent analysis of compilation errors**  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_bc1739cf.png 'image.png')  

After a compilation error, clicking the blue button prompt will automatically唤起 the AI coding assistant's menu View to explain the compilation error information.  

**2. Intelligent code interpretation**  
I am using DevEco Studio 5.0.5 Release. Currently, there is no official documentation prompting: select the code lines or code snippets to be explained in the .ets file or .cpp file, right-click and select CodeGeine > Explain Code to start interpreting the current code content.  

A support ticket has been raised, and the follow-up feedback results will be updated here.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_9bb38747.png 'image.png')