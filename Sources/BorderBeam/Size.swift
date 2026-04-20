import Foundation

/// Visual form of the border beam. Each case selects a dedicated shader entry
/// point and a set of tuned defaults (corner radius, rotation duration,
/// opacity stops) appropriate for the element it decorates.
public enum BorderBeamSize: Sendable {
  /// Full rounded-rectangle border with a traveling conic highlight.
  /// Best for cards, chat inputs, and other container-sized elements.
  /// Default corner radius 16, rotation period 1.96 s.
  case medium

  /// Compact version of `.medium` with a wider inner-glow window, tuned so
  /// the effect remains visible on small targets like icon buttons and chips.
  /// Default corner radius 18, rotation period 1.96 s.
  case small

  /// Traveling beam that sweeps along the bottom edge of the receiver with a
  /// bloom halo. Designed for search fields, text inputs, and status bars.
  /// Default corner radius 16, rotation period 2.4 s.
  case line
}
