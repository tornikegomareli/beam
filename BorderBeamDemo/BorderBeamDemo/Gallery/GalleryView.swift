import SwiftUI

/// Curated gallery of realistic UI scenarios with the border beam applied.
/// Layout adapts from a single column on iPhone to two or three columns on
/// iPad via `LazyVGrid` with an adaptive column rule.
struct GalleryView: View {
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 32) {
          hero

          sectionHeader("Inputs")
          LazyVGrid(columns: gridColumns, spacing: 20) {
            AIPromptScene()
            SearchFieldScene()
          }

          sectionHeader("Actions")
          LazyVGrid(columns: gridColumns, spacing: 20) {
            GenerateButtonScene()
            RecordButtonScene()
          }

          sectionHeader("Cards")
          LazyVGrid(columns: gridColumns, spacing: 20) {
            PremiumCardScene()
            UsageCardScene()
          }

          sectionHeader("Shapes")
          LazyVGrid(columns: gridColumns, spacing: 20) {
            CapsuleShapeScene()
            CircleShapeScene()
          }

          sectionHeader("Glyphs")
          LazyVGrid(columns: gridColumns, spacing: 20) {
            TextGlyphScene()
            SymbolGlyphScene()
          }

          sectionHeader("Motion")
          LazyVGrid(columns: gridColumns, spacing: 20) {
            CometCardScene()
            PulseScene()
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: 1200)
        .frame(maxWidth: .infinity)
      }
      .background(Color.black.ignoresSafeArea())
      .navigationTitle("BorderBeam")
      .navigationBarTitleDisplayMode(.large)
    }
  }

  private var hero: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Animated border beams,\npowered by Metal.")
        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
        .foregroundStyle(.primary)
        .fixedSize(horizontal: false, vertical: true)

      Text("Add a shader-rendered, hue-shifting animated border to any SwiftUI view with one modifier.")
        .font(.body)
        .foregroundStyle(.secondary)
    }
    .padding(.top, 4)
  }

  private var gridColumns: [GridItem] {
    [GridItem(.adaptive(minimum: 320), spacing: 20)]
  }

  private func sectionHeader(_ title: String) -> some View {
    Text(title)
      .font(.caption.monospaced().weight(.medium))
      .foregroundStyle(.tertiary)
      .textCase(.uppercase)
      .tracking(1.2)
  }
}
