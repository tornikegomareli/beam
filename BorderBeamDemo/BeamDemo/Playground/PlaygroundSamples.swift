import SwiftUI
import Beam

/// Chat-input mock for the `.medium` sample row.
struct MediumPlaygroundSample: View {
  let palette: BeamPalette
  let theme: BeamTheme
  let active: Bool
  let strength: Double

  var body: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(theme == .dark ? Color(white: 0.08) : Color(white: 0.95))
      .frame(width: 370, height: 90)
      .overlay(alignment: .leading) {
        Text("Build anything…")
          .foregroundStyle(.secondary)
          .padding(.leading, 20)
      }
      .beam(.medium, palette: palette, theme: theme, active: active, cornerRadius: 16, strength: strength)
  }
}

/// Compact icon-button mock for the `.small` sample row.
struct SmallPlaygroundSample: View {
  let palette: BeamPalette
  let theme: BeamTheme
  let active: Bool
  let strength: Double

  var body: some View {
    RoundedRectangle(cornerRadius: 18)
      .fill(theme == .dark ? Color(white: 0.08) : Color(white: 0.95))
      .frame(width: 72, height: 36)
      .overlay {
        Image(systemName: "stop.fill")
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
      }
      .beam(.small, palette: palette, theme: theme, active: active, cornerRadius: 18, strength: strength)
  }
}

/// Search-field mock for the `.line` sample row.
struct LinePlaygroundSample: View {
  let palette: BeamPalette
  let theme: BeamTheme
  let active: Bool
  let strength: Double

  var body: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(theme == .dark ? Color(white: 0.08) : Color(white: 0.95))
      .frame(width: 320, height: 40)
      .overlay(alignment: .leading) {
        HStack(spacing: 8) {
          Image(systemName: "magnifyingglass")
          Text("Search")
        }
        .foregroundStyle(.secondary)
        .padding(.leading, 12)
      }
      .beam(.line, palette: palette, theme: theme, active: active, cornerRadius: 16, strength: strength)
  }
}
