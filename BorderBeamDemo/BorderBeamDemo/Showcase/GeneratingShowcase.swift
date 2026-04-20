import SwiftUI
import BorderBeam

/// Interactive demo of the fade-in / fade-out lifecycle and the `active`
/// binding. Tapping Generate flips the beam on, streams a mocked response
/// into the card, and demonstrates `onActivate` / `onDeactivate` firing.
struct GeneratingShowcase: View {
  @State private var isGenerating = false
  @State private var streamedText = ""
  @State private var streamTask: Task<Void, Never>?

  private let fullResponse = """
  Here's a haiku about SwiftUI:

  Views compose like streams,
  bindings flow through modifier chains —
  your UI in poetry.
  """

  var body: some View {
    ShowcaseContainer(maxContentWidth: 820) {
      VStack(alignment: .leading, spacing: 32) {
        ShowcaseHeader(
          title: "Generating",
          subtitle: "Tap Generate to see the fade-in (0.6 s) and the active beam; tap Stop to watch the fade-out."
        )

        streamingCard
          .frame(height: 220)
          .borderBeam(
            .medium,
            palette: .colorful,
            active: isGenerating,
            cornerRadius: 22,
            onActivate: { append("onActivate  (fade-in complete)") },
            onDeactivate: { append("onDeactivate (fade-out complete)") }
          )

        controls

        callbackLog
      }
    }
    .navigationTitle("Generating")
    .navigationBarTitleDisplayMode(.inline)
    .onDisappear { streamTask?.cancel() }
  }

  // MARK: - Streaming output

  private var streamingCard: some View {
    RoundedRectangle(cornerRadius: 22)
      .fill(showcaseElevatedFill)
      .overlay(alignment: .topLeading) {
        VStack(alignment: .leading, spacing: 14) {
          HStack(spacing: 8) {
            Circle()
              .fill(isGenerating ? Color.green : Color.white.opacity(0.15))
              .frame(width: 8, height: 8)
            Text(isGenerating ? "Generating…" : "Idle")
              .font(.caption.monospaced().weight(.medium))
              .foregroundStyle(.secondary)
            Spacer()
            Text("GPT‑4.5 · 12.4 tok/s")
              .font(.caption.monospaced())
              .foregroundStyle(.tertiary)
          }

          if streamedText.isEmpty {
            Text("Waiting for a prompt…")
              .font(.system(size: 15))
              .foregroundStyle(.tertiary)
          } else {
            Text(streamedText)
              .font(.system(size: 16, design: .rounded))
              .foregroundStyle(.primary)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity, alignment: .leading)
          }

          Spacer(minLength: 0)
        }
        .padding(20)
      }
  }

  // MARK: - Controls

  private var controls: some View {
    HStack(spacing: 12) {
      Button(action: toggle) {
        HStack(spacing: 8) {
          Image(systemName: isGenerating ? "stop.fill" : "sparkles")
          Text(isGenerating ? "Stop" : "Generate")
            .font(.system(.callout, design: .rounded, weight: .semibold))
        }
        .foregroundStyle(.primary)
        .frame(width: 170, height: 46)
        .background(showcaseElevatedFill, in: Capsule())
      }
      .buttonStyle(.plain)
      .borderBeam(.small, palette: .sunset, active: isGenerating, cornerRadius: 23)

      Button(action: reset) {
        Text("Reset")
          .font(.system(.callout, design: .rounded))
          .foregroundStyle(.secondary)
          .frame(width: 100, height: 46)
          .background(showcaseSurfaceFill, in: Capsule())
      }
      .buttonStyle(.plain)

      Spacer()
    }
  }

  // MARK: - Callback log

  @State private var log: [String] = []

  private var callbackLog: some View {
    VStack(alignment: .leading, spacing: 10) {
      ShowcaseSectionHeader("Callback log")
      VStack(alignment: .leading, spacing: 4) {
        if log.isEmpty {
          Text("onActivate / onDeactivate fire after the fade completes.")
            .font(.caption.monospaced())
            .foregroundStyle(.tertiary)
        } else {
          ForEach(log.indices, id: \.self) { i in
            Text(log[i])
              .font(.caption.monospaced())
              .foregroundStyle(.secondary)
          }
        }
      }
      .padding(14)
      .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
      .background(showcaseSurfaceFill, in: RoundedRectangle(cornerRadius: 12))
    }
  }

  // MARK: - Actions

  private func toggle() {
    isGenerating.toggle()
    if isGenerating {
      startStreaming()
    } else {
      streamTask?.cancel()
    }
  }

  private func reset() {
    streamTask?.cancel()
    isGenerating = false
    streamedText = ""
    log.removeAll()
  }

  private func startStreaming() {
    streamedText = ""
    streamTask?.cancel()
    streamTask = Task { @MainActor in
      for ch in fullResponse {
        if Task.isCancelled { return }
        streamedText.append(ch)
        try? await Task.sleep(for: .milliseconds(18))
      }
      // Auto-stop when we reach the end.
      if !Task.isCancelled {
        isGenerating = false
      }
    }
  }

  private func append(_ line: String) {
    let stamp = Date().formatted(date: .omitted, time: .standard)
    log.append("\(stamp)  \(line)")
    if log.count > 6 { log.removeFirst() }
  }
}

#Preview {
  GeneratingShowcase()
    .preferredColorScheme(.dark)
}
