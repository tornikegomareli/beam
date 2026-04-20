import SwiftUI
import Beam

// MARK: - Root

/// Full-screen interactive showcase. One hero element that morphs between
/// the library's five visual modes (Beam, Comet, Fill, Lens, Pulse),
/// driven by a live control panel and accompanied by a code snippet that
/// updates as the user changes settings.
///
/// Every control here exercises a real library surface:
///   • mode tabs       → picks which modifier to apply
///   • palette swatches → `BeamPalette`
///   • shape pills     → `BeamShape`
///   • strength slider → `strength:`
///   • speed slider    → `duration:`
///   • tap hero        → `pulse:` token increment
///
/// The ambient background uses `beamFill` on four drifting blobs so the
/// page itself demonstrates the API it's advertising.
struct SpotlightView: View {
  @State private var mode: SpotlightMode = .beam
  @State private var palette: BeamPalette = .colorful
  @State private var shape: SpotlightShape = .roundedRect
  @State private var strength: Double = 1.0
  @State private var speed: Double = 1.96
  @State private var lensStrength: Double = 6
  @State private var active: Bool = true
  @State private var pulseCount: Int = 0
  @State private var fillSubject: FillSubject = .text
  @State private var symbolIndex: Int = 0

  /// SF Symbols cycled in Fill → Symbol mode. Chosen for recognizable
  /// shapes with plenty of interior area so the palette wash is visible.
  private static let fillSymbols: [String] = [
    "sparkles", "wand.and.stars", "bolt.fill", "heart.fill", "star.fill"
  ]

