## 【HarmonyOS 5】ArrayBuffer to Base64, Base64 to ArrayBuffer, Uri to ArrayBuffer, PixelMap to ArrayBuffer, Image Uri to PixelMap  

\##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services ##HarmonyOS Financial Applications (Financial Management #  


**HarmonyOS NEXT**  

## Preface  

ArrayBuffer and Uint8Array are commonly used binary byte stream processing objects in HarmonyOS application development, analogous to byte[] in Android.  

In HarmonyOS application development, ArrayBuffer serves as a transferable object that can be passed between threads without copying, avoiding the issue of the same data occupying memory in both the main thread and child threads. This feature is particularly important when **handling large data volumes**, as it can **effectively reduce memory usage and improve application performance**.  

- **fd**: A resource descriptor, existing as a number, unique to the HarmonyOS system. It can be understood as the file's ID sequence in the HarmonyOS system.  
- **uri**: The resource path, differing from path in that the path string starts with the "file:" prefix. For example: file://xxx.xxx.xx.png  
- **pixelMap**: Similar to Android's bitmap, an object describing image pixel information.  


## Utility Functions:  

The most commonly used conversion and storage functions  

```dart
import { util } from "@kit.ArkTS";

  /**
   * Convert ArrayBuffer to Base64
   * @param buffer The ArrayBuffer to convert
   * @returns Base64 string
   */
  public arrayBuffer2Base64(buffer: ArrayBuffer): string {
    let temp = new Uint8Array(buffer);
    // Official Base64 encoding conversion utility
    let helper = new util.Base64Helper();
    let res = helper.encodeToStringSync(temp);
    return res;
  }

  /**
   * Convert Base64 to ArrayBuffer
   * @param base64Str The Base64 string to convert
   * @returns ArrayBuffer
   */
  public base642Buffer(str: string): ArrayBuffer {
    let helper = new util.Base64Helper();
    let temp: Uint8Array = helper.decodeSync(str);
    let res: ArrayBuffer = temp.buffer as ArrayBuffer;
    return res;
  }

  /**
   * Convert image Uri to ArrayBuffer
   * @param uri The image Uri to convert
   * @returns ArrayBuffer
   */
  public ImageUri2Buffer(uri: string): ArrayBuffer {
    let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    let buffer = new ArrayBuffer(4096);
    fs.readSync(file.fd, buffer);
    return buffer;
  }

  /**
   * Convert PixelMap to ArrayBuffer
   * @param pm The PixelMap to convert
   * @returns ArrayBuffer
   */
  public pixelMapToArrayBuff(pm: image.PixelMap): ArrayBuffer {
    // Create an ArrayBuffer object
    let buffer = new ArrayBuffer(pm.getPixelBytesNumber());
    // Read pixel data into ArrayBuffer
    pm.readPixelsToBufferSync(buffer);
    return buffer;
  }

  /**
   * Convert image Uri to PixelMap
   * @param uri The image Uri to convert
   * @returns PixelMap
   */
  public ImageUriToPixelMap(uri: string): image.PixelMap {
    let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    let imageSource: image.ImageSource = image.createImageSource(file.fd);
    let res: image.PixelMap = imageSource.createPixelMapSync({
      editable: true, // Whether editable. When set to false, the image cannot be edited twice, and operations like writepixels will fail.
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888 // The decoded pixel format. Only supports: RGBA_8888, BGRA_8888, and RGB_565. Images with transparent channels (e.g., PNG, GIF, ICO, WEBP) do not support setting RGB_565.
    });
    return res;
  }
```