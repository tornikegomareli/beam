import SwiftUI
import BorderBeam

// MARK: - Inputs

/// Chat-style composer with paperclip, tags, and send button — the canonical
/// "agent is thinking" affordance.
struct AIPromptScene: View {
  var body: some View {
    DemoCard(title: "AI Prompt", tag: "Medium · Colorful") {
      ZStack {
        sceneBackground()
        RoundedRectangle(cornerRadius: 18)
          .fill(sceneSurfaceFill)
          .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 14) {
              HStack(spacing: 10) {
                Circle()
                  .fill(Color.white.opacity(0.08))
                  .frame(width: 28, height: 28)
                  .overlay {
                    Image(systemName: "paperclip")
                      .font(.system(size: 12))
                      .foregroundStyle(.secondary)
                  }
                Text("Build anything…")
                  .font(.system(size: 15))
                  .foregroundStyle(.secondary)
                Spacer()
              }
              Spacer()
              HStack(spacing: 6) {
                SceneChip(label: "Agent", icon: "chevron.down")
                SceneChip(label: "Auto", icon: "chevron.down")
                Spacer()
                Circle()
                  .fill(Color.white.opacity(0.10))
                  .frame(width: 28, height: 28)
                  .overlay {
                    Image(systemName: "arrow.up")
                      .font(.system(size: 11, weight: .semibold))
                  }
              }
            }
            .padding(14)
          }
          .frame(height: 144)
          .borderBeam(.medium, palette: .colorful, cornerRadius: 18)
          .padding(18)
      }
    }
  }
}

/// Underline-style beam on a typical search field.
struct SearchFieldScene: View {
  var body: some View {
    DemoCard(title: "Search", tag: "Line · Ocean") {
      ZStack {
        sceneBackground()
        VStack(spacing: 10) {
          Spacer()
          RoundedRectangle(cornerRadius: 14)
            .fill(sceneSurfaceFill)
            .frame(height: 44)
            .overlay(alignment: .leading) {
              HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                  .foregroundStyle(.secondary)
                Text("Search products…")
                  .foregroundStyle(.secondary)
              }
              .font(.system(size: 14))
              .padding(.leading, 14)
            }
            .borderBeam(.line, palette: .ocean, cornerRadius: 14)
            .padding(.horizontal, 20)
          Spacer()
        }
      }
    }
  }
}

// MARK: - Actions

/// Pill-shaped button whose beam activates while generation is in flight.
/// The toggle below the button flips the `active` binding so contributors
/// can see the fade-in / fade-out lifecycle work.
struct GenerateButtonScene: View {
  @State private var busy = true

  var body: some View {
    DemoCard(title: "Generate", tag: "Small · Sunset · Active") {
      ZStack {
        sceneBackground()
        VStack(spacing: 14) {
          Capsule()
            .fill(sceneSurfaceFill)
            .frame(width: 170, height: 46)
            .overlay {
              HStack(spacing: 8) {
                Image(systemName: "sparkles")
                  .symbolEffect(.pulse, options: .repeating, isActive: busy)
                Text(busy ? "Generating…" : "Generate")
                  .font(.system(.callout, design: .rounded, weight: .semibold))
              }
              .foregroundStyle(.primary)
            }
            .borderBeam(.small, palette: .sunset, active: busy, cornerRadius: 23)

          Button(busy ? "Stop" : "Run again") { busy.toggle() }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
      }
    }
  }
}

/// Circular record affordance — a real-world use for the `.small` variant
/// on a round target. Toggle below flips `active`.
struct RecordButtonScene: View {
  @State private var recording = true

  var body: some View {
    DemoCard(title: "Record", tag: "Small · Mono · Toggle") {
      ZStack {
        sceneBackground()
        VStack(spacing: 14) {
          ZStack {
            Circle()
              .fill(sceneSurfaceFill)
              .frame(width: 64, height: 64)
            Circle()
              .fill(recording ? .red : .red.opacity(0.5))
              .frame(width: 22, height: 22)
          }
          .borderBeam(.small, palette: .mono, active: recording, cornerRadius: 32)

          Button(recording ? "Stop recording" : "Start recording") { recording.toggle() }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
      }
    }
  }
}

// MARK: - Cards

/// Premium upsell card with a crown badge, price, and CTA.
struct PremiumCardScene: View {
  var body: some View {
    DemoCard(title: "Premium", tag: "Medium · Sunset") {
      ZStack {
        sceneBackground()
        RoundedRectangle(cornerRadius: 20)
          .fill(sceneSurfaceFill)
          .frame(height: 148)
          .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 8) {
              HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                  .font(.system(size: 12))
                  .foregroundStyle(.yellow)
                Text("PRO")
                  .font(.system(.caption, design: .rounded, weight: .bold))
                  .tracking(1.0)
                  .foregroundStyle(.yellow)
              }
              Text("Unlock every model")
                .font(.system(.title3, design: .rounded, weight: .semibold))
              Text("GPT‑4.5, Claude 4.7, Gemini 3 and more.")
                .font(.footnote)
                .foregroundStyle(.secondary)
              Spacer()
              HStack {
                Text("$19")
                  .font(.system(.title2, design: .rounded, weight: .bold))
                + Text(" / month")
                  .font(.footnote)
                  .foregroundStyle(.secondary)
                Spacer()
                Capsule()
                  .fill(Color.white.opacity(0.12))
                  .frame(width: 80, height: 28)
                  .overlay {
                    Text("Upgrade")
                      .font(.caption.weight(.semibold))
                  }
              }
            }
            .padding(16)
          }
          .borderBeam(.medium, palette: .sunset, cornerRadius: 20)
          .padding(18)
      }
    }
  }
}