  var body: some View {
    ZStack {
      AmbientBackdrop()

      VStack(spacing: 24) {
        modeTabs

        Spacer(minLength: 12)

        SpotlightHero(
          mode: mode,
          palette: palette,
          shape: shape,
          strength: strength,
          duration: speed,
          lensStrength: lensStrength,
          active: active,
          pulseCount: pulseCount,
          fillSubject: fillSubject,
          fillSymbol: Self.fillSymbols[symbolIndex % Self.fillSymbols.count],
          onTap: { pulseCount += 1 }
        )
        .frame(maxWidth: 520, maxHeight: 220)

        if mode == .fill {
          fillSubjectPicker
        }

        Spacer(minLength: 12)

        controlPanel
          .frame(maxWidth: 640)

        CodeSnippetView(
          mode: mode,
          palette: palette,
          shape: shape,
          strength: strength,
          duration: speed,
          lensStrength: lensStrength,
          active: active,
          fillSubject: fillSubject,
          fillSymbol: Self.fillSymbols[symbolIndex % Self.fillSymbols.count]
        )
        .frame(maxWidth: 640)
      }
      .padding(24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .navigationTitle("Spotlight")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.hidden, for: .navigationBar)
  }

  /// Small picker that only appears in Fill mode. Toggles the hero
  /// between the "BEAM" text glyphs and an SF Symbol, and when Symbol is
  /// selected lets the user cycle through a few representative symbols
  /// so both surfaces get demonstrated.
  private var fillSubjectPicker: some View {
    HStack(spacing: 10) {
      ForEach(FillSubject.allCases) { subject in
        Button { withAnimation(.snappy) { fillSubject = subject } } label: {
          HStack(spacing: 6) {
            Image(systemName: subject.icon)
              .font(.caption2)
            Text(subject.title)
              .font(.caption.weight(.semibold))
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 8)
          .foregroundStyle(fillSubject == subject ? .black : .white.opacity(0.7))
          .background {
            if fillSubject == subject {
              Capsule().fill(.white)
            } else {
              Capsule().stroke(.white.opacity(0.18), lineWidth: 0.5)
            }
          }
        }
        .buttonStyle(.plain)
      }

      if fillSubject == .symbol {
        Button {
          withAnimation(.snappy) {
            symbolIndex = (symbolIndex + 1) % Self.fillSymbols.count
          }
        } label: {
          Label("Next", systemImage: "arrow.clockwise")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
              Capsule().stroke(.white.opacity(0.18), lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
        .transition(.scale.combined(with: .opacity))
      }
    }
  }

  private var modeTabs: some View {
    HStack(spacing: 8) {
      ForEach(SpotlightMode.allCases) { m in
        Button { withAnimation(.snappy) { mode = m } } label: {
          Text(m.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(mode == m ? .black : .white.opacity(0.7))
            .background {
              if mode == m {
                Capsule().fill(.white)
              } else {
                Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5)
              }
            }
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.top, 8)
  }

  private var controlPanel: some View {
    VStack(spacing: 18) {
      paletteSwatches

      if mode.usesShape {
        shapePills
      }

      VStack(spacing: 10) {
        labeledSlider(
          label: "Strength",
          value: $strength,
          range: 0.2...1.0,
          display: "\(Int(strength * 100))%"
        )
        labeledSlider(
          label: "Speed",
          value: $speed,
          range: 0.8...4.0,
          display: String(format: "%.1fs", speed),
          reversed: true
        )
        if mode == .lens {
          labeledSlider(
            label: "Lens",
            value: $lensStrength,
            range: 0...12,
            display: "\(Int(lensStrength))px"
          )
        }
      }

      HStack(spacing: 10) {
        Toggle(isOn: $active) {
          Label("Active", systemImage: active ? "power.circle.fill" : "power.circle")
            .labelStyle(.titleAndIcon)
        }
        .toggleStyle(.button)
        .tint(.white.opacity(0.12))
        .foregroundStyle(.white)

        Spacer()

        Button {
          withAnimation(.snappy) { pulseCount += 1 }
        } label: {
          Label("Pulse", systemImage: "wave.3.right")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundStyle(.black)
            .background(Capsule().fill(.white))
        }
        .buttonStyle(.plain)
      }
    }
    .padding(20)
    .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 22))
    .overlay {
      RoundedRectangle(cornerRadius: 22)
        .stroke(.white.opacity(0.08), lineWidth: 0.5)
    }
  }

  private var paletteSwatches: some View {
    HStack(spacing: 12) {
      ForEach(BeamPalette.allCases) { p in
        PaletteSwatch(palette: p, selected: palette == p) {
          withAnimation(.snappy) { palette = p }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var shapePills: some View {
    HStack(spacing: 8) {
      ForEach(SpotlightShape.allCases) { s in
        Button { withAnimation(.snappy) { shape = s } } label: {
          HStack(spacing: 6) {
            s.icon
              .font(.caption)
            Text(s.title)
              .font(.caption2.weight(.medium))
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 7)
          .foregroundStyle(shape == s ? .black : .white.opacity(0.6))
          .background {
            if shape == s {
              Capsule().fill(.white)
            } else {
              Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5)
            }
          }
        }
        .buttonStyle(.plain)
      }
      Spacer()
    }
  }

  private func labeledSlider(
    label: String,
    value: Binding<Double>,
    range: ClosedRange<Double>,
    display: String,
    reversed: Bool = false
  ) -> some View {
    HStack(spacing: 12) {
      Text(label)
        .font(.caption.monospaced())
        .foregroundStyle(.white.opacity(0.55))
        .frame(width: 70, alignment: .leading)
      Slider(value: value, in: range)
        .tint(.white)
      Text(display)
        .font(.caption.monospaced())
        .foregroundStyle(.white.opacity(0.45))
        .frame(width: 56, alignment: .trailing)
    }
  }
}

// MARK: - Mode / shape enums

/// Which modifier(s) the hero is currently showing. Keeping this as a
/// local enum (rather than reusing `BeamSize`) lets the UI express
/// `.fill` and `.lens` as first-class modes alongside the size variants.
enum SpotlightMode: String, CaseIterable, Identifiable {
  case beam, comet, fill, lens, pulse
  var id: String { rawValue }

  var title: String {
    switch self {
    case .beam:  return "Beam"
    case .comet: return "Comet"
    case .fill:  return "Fill"
    case .lens:  return "Lens"
    case .pulse: return "Pulse"
    }
  }

  var usesShape: Bool { self == .beam || self == .comet || self == .pulse }
}

/// What the hero shows in Fill mode: text glyphs or an SF Symbol.
/// Both exercise the same `.beamFill(...)` modifier; the only difference
/// is the receiver view.
enum FillSubject: String, CaseIterable, Identifiable {
  case text, symbol
  var id: String { rawValue }

  var title: String {
    switch self {
    case .text:   return "Text"
    case .symbol: return "Symbol"
    }
  }

  var icon: String {
    switch self {
    case .text:   return "textformat"
    case .symbol: return "sparkles"
    }
  }
}

enum SpotlightShape: String, CaseIterable, Identifiable {
  case roundedRect, capsule, circle
  var id: String { rawValue }

  var title: String {
    switch self {
    case .roundedRect: return "Rect"
    case .capsule:     return "Pill"
    case .circle:      return "Circle"
    }
  }

  @ViewBuilder
  var icon: some View {
    switch self {
    case .roundedRect:
      RoundedRectangle(cornerRadius: 3).frame(width: 14, height: 9)
    case .capsule:
      Capsule().frame(width: 16, height: 8)
    case .circle:
      Circle().frame(width: 10, height: 10)
    }
  }

  var beamShape: BeamShape {
    switch self {
    case .roundedRect: return .roundedRect(cornerRadius: 22)
    case .capsule:     return .capsule
    case .circle:      return .circle
    }
  }
}

// MARK: - Hero

/// Central interactive preview. Renders a size-appropriate surface and
/// applies whichever library effect the current `mode` calls for. Tapping
/// increments a pulse token via `onTap`, which the parent hands back into
/// the `.beam(pulse:)` binding.
private struct SpotlightHero: View {
  let mode: SpotlightMode
  let palette: BeamPalette
  let shape: SpotlightShape
  let strength: Double
  let duration: Double
  let lensStrength: Double
  let active: Bool
  let pulseCount: Int
  let fillSubject: FillSubject
  let fillSymbol: String
  let onTap: () -> Void

  var body: some View {
    heroSurface
      .contentShape(Rectangle())
      .onTapGesture { onTap() }
      .animation(.snappy(duration: 0.35), value: mode)
      .animation(.snappy(duration: 0.35), value: shape)
      .animation(.snappy(duration: 0.35), value: fillSubject)
      .animation(.snappy(duration: 0.35), value: fillSymbol)
  }

  @ViewBuilder
  private var heroSurface: some View {
    switch mode {
    case .beam:
      beamCard
    case .comet:
      cometCard
    case .fill:
      fillHero
    case .lens:
      lensCard
    case .pulse:
      pulseCard
    }
  }

  // MARK: Beam mode

  @ViewBuilder
  private var beamCard: some View {
    shapedSurface(height: 200)
      .beam(
        .medium,
        palette: palette,
        active: active,
        shape: shape.beamShape,
        duration: duration,
        strength: strength
      )
  }

  // MARK: Comet mode

  @ViewBuilder
  private var cometCard: some View {
    shapedSurface(height: 200)
      .beam(
        .comet,
        palette: palette,
        active: active,
        shape: shape.beamShape,
        duration: duration,
        strength: strength
      )
  }

  // MARK: Fill mode — big letter glyphs OR SF Symbol

  @ViewBuilder
  private var fillHero: some View {
    switch fillSubject {
    case .text:
      Text("BEAM")
        .font(.system(size: 120, weight: .black, design: .rounded))
        .tracking(4)
        .beamFill(
          palette: palette,
          active: active,
          duration: duration,
          strength: strength
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .symbol:
      Image(systemName: fillSymbol)
        .font(.system(size: 180, weight: .semibold))
        .symbolRenderingMode(.monochrome)
        .beamFill(
          palette: palette,
          active: active,
          duration: duration,
          strength: strength
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  // MARK: Lens mode — dot grid card so distortion reads

  @ViewBuilder
  private var lensCard: some View {
    RoundedRectangle(cornerRadius: shape.cornerRadius)
      .fill(.white.opacity(0.05))
      .frame(height: 200)
      .overlay {
        DotField()
          .padding(16)
      }
      .beam(
        .medium,
        palette: palette,
        active: active,
        shape: shape.beamShape,
        duration: duration,
        strength: strength,
        lensStrength: lensStrength
      )
  }

  // MARK: Pulse mode — tap-to-pulse card, active bound to false

  @ViewBuilder
  private var pulseCard: some View {
    shapedSurface(height: 200)
      .overlay {
        VStack(spacing: 6) {
          Image(systemName: "hand.tap.fill")
            .font(.system(size: 32))
            .foregroundStyle(.white.opacity(0.85))
          Text("Tap the card")
            .font(.callout.weight(.medium))
            .foregroundStyle(.white.opacity(0.7))
          Text("pulse #\(pulseCount)")
            .font(.caption.monospaced())
            .foregroundStyle(.white.opacity(0.35))
            .contentTransition(.numericText())
        }
      }
      .beam(
        .comet,
        palette: palette,
        active: false,
        shape: shape.beamShape,
        duration: duration,
        strength: strength,
        pulse: pulseCount
      )
  }

  // MARK: Shared surface

  @ViewBuilder
  private func shapedSurface(height: CGFloat) -> some View {
    switch shape {
    case .roundedRect:
      RoundedRectangle(cornerRadius: 22)
        .fill(.white.opacity(0.05))
        .frame(height: height)
        .overlay { surfaceContents }
    case .capsule:
      Capsule()
        .fill(.white.opacity(0.05))
        .frame(height: min(height, 120))
        .overlay { surfaceContents }
    case .circle:
      Circle()
        .fill(.white.opacity(0.05))
        .frame(width: height, height: height)
        .overlay { surfaceContents }
    }
  }

  @ViewBuilder
  private var surfaceContents: some View {
    if mode != .pulse {
      Image(systemName: modeGlyph)
        .font(.system(size: 34, weight: .light))
        .foregroundStyle(.white.opacity(0.55))
    }
  }

  private var modeGlyph: String {
    switch mode {
    case .beam:  return "sparkle"
    case .comet: return "comet"
    case .fill:  return "textformat"
    case .lens:  return "circle.hexagongrid"
    case .pulse: return "hand.tap"
    }
  }
}

private extension SpotlightShape {
  var cornerRadius: CGFloat {
    switch self {
    case .roundedRect: return 22
    case .capsule:     return 100
    case .circle:      return 200
    }
  }
}

// MARK: - Palette swatch

/// Four-dot swatch that previews a palette's anchor colors. Selected
/// swatch gets a ring + subtle beam behind it so the picker itself
/// advertises the library.
private struct PaletteSwatch: View {
  let palette: BeamPalette
  let selected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 6) {
        HStack(spacing: 3) {
          ForEach(palette.previewColors.indices, id: \.self) { i in
            Circle()
              .fill(palette.previewColors[i])
              .frame(width: 10, height: 10)
          }
        }
        Text(palette.label)
          .font(.caption2.monospaced())
          .foregroundStyle(selected ? .white : .white.opacity(0.45))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .background {
        RoundedRectangle(cornerRadius: 14)
          .fill(.white.opacity(selected ? 0.10 : 0.03))
      }
      .overlay {
        RoundedRectangle(cornerRadius: 14)
          .stroke(.white.opacity(selected ? 0.25 : 0.06), lineWidth: 0.5)
      }
    }
    .buttonStyle(.plain)
  }
}

private extension BeamPalette {
  var label: String {
    switch self {
    case .colorful: return "colorful"
    case .mono:     return "mono"
    case .ocean:    return "ocean"
    case .sunset:   return "sunset"
    }
  }

  /// Four-dot preview colors matching the `GlyphFill.metal` corner table
  /// closely enough to read as the same palette.
  var previewColors: [Color] {
    switch self {
    case .colorful:
      return [
        Color(red: 1.00, green: 0.20, blue: 0.40),
        Color(red: 0.16, green: 0.55, blue: 1.00),
        Color(red: 1.00, green: 0.55, blue: 0.16),
        Color(red: 0.71, green: 0.16, blue: 0.94),
      ]
    case .mono:
      return [Color(white: 0.85), Color(white: 0.65), Color(white: 0.55), Color(white: 0.75)]
    case .ocean:
      return [
        Color(red: 0.47, green: 0.35, blue: 1.00),
        Color(red: 0.24, green: 0.55, blue: 0.90),
        Color(red: 0.31, green: 0.39, blue: 0.78),
        Color(red: 0.55, green: 0.39, blue: 0.94),
      ]
    case .sunset:
      return [
        Color(red: 1.00, green: 0.31, blue: 0.20),
        Color(red: 1.00, green: 0.63, blue: 0.16),
        Color(red: 1.00, green: 0.39, blue: 0.31),
        Color(red: 1.00, green: 0.78, blue: 0.24),
      ]
    }
  }
}

// MARK: - Ambient backdrop

/// Four slow-drifting blurred blobs, each tinted by a different palette.
/// Uses `beamFill` on the blobs so the page's own backdrop demonstrates
/// one of the modes on offer.
private struct AmbientBackdrop: View {
  @State private var phase: Double = 0

  var body: some View {
    Canvas { context, size in
      let blobs: [(CGPoint, CGFloat, Color)] = [
        (CGPoint(x: size.width * 0.15, y: size.height * 0.25), 260, Color(red: 1.0, green: 0.2, blue: 0.4)),
        (CGPoint(x: size.width * 0.82, y: size.height * 0.35), 220, Color(red: 0.2, green: 0.55, blue: 1.0)),
        (CGPoint(x: size.width * 0.28, y: size.height * 0.85), 300, Color(red: 1.0, green: 0.6, blue: 0.2)),
        (CGPoint(x: size.width * 0.78, y: size.height * 0.75), 240, Color(red: 0.6, green: 0.3, blue: 1.0)),
      ]
      for (i, blob) in blobs.enumerated() {
        let wobble = CGFloat(sin(phase + Double(i) * 1.3) * 30)
        let c = CGPoint(x: blob.0.x + wobble, y: blob.0.y + wobble * 0.6)
        let rect = CGRect(x: c.x - blob.1, y: c.y - blob.1, width: blob.1 * 2, height: blob.1 * 2)
        context.opacity = 0.22
        context.fill(Path(ellipseIn: rect), with: .color(blob.2))
      }
    }
    .blur(radius: 90)
    .ignoresSafeArea()
    .background(Color.black.ignoresSafeArea())
    .task {
      while !Task.isCancelled {
        try? await Task.sleep(for: .milliseconds(32))
        phase += 0.02
      }
    }
  }
}

// MARK: - Dot field (for lens mode)

private struct DotField: View {
  var body: some View {
    Canvas { context, size in
      let spacing: CGFloat = 11
      let dotSize: CGFloat = 2
      let cols = Int(size.width / spacing)
      let rows = Int(size.height / spacing)
      for r in 0...rows {
        for c in 0...cols {
          let rect = CGRect(
            x: CGFloat(c) * spacing - dotSize / 2,
            y: CGFloat(r) * spacing - dotSize / 2,
            width: dotSize,
            height: dotSize
          )
          context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.4)))
        }
      }
    }
  }
}

// MARK: - Code snippet

/// Renders the current configuration as a syntax-ish colored Swift call.
/// No real syntax highlighting — just colored spans so the snippet reads
/// like a code sample and stays readable in the dark theme.
private struct CodeSnippetView: View {
  let mode: SpotlightMode
  let palette: BeamPalette
  let shape: SpotlightShape
  let strength: Double
  let duration: Double
  let lensStrength: Double
  let active: Bool
  let fillSubject: FillSubject
  let fillSymbol: String

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 8) {
        Circle().fill(Color(red: 1, green: 0.37, blue: 0.37)).frame(width: 12, height: 12)
        Circle().fill(Color(red: 1, green: 0.80, blue: 0.24)).frame(width: 12, height: 12)
        Circle().fill(Color(red: 0.20, green: 0.80, blue: 0.40)).frame(width: 12, height: 12)
        Spacer()
        Text("swift")
          .font(.callout.monospaced())
          .foregroundStyle(.white.opacity(0.45))
      }
      .padding(.horizontal, 18)
      .padding(.vertical, 14)

      Divider().background(.white.opacity(0.08))

      snippet
        .font(.system(size: 18, weight: .medium, design: .monospaced))
        .textSelection(.enabled)
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(.white.opacity(0.08), lineWidth: 0.5)
    }
  }

  @ViewBuilder
  private var snippet: some View {
    switch mode {
    case .beam:
      Text(functionCall(
        name: "beam",
        args: baseArgs(size: ".medium") + shapeArg + durationArg + strengthArg + activeArg
      ))
    case .comet:
      Text(functionCall(
        name: "beam",
        args: baseArgs(size: ".comet") + shapeArg + durationArg + strengthArg + activeArg
      ))
    case .fill:
      // Fill is the only mode where the receiver matters a lot — call
      // it out in the snippet so the reader knows `beamFill` works on
      // both `Text` and `Image(systemName:)`.
      VStack(alignment: .leading, spacing: 4) {
        Text(fillReceiverLine)
          .foregroundStyle(Color(white: 0.55))
        Text("  ")
          + Text(functionCall(
            name: "beamFill",
            args: baseArgs(size: nil) + durationArg + strengthArg + activeArg
          ))
      }
    case .lens:
      Text(functionCall(
        name: "beam",
        args: baseArgs(size: ".medium") + shapeArg + durationArg + strengthArg + lensArg + activeArg
      ))
    case .pulse:
      Text(functionCall(
        name: "beam",
        args: baseArgs(size: ".comet") + shapeArg + [("active", "false"), ("pulse", "tapCount")]
      ))
    }
  }

  private func functionCall(name: String, args: [(String, String)]) -> AttributedString {
    // Pretty-print as multi-line when there are enough args to benefit
    // from one-arg-per-line formatting. Short calls stay on one line.
    let multiline = args.count > 2

    var s = AttributedString(".\(name)(")
    s.foregroundColor = Color(white: 0.92)

    for (i, arg) in args.enumerated() {
      if multiline {
        var nl = AttributedString(i == 0 ? "\n  " : ",\n  ")
        nl.foregroundColor = Color(white: 0.55)
        s += nl
      } else if i > 0 {
        var comma = AttributedString(", ")
        comma.foregroundColor = Color(white: 0.55)
        s += comma
      }

      if !arg.0.isEmpty {
        var label = AttributedString("\(arg.0): ")
        label.foregroundColor = Color(red: 0.58, green: 0.80, blue: 1.00)
        s += label
      }
      var val = AttributedString(arg.1)
      val.foregroundColor = arg.1.hasPrefix(".") || arg.1.hasPrefix("\"")
        ? Color(red: 1.00, green: 0.70, blue: 0.42)
        : Color(red: 0.75, green: 0.95, blue: 0.55)
      s += val
    }

    if multiline {
      var trailing = AttributedString("\n)")
      trailing.foregroundColor = Color(white: 0.92)
      s += trailing
    } else {
      var closing = AttributedString(")")
      closing.foregroundColor = Color(white: 0.92)
      s += closing
    }
    return s
  }

  private func baseArgs(size: String?) -> [(String, String)] {
    var args: [(String, String)] = []
    if let size {
      args.append(("", size))
    }
    args.append(("palette", ".\(palette.label)"))
    return args
  }

  private var shapeArg: [(String, String)] {
    switch shape {
    case .roundedRect: return []
    case .capsule:     return [("shape", ".capsule")]
    case .circle:      return [("shape", ".circle")]
    }
  }

  private var durationArg: [(String, String)] {
    [("duration", String(format: "%.1f", duration))]
  }

  private var strengthArg: [(String, String)] {
    strength < 0.999 ? [("strength", String(format: "%.2f", strength))] : []
  }

  private var activeArg: [(String, String)] {
    active ? [] : [("active", "false")]
  }

  private var lensArg: [(String, String)] {
    [("lensStrength", String(Int(lensStrength)))]
  }

  /// Receiver line above the `.beamFill(...)` call so the snippet reads
  /// like a real code sample. Matches the hero's current subject.
  private var fillReceiverLine: AttributedString {
    switch fillSubject {
    case .text:
      var s = AttributedString("Text(\"BEAM\")")
      s.foregroundColor = Color(white: 0.85)
      return s
    case .symbol:
      var s = AttributedString("Image(systemName: \"\(fillSymbol)\")")
      s.foregroundColor = Color(white: 0.85)
      return s
    }
  }
}

// MARK: - BeamPalette Identifiable

// `BeamPalette` already conforms to `CaseIterable` in the library; we just
// need Identifiable here for `ForEach`.
extension BeamPalette: Identifiable {
  public var id: Int { rawValue }
}
