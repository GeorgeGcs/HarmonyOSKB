## 【HarmonyOS 5】Implementing a Handwriting Board in HarmonyOS  

\## HarmonyOS Development Capabilities ## HarmonyOS SDK Application Services ## HarmonyOS Financial Applications (Financial Management #  


### 一、Preface  
**Basic approach to implementing a handwriting board function:**  
Create an interactive component that dynamically generates paths based on touch positions and draws them with black strokes when the user touches and moves their finger on the screen. When the user presses the screen, the coordinate of the press point is recorded as the starting point of the path. As the user moves their finger, the coordinates of the moving points are continuously recorded and connected by line segments to form the path.  

**Functional effect diagram:**  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_3e7bfbf2.png 'image.png')  


### 二、Solution Approach  
The system provides a convenient line-drawing component `Path`, which integrates canvas and line-drawing functions, offering a concise interface for drawing.  

**Refer to the official component API documentation:** [Path - Graphic Drawing - ArkTS Components - ArkUI (Ark UI Framework) - Application Framework - Huawei HarmonyOS Developer](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-drawing-components-path)  

**The Path component is simple to use, as shown in the following code:**  

```javascript  
Path()  
  .commands(this.pathCommands) // Set SVG path description string  
  .strokeWidth(5) // Set stroke width to 5  
  .fill("none") // Set fill color to none  
  .stroke(Color.Black) // Set stroke color to black  
  .height('100%')  
  .width('100%')  
```  

**1. Set the component's width and height to the desired canvas area size.**  
Set `height` and `width` to 100%.  

**2. Set the line style, color, and width.**  
`stroke` is `Color.Black`, and `strokeWidth` is 5.  

**3. Set the fill color for closed areas.**  
`fill` is `none`.  

If you modify `fill` to a color, you will get the following effect:  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_004a56cc.png 'image.png')  

Since this effect does not meet the handwriting board requirement, set `fill` to `none` to remove the fill color.  

**4. Set the SVG path description string.**  
This is the core property of the component. Its value is a string similar to:  

```javascript  
M225.99999999999997 409.99999999999994 L225.99999999999997 409.99999999999994  
```  

**First, understand the role of SVG path descriptors:**  
SVG path descriptors are a set of commands for defining vector graphic paths, playing a key role in drawing with the Path component to create various complex custom shapes. Their main functions include:  

**(1) Building basic graphics:**  
Determine the starting point with the `M` (moveto) command, and draw line segments with commands like `L` (lineto), `H` (horizontal lineto), and `V` (vertical lineto) to construct basic shapes such as triangles and rectangles. For example, `commands('M0 20 L50 50 L50 100 Z')` defines a triangle starting at (0, 20), drawing two line segments, and closing the path with the `Z` (closepath) command.  

**(2) Drawing curved graphics:**  
Use commands like `C` (curveto), `S` (smooth curveto), `Q` (quadratic Belzier curve), and `T` (smooth quadratic Belzier curveto) to draw different types of Bézier curves for complex shapes. For instance, `C100 100 250 100 250 200` draws a cubic Bézier curve from the current point to (250, 200), suitable for creating curved shapes like petals or wavy lines.  

**(3) Drawing elliptical arcs:**  
The `A` (elliptical Arc) command draws an elliptical arc from the current point to a specified point. By setting the ellipse's radius, rotation angle, and other flags, it can draw partial arcs of various ellipses, such as sectors of a pie chart.  
![image.png](https://gonline-file.oss-cn-shenzhen.aliyuncs.com/file/png/2025-06-11/image_7dc41209.png 'image.png')  

**In the handwriting board scenario, SVG path descriptors only need the `M` (moveto) and `L` (lineto) commands to achieve the main function.**  
This is because the core requirement of a handwriting board is to record and present the user's drawing trajectory in real time. The `M` command determines the starting point of the trajectory: each time the user touches the screen to start writing, it initiates a new path, and the `M` command records the starting coordinate, similar to determining the first stroke on paper. The `L` command draws a line from the current point to the specified coordinate: as the user moves their finger, the coordinates of the moving points are continuously obtained, and the `L` command connects these points in sequence to form a continuous line, accurately presenting the handwriting.  

**Finally, add an `onTouch` event outside the Path component** to record the user's touch events and obtain their x and y coordinates, enabling the SVG path descriptor for the handwriting board:  

```javascript  
// Method to handle touch events  
onTouchEvent(event: TouchEvent) {  
    // Process differently based on touch event type  
    switch (event.type) {  
        // When touch type is down  
        case TouchType.Down:  
            // Add a move command (M) to pathCommands and record the down point coordinates  
            this.pathCommands += 'M' + event.touches[0].x + ' ' + event.touches[0].y;  
            break;  
        // When touch type is move  
        case TouchType.Move:  
            // Add a line command (L) to pathCommands and record the move point coordinates  
            this.pathCommands += 'L' + event.touches[0].x + ' ' + event.touches[0].y;  
            break;  
        // Other touch types, no processing  
        default:  
            break;  
    }  
}  
```  

**5. To clear the handwriting board,** simply set the `commands` property of the Path component to an empty string.  


### 三、Source Code Example  

```javascript  
@Entry  
@Component  
struct PathTestPage {  
  @State pathCommands: string = "";  

  private setPathCommands(str: string, event: TouchEvent){  
    let x = event.touches[0].x;  
    let y = event.touches[0].y;  
    this.pathCommands += str + vp2px(x) + ' ' + vp2px(y);  
    console.log("georgeDebug", " this.pathCommands: " + this.pathCommands);  
  }  

  onTouchEvent(event: TouchEvent){  
    // event xy unit: vp  
    switch (event.type){  
      case TouchType.Down:  
        this.setPathCommands('M', event);  
        break;  

      case TouchType.Move:  
        this.setPathCommands('L', event);  
        break;  
        default:  
          break;  
    }  
  }  

  build() {  
    Stack({  
      alignContent: Alignment.TopStart  
    }){  
      Path()  
        .commands(this.pathCommands) // Set SVG path description string  
        .strokeWidth(5) // Set stroke width to 5  
        .fill("none") // Set fill color to none  
        .stroke(Color.Black) // Set stroke color to black  
        .height('100%')  
        .width('100%')  
        .onTouch((event: TouchEvent)=>{  
          this.onTouchEvent(event);  
        })  

      Button("Clear Drawing")  
        .onClick(()=>{  
          this.pathCommands = "";  
        })  
    }  
    .height('100%')  
    .width('100%')  
  }  
}  
```  


### Notes  

1. Since `Path` cannot be the root node of `build`, it is wrapped in a container component (e.g., `Stack`).  

2. The coordinates `x` and `y` obtained from `onTouch` are in `vp` units, while the SVG descriptor uses `px` units. Therefore, unit conversion (e.g., `vp2px`) is required. Failing to convert units will cause the drawn content to appear smaller than the touch position.  

3. The `Path` component must have its width and height set; otherwise, it will not be displayed.