import SwiftUI
import BorderBeam

/// Interactive exploration of every `.borderBeam(...)` parameter. The control
/// panel drives a `@State` bag that three sample views — one per size — read
/// from, so contributors can see how palette, theme, active, and strength
/// each affect the visual result in real time.
struct PlaygroundView: View {
  @State private var palette: BorderBeamPalette = .colorful
  @State private var theme: BorderBeamTheme = .dark
  @State private var active: Bool = true
  @State private var strength: Double = 1.0

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 28) {
          controlPanel

          VStack(spacing: 20) {
            sampleRow("Medium") {
              MediumPlaygroundSample(palette: palette, theme: theme, active: active, strength: strength)
            }
            sampleRow("Small") {
              SmallPlaygroundSample(palette: palette, theme: theme, active: active, strength: strength)
            }
            sampleRow("Line") {
              LinePlaygroundSample(palette: palette, theme: theme, active: active, strength: strength)
            }
          }
          .frame(maxWidth: 600)

          Spacer(minLength: 20)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
      }
      .background((theme == .dark ? Color.black : Color.white).ignoresSafeArea())
      .animation(.easeInOut(duration: 0.25), value: theme)
      .navigationTitle("Playground")
      .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(theme == .dark ? .dark : .light)
  }

  private var controlPanel: some View {
    VStack(spacing: 14) {
      Picker("Palette", selection: $palette) {
        Text("Colorful").tag(BorderBeamPalette.colorful)
        Text("Mono").tag(BorderBeamPalette.mono)
        Text("Ocean").tag(BorderBeamPalette.ocean)
        Text("Sunset").tag(BorderBeamPalette.sunset)
      }
      .pickerStyle(.segmented)

      Picker("Theme", selection: $theme) {
        Text("Dark").tag(BorderBeamTheme.dark)
        Text("Light").tag(BorderBeamTheme.light)
      }
      .pickerStyle(.segmented)

      HStack(spacing: 18) {
        Toggle(isOn: $active) {
          Label("Active", systemImage: "power")
            .labelStyle(.titleOnly)
        }
        .toggleStyle(.switch)
        .fixedSize()

        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text("Strength")
              .font(.caption)
              .foregroundStyle(.secondary)
            Spacer()
            Text("\(Int(strength * 100))%")
              .font(.caption.monospaced())
              .foregroundStyle(.tertiary)
          }
          Slider(value: $strength, in: 0...1)
        }
      }
    }
    .padding(16)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    .frame(maxWidth: 600)
  }

  @ViewBuilder
  private func sampleRow<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.caption.monospaced().weight(.medium))
        .foregroundStyle(.tertiary)
        .textCase(.uppercase)
        .tracking(1.0)
      content()
        .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}
