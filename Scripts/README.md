# Scripts

## `GeneratePalettes.swift`

Single source of truth for every palette table consumed by the Metal shader.
Adding a new palette is a one-edit change: append a new entry to the
`palettes` array at the top of the script, then regenerate:

```sh
swift Scripts/GeneratePalettes.swift
```

The script walks every `.metal` file under `Sources/Beam/Shaders/`
and rewrites the body of every region delimited by

```metal
// GENERATED-BEGIN: <tableName>
…
// GENERATED-END: <tableName>
```

It is idempotent — running it twice without editing the palette data
produces no textual change.

### Layout contract

The `palettes` array must stay in the same order as `BeamPalette`'s
enum cases, because the shader indexes its constant tables with
`variant * N + i` where `variant` comes from the enum's raw value. Adding
a palette without also adding an enum case (or vice versa) will render
the wrong colors.

### What the script regenerates

| Marker name              | File           | Shape          |
|--------------------------|----------------|----------------|
| `paletteColors`          | `Medium.metal` | 4 × 9 RGB      |
| `smBorderColors`         | `Small.metal`  | 4 × 8 RGB      |
| `smInnerColors`          | `Small.metal`  | 4 × 8 RGBA     |
| `lineBorderColors`       | `Line.metal`   | 4 × 9 RGB      |
| `lineInnerColors`        | `Line.metal`   | 4 × 9 RGBA     |
| `lineBorderColorsLight`  | `Line.metal`   | 4 × 9 RGB      |
| `lineSpikeColors`        | `Line.metal`   | 4 × 14 RGBA    |

The geometry tables (`spotPosSize`, `smSpotPosSize`, `lineBorderGeom`, etc.)
are NOT generated — they're shared across palettes and live in the
`.metal` files directly.
