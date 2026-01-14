import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../config/quality_config.dart';
import '../detectors/blur_detector.dart';
import '../detectors/brightness_analyzer.dart';
import '../detectors/contrast_analyzer.dart';
import '../models/blur_result.dart';
import '../models/brightness_result.dart';
import '../models/contrast_result.dart';
import '../models/quality_result.dart';

/// Main validator that combines blur, brightness, and contrast checks.
///
/// Use this class for comprehensive image quality validation with a single
/// entry point. Individual detectors can also be used separately for more
/// granular control.
///
/// Example:
/// ```dart
/// final validator = ImageQualityValidator();
/// final result = await validator.validate(imageBytes);
///
/// if (result.isValid) {
///   // Image quality is acceptable
/// } else {
///   print('Issues: ${result.issues}');
/// }
/// ```
class ImageQualityValidator {
  /// The configuration for quality thresholds.
  final QualityConfig config;

  /// Internal blur detector instance.
  late final BlurDetector _blurDetector;

  /// Internal brightness analyzer instance.
  late final BrightnessAnalyzer _brightnessAnalyzer;

  /// Internal contrast analyzer instance.
  late final ContrastAnalyzer _contrastAnalyzer;

  /// Creates an [ImageQualityValidator] with the given configuration.
  ///
  /// If no [config] is provided, default thresholds are used.
  ImageQualityValidator({this.config = const QualityConfig()}) {
    _blurDetector = BlurDetector(threshold: config.blurThreshold);
    _brightnessAnalyzer = BrightnessAnalyzer(
      minBrightness: config.minBrightness,
      maxBrightness: config.maxBrightness,
    );
    _contrastAnalyzer = ContrastAnalyzer(minContrast: config.minContrast);
  }

  /// Validates the image quality from raw bytes.
  ///
  /// Performs all quality checks (blur, brightness, contrast) and returns
  /// a combined [QualityResult].
  ///
  /// This is an async method to allow for potential future optimizations
  /// like running checks in isolates for large images.
  ///
  /// Throws an [ArgumentError] if the image cannot be decoded.
  Future<QualityResult> validate(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ArgumentError('Cannot decode image from provided bytes');
    }
    return validateFromImage(image);
  }

  /// Validates the quality of an already decoded image.
  ///
  /// Performs all quality checks (blur, brightness, contrast) and returns
  /// a combined [QualityResult].
  Future<QualityResult> validateFromImage(img.Image image) async {
    final blurResult = _blurDetector.detectFromImage(image);
    final brightnessResult = _brightnessAnalyzer.analyzeFromImage(image);
    final contrastResult = _contrastAnalyzer.analyzeFromImage(image);

    final isValid = !blurResult.isBlurry &&
        brightnessResult.isOptimal &&
        contrastResult.hasGoodContrast;

    return QualityResult(
      isValid: isValid,
      blurResult: blurResult,
      brightnessResult: brightnessResult,
      contrastResult: contrastResult,
    );
  }

  /// Checks only the blur of an image from raw bytes.
  ///
  /// Returns a [BlurResult] containing the blur detection result.
  /// Throws an [ArgumentError] if the image cannot be decoded.
  BlurResult checkBlur(Uint8List imageBytes) {
    return _blurDetector.detect(imageBytes);
  }

  /// Checks only the blur of an already decoded image.
  ///
  /// Returns a [BlurResult] containing the blur detection result.
  BlurResult checkBlurFromImage(img.Image image) {
    return _blurDetector.detectFromImage(image);
  }

  /// Checks only the brightness of an image from raw bytes.
  ///
  /// Returns a [BrightnessResult] containing the brightness analysis.
  /// Throws an [ArgumentError] if the image cannot be decoded.
  BrightnessResult checkBrightness(Uint8List imageBytes) {
    return _brightnessAnalyzer.analyze(imageBytes);
  }

  /// Checks only the brightness of an already decoded image.
  ///
  /// Returns a [BrightnessResult] containing the brightness analysis.
  BrightnessResult checkBrightnessFromImage(img.Image image) {
    return _brightnessAnalyzer.analyzeFromImage(image);
  }

  /// Checks only the contrast of an image from raw bytes.
  ///
  /// Returns a [ContrastResult] containing the contrast analysis.
  /// Throws an [ArgumentError] if the image cannot be decoded.
  ContrastResult checkContrast(Uint8List imageBytes) {
    return _contrastAnalyzer.analyze(imageBytes);
  }

  /// Checks only the contrast of an already decoded image.
  ///
  /// Returns a [ContrastResult] containing the contrast analysis.
  ContrastResult checkContrastFromImage(img.Image image) {
    return _contrastAnalyzer.analyzeFromImage(image);
  }
}
