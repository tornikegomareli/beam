import SwiftUI

// MARK: - Public API

public extension View {
  /// Renders a single frozen frame of the border beam at `phase`.
  ///
  /// Designed for contexts that can't drive a continuous animation — most
  /// importantly WidgetKit (timeline entries) and the lock screen, where
  /// `TimelineView(.animation)` freezes at whatever `date` was last supplied.
  /// The same Metal shader is used, so the output is pixel-identical to the
  /// corresponding frame of the animated modifier at `time = phase`.
  ///
  /// ```swift
  /// // In a Widget's EntryView:
  /// VStack { ... }
  ///   .borderBeam(.medium, palette: .ocean, phase: entry.phase)
  /// ```
  ///
  /// To animate *between* widget timeline entries, vary `phase` across entries
  /// — WidgetKit will cross-fade the snapshots. A full rotation is `0...1`.
  ///
  /// - Parameters:
  ///   - phase: beam position along its rotation cycle in `0...1`. `0` matches
  ///     the animated modifier at `time = 0`; `0.5` is halfway around.
  func borderBeam(
    _ size: BorderBeamSize = .medium,
    palette: BorderBeamPalette = .colorful,
    theme: BorderBeamTheme = .dark,
    phase: Double,
    cornerRadius: CGFloat? = nil,
    strength: Double = 1.0
  ) -> some View {
    let presets = ThemePresets.resolve(size: size, theme: theme)
    let resolvedRadius = cornerRadius ?? (size == .small ? 18 : 16)
    return modifier(BorderBeamStaticModifier(
      size: size,
      palette: palette,
      cornerRadius: resolvedRadius,
      strength: strength,
      presets: presets,
      phase: phase
    ))
  }

  /// Overlays an animated, metal-shader-rendered border beam on the receiver.
  ///
  /// ```swift
  /// RoundedRectangle(cornerRadius: 16)
  ///     .fill(.regularMaterial)
  ///     .borderBeam()                                // default: medium, colorful, dark
  ///
  /// Button("Generate") { ... }
  ///     .borderBeam(.small, palette: .ocean)
  ///
  /// SearchField(...)
  ///     .borderBeam(.line, palette: .sunset, active: isSearching)
  /// ```
  ///
  /// - Parameters:
  ///   - size: `.medium` (card-sized, default), `.small` (button-sized), or
  ///     `.line` (traveling beam along the bottom edge).
  ///   - palette: one of `.colorful`, `.mono`, `.ocean`, `.sunset`.
  ///   - theme: `.dark` (default — white highlights on dark surfaces) or
  ///     `.light` (muted pastel beam on white surfaces).
  ///   - active: drives fade in/out. `true` fades in over 0.6 s, `false`
  ///     fades out over 0.5 s. Rendering is fully suspended while faded out.
  ///   - cornerRadius: corner radius to match the underlying shape. Defaults
  ///     to a size-appropriate value (16 for medium/line, 18 for small).
  ///   - duration: seconds per full rotation around the border. Defaults to
  ///     1.96 s for medium/small, 2.4 s for line.
  ///   - strength: overall opacity multiplier in `0...1`. `1.0` is full intensity.
  ///   - onActivate: called when the fade-in completes (or immediately when
  ///     Reduce Motion is on and the beam snaps in).
  ///   - onDeactivate: called when the fade-out completes (or immediately
  ///     when Reduce Motion is on and the beam snaps out).
  func borderBeam(
    _ size: BorderBeamSize = .medium,
    palette: BorderBeamPalette = .colorful,
    theme: BorderBeamTheme = .dark,
    active: Bool = true,
    cornerRadius: CGFloat? = nil,
    duration: Double? = nil,
    strength: Double = 1.0,
    onActivate: (() -> Void)? = nil,
    onDeactivate: (() -> Void)? = nil
  ) -> some View {
    let presets = ThemePresets.resolve(size: size, theme: theme)
    let resolvedRadius = cornerRadius ?? (size == .small ? 18 : 16)
    let resolvedDuration = duration ?? (size == .line ? 2.4 : 1.96)
    return modifier(BorderBeamModifier(
      size: size,
      palette: palette,
      cornerRadius: resolvedRadius,
      duration: resolvedDuration,
      strength: strength,
      presets: presets,
      active: active,
      onActivate: onActivate,
      onDeactivate: onDeactivate
    ))
  }
}

// MARK: - ViewModifier

