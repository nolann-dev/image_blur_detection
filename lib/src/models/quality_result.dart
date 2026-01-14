import 'blur_result.dart';
import 'brightness_result.dart';
import 'contrast_result.dart';

/// Combined result of all image quality checks.
class QualityResult {
  /// Whether the image passes all quality checks.
  final bool isValid;

  /// The blur detection result.
  final BlurResult blurResult;

  /// The brightness analysis result.
  final BrightnessResult brightnessResult;

  /// The contrast analysis result.
  final ContrastResult contrastResult;

  /// Creates a [QualityResult] with the given parameters.
  const QualityResult({
    required this.isValid,
    required this.blurResult,
    required this.brightnessResult,
    required this.contrastResult,
  });

  /// Returns a list of all detected quality issues.
  List<String> get issues {
    final issuesList = <String>[];

    if (blurResult.isBlurry) {
      issuesList.add('Image is blurry');
    }

    if (!brightnessResult.isOptimal) {
      issuesList.add(brightnessResult.message);
    }

    if (!contrastResult.hasGoodContrast) {
      issuesList.add('Image has low contrast');
    }

    return issuesList;
  }

  /// Returns the primary error message, if any.
  String? get errorMessage {
    if (isValid) return null;
    final issuesList = issues;
    if (issuesList.isEmpty) return null;
    return issuesList.first;
  }

  /// Returns a summary message of the quality check.
  String get summary {
    if (isValid) {
      return 'Image quality is acceptable';
    }
    return 'Image quality issues detected: ${issues.join(', ')}';
  }

  @override
  String toString() =>
      'QualityResult(isValid: $isValid, issues: $issues, blur: $blurResult, brightness: $brightnessResult, contrast: $contrastResult)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityResult &&
          runtimeType == other.runtimeType &&
          isValid == other.isValid &&
          blurResult == other.blurResult &&
          brightnessResult == other.brightnessResult &&
          contrastResult == other.contrastResult;

  @override
  int get hashCode =>
      isValid.hashCode ^
      blurResult.hashCode ^
      brightnessResult.hashCode ^
      contrastResult.hashCode;
}
