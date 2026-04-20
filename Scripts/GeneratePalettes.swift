#!/usr/bin/env swift
//
// Single source of truth for every palette table consumed by the Metal shader.
// Adding a new palette is a one-edit change: append a new entry to `palettes`,
// run this script, and the four `.metal` files are regenerated between their
// GENERATED-BEGIN / GENERATED-END markers.
//
// Usage (from the repo root):
//
//     swift Scripts/GeneratePalettes.swift
//
// The script prints a diff summary and exits 0 on success. It is idempotent —
// running it twice without editing palettes produces no textual change.
//
// Layout contract
// ---------------
// The palettes array must appear in the SAME order as `BeamPalette`'s
// enum cases, because the shader indexes `variant * N + i` where `variant`
// is the enum's raw value. If you reorder, update the Swift enum too.

import Foundation

// MARK: - Color primitives

/// Red/green/blue triple in the 0...255 range the shader divides back down.
struct RGB {
  let r, g, b: Int
  var metalLiteral: String { formatted(alpha: 1.0) }

  func formatted(alpha: Double) -> String {
    let rgb = "float3(\(fmt(r)), \(fmt(g)), \(fmt(b)))"
    if alpha == 1.0 {
      return "\(rgb) / 255.0"
    } else {
      return "\(rgb) * \(fmtAlpha(alpha)) / 255.0"
    }
  }

  private func fmt(_ v: Int) -> String {
    String(format: "%5.1f", Double(v))
  }

  private func fmtAlpha(_ a: Double) -> String {
    // %g trims trailing zeros: 0.48 → "0.48", 0.0826 → "0.0826".
    String(format: "%g", a)
  }
}

/// Convenience constructor — reads like a CSS rgba tuple.
func rgb(_ r: Int, _ g: Int, _ b: Int) -> RGB { RGB(r: r, g: g, b: b) }

/// Color + per-spot premultiplied alpha (baked into the shader constant).
struct RGBA {
  let color: RGB
  let alpha: Double
  var metalLiteral: String { color.formatted(alpha: alpha) }
}

func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: Double) -> RGBA {
  RGBA(color: RGB(r: r, g: g, b: b), alpha: a)
}

// MARK: - Palette definitions

/// One palette's contribution to every shader table. Each array's length is
/// fixed by the shader — validate() enforces it.
struct Palette {
  let name: String
  let mediumColors: [RGB]         // 9 — Medium.paletteColors
  let smBorder: [RGB]             // 8 — Small.smBorderColors
  let smInner: [RGBA]             // 8 — Small.smInnerColors
  let lineBorder: [RGB]           // 9 — Line.lineBorderColors (dark)
  let lineInner: [RGBA]           // 9 — Line.lineInnerColors
  let lineBorderLight: [RGB]      // 9 — Line.lineBorderColorsLight
  let lineSpike: [RGBA]           // 14 — Line.lineSpikeColors (7 spikes × center+mid)
}

