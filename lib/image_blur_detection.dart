/// A Flutter/Dart package to detect blur, brightness, and contrast issues
/// in images with configurable thresholds.
///
/// This package provides tools for validating image quality before processing,
/// which is especially useful for card scanning, document scanning, and
/// photo capture scenarios.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:image_blur_detection/image_blur_detection.dart';
///
/// // Simple usage with defaults
/// final validator = ImageQualityValidator();
/// final result = await validator.validate(imageBytes);
///
/// if (result.isValid) {
///   // Proceed with image processing
/// } else {
///   print('Issues: ${result.issues}');
/// }
/// ```
///
/// ## Custom Configuration
///
/// ```dart
/// final customValidator = ImageQualityValidator(
///   config: QualityConfig(
///     blurThreshold: 150.0,    // Stricter blur detection
///     minBrightness: 50.0,
///     maxBrightness: 200.0,
///   ),
/// );
/// ```
///
/// ## Using Presets
///
/// ```dart
/// final cardValidator = ImageQualityValidator(
///   config: QualityConfig.cardScanning,
/// );
/// ```
library image_blur_detection;

// Config
export 'src/config/quality_config.dart';

// Detectors
export 'src/detectors/blur_detector.dart';
export 'src/detectors/brightness_analyzer.dart';
export 'src/detectors/contrast_analyzer.dart';

// Models
export 'src/models/blur_result.dart';
export 'src/models/brightness_level.dart';
export 'src/models/brightness_result.dart';
export 'src/models/contrast_result.dart';
export 'src/models/quality_result.dart';

// Validator
export 'src/validator/image_quality_validator.dart';
