import SwiftUI

/// Builds a Metal `Shader` from the packaged Metal library, selecting the
/// correct entry point for the given size and packing the uniform arguments
/// in the order the shader expects.
///
/// ### Uniform contract
///
/// Uniforms are passed as four `float4` bundles plus a `float2` for the hue
/// sin/cos, rather than as 18 individual scalars. The packing reduces the
/// number of positional arguments both sides have to agree on — each bundle
/// groups values that change together — and each layout is documented at
/// both the Swift packing site (below) and the shader unpacking site (the
/// prologue of each `[[ stitchable ]]` entry point in `Shaders/`).
///
/// If you add a new uniform, extend one of the existing `float4`s into an
/// unused lane or introduce a new bundle at BOTH ends — Metal doesn't
/// name-match uniforms, so a mismatch silently reads garbage.
enum ShaderDispatch {
  static func shader(
    size: BorderBeamSize,
    pixelSize: CGSize,
    cornerRadius: CGFloat,
    borderWidth: CGFloat,
    time: TimeInterval,
    duration: Double,
    strokeOpacity: Double,
    innerOpacity: Double,
    bloomOpacity: Double,
    strength: Double,
    brightness: Double,
    saturation: Double,
    variant: Float,
    inkLuma: Double,
    innerShadowAlpha: Double,
    inkAlphaScale: Double,
    hueCos: Double,
    hueSin: Double,
    paletteScale: Double,
    shapeType: Int
  ) -> Shader {
    let function = ShaderFunction(
      library: .bundle(.module),
      name: entryPointName(for: size)
    )

    let args: [Shader.Argument] = [
      // rect:       sizeW, sizeH, cornerRadius, borderWidth
      .float4(
        Float(pixelSize.width),
        Float(pixelSize.height),
        Float(cornerRadius),
        Float(borderWidth)
      ),
      // timing:     time, duration, brightness, saturation
      .float4(
        Float(time),
        Float(duration),
        Float(brightness),
        Float(saturation)
      ),
      // opacities:  stroke, inner, bloom, strength
      .float4(
        Float(strokeOpacity),
        Float(innerOpacity),
        Float(bloomOpacity),
        Float(strength)
      ),
      // theme:      variant, inkLuma, innerShadowAlpha, inkAlphaScale
      .float4(
        variant,
        Float(inkLuma),
        Float(innerShadowAlpha),
        Float(inkAlphaScale)
      ),
      // hueAndScale: cos, sin, paletteScale, shapeType
      .float4(
        Float(hueCos),
        Float(hueSin),
        Float(paletteScale),
        Float(shapeType)
      ),
    ]
    return Shader(function: function, arguments: args)
  }

  private static func entryPointName(for size: BorderBeamSize) -> String {
    switch size {
    case .medium: return "borderBeam"
    case .small:  return "borderBeamSmall"
    case .line:   return "borderBeamLine"
    }
  }
}
