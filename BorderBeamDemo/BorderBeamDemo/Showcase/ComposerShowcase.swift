import SwiftUI
import BorderBeam

/// Full-screen iPad-sized scene modeled on an AI prompt composer. The large
/// medium-colorful beam draws the eye to the active text-entry surface; the
/// rest of the scene grounds the beam in a realistic product context.
struct ComposerShowcase: View {
  var body: some View {
    ShowcaseContainer {
      VStack(alignment: .leading, spacing: 32) {
        ShowcaseHeader(
          title: "AI Composer",
          subtitle: "Build anything with natural language — the beam tracks the active prompt."
        )

        planBadge

        composer
          .frame(height: 150)
          .borderBeam(.medium, palette: .colorful, cornerRadius: 22)

        suggestions

        recentPrompts
      }
    }
    .navigationTitle("AI Composer")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Plan badge

  private var planBadge: some View {
    HStack(spacing: 8) {
      Circle().fill(.green).frame(width: 6, height: 6)
      Text("Plus plan")
        .font(.system(.caption, design: .rounded, weight: .semibold))
      Text("·")
        .foregroundStyle(.tertiary)
      Text("4,812 tokens remaining")
        .font(.caption.monospaced())
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(showcaseSurfaceFill, in: Capsule())
  }

  // MARK: - Composer hero

  private var composer: some View {
    RoundedRectangle(cornerRadius: 22)
      .fill(showcaseElevatedFill)
      .overlay(alignment: .topLeading) {
        VStack(alignment: .leading, spacing: 14) {
          HStack(spacing: 12) {
            Circle()
              .fill(Color.white.opacity(0.08))
              .frame(width: 30, height: 30)
              .overlay {
                Image(systemName: "paperclip")
                  .font(.system(size: 13))
                  .foregroundStyle(.secondary)
              }
            Text("Ask me anything…")
              .font(.system(size: 16))
              .foregroundStyle(.secondary)
            Spacer()
          }

          Spacer()

          HStack(spacing: 6) {
            composerChip(label: "Agent", icon: "chevron.down")
            composerChip(label: "Auto",  icon: "chevron.down")
            composerChip(label: "GPT‑4.5", icon: "chevron.down")
            Spacer()
            Button(action: {}) {
              Image(systemName: "arrow.up")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.14), in: Circle())
            }
            .buttonStyle(.plain)
          }
        }
        .padding(16)
      }
  }

  private func composerChip(label: String, icon: String) -> some View {
    HStack(spacing: 4) {
      Text(label)
      Image(systemName: icon).font(.system(size: 9))
    }
    .font(.system(size: 12, weight: .medium))
    .foregroundStyle(.secondary)
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(Color.white.opacity(0.06), in: Capsule())
  }

  // MARK: - Suggestions

  private var suggestions: some View {
    VStack(alignment: .leading, spacing: 12) {
      ShowcaseSectionHeader("Try")
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 10)], spacing: 10) {
        suggestionChip("Write me a haiku about SwiftUI")
        suggestionChip("Explain Metal shaders in one paragraph")
        suggestionChip("Design a pricing card with MIT-licensed icons")
        suggestionChip("Convert this JSON to a Swift struct")
        suggestionChip("Write unit tests for a SwiftUI modifier")
        suggestionChip("Summarize WWDC 2025's shader session")
      }
    }
  }

  private func suggestionChip(_ text: String) -> some View {
    HStack(spacing: 10) {
      Image(systemName: "arrow.up.right")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(.tertiary)
      Text(text)
        .font(.system(size: 13))
        .foregroundStyle(.secondary)
        .lineLimit(1)
      Spacer(minLength: 0)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
    .background(showcaseSurfaceFill, in: RoundedRectangle(cornerRadius: 12))
  }

  // MARK: - Recent prompts

  private var recentPrompts: some View {
    VStack(alignment: .leading, spacing: 12) {
      ShowcaseSectionHeader("Recent")
      VStack(spacing: 10) {
        recentRow(
          prompt: "How do I respect Reduce Motion in SwiftUI?",
          time: "2 hours ago"
        )
        recentRow(
          prompt: "Generate a hero section for a startup landing page",
          time: "Yesterday"
        )
        recentRow(
          prompt: "Explain premultiplied alpha in one sentence",
          time: "3 days ago"
        )
      }
    }
  }

  private func recentRow(prompt: String, time: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "clock.arrow.circlepath")
        .font(.system(size: 13))
        .foregroundStyle(.tertiary)
      VStack(alignment: .leading, spacing: 2) {
        Text(prompt)
          .font(.system(size: 14))
          .foregroundStyle(.primary)
          .lineLimit(1)
        Text(time)
          .font(.caption.monospaced())
          .foregroundStyle(.tertiary)
      }
      Spacer()
      Image(systemName: "chevron.right")
        .font(.system(size: 11))
        .foregroundStyle(.tertiary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(showcaseSurfaceFill, in: RoundedRectangle(cornerRadius: 14))
  }
}

#Preview {
  ComposerShowcase()
    .preferredColorScheme(.dark)
}
