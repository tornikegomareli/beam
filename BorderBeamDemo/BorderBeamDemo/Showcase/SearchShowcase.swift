import SwiftUI
import BorderBeam

/// Workspace-search experience modeled after GitHub / Linear / Notion.
/// Line ocean beam on the search bar; an adaptive grid of result cards
/// shows off the `.small` variant as each result's row indicator.
struct SearchShowcase: View {
  @State private var activeFilter: SearchFilter = .all
  @State private var queryFocused = true

  var body: some View {
    ShowcaseContainer {
      VStack(alignment: .leading, spacing: 32) {
        ShowcaseHeader(
          title: "Search",
          subtitle: "Find anything across your workspace — docs, components, shaders, people."
        )

        searchField
          .borderBeam(.line, palette: .ocean, active: queryFocused, cornerRadius: 16)

        filterChips

        resultsGrid
      }
    }
    .navigationTitle("Search")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Search field

  private var searchField: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(showcaseElevatedFill)
      .frame(height: 56)
      .overlay(alignment: .leading) {
        HStack(spacing: 12) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.secondary)
          Text("Search products, docs, community…")
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
          Spacer()
          keystrokeHint
        }
        .padding(.horizontal, 18)
      }
      .onTapGesture { queryFocused.toggle() }
  }

  private var keystrokeHint: some View {
    HStack(spacing: 4) {
      keycap("⌘")
      keycap("K")
    }
  }

  private func keycap(_ key: String) -> some View {
    Text(key)
      .font(.caption.monospaced().weight(.semibold))
      .foregroundStyle(.tertiary)
      .frame(width: 22, height: 22)
      .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 4))
  }

  // MARK: - Filter chips

  private var filterChips: some View {
    HStack(spacing: 8) {
      ForEach(SearchFilter.allCases) { filter in
        FilterChip(filter: filter, isActive: filter == activeFilter) {
          activeFilter = filter
        }
      }
      Spacer()
    }
  }

  // MARK: - Results grid

  private var resultsGrid: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
      ForEach(SearchResult.sample) { result in
        ResultCard(result: result)
      }
    }
  }
}

// MARK: - Filter chip

private enum SearchFilter: String, CaseIterable, Identifiable {
  case all, docs, components, shaders, community
  var id: String { rawValue }
  var title: String { rawValue.capitalized }
}

private struct FilterChip: View {
  let filter: SearchFilter
  let isActive: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(filter.title)
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(isActive ? .primary : Color.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
          Capsule()
            .fill(isActive ? Color.white.opacity(0.14) : showcaseSurfaceFill)
        )
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Results

private struct SearchResult: Identifiable {
  let id = UUID()
  let icon: String
  let iconColor: Color
  let title: String
  let kind: String
  let snippet: String

  static let sample: [SearchResult] = [
    SearchResult(
      icon: "swift", iconColor: .orange,
      title: "BorderBeam.swift",
      kind: "Swift · public",
      snippet: "public extension View { func borderBeam(...) -> some View { ... } }"
    ),
    SearchResult(
      icon: "doc.richtext", iconColor: .blue,
      title: "Using Metal shaders in SwiftUI",
      kind: "Docs · getting started",
      snippet: "Attach a ShaderFunction to foregroundStyle for per-pixel control…"
    ),
    SearchResult(
      icon: "cube", iconColor: .purple,
      title: "RoundedRectangle snippets",
      kind: "Components",
      snippet: "A collection of shape mocks that pair well with .borderBeam()"
    ),
    SearchResult(
      icon: "sparkles", iconColor: .pink,
      title: "Premultiplied alpha, explained",
      kind: "Community · ⭐ 124",
      snippet: "If you composite RGB * alpha separately from alpha, you're in premul land…"
    ),
    SearchResult(
      icon: "play.rectangle", iconColor: .red,
      title: "WWDC 2025 — Shader-powered SwiftUI",
      kind: "Video · 31 min",
      snippet: "A walkthrough of the new Shader / ShaderLibrary / [[ stitchable ]] APIs."
    ),
    SearchResult(
      icon: "cpu", iconColor: .green,
      title: "GPU fragment lifecycle",
      kind: "Docs · performance",
      snippet: "Understanding warps, uniform control flow, and how Metal schedules work…"
    ),
  ]
}

private struct ResultCard: View {
  let result: SearchResult

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 10) {
        Image(systemName: result.icon)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(result.iconColor)
          .frame(width: 32, height: 32)
          .background(result.iconColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
        VStack(alignment: .leading, spacing: 2) {
          Text(result.title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.primary)
            .lineLimit(1)
          Text(result.kind)
            .font(.caption.monospaced())
            .foregroundStyle(.tertiary)
            .lineLimit(1)
        }
        Spacer(minLength: 0)
      }
      Text(result.snippet)
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .lineLimit(2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(16)
    .frame(minHeight: 120, alignment: .topLeading)
    .background(showcaseSurfaceFill, in: RoundedRectangle(cornerRadius: 16))
  }
}

#Preview {
  SearchShowcase()
    .preferredColorScheme(.dark)
}
