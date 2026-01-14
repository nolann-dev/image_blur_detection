/// Enum representing the brightness level of an image.
enum BrightnessLevel {
  /// Image is too dark (below minimum brightness threshold).
  tooDark,

  /// Image brightness is within optimal range.
  optimal,

  /// Image is too bright/overexposed (above maximum brightness threshold).
  tooBright,
}