let palettes: [Palette] = [
  // MARK: colorful
  Palette(
    name: "colorful",
    mediumColors: [
      rgb(255,  50, 100),
      rgb( 40, 140, 255),
      rgb( 50, 200,  80),
      rgb( 30, 185, 170),
      rgb(100,  70, 255),
      rgb( 40, 140, 255),
      rgb(255, 120,  40),
      rgb(240,  50, 180),
      rgb(180,  40, 240),
    ],
    smBorder: [
      rgb( 50, 200,  80),
      rgb( 30, 185, 170),
      rgb(255, 120,  40),
      rgb(100,  70, 255),
      rgb(240,  50, 180),
      rgb(180,  40, 240),
      rgb( 40, 140, 255),
      rgb(255,  50, 100),
    ],
    smInner: [
      rgba( 50, 200,  80, 0.50),
      rgba( 30, 185, 170, 0.45),
      rgba(255, 120,  40, 0.35),
      rgba(100,  70, 255, 0.35),
      rgba(240,  50, 180, 0.30),
      rgba(180,  40, 240, 0.40),
      rgba( 40, 140, 255, 0.30),
      rgba(255,  50, 100, 0.30),
    ],
    lineBorder: [
      rgb(255,  50, 100),
      rgb( 40, 180, 220),
      rgb( 50, 200,  80),
      rgb(180,  40, 240),
      rgb(255, 160,  30),
      rgb(100,  70, 255),
      rgb( 40, 140, 255),
      rgb(240,  50, 180),
      rgb( 30, 185, 170),
    ],
    lineInner: [
      rgba(255,  50, 100, 0.48),
      rgba( 40, 180, 220, 0.42),
      rgba( 50, 200,  80, 0.48),
      rgba(180,  40, 240, 0.42),
      rgba(255, 160,  30, 0.50),
      rgba(100,  70, 255, 0.45),
      rgba( 40, 140, 255, 0.40),
      rgba(240,  50, 180, 0.45),
      rgba( 30, 185, 170, 0.52),
    ],
    lineBorderLight: [
      rgb(255,  50, 100),
      rgb( 40, 140, 255),
      rgb( 50, 200,  80),
      rgb(180,  40, 240),
      rgb( 30, 185, 170),
      rgb(100,  70, 255),
      rgb( 40, 140, 255),
      rgb(255, 120,  40),
      rgb(240,  50, 180),
    ],
    lineSpike: [
      rgba(255,  60,  80, 1.0),
      rgba(255,  60,  80, 1.0),
      rgba( 40, 190, 180, 0.98),
      rgba( 40, 190, 180, 0.49),
      rgba(100,  70, 255, 1.0),
      rgba(100,  70, 255, 1.0),
      rgba(255, 170,  40, 0.59),
      rgba(255, 170,  40, 0.29),
      rgba( 50, 200, 100, 1.0),
      rgba( 50, 200, 100, 1.0),
      rgba(200,  50, 240, 0.91),
      rgba(200,  50, 240, 0.45),
      rgba( 40, 140, 255, 1.0),
      rgba( 40, 140, 255, 1.0),
    ]
  ),

  // MARK: mono
  Palette(
    name: "mono",
    mediumColors: [
      rgb(180, 180, 180),
      rgb(140, 140, 140),
      rgb(160, 160, 160),
      rgb(130, 130, 130),
      rgb(170, 170, 170),
      rgb(150, 150, 150),
      rgb(190, 190, 190),
      rgb(145, 145, 145),
      rgb(165, 165, 165),
    ],
    smBorder: [
      rgb(160, 160, 160),
      rgb(140, 140, 140),
      rgb(180, 180, 180),
      rgb(150, 150, 150),
      rgb(170, 170, 170),
      rgb(155, 155, 155),
      rgb(145, 145, 145),
      rgb(165, 165, 165),
    ],
    smInner: [
      rgba(160, 160, 160, 0.25),
      rgba(140, 140, 140, 0.22),
      rgba(180, 180, 180, 0.17),
      rgba(150, 150, 150, 0.17),
      rgba(170, 170, 170, 0.15),
      rgba(155, 155, 155, 0.20),
      rgba(145, 145, 145, 0.15),
      rgba(165, 165, 165, 0.15),
    ],
    lineBorder: [
      rgb(200, 200, 200),
      rgb(170, 170, 170),
      rgb(155, 155, 155),
      rgb(185, 185, 185),
      rgb(165, 165, 165),
      rgb(180, 180, 180),
      rgb(160, 160, 160),
      rgb(175, 175, 175),
      rgb(190, 190, 190),
    ],
    lineInner: [
      rgba(200, 200, 200, 0.48),
      rgba(170, 170, 170, 0.42),
      rgba(155, 155, 155, 0.48),
      rgba(185, 185, 185, 0.42),
      rgba(165, 165, 165, 0.50),
      rgba(180, 180, 180, 0.45),
      rgba(160, 160, 160, 0.40),
      rgba(175, 175, 175, 0.45),
      rgba(190, 190, 190, 0.52),
    ],
    lineBorderLight: [
      rgb(100, 100, 100),
      rgb( 80,  80,  80),
      rgb( 90,  90,  90),
      rgb( 70,  70,  70),
      rgb( 85,  85,  85),
      rgb( 95,  95,  95),
      rgb( 75,  75,  75),
      rgb(105, 105, 105),
      rgb( 65,  65,  65),
    ],
    lineSpike: [
      rgba(200, 200, 200, 0.1400),
      rgba(200, 200, 200, 0.0900),
      rgba(170, 170, 170, 0.1200),
      rgba(170, 170, 170, 0.0600),
      rgba(200, 200, 200, 0.1400),
      rgba(200, 200, 200, 0.0980),
      rgba(180, 180, 180, 0.0826),
      rgba(180, 180, 180, 0.0284),
      rgba(190, 190, 190, 0.1400),
      rgba(190, 190, 190, 0.0980),
      rgba(170, 170, 170, 0.1274),
      rgba(170, 170, 170, 0.0441),
      rgba(185, 185, 185, 0.1400),
      rgba(185, 185, 185, 0.0980),
    ]
  ),

  // MARK: ocean
  Palette(
    name: "ocean",
    mediumColors: [
      rgb(100,  80, 220),
      rgb( 60, 120, 255),
      rgb( 80, 100, 200),
      rgb( 50, 140, 220),
      rgb(120,  80, 255),
      rgb( 70, 130, 255),
      rgb(140, 100, 240),
      rgb( 90, 110, 230),
      rgb(130,  70, 255),
    ],
    smBorder: [
      rgb( 60, 140, 200),
      rgb( 50, 120, 180),
      rgb(100,  80, 220),
      rgb( 80, 100, 255),
      rgb(120,  70, 240),
      rgb( 90,  80, 220),
      rgb( 70, 110, 255),
      rgb(110,  90, 230),
    ],
    smInner: [
      rgba( 60, 140, 200, 0.50),
      rgba( 50, 120, 180, 0.45),
      rgba(100,  80, 220, 0.35),
      rgba( 80, 100, 255, 0.35),
      rgba(120,  70, 240, 0.30),
      rgba( 90,  80, 220, 0.40),
      rgba( 70, 110, 255, 0.30),
      rgba(110,  90, 230, 0.30),
    ],
    lineBorder: [
      rgb(100,  80, 220),
      rgb( 60, 120, 255),
      rgb( 80, 100, 200),
      rgb(130,  70, 255),
      rgb( 70, 130, 255),
      rgb(120,  80, 255),
      rgb( 90, 110, 230),
      rgb(110,  90, 240),
      rgb(140, 100, 255),
    ],
    lineInner: [
      rgba(100,  80, 220, 0.48),
      rgba( 60, 120, 255, 0.42),
      rgba( 80, 100, 200, 0.48),
      rgba(130,  70, 255, 0.42),
      rgba( 70, 130, 255, 0.50),
      rgba(120,  80, 255, 0.45),
      rgba( 90, 110, 230, 0.40),
      rgba(110,  90, 240, 0.45),
      rgba(140, 100, 255, 0.52),
    ],
    lineBorderLight: [
      rgb( 80,  60, 200),
      rgb( 50, 100, 220),
      rgb( 70,  90, 190),
      rgb(110,  60, 220),
      rgb( 60, 110, 230),
      rgb(100,  70, 240),
      rgb( 80, 100, 210),
      rgb( 90,  80, 225),
      rgb(120,  90, 245),
    ],
    lineSpike: [
      rgba(100, 120, 255, 1.0),
      rgba(100, 120, 255, 1.0),
      rgba(130, 100, 220, 0.98),
      rgba(130, 100, 220, 0.49),
      rgba(100,  80, 255, 1.0),
      rgba(100,  80, 255, 1.0),
      rgba( 80, 130, 220, 0.59),
      rgba( 80, 130, 220, 0.29),
      rgba( 60, 100, 255, 1.0),
      rgba( 60, 100, 255, 1.0),
      rgba( 90, 120, 200, 0.91),
      rgba( 90, 120, 200, 0.45),
      rgba(120,  90, 255, 1.0),
      rgba(120,  90, 255, 1.0),
    ]
  ),

  // MARK: sunset
  Palette(
    name: "sunset",
    mediumColors: [
      rgb(255,  80,  50),
      rgb(255, 160,  40),
      rgb(255, 120,  60),
      rgb(255, 200,  50),
      rgb(255, 100,  80),
      rgb(255, 180,  60),
      rgb(255,  60,  60),
      rgb(255, 140,  50),
      rgb(255,  90,  70),
    ],
    smBorder: [
      rgb(255, 180,  50),
      rgb(255, 150,  40),
      rgb(255,  80,  60),
      rgb(255, 100,  80),
      rgb(255,  60,  80),
      rgb(255, 120,  60),
      rgb(255, 200,  50),
      rgb(255,  90,  70),
    ],
    smInner: [
      rgba(255, 180,  50, 0.50),
      rgba(255, 150,  40, 0.45),
      rgba(255,  80,  60, 0.35),
      rgba(255, 100,  80, 0.35),
      rgba(255,  60,  80, 0.30),
      rgba(255, 120,  60, 0.40),
      rgba(255, 200,  50, 0.30),
      rgba(255,  90,  70, 0.30),
    ],
    lineBorder: [
      rgb(255, 100,  60),
      rgb(255, 180,  50),
      rgb(255, 140,  70),
      rgb(255,  80,  80),
      rgb(255, 200,  60),
      rgb(255, 120,  50),
      rgb(255, 160,  80),
      rgb(255,  90,  60),
      rgb(255,  70,  70),
    ],
    lineInner: [
      rgba(255, 100,  60, 0.48),
      rgba(255, 180,  50, 0.42),
      rgba(255, 140,  70, 0.48),
      rgba(255,  80,  80, 0.42),
      rgba(255, 200,  60, 0.50),
      rgba(255, 120,  50, 0.45),
      rgba(255, 160,  80, 0.40),
      rgba(255,  90,  60, 0.45),
      rgba(255,  70,  70, 0.52),
    ],
    lineBorderLight: [
      rgb(220,  80,  40),
      rgb(230, 150,  30),
      rgb(210, 110,  50),
      rgb(200,  60,  60),
      rgb(220, 170,  40),
      rgb(210, 100,  30),
      rgb(230, 130,  60),
      rgb(190,  70,  50),
      rgb(180,  50,  50),
    ],
    lineSpike: [
      rgba(255, 140,  80, 1.0),
      rgba(255, 140,  80, 1.0),
      rgba(255, 100,  60, 0.98),
      rgba(255, 100,  60, 0.49),
      rgba(255, 100,  80, 1.0),
      rgba(255, 100,  80, 1.0),
      rgba(255, 150,  80, 0.59),
      rgba(255, 150,  80, 0.29),
      rgba(255,  80,  60, 1.0),
      rgba(255,  80,  60, 1.0),
      rgba(255, 120,  50, 0.91),
      rgba(255, 120,  50, 0.45),
      rgba(255, 140,  70, 1.0),
      rgba(255, 140,  70, 1.0),
    ]
  ),
]