/// Implementation detail of `.borderBeam(...)`. Owns the fade-in/out
/// lifecycle state and drives the Metal shader via a `TimelineView`.
///
/// The modifier collapses the shader's many individual uniforms into a
/// single `ThemePresets` bundle at construction time so the stored
/// property count stays manageable. Per-frame uniforms (time, hue) are
/// computed inside the `TimelineView` closure.
struct BorderBeamModifier: ViewModifier {
  // Immutable configuration
  let size: BorderBeamSize
  let palette: BorderBeamPalette
  let cornerRadius: CGFloat
  let duration: Double
  let strength: Double
  let presets: ThemePresets
  let active: Bool
  let onActivate: (() -> Void)?
  let onDeactivate: (() -> Void)?

  // Respect the system's Reduce Motion preference: freeze the TimelineView at
  // a single frame and snap fade transitions instead of easing them.
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // Lifecycle state — drives the 0.6 s / 0.5 s fade in/out.
  @State private var visualOpacity: Double = 0

  /// Incremented on every state change that schedules a callback. The delayed
  /// task checks that its captured generation still matches before firing —
  /// prevents a rapid `active=true → false → true` toggle from firing stale
  /// `onDeactivate` after a later fade-in already started.
  @State private var transitionGeneration: Int = 0

  /// Overall opacity multiplier applied to the `.mono` palette. Bright
  /// grayscale values read louder than saturated hues at the same alpha,
  /// so we halve the opacity to keep the mono beam visually matched.
  private var monoMultiplier: Double { palette == .mono ? 0.5 : 1.0 }

  func body(content: Content) -> some View {
    content.overlay {
      Group {
        if visualOpacity > 0.001 {
          beamOverlay
            .opacity(visualOpacity)
        }
      }
      .allowsHitTesting(false)
      // The beam is purely decorative — VoiceOver shouldn't announce it.
      .accessibilityHidden(true)
    }
    .onAppear {
      guard active else { return }
      withAnimation(fadeInAnimation) { visualOpacity = 1.0 }
      scheduleCallback(isActive: true)
    }
    .onChange(of: active) { _, isActive in
      withAnimation(isActive ? fadeInAnimation : fadeOutAnimation) {
        visualOpacity = isActive ? 1.0 : 0.0
      }
      scheduleCallback(isActive: isActive)
    }
  }

  /// Fires the appropriate callback after the fade transition completes. When
  /// Reduce Motion is on the delay is zero so the callback runs on the next
  /// runloop tick.
  private func scheduleCallback(isActive: Bool) {
    let callback = isActive ? onActivate : onDeactivate
    guard let callback else { return }

    transitionGeneration += 1
    let generation = transitionGeneration
    let delay: TimeInterval = reduceMotion ? 0 : (isActive ? 0.6 : 0.5)

    Task { @MainActor in
      if delay > 0 {
        try? await Task.sleep(for: .seconds(delay))
      }
      guard generation == transitionGeneration else { return }
      callback()
    }
  }

  /// The animated shader overlay. Split out so the `if visualOpacity` guard
  /// in `body` can suspend the entire `TimelineView` — no GPU work happens
  /// while the beam is faded out. When Reduce Motion is on the schedule is
  /// paused, so `timeline.date` freezes and the shader renders a single
  /// static frame.
  @ViewBuilder
  private var beamOverlay: some View {
    TimelineView(.animation(paused: reduceMotion)) { timeline in
      // `timeIntervalSinceReferenceDate` is ~2.5e9 s, which loses ~1 ms of
      // precision when downcast to Float. Wrap into a 1000 s window so the
      // shader sees a high-precision time value.
      let t = timeline.date.timeIntervalSinceReferenceDate
        .truncatingRemainder(dividingBy: 1000)
      GeometryReader { proxy in
        Rectangle()
          .foregroundStyle(makeShader(pixelSize: proxy.size, time: t))
      }
    }
  }

  private var fadeInAnimation: Animation? {
    reduceMotion ? nil : .easeOut(duration: 0.6)
  }

  private var fadeOutAnimation: Animation? {
    reduceMotion ? nil : .easeIn(duration: 0.5)
  }
  