/// Usage/quota summary card with a progress bar.
struct UsageCardScene: View {
  var body: some View {
    DemoCard(title: "Usage", tag: "Medium · Ocean") {
      ZStack {
        sceneBackground()
        RoundedRectangle(cornerRadius: 20)
          .fill(sceneSurfaceFill)
          .frame(height: 148)
          .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
              HStack {
                Text("This month")
                  .font(.footnote)
                  .foregroundStyle(.secondary)
                Spacer()
                Text("On track")
                  .font(.system(.caption, design: .rounded, weight: .semibold))
                  .foregroundStyle(.green)
              }
              Text("4,812")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
              + Text(" tokens")
                .font(.callout)
                .foregroundStyle(.secondary)
              Spacer()
              usageBar
            }
            .padding(16)
          }
          .borderBeam(.medium, palette: .ocean, cornerRadius: 20)
          .padding(18)
      }
    }
  }

  private var usageBar: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule().fill(Color.white.opacity(0.08))
        Capsule()
          .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
          .frame(width: geo.size.width * 0.48)
      }
    }
    .frame(height: 6)
  }
}

// MARK: - Shapes

/// Capsule-shaped pill with the beam tracing the rounded ends. Exercises
/// `.borderBeam(shape: .capsule)` — the SDF falls back to a rounded rect
/// with cornerRadius = min(width, height) / 2, so no cornerRadius tuning
/// is needed at the call site.
struct CapsuleShapeScene: View {
  var body: some View {
    DemoCard(title: "Pill", tag: "Medium · Shape .capsule") {
      ZStack {
        sceneBackground()
        Capsule()
          .fill(sceneSurfaceFill)
          .frame(width: 260, height: 64)
          .overlay {
            HStack(spacing: 10) {
              Image(systemName: "sparkles")
                .foregroundStyle(.yellow)
              Text("Summon the muse")
                .font(.system(.callout, design: .rounded, weight: .semibold))
            }
          }
          .borderBeam(.medium, palette: .colorful, shape: .capsule)
      }
    }
  }
}

/// Circular avatar / status ring. Exercises `.borderBeam(shape: .circle)`
/// with a proper circular SDF (not a rounded-rect approximation).
struct CircleShapeScene: View {
  var body: some View {
    DemoCard(title: "Avatar", tag: "Medium · Shape .circle") {
      ZStack {
        sceneBackground()
        Circle()
          .fill(sceneSurfaceFill)
          .frame(width: 140, height: 140)
          .overlay {
            Image(systemName: "person.fill")
              .font(.system(size: 52))
              .foregroundStyle(.secondary)
          }
          .borderBeam(.medium, palette: .ocean, shape: .circle)
      }
    }
  }
}

// MARK: - Glyphs

/// Large headline text filled with the traveling beam. Exercises
/// `.beamFill(...)` — the glyph outlines act as the mask so the letters
/// appear to catch the light as the beam sweeps through them.
struct TextGlyphScene: View {
  var body: some View {
    DemoCard(title: "Text fill", tag: "Beam fill · Colorful") {
      ZStack {
        sceneBackground()
        Text("GENERATE")
          .font(.system(size: 52, weight: .black, design: .rounded))
          .tracking(2)
          .beamFill(palette: .colorful)
      }
    }
  }
}

/// SF Symbol filled with the beam. Same mechanism as text — the symbol
/// path masks the shader output.
struct SymbolGlyphScene: View {
  var body: some View {
    DemoCard(title: "Symbol fill", tag: "Beam fill · Sunset") {
      ZStack {
        sceneBackground()
        Image(systemName: "sparkles")
          .font(.system(size: 100, weight: .semibold))
          .beamFill(palette: .sunset)
      }
    }
  }
}
