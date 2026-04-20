<div align="center">

# Beam

**Animated border beams for SwiftUI, rendered in Metal.**

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-F05138.svg?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![iOS 17+](https://img.shields.io/badge/iOS-17%2B-007AFF.svg?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-007AFF.svg?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/macos/)
[![SPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-E8E2D6.svg?style=flat)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-A78BFA.svg?style=flat)](LICENSE)

One SwiftUI modifier. Every `View` gets a hue-shifting, palette-driven beam traveling its border.
<br>Metal shaders. No assets, no images, no layer hacks — just `.beam(...)`.

<br>

<!-- HERO VIDEO — replace with uploaded asset URL -->
<!-- https://github.com/user-attachments/assets/REPLACE_ME_HERO -->

</div>

<br>

## Why

UIKit and SwiftUI don't ship a "moving colorful border" primitive. The typical workaround is an `AngularGradient` + rotation + masking + blur — which animates the host view's hierarchy on every frame, thrashes layout, and still doesn't look right on rounded corners.

Beam renders the whole effect in a single `[[ stitchable ]]` Metal shader per size variant. The beam's geometry, palette, inner glow, stroke, and bloom all live on the GPU. SwiftUI just ticks a `TimelineView` and hands the shader the current time. No image assets, no `CADisplayLink`, no offscreen passes.

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

Three lines, one modifier. That's the whole library surface.

---

## API

### Size variants

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

### Active / inactive

```swift
.beam(active: isGenerating,
      onActivate: { print("fade-in finished") },
      onDeactivate: { print("fade-out finished") })
```

Fade-in is 0.6 s, fade-out 0.5 s. Callbacks fire at the end of each fade (or immediately under Reduce Motion, where transitions snap).

### Pulse on demand

```swift
@State private var sentCount = 0

Button("Send") { sentCount += 1 }

Card()
  .beam(.comet, active: false, pulse: sentCount)
```

Each time the `pulse` value changes, the beam fires a single lap and fades out. Pass a counter, a message ID, a UUID — any `AnyHashable`.

### Liquid-glass lens

```swift
.beam(.medium, palette: .mono, lensStrength: 6)
```

Warps the content *under* the beam head as it passes. `lensStrength` is pixels of max radial displacement — try `3...6` for a subtle bulge, higher for an obvious glass-bead effect.

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

Works on any view whose silhouette can act as a mask — text glyphs, SF Symbols, custom `Shape`s.

---

## Accessibility

- **Reduce Motion**: when the system preference is on, fade transitions snap and the Metal `TimelineView` is paused — the beam renders a single static frame.
- **VoiceOver**: the overlay is marked `.accessibilityHidden(true)` — beams are decoration, not content.
- **Low-power defaults**: rendering is fully suspended when `visualOpacity ≈ 0`, so inactive beams cost nothing.

---

## API summary

| Modifier / Type | Purpose |
|-----------------|---------|
| `.beam(_:palette:theme:active:shape:cornerRadius:duration:strength:lensStrength:pulse:onActivate:onDeactivate:)` | Overlay a traveling beam on the border. |
| `.beamFill(palette:active:duration:strength:)` | Fill the receiver's glyphs / shape with a palette wash. |
| `BeamSize` | `.medium` / `.small` / `.line` / `.comet` |
| `BeamPalette` | `.colorful` / `.mono` / `.ocean` / `.sunset` |
| `BeamShape` | `.roundedRect(cornerRadius:)` / `.capsule` / `.circle` |
| `BeamTheme` | `.dark` / `.light` |

---

## Demos

<div align="center">

**Spotlight** — Interactive playground: every mode, every palette, every shape, with live code

<!-- https://github.com/user-attachments/assets/REPLACE_ME_SPOTLIGHT -->

<br>

**Composer** — Chat-style input card with the full medium beam

<!-- https://github.com/user-attachments/assets/REPLACE_ME_COMPOSER -->

<br>

**Search** — Line beam tracing a search field underline

<!-- https://github.com/user-attachments/assets/REPLACE_ME_SEARCH -->

<br>

**Upgrade** — Sunset palette on a Pro upsell card

<!-- https://github.com/user-attachments/assets/REPLACE_ME_UPGRADE -->

<br>

**Generating** — Active state bound to a streaming task

<!-- https://github.com/user-attachments/assets/REPLACE_ME_GENERATING -->

<br>

**Glass lens** — Content bulges as the beam head sweeps over a dot field

<!-- https://github.com/user-attachments/assets/REPLACE_ME_LENS -->

<br>

**Glyphs** — Text and SF Symbols filled with `.beamFill`

<!-- https://github.com/user-attachments/assets/REPLACE_ME_GLYPHS -->

</div>

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

## Contributing

Ideas, bug reports, PRs — all welcome. The Metal shaders live in `Sources/Beam/Shaders/` and each has a header-comment explaining its layer composition. The palette tables are single-sourced in `Scripts/GeneratePalettes.swift`; regenerate with `swift Scripts/GeneratePalettes.swift` after editing.

## License

MIT