// MARK: - Validation

func validate(_ palettes: [Palette]) {
  for p in palettes {
    assert(p.mediumColors.count == 9, "\(p.name).mediumColors must have 9 entries")
    assert(p.smBorder.count == 8,     "\(p.name).smBorder must have 8 entries")
    assert(p.smInner.count == 8,      "\(p.name).smInner must have 8 entries")
    assert(p.lineBorder.count == 9,   "\(p.name).lineBorder must have 9 entries")
    assert(p.lineInner.count == 9,    "\(p.name).lineInner must have 9 entries")
    assert(p.lineBorderLight.count == 9, "\(p.name).lineBorderLight must have 9 entries")
    assert(p.lineSpike.count == 14,   "\(p.name).lineSpike must have 14 entries")
  }
}

// MARK: - Emitter

/// Collects the output block for a single table.
struct Emitter {
  var lines: [String] = []

  mutating func comment(_ text: String) {
    lines.append("  // \(text)")
  }

  mutating func row(_ literal: String) {
    lines.append("  \(literal),")
  }

  func body() -> String { lines.joined(separator: "\n") }
}

// MARK: - Per-table generators
//
// Each emitter returns the full Metal declaration including the opening
// `constant float3 <name>[N] = {` and closing `};`, so the patcher can
// replace everything between the GENERATED-BEGIN / END markers without
// having to preserve a specific declaration line.

