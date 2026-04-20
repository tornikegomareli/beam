import SwiftUI

/// Root of the demo app. Uses `NavigationSplitView` so the layout is a proper
/// sidebar + detail on iPad (portrait or landscape) and collapses to a
/// navigation stack on iPhone without any extra code.
struct ContentView: View {
  @State private var selection: SidebarItem? = .gallery

  var body: some View {
    NavigationSplitView {
      sidebar
    } detail: {
      detail
    }
    .preferredColorScheme(.dark)
    .tint(.white)
  }

  private var sidebar: some View {
    List(selection: $selection) {
      Section {
        row(.gallery)
      }
      Section("Showcases") {
        row(.composer)
        row(.search)
        row(.upgrade)
        row(.generating)
      }
      Section("Developer") {
        row(.playground)
      }
    }
    .navigationTitle("Beam")
    .listStyle(.sidebar)
  }

  @ViewBuilder
  private var detail: some View {
    switch selection {
    case .gallery:    GalleryView()
    case .composer:   ComposerShowcase()
    case .search:     SearchShowcase()
    case .upgrade:    UpgradeShowcase()
    case .generating: GeneratingShowcase()
    case .playground: PlaygroundView()
    case .none:
      ContentUnavailableView("Pick a scene", systemImage: "sparkle")
        .foregroundStyle(.secondary)
    }
  }

  private func row(_ item: SidebarItem) -> some View {
    NavigationLink(value: item) {
      Label(item.title, systemImage: item.icon)
    }
  }
}

enum SidebarItem: String, Hashable, CaseIterable {
  case gallery
  case composer
  case search
  case upgrade
  case generating
  case playground

  var title: String {
    switch self {
    case .gallery:    return "Gallery"
    case .composer:   return "AI Composer"
    case .search:     return "Search"
    case .upgrade:    return "Upgrade"
    case .generating: return "Generating"
    case .playground: return "Playground"
    }
  }

  var icon: String {
    switch self {
    case .gallery:    return "square.grid.2x2.fill"
    case .composer:   return "sparkles"
    case .search:     return "magnifyingglass"
    case .upgrade:    return "crown.fill"
    case .generating: return "bolt.fill"
    case .playground: return "slider.horizontal.3"
    }
  }
}

#Preview {
  ContentView()
}
