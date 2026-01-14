/// Result of blur detection analysis.
class BlurResult {
  /// Whether the image is considered blurry based on the threshold.
  final bool isBlurry;

  /// The raw Laplacian variance score.
  /// Higher values indicate sharper images.
  final double variance;

  /// Confidence level of the blur detection (0.0 - 1.0).
  /// Higher values indicate more certainty in the result.
  final double confidence;

  /// The threshold used for blur detection.
  final double threshold;

  /// Creates a [BlurResult] with the given parameters.
  const BlurResult({
    required this.isBlurry,
    required this.variance,
    required this.confidence,
    required this.threshold,
  });

  /// Returns a human-readable message describing the blur status.
  String get message {
    if (isBlurry) {
      return 'Image is blurry. Variance: ${variance.toStringAsFixed(2)} (threshold: ${threshold.toStringAsFixed(2)})';
    }
    return 'Image is sharp. Variance: ${variance.toStringAsFixed(2)}';
  }

  @override
  String toString() =>
      'BlurResult(isBlurry: $isBlurry, variance: ${variance.toStringAsFixed(2)}, confidence: ${confidence.toStringAsFixed(2)}, threshold: ${threshold.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlurResult &&
          runtimeType == other.runtimeType &&
          isBlurry == other.isBlurry &&
          variance == other.variance &&
          confidence == other.confidence &&
          threshold == other.threshold;

  @override
  int get hashCode =>
      isBlurry.hashCode ^
      variance.hashCode ^
      confidence.hashCode ^
      threshold.hashCode;
}
