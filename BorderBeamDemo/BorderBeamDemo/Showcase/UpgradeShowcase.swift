import SwiftUI
import BorderBeam

/// Split-layout upgrade page. On iPad landscape / regular width the feature
/// list sits on the left and the pricing card on the right; on compact width
/// the layout stacks. A medium sunset beam ringed the pricing card makes it
/// the visual anchor.
struct UpgradeShowcase: View {
  @Environment(\.horizontalSizeClass) private var hSize

  var body: some View {
    ShowcaseContainer(maxContentWidth: 1100) {
      VStack(alignment: .leading, spacing: 36) {
        ShowcaseHeader(
          title: "Upgrade to BorderBeam Pro",
          subtitle: "Unlimited Metal beams, early access to new sizes, and pro-tier support."
        )

        contentStack
      }
    }
    .navigationTitle("Upgrade")
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  private var contentStack: some View {
    if hSize == .regular {
      HStack(alignment: .top, spacing: 40) {
        featureList
          .frame(maxWidth: .infinity, alignment: .leading)
        pricingCard
          .frame(width: 380)
      }
    } else {
      VStack(alignment: .leading, spacing: 28) {
        pricingCard
        featureList
      }
    }
  }

  // MARK: - Feature list

  private var featureList: some View {
    VStack(alignment: .leading, spacing: 20) {
      ShowcaseSectionHeader("Everything in Pro")
      VStack(alignment: .leading, spacing: 14) {
        feature(
          title: "Unlimited Metal beams",
          detail: "Render as many beams per view as you want — no throttle, no rate limit."
        )
        feature(
          title: "All four palettes + custom",
          detail: "Extend the palette system with hand-authored gradients of your own."
        )
        feature(
          title: "Priority Metal toolchain updates",
          detail: "Get new shader stages and debug tooling the day they ship."
        )
        feature(
          title: "Early access to upcoming sizes",
          detail: "Ring, ribbon, starfield — try them before they land in the public API."
        )
        feature(
          title: "Pro-tier support",
          detail: "Direct channel to the maintainers. Answers in under a business day."
        )
      }
    }
  }

  private func feature(title: String, detail: String) -> some View {
    HStack(alignment: .top, spacing: 14) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 18))
        .foregroundStyle(.green)
        .padding(.top, 1)
      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(.system(.subheadline, design: .rounded, weight: .semibold))
          .foregroundStyle(.primary)
        Text(detail)
          .font(.footnote)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }

  // MARK: - Pricing card

  private var pricingCard: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack(spacing: 8) {
        Image(systemName: "crown.fill")
          .font(.system(size: 13))
          .foregroundStyle(.yellow)
        Text("PRO")
          .font(.system(.caption, design: .rounded, weight: .bold))
          .tracking(1.2)
          .foregroundStyle(.yellow)
        Spacer()
        Text("MOST POPULAR")
          .font(.system(.caption2, design: .rounded).weight(.bold))
          .tracking(1.0)
          .foregroundStyle(.pink)
          .padding(.horizontal, 8)
          .padding(.vertical, 3)
          .background(Color.pink.opacity(0.12), in: Capsule())
      }

      VStack(alignment: .leading, spacing: 4) {
        Text("$19")
          .font(.system(size: 42, weight: .bold, design: .rounded))
        + Text(" / month")
          .font(.system(.body, design: .rounded))
          .foregroundStyle(.secondary)
        Text("or $190 / year — save two months")
          .font(.footnote)
          .foregroundStyle(.tertiary)
      }

      Divider().background(Color.white.opacity(0.08))

      VStack(alignment: .leading, spacing: 10) {
        pricingBullet("Unlimited beams")
        pricingBullet("Custom palettes")
        pricingBullet("Early-access sizes")
        pricingBullet("Pro-tier support")
      }

      Button(action: {}) {
        Text("Start free trial")
          .font(.system(.callout, design: .rounded, weight: .semibold))
          .foregroundStyle(.black)
          .frame(maxWidth: .infinity)
          .frame(height: 46)
          .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
      }
      .buttonStyle(.plain)

      Text("14-day free trial · cancel anytime")
        .font(.caption.monospaced())
        .foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity)
    }
    .padding(24)
    .frame(maxWidth: .infinity)
    .background(showcaseElevatedFill, in: RoundedRectangle(cornerRadius: 24))
    .borderBeam(.medium, palette: .sunset, cornerRadius: 24)
  }

  private func pricingBullet(_ text: String) -> some View {
    HStack(spacing: 10) {
      Image(systemName: "checkmark")
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(.yellow)
      Text(text)
        .font(.system(size: 14))
        .foregroundStyle(.primary)
    }
  }
}

#Preview {
  UpgradeShowcase()
    .preferredColorScheme(.dark)
}