  private func makeShader(pixelSize: CGSize, time: TimeInterval) -> Shader {
    // Ping-pong hue oscillation driven by a cosine so the curve eases in and
    // out at both extrema without needing a piecewise tween. The beam's hue
    // sweeps across `±hueRangeDeg` once per `hueCycleSeconds`:
    //   t=0 → -30°,   t=6s → +30°,   t=12s → -30°
    let hueShiftDeg = -BorderBeamTiming.hueRangeDeg
    * cos((time / BorderBeamTiming.hueCycleSeconds) * 2.0 * .pi)
    let hueShiftRad = hueShiftDeg * .pi / 180.0

    // The rotation angle is uniform across the draw, so precompute cos/sin
    // here instead of having the shader evaluate them at every pixel.
    let hueCos = cos(hueShiftRad)
    let hueSin = sin(hueShiftRad)

    // Palette ellipses have fixed pixel sizes tuned for the reference card
    // (~370×144 for medium). Grow them with the card's shorter dimension so
    // spots stay visually dense on large iPad cards. Clamped at 1.0 so small
    // cards don't shrink below the reference tuning.
    let paletteScale = BorderBeamTiming.paletteScale(size: size, pixelSize: pixelSize)

    return ShaderDispatch.shader(
      size: size,
      pixelSize: pixelSize,
      cornerRadius: cornerRadius,
      borderWidth: 1,
      time: time,
      duration: duration,
      strokeOpacity: presets.strokeOpacity * monoMultiplier,
      innerOpacity: presets.innerOpacity * monoMultiplier,
      bloomOpacity: presets.bloomOpacity * monoMultiplier,
      strength: strength,
      brightness: BorderBeamTiming.brightness,
      saturation: presets.saturation,
      variant: Float(palette.rawValue),
      inkLuma: presets.inkLuma,
      innerShadowAlpha: presets.innerShadowAlpha,
      inkAlphaScale: presets.inkAlphaScale,
      hueCos: hueCos,
      hueSin: hueSin,
      paletteScale: paletteScale
    )
  }
}

// MARK: - Timing constants

/// Timing and tuning values that are shared across every beam instance. Kept
/// as a single namespace so contributors adjusting the feel of the animation
/// have one obvious place to look.
enum BorderBeamTiming {
  /// Half-range of the hue oscillation in degrees. The beam's hue sweeps
  /// `-hueRangeDeg ↔ +hueRangeDeg` once per `hueCycleSeconds`.
  static let hueRangeDeg: Double = 30

  /// Period of the hue oscillation in seconds.
  static let hueCycleSeconds: Double = 12

  /// Constant brightness bump applied inside the shader to compensate for the
  /// dimming that premultiplied-alpha compositing introduces at low stroke
  /// opacities. Empirically tuned — values much above 1.3 clip highlights.
  static let brightness: Double = 1.30

  /// Shorter-dimension (pt) the palette spots were originally sized for, per
  /// size variant. When the rendered card is larger than this, the shader's
  /// fixed-pixel spots start leaving visible gaps on the beam's lit edge;
  /// `paletteScale` grows them proportionally to close the gaps.
  ///
  /// The reference is the card size used in the Gallery scenes — the only
  /// place the palette was hand-tuned side-by-side with the React original.
  static func paletteScale(size: BorderBeamSize, pixelSize: CGSize) -> Double {
    let reference: Double
    switch size {
    case .medium: reference = 144
    case .small:  reference = 36
    case .line:   reference = 40
    }
    let shorter = Double(min(pixelSize.width, pixelSize.height))
    return max(1.0, shorter / reference)
  }
}

// MARK: - Static (widget / snapshot) modifier

/// Implementation detail of `.borderBeam(..., phase:)`. Renders a single frame
/// of the shader without a `TimelineView`, because WidgetKit and the lock
/// screen don't drive `.animation` schedules — the same approach as the
/// animated modifier would freeze at a single `date` anyway, so we skip the
/// intermediate view and wire the phase straight into the shader's `time`
/// uniform (`duration` pinned at `1` so `fract(time/duration) = phase`).
struct BorderBeamStaticModifier: ViewModifier {
  let size: BorderBeamSize
  let palette: BorderBeamPalette
  let cornerRadius: CGFloat
  let strength: Double
  let presets: ThemePresets
  let phase: Double

  private var monoMultiplier: Double { palette == .mono ? 0.5 : 1.0 }

  func body(content: Content) -> some View {
    content.overlay {
      GeometryReader { proxy in
        Rectangle()
          .foregroundStyle(makeShader(pixelSize: proxy.size))
      }
      .allowsHitTesting(false)
      .accessibilityHidden(true)
    }
  }

  private func makeShader(pixelSize: CGSize) -> Shader {
    let paletteScale = BorderBeamTiming.paletteScale(size: size, pixelSize: pixelSize)
    return ShaderDispatch.shader(
      size: size,
      pixelSize: pixelSize,
      cornerRadius: cornerRadius,
      borderWidth: 1,
      time: phase,
      duration: 1.0,
      strokeOpacity: presets.strokeOpacity * monoMultiplier,
      innerOpacity: presets.innerOpacity * monoMultiplier,
      bloomOpacity: presets.bloomOpacity * monoMultiplier,
      strength: strength,
      brightness: BorderBeamTiming.brightness,
      saturation: presets.saturation,
      variant: Float(palette.rawValue),
      inkLuma: presets.inkLuma,
      innerShadowAlpha: presets.innerShadowAlpha,
      inkAlphaScale: presets.inkAlphaScale,
      hueCos: 1.0,
      hueSin: 0.0,
      paletteScale: paletteScale
    )
  }
}
