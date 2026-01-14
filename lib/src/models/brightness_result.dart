import 'brightness_level.dart';

/// Result of brightness analysis.
class BrightnessResult {
  /// The brightness level classification.
  final BrightnessLevel level;

  /// The average brightness value (0-255 scale).
  final double averageBrightness;

  /// The minimum brightness threshold used.
  final double minThreshold;

  /// The maximum brightness threshold used.
  final double maxThreshold;

  /// Creates a [BrightnessResult] with the given parameters.
  const BrightnessResult({
    required this.level,
    required this.averageBrightness,
    required this.minThreshold,
    required this.maxThreshold,
  });

  /// Whether the brightness is within the acceptable range.
  bool get isOptimal => level == BrightnessLevel.optimal;

  /// Returns a human-readable message describing the brightness status.
  String get message {
    switch (level) {
      case BrightnessLevel.tooDark:
        return 'Image is too dark. Brightness: ${averageBrightness.toStringAsFixed(2)} (min: ${minThreshold.toStringAsFixed(2)})';
      case BrightnessLevel.tooBright:
        return 'Image is too bright. Brightness: ${averageBrightness.toStringAsFixed(2)} (max: ${maxThreshold.toStringAsFixed(2)})';
      case BrightnessLevel.optimal:
        return 'Image brightness is optimal. Brightness: ${averageBrightness.toStringAsFixed(2)}';
    }
  }

  @override
  String toString() =>
      'BrightnessResult(level: $level, averageBrightness: ${averageBrightness.toStringAsFixed(2)}, range: ${minThreshold.toStringAsFixed(2)}-${maxThreshold.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrightnessResult &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          averageBrightness == other.averageBrightness &&
          minThreshold == other.minThreshold &&
          maxThreshold == other.maxThreshold;

  @override
  int get hashCode =>
      level.hashCode ^
      averageBrightness.hashCode ^
      minThreshold.hashCode ^
      maxThreshold.hashCode;
}
