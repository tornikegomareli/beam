import SwiftUI

/// Wrapper chrome shared by every gallery scene — a rounded container with
/// a small title/tag header above the scene content. Fixes the content area
/// to 220pt tall so every card in the grid shares the same baseline height.
struct DemoCard<Content: View>: View {
  let title: String
  let tag: String
  @ViewBuilder let content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(title)
          .font(.system(.subheadline, design: .rounded, weight: .semibold))
        Spacer()
        Text(tag)
          .font(.caption2.monospaced())
          .foregroundStyle(.tertiary)
      }
      .padding(.horizontal, 2)

      content
        .frame(height: 220)
    }
  }
}

/// Rounded dark panel that every scene sits on top of. Drawn once per scene
/// as the bottom layer of a `ZStack` so the beam has a consistent surface to
/// appear on.
@ViewBuilder
func sceneBackground() -> some View {
  RoundedRectangle(cornerRadius: 22)
    .fill(Color(white: 0.06))
    .overlay(
      RoundedRectangle(cornerRadius: 22)
        .stroke(Color.white.opacity(0.06), lineWidth: 1)
    )
}

/// Fill color for the inner UI element (chat card, search bar, etc.) that
/// the beam is applied to. Matches the dark theme's card surface.
let sceneSurfaceFill = Color(white: 0.10)

/// Small capsule chip used for the "Agent ▾" / "Auto ▾" affordances on the
/// AI prompt scene. Factored out because both chips would otherwise duplicate
/// the same layout.
struct SceneChip: View {
  let label: String
  let icon: String

  var body: some View {
    HStack(spacing: 4) {
      Text(label)
      Image(systemName: icon)
        .font(.system(size: 8))
    }
    .font(.system(size: 11, weight: .medium))
    .foregroundStyle(.secondary)
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Color.white.opacity(0.06), in: Capsule())
  }
}