func emitTable(name: String, count: Int, body: (inout Emitter) -> Void) -> String {
  var e = Emitter()
  body(&e)
  return "constant float3 \(name)[\(count)] = {\n\(e.body())\n};"
}

func emitMediumPalette() -> String {
  emitTable(name: "paletteColors", count: 36) { e in
    for palette in palettes {
      e.comment(palette.name)
      for color in palette.mediumColors {
        e.row(color.metalLiteral)
      }
    }
  }
}

func emitSmBorder() -> String {
  emitTable(name: "smBorderColors", count: 32) { e in
    for palette in palettes {
      e.comment(palette.name)
      for color in palette.smBorder {
        e.row(color.metalLiteral)
      }
    }
  }
}

func emitSmInner() -> String {
  emitTable(name: "smInnerColors", count: 32) { e in
    for palette in palettes {
      e.comment(palette.name)
      for color in palette.smInner {
        e.row(color.metalLiteral)
      }
    }
  }
}

func emitLineBorder() -> String {
  emitTable(name: "lineBorderColors", count: 36) { e in
    for palette in palettes {
      e.comment(palette.name)
      for color in palette.lineBorder {
        e.row(color.metalLiteral)
      }
    }
  }
}

func emitLineInner() -> String {
  emitTable(name: "lineInnerColors", count: 36) { e in
    for palette in palettes {
      e.comment(palette.name)
      for color in palette.lineInner {
        e.row(color.metalLiteral)
      }
    }
  }
}

