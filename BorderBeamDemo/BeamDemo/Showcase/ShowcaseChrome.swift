import SwiftUI

/// Header block every showcase starts with — a large rounded title and a
/// muted supporting line. Sized to fill the width on iPad and stays
/// readable on iPhone.
struct ShowcaseHeader: View {
  let title: String
  let subtitle: String
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
      Text(subtitle)
        .font(.body)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

/// Section label above a cluster of cards. Uppercase, monospaced, tracked —
/// matches the rest of the demo app's section dividers.
struct ShowcaseSectionHeader: View {
  let title: String
  init(_ title: String) { self.title = title }
  var body: some View {
    Text(title)
      .font(.caption.monospaced().weight(.medium))
      .foregroundStyle(.tertiary)
      .textCase(.uppercase)
      .tracking(1.2)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

/// Standard surface fill used behind every mock UI element in the showcases.
let showcaseSurfaceFill = Color(white: 0.10)

/// Slightly lighter elevated surface — used for mocks layered on top of the
/// scene background.
let showcaseElevatedFill = Color(white: 0.13)

/// Wraps any scene body in the standard black background + max-width frame
/// so content doesn't sprawl on iPad Pro 13".
struct ShowcaseContainer<Content: View>: View {
  let maxContentWidth: CGFloat
  @ViewBuilder let content: Content

  init(maxContentWidth: CGFloat = 960, @ViewBuilder content: () -> Content) {
    self.maxContentWidth = maxContentWidth
    self.content = content()
  }

  var body: some View {
    ScrollView {
      content
        .padding(.horizontal, 32)
        .padding(.vertical, 36)
        .frame(maxWidth: maxContentWidth)
        .frame(maxWidth: .infinity)
    }
    .background(Color.black.ignoresSafeArea())
  }
}
