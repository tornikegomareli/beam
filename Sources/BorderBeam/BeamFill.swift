import SwiftUI

// MARK: - Public API

public extension View {
  /// Paints the receiver's rendered shape with the traveling beam effect
  /// instead of overlaying it as a border. The view's own silhouette —
  /// text glyphs, an SF Symbol, a `Shape` — acts as the natural mask, so
  /// the beam appears to shine *through* the letterforms rather than
  /// orbiting around them.
  ///
  /// ```swift
  /// Text("GENERATE")
  ///     .font(.system(size: 56, weight: .black, design: .rounded))
  ///     .beamFill(palette: .colorful)
  ///
  /// Image(systemName: "sparkles")
  ///     .font(.system(size: 72))
  ///     .beamFill(palette: .sunset)
  ///
  /// Circle()
  ///     .frame(width: 120, height: 120)
  ///     .beamFill(palette: .ocean)
  /// ```
  ///
  /// The beam operates on the view's bounding box. `.small` (default)
  /// uses a wide angular window that reads best when the lit area is the
  /// interior rather than just the border.
  ///
  /// - Parameters:
  ///   - size: which beam variant to sample. Defaults to `.small`.
  ///   - palette: one of `.colorful`, `.mono`, `.ocean`, `.sunset`.
  ///   - theme: `.dark` (default) or `.light`.
  ///   - active: fade in/out. Matches `.borderBeam` semantics (0.6 s in,
  ///     0.5 s out).
  ///   - duration: seconds per sweep. Defaults to `1.96`.
  ///   - strength: overall opacity multiplier in `0...1`.
  func beamFill(
    _ size: BorderBeamSize = .small,
    palette: BorderBeamPalette = .colorful,
    theme: BorderBeamTheme = .dark,
    active: Bool = true,
    duration: Double? = nil,
    strength: Double = 1.0
  ) -> some View {
    let presets = ThemePresets.resolve(size: size, theme: theme)
    let resolvedDuration = duration ?? (size == .line ? 2.4 : 1.96)
    return modifier(BeamFillModifier(
      size: size,
      palette: palette,
      duration: resolvedDuration,
      strength: strength,
      presets: presets,
      active: active
    ))
  }
}

// MARK: - ViewModifier

/// Implementation detail of `.beamFill(...)`. Unlike `BorderBeamModifier`,
/// this applies the shader via `foregroundStyle` so the host view's own
/// shape becomes the beam's visible area. There's no overlay — the beam
/// is the view's fill color.
private struct BeamFillModifier: ViewModifier {
  let size: BorderBeamSize
  let palette: BorderBeamPalette
  let duration: Double
  let strength: Double
  let presets: ThemePresets
  let active: Bool

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var pixelSize: CGSize = .zero
  @State private var visualOpacity: Double = 0

  /// See `BorderBeamModifier.monoMultiplier` — same rationale applies.
  private var monoMultiplier: Double { palette == .mono ? 0.5 : 1.0 }

  func body(content: Content) -> some View {
    TimelineView(.animation(paused: reduceMotion)) { timeline in
      let t = timeline.date.timeIntervalSinceReferenceDate
        .truncatingRemainder(dividingBy: 1000)
      content
        .foregroundStyle(makeShader(pixelSize: pixelSize, time: t))
        .opacity(visualOpacity)
        .background {
          GeometryReader { proxy in
            Color.clear
              .task(id: proxy.size) { pixelSize = proxy.size }
          }
        }
    }
    .onAppear {
      guard active else { return }
      withAnimation(reduceMotion ? nil : .easeOut(duration: 0.6)) {
        visualOpacity = 1.0
      }
    }
    .onChange(of: active) { _, isActive in
      withAnimation(reduceMotion ? nil : (isActive ? .easeOut(duration: 0.6) : .easeIn(duration: 0.5))) {
        visualOpacity = isActive ? 1.0 : 0.0
      }
    }
  }

  private func makeShader(pixelSize: CGSize, time: TimeInterval) -> Shader {
    let hueShiftDeg = -30.0 * cos((time / 12.0) * 2.0 * .pi)
    let hueShiftRad = hueShiftDeg * .pi / 180.0
    let hueCos = cos(hueShiftRad)
    let hueSin = sin(hueShiftRad)

    // Grow the palette with the smaller dimension so small glyphs (a short
    // SF Symbol) and tall headlines ("GENERATE" at 80pt) both get adequate
    // color spread. Uses the same reference scale as `.borderBeam`.
    let reference: Double = (size == .small) ? 36 : ((size == .line) ? 40 : 144)
    let shorter = Double(min(pixelSize.width, pixelSize.height))
    let paletteScale = max(1.0, shorter / reference)

    return ShaderDispatch.shader(
      size: size,
      pixelSize: pixelSize,
      // No rounded corners — the beam's bounding box matches the glyph
      // layout, which isn't a rounded rect. A regular rect SDF avoids
      // accidentally clipping glyph pixels at the corners.
      cornerRadius: 0,
      borderWidth: 1,
      time: time,
      duration: duration,
      strokeOpacity: presets.strokeOpacity * monoMultiplier,
      innerOpacity: presets.innerOpacity * monoMultiplier,
      bloomOpacity: presets.bloomOpacity * monoMultiplier,
      strength: strength,
      brightness: 1.30,
      saturation: presets.saturation,
      variant: Float(palette.rawValue),
      inkLuma: presets.inkLuma,
      innerShadowAlpha: presets.innerShadowAlpha,
      inkAlphaScale: presets.inkAlphaScale,
      hueCos: hueCos,
      hueSin: hueSin,
      paletteScale: paletteScale,
      shapeType: 0
    )
  }
}
