/// Configuration for image quality validation thresholds.
///
/// This class provides configurable thresholds for blur detection,
/// brightness analysis, and contrast analysis. It also includes
/// preset configurations for common use cases.
class QualityConfig {
  /// Threshold for blur detection using Laplacian variance.
  /// Higher values require sharper images.
  /// Typical range: 50-500, default: 100.0
  final double blurThreshold;

  /// Minimum acceptable brightness value (0-255 scale).
  /// Images below this value are considered too dark.
  /// Default: 40.0
  final double minBrightness;

  /// Maximum acceptable brightness value (0-255 scale).
  /// Images above this value are considered too bright/overexposed.
  /// Default: 220.0
  final double maxBrightness;

  /// Minimum acceptable contrast score (standard deviation).
  /// Images below this value are considered low contrast.
  /// Default: 50.0
  final double minContrast;

  /// Creates a [QualityConfig] with the given thresholds.
  ///
  /// All parameters have sensible defaults suitable for general-purpose
  /// image quality validation.
  const QualityConfig({
    this.blurThreshold = 100.0,
    this.minBrightness = 40.0,
    this.maxBrightness = 220.0,
    this.minContrast = 50.0,
  })  : assert(blurThreshold > 0, 'blurThreshold must be positive'),
        assert(minBrightness >= 0 && minBrightness <= 255,
            'minBrightness must be between 0 and 255'),
        assert(maxBrightness >= 0 && maxBrightness <= 255,
            'maxBrightness must be between 0 and 255'),
        assert(minBrightness < maxBrightness,
            'minBrightness must be less than maxBrightness'),
        assert(minContrast >= 0, 'minContrast must be non-negative');

  /// Preset configuration optimized for card scanning (ID cards, credit cards).
  ///
  /// Uses relaxed blur threshold and brightness range suitable for
  /// handheld card scanning scenarios.
  static const QualityConfig cardScanning = QualityConfig(
    blurThreshold: 80.0,
    minBrightness: 35.0,
    maxBrightness: 230.0,
    minContrast: 40.0,
  );

  /// Preset configuration optimized for document scanning.
  ///
  /// Uses moderate settings suitable for scanning documents with text.
  static const QualityConfig documentScanning = QualityConfig(
    blurThreshold: 120.0,
    minBrightness: 45.0,
    maxBrightness: 215.0,
    minContrast: 55.0,
  );

  /// Preset configuration optimized for photo capture.
  ///
  /// Uses stricter blur threshold for higher quality photo requirements.
  static const QualityConfig photoCapture = QualityConfig(
    blurThreshold: 200.0,
    minBrightness: 30.0,
    maxBrightness: 235.0,
    minContrast: 45.0,
  );

  /// Preset configuration with relaxed thresholds.
  ///
  /// Useful for low-quality cameras or challenging lighting conditions.
  static const QualityConfig relaxed = QualityConfig(
    blurThreshold: 50.0,
    minBrightness: 25.0,
    maxBrightness: 240.0,
    minContrast: 30.0,
  );

  /// Preset configuration with strict thresholds.
  ///
  /// Useful when high image quality is required.
  static const QualityConfig strict = QualityConfig(
    blurThreshold: 250.0,
    minBrightness: 50.0,
    maxBrightness: 200.0,
    minContrast: 65.0,
  );

  /// Creates a copy of this config with the given fields replaced.
  QualityConfig copyWith({
    double? blurThreshold,
    double? minBrightness,
    double? maxBrightness,
    double? minContrast,
  }) {
    return QualityConfig(
      blurThreshold: blurThreshold ?? this.blurThreshold,
      minBrightness: minBrightness ?? this.minBrightness,
      maxBrightness: maxBrightness ?? this.maxBrightness,
      minContrast: minContrast ?? this.minContrast,
    );
  }

  @override
  String toString() =>
      'QualityConfig(blurThreshold: $blurThreshold, brightness: $minBrightness-$maxBrightness, minContrast: $minContrast)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityConfig &&
          runtimeType == other.runtimeType &&
          blurThreshold == other.blurThreshold &&
          minBrightness == other.minBrightness &&
          maxBrightness == other.maxBrightness &&
          minContrast == other.minContrast;

  @override
  int get hashCode =>
      blurThreshold.hashCode ^
      minBrightness.hashCode ^
      maxBrightness.hashCode ^
      minContrast.hashCode;
}
