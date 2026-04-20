<div align="center">

# Beam

**Animated beams for SwiftUI, backed with Metal Shaders.**

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-F05138.svg?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![iOS 17+](https://img.shields.io/badge/iOS-17%2B-007AFF.svg?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-007AFF.svg?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/macos/)
[![SPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-E8E2D6.svg?style=flat)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-A78BFA.svg?style=flat)](LICENSE)

One SwiftUI modifier. Every `View` gets a shifting, palette-driven beautiful beam traveling its border.

<br>

<!-- HERO VIDEO — replace with uploaded asset URL -->
<!-- https://github.com/user-attachments/assets/REPLACE_ME_HERO -->

</div>

<br>

## Why

UIKit and SwiftUI don't ship a "moving colorful border" primitive. The typical workaround is an `AngularGradient` + rotation + masking + blur — which animates the host view's hierarchy on every frame, and still doesn't look right on rounded corners.

Beam renders the whole effect in a single `[[ stitchable ]]` Metal shader per size variant. The beam's geometry, palette, inner glow, stroke, and bloom all live on the GPU. SwiftUI just ticks a `TimelineView` and hands the shader the current time.

## Install

```swift
// Package.swift
.package(url: "https://github.com/tornikegomareli/beam.git", from: "0.1.0")
```

Or in Xcode: **File → Add Package Dependencies** → paste the URL.

---

## Quick Start

```swift
import SwiftUI
import Beam

struct ContentView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 18)
      .fill(.regularMaterial)
      .frame(height: 144)
      .beam()                            // default: medium, colorful, dark
  }
}
```

---

## Size variants

```swift
.beam(.medium)   // card-sized — full rounded-rect border
.beam(.small)    // button-sized — compact with wider inner glow
.beam(.line)     // traveling bar along the bottom edge
.beam(.comet)    // single bright head with a fading trail
```

| Size | Best for | Rotation period |
|------|----------|-----------------|
| `.medium` | Cards, chat inputs, hero modules | 1.96 s |
| `.small` | Buttons, chips, icon affordances | 1.96 s |
| `.line` | Search fields, text inputs, status bars | 2.4 s |
| `.comet` | Notifications, "message landed" moments | 1.96 s |

### Palettes

```swift
.beam(palette: .colorful)   // pink / blue / green / purple / orange / magenta
.beam(palette: .mono)       // desaturated grayscale
.beam(palette: .ocean)      // cool blues + purples
.beam(palette: .sunset)     // warm reds / oranges / yellows
```

### Shapes

```swift
Capsule()
  .fill(.regularMaterial)
  .beam(shape: .capsule)

Circle()
  .frame(width: 120, height: 120)
  .beam(.small, shape: .circle)

RoundedRectangle(cornerRadius: 24)
  .beam(shape: .roundedRect(cornerRadius: 24))
```

### You can control control activate and deactivate events 

```swift
.beam(active: isGenerating,
      onActivate: { print("fade-in finished") },
      onDeactivate: { print("fade-out finished") })
```

Fade-in is 0.6 s, fade-out 0.5 s. Callbacks fire at the end of each fade (or immediately under Reduce Motion, where transitions snap).

### Text & SF Symbol fills

`.beamFill(...)` paints the receiver's own shape with a traveling palette wash instead of overlaying a border:

```swift
Text("GENERATE")
  .font(.system(size: 56, weight: .black, design: .rounded))
  .beamFill(palette: .colorful)

Image(systemName: "sparkles")
  .font(.system(size: 72))
  .beamFill(palette: .sunset)

Circle()
  .frame(width: 120, height: 120)
  .beamFill(palette: .ocean)
```

---

## Example app

The `BorderBeamDemo` Xcode project in this repo ships with:

- **Spotlight** — single-screen interactive showcase driven by live controls.
- **Gallery** — curated grid of realistic UI scenarios (prompt card, search field, pro upsell, generate button, record ring, pulse, lens, glyph fills).
- **Showcases** — full-detail scenes for Composer, Search, Upgrade, and Generating.
- **Playground** — every parameter exposed as a slider / picker.

Open `BorderBeamDemo/BeamDemo.xcodeproj`, pick a simulator, run.

---

## Requirements

- iOS 17+
- macOS 14+
- Swift 5.9+
- Xcode 15+

---

## License

MIT
