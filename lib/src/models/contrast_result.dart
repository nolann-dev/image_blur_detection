/// Result of contrast analysis.
class ContrastResult {
  /// Whether the image has sufficient contrast.
  final bool hasGoodContrast;

  /// The contrast score (standard deviation of pixel intensities).
  /// Higher values indicate better contrast.
  final double contrastScore;

  /// The minimum contrast threshold used.
  final double threshold;

  /// Creates a [ContrastResult] with the given parameters.
  const ContrastResult({
    required this.hasGoodContrast,
    required this.contrastScore,
    required this.threshold,
  });

  /// Returns a human-readable message describing the contrast status.
  String get message {
    if (hasGoodContrast) {
      return 'Image has good contrast. Score: ${contrastScore.toStringAsFixed(2)}';
    }
    return 'Image has low contrast. Score: ${contrastScore.toStringAsFixed(2)} (threshold: ${threshold.toStringAsFixed(2)})';
  }

  @override
  String toString() =>
      'ContrastResult(hasGoodContrast: $hasGoodContrast, contrastScore: ${contrastScore.toStringAsFixed(2)}, threshold: ${threshold.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContrastResult &&
          runtimeType == other.runtimeType &&
          hasGoodContrast == other.hasGoodContrast &&
          contrastScore == other.contrastScore &&
          threshold == other.threshold;

  @override
  int get hashCode =>
      hasGoodContrast.hashCode ^ contrastScore.hashCode ^ threshold.hashCode;
}