func emitLineBorderLight() -> String {
  emitTable(name: "lineBorderColorsLight", count: 36) { e in
    for palette in palettes {
      e.comment(palette.name)
      for color in palette.lineBorderLight {
        e.row(color.metalLiteral)
      }
    }
  }
}

func emitLineSpike() -> String {
  emitTable(name: "lineSpikeColors", count: 56) { e in
    for palette in palettes {
      e.comment(palette.name)
      for color in palette.lineSpike {
        e.row(color.metalLiteral)
      }
    }
  }
}

// MARK: - File patching

/// Rewrites every `GENERATED-BEGIN: <marker>` … `GENERATED-END: <marker>`
/// region in `file` with the new body. The body fully replaces everything
/// between the two marker lines (exclusive) — the markers themselves stay.
/// Returns whether the file was actually modified.
func patchFile(at path: String, regions: [String: String]) throws -> Bool {
  let url = URL(fileURLWithPath: path)
  var text = try String(contentsOf: url, encoding: .utf8)
  let original = text

  for (marker, body) in regions {
    let beginLine = "// GENERATED-BEGIN: \(marker)"
    let endLine   = "// GENERATED-END: \(marker)"

    guard let beginRange = text.range(of: beginLine) else {
      fputs("error: missing `\(beginLine)` in \(path)\n", stderr)
      exit(2)
    }
    guard let endRange = text.range(of: endLine, range: beginRange.upperBound..<text.endIndex) else {
      fputs("error: missing `\(endLine)` in \(path)\n", stderr)
      exit(2)
    }

    // Replace everything strictly between the BEGIN line and the END line —
    // from the newline after BEGIN up to (but not including) the END line.
    let contentStart = text.index(after: beginRange.upperBound) // skip the \n after BEGIN marker
    let contentEnd = endRange.lowerBound
    text.replaceSubrange(contentStart..<contentEnd, with: "\(body)\n")
  }

  if text != original {
    try text.write(to: url, atomically: true, encoding: .utf8)
    return true
  }
  return false
}

// MARK: - Main

validate(palettes)

let repoRoot: URL = {
  let scriptPath = URL(fileURLWithPath: CommandLine.arguments[0])
  // Scripts/GeneratePalettes.swift → repo root is parent of Scripts/
  return scriptPath.deletingLastPathComponent().deletingLastPathComponent()
}()

let shadersDir = repoRoot.appendingPathComponent("Sources/Beam/Shaders")

let fileRegions: [(String, [String: String])] = [
  (shadersDir.appendingPathComponent("Medium.metal").path, [
    "paletteColors": emitMediumPalette(),
  ]),
  (shadersDir.appendingPathComponent("Small.metal").path, [
    "smBorderColors": emitSmBorder(),
    "smInnerColors":  emitSmInner(),
  ]),
  (shadersDir.appendingPathComponent("Line.metal").path, [
    "lineBorderColors":      emitLineBorder(),
    "lineInnerColors":       emitLineInner(),
    "lineBorderColorsLight": emitLineBorderLight(),
    "lineSpikeColors":       emitLineSpike(),
  ]),
]

var anyChanged = false
for (path, regions) in fileRegions {
  do {
    let changed = try patchFile(at: path, regions: regions)
    if changed {
      print("regenerated: \(path)")
      anyChanged = true
    } else {
      print("unchanged:   \(path)")
    }
  } catch {
    fputs("error patching \(path): \(error)\n", stderr)
    exit(1)
  }
}

if !anyChanged {
  print("\nall palette tables already match the source of truth.")
}
