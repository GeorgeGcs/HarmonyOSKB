【HarmonyOS 5】Common Title Bar Layout Schemes in HarmonyOS
##HarmonyOS Development Capabilities ##HarmonyOS SDK Application Services##HarmonyOS Financial Applications (Financial Wealth Management#

### I. Background
Common title bars in HarmonyOS: a rectangular area with a back button on the left, a question mark help button on the right, and title text in the middle.

Financial applications have stricter requirements for title bars: on one hand, they must ensure the stability of navigation functions (the back button must be easily accessible); on the other hand, they must take into account brand tone (the title text must be clear and prominent); at the same time, the help button must be easy to find (to facilitate users in obtaining financial management guidance).

An ideal title bar should meet:
- Cross-device adaptation (consistent display on multiple terminals such as mobile phones and tablets)
- Precise component alignment (vertical centering, reasonable horizontal spacing)
- Clear interaction feedback (buttons have obvious state changes when clicked)
- Flexible expansion (can quickly add elements such as user avatars and notification icons)

What are the layout methods and how to implement them? A common thought is that some developers use row for layout but struggle to align elements properly.

### II. Solutions


#### Scheme 1: Flex Layout (Recommended First Choice)
Flex layout (flexible layout) is the best choice for handling linear arrangements in HarmonyOS. Through the justifyContent and alignItems properties, it can easily achieve uniform distribution and centering alignment of components, especially suitable for responsive scenarios.

Using the Row direction of the Flex container (horizontal arrangement by default), SpaceBetween makes the three components (back button, title, help button) align at both ends in the horizontal direction with the middle part adapting automatically; setting alignItems to Center ensures vertical centering. This layout automatically distributes remaining space, maintaining stable relative positions of components across different screen sizes.

**Code Implementation**
```typescript
@Entry
@Component
struct FinanceTitleBar {
  // Title text can be dynamically modified (adapts to different pages)
  @State title: string = "My Assets"

  build() {
    Column() {
      // Title bar main body
      Flex({ 
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        // Left back button: add ripple effect to enhance interaction
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r("app.media.ic_back")) // Use actual back icon
            .width(24)
            .height(24)
            .fillColor("#333333")
        }
        .width(40)
        .height(40)
        .backgroundColor("transparent")
        .onClick(() => {
          // In financial applications, returning may require confirmation (e.g., unsaved forms)
          router.back()
        })

        // Middle title: recommended to be bold in financial scenarios for prominence
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor("#1A1A1A")
          .maxLines(1) // Prevent line breaks for long titles
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // Right help button: circular design fits the sense of security in financial applications
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r("app.media.ic_help")) // Use actual help icon
            .width(24)
            .height(24)
            .fillColor("#333333")
        }
        .width(40)
        .height(40)
        .backgroundColor("transparent")
        .onClick(() => {
          // Jump to help center (common requirement in financial applications)
          router.pushUrl({ url: "pages/HelpPage" })
        })
      }
      .width('100%')
      .height(56) // Title bar height conforming to HarmonyOS design specifications
      .padding({ left: 16, right: 16 }) // Left and right margins adapt to touch areas
      .backgroundColor("#FFFFFF")
      .shadow({ radius: 2, color: "#00000010" }) // Bottom shadow enhances layering

      // Page content area (example)
      Text("Asset details content...")
        .flexGrow(1)
        .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor("#F5F5F5")
  }
}
```


#### Scheme 2: Stack Layout (Precise Positioning Scenarios)
Stack layout (stacked layout) overlays components in layers, suitable for scenarios requiring precise positioning. The core idea is to fix the title text in the center, and place the back button and help button on both sides through absolute positioning.

The Stack container stacks sub-components by default. The title text is centered using alignContent: Alignment.Center; button components are positioned on the x-axis via the position property (left button 16vp from the left, right button 16vp from the right), and the y-axis is set to 0 for vertical centering.

**Code Implementation**
```typescript
@Entry
@Component
struct StackTitleBar {
  @State title: string = "Financial Products"

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // Middle title: rendered first to ensure it is not blocked by buttons
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor("#1A1A1A")

        // Left back button: using absolute positioning
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r("app.media.ic_back"))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor("transparent")
        .position({ x: 16, y: 0 }) // x=16 sticks to the left, y=0 for vertical centering
        .onClick(() => {
          router.back()
        })

        // Right help button: positioned by calculating right margin
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r("app.media.ic_help"))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor("transparent")
        .position({ x: "calc(100% - 56vp)", y: 0 }) // 100% width minus button width (40) and right margin (16)
        .onClick(() => {
          router.pushUrl({ url: "pages/HelpPage" })
        })
      }
      .width('100%')
      .height(56)
      .backgroundColor("#FFFFFF")
      .shadow({ radius: 2, color: "#00000010" })

      // Page content
      Text("Financial product list...")
        .flexGrow(1)
        .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor("#F5F5F5")
  }
}
```


#### Scheme 3: Row+Column Combined Layout (Complex Expansion Scenarios)
When the title bar needs to include more elements (such as user avatars, multi-button groups), a combined layout of Row nested with Column can be used to achieve flexible arrangement through weight distribution.

The outer layer uses Row as the main container, which is divided into three areas: left area (back button), middle area (title), and right area (help button + user avatar). Each area is set with weight via flexGrow (left and right areas have a weight of 0, middle area has a weight of 1, ensuring the title fills the remaining space).

**Code Implementation**
```typescript
@Entry
@Component
struct ComplexTitleBar {
  @State title: string = "Account Settings"
  @State userName: string = "Zhang**" // Financial applications hide part of the name

  build() {
    Column() {
      Row() {
        // Left area: only back button
        Row() {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image($r("app.media.ic_back"))
              .width(24)
              .height(24)
          }
          .width(40)
          .height(40)
          .backgroundColor("transparent")
          .onClick(() => router.back())
        }
        .flexGrow(0) // Does not occupy extra space

        // Middle area: title (fills remaining space)
        Row() {
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
        }
        .flexGrow(1) // Weight 1, fills remaining space
        .justifyContent(FlexAlign.Center) // Center internally

        // Right area: help button + user avatar
        Row({ space: 12 }) { // 12vp spacing between buttons
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image($r("app.media.ic_help"))
              .width(24)
              .height(24)
          }
          .width(40)
          .height(40)
          .backgroundColor("transparent")
          .onClick(() => router.pushUrl({ url: "pages/HelpPage" }))

          // Common in financial applications: user avatar
          Image($r("app.media.ic_avatar"))
            .width(36)
            .height(36)
            .borderRadius(18) // Circular avatar
            .onClick(() => router.pushUrl({ url: "pages/UserPage" }))
        }
        .flexGrow(0)
        .alignItems(ItemAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor("#FFFFFF")
      .shadow({ radius: 2, color: "#00000010" })

      // Page content
      Text("Account security settings...")
        .flexGrow(1)
        .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor("#F5F5F5")
  }
}
```
