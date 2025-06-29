## 【HarmonyOS 5】ArrayBuffer转Base64，Base64转ArrayBuffer，Uri转ArrayBuff，PixelMap转ArrayBuffer，图片Uri转为PixelMap

\##鸿蒙开发能力 ##HarmonyOS SDK应用服务##鸿蒙金融类应用 （金融理财#


**HarmonyOS NEXT**

## 前言

ArrayBuff与Unint8Array是鸿蒙应用开发中，常用的二进制字节流处理对象，类比于安卓中的byte[]。

在鸿蒙系统的应用开发中，ArrayBuffer作为一种可转移对象，在线程间传递时不需要进行拷贝，从而避免了同一份数据在主线程和子线程中分别占用内存的问题。这种特性在**处理大数据量**时尤为重要，因为它能**有效减少内存占用，提高应用性能**。

fd：资源描述符，以number形式存在，是鸿蒙系统中独有的，可以理解成文件在鸿蒙系统中的id序号。

uri：资源的路径，与path不同的是，路径字符串最前面带有file:头。例如 file://xxx.xxx.xx.png

pixelMap:类似于android中的bitmap，描述图片像素的信息对象。

## 工具函数：

最常用的转化存储函数

```dart
import { util } from "@kit.ArkTS";

  /**
   * ArrayBuffer转Base64
   * @param buffer
   * @returns
   */
  public arrayBuffer2Base64(buffer: ArrayBuffer){
    let temp = new Uint8Array(buffer);
    // 官方提供的base64编码转换工具
    let helper = new util.Base64Helper();
    let res = helper.encodeToStringSync(temp);
    return res;
  }

  /**
   * Base64转ArrayBuffer
   * @param base64Str
   * @returns 
   */
  public base642Buffer(str: string){
    let helper = new util.Base64Helper();
    let temp: Uint8Array = helper.decodeSync(str);
    let res: ArrayBuffer = temp.buffer as ArrayBuffer;
    return res;
  }

  /**
   * 图片Uri转ArrayBuff
   * @param uri
   * @returns 
   */
  public ImageUri2Buffer(uri: string){
    let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    let buffer = new ArrayBuffer(4096);
    fs.readSync(file.fd, buffer);
    return buffer ;
  }

  /**
   * PixelMap转化为ArrayBuffer
   * @param pm
   * @returns
   */
  public pixelMapToArrayBuff(pm: image.PixelMap){
    // 创建ArrayBuffer对象
    let buffer = new ArrayBuffer(pm.getPixelBytesNumber());
    // 读取像素数据到ArrayBuffer
    pm.readPixelsToBufferSync(buffer);
    return buffer;
  }

  /**
   * 图片Uri转为PixelMap
   * @param uri
   * @returns
   */
  public ImageUriToPixelMap(uri: string): image.PixelMap {
    let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    let imageSource: image.ImageSource = image.createImageSource(file.fd);
    let res: image.PixelMap = imageSource.createPixelMapSync({
      editable: true, // 是否可编辑。当取值为false时，图片不可二次编辑，如writepixels操作将失败。
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888 // 解码的像素格式。仅支持设置：RGBA_8888、BGRA_8888和RGB_565。有透明通道图片格式不支持设置RGB_565，如PNG、GIF、ICO和WEBP。
    });
    return res;
  }
```

