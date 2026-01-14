// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_blur_detection/image_blur_detection.dart';

/// Example demonstrating how to use the image_blur_detection package.
void main() async {
  print('=== Image Blur Detection Package Example ===\n');

  // Create a sample image for demonstration
  final sampleImage = _createSampleImage();
  final imageBytes = Uint8List.fromList(img.encodePng(sampleImage));

  // Example 1: Basic usage with default configuration
  print('1. Basic Usage with Default Configuration:');
  await basicUsage(imageBytes);

  // Example 2: Using preset configurations
  print('\n2. Using Preset Configurations:');
  await presetConfigurations(imageBytes);

  // Example 3: Custom configuration
  print('\n3. Custom Configuration:');
  await customConfiguration(imageBytes);

  // Example 4: Individual quality checks
  print('\n4. Individual Quality Checks:');
  individualChecks(imageBytes);

  // Example 5: Using the detectors directly
  print('\n5. Using Detectors Directly:');
  directDetectorUsage(imageBytes);

  // Example 6: Working with file images (if you have a real image)
  print('\n6. File Image Usage (demonstration):');
  demonstrateFileUsage();
}

/// Example 1: Basic usage with default configuration
Future<void> basicUsage(Uint8List imageBytes) async {
  final validator = ImageQualityValidator();
  final result = await validator.validate(imageBytes);

  print('  Is valid: ${result.isValid}');
  print('  Summary: ${result.summary}');

  if (!result.isValid) {
    print('  Issues: ${result.issues}');
  }
}

/// Example 2: Using preset configurations
Future<void> presetConfigurations(Uint8List imageBytes) async {
  // Card scanning preset (more relaxed)
  final cardValidator = ImageQualityValidator(
    config: QualityConfig.cardScanning,
  );
  final cardResult = await cardValidator.validate(imageBytes);
  print('  Card Scanning - Is valid: ${cardResult.isValid}');

  // Document scanning preset (moderate)
  final docValidator = ImageQualityValidator(
    config: QualityConfig.documentScanning,
  );
  final docResult = await docValidator.validate(imageBytes);
  print('  Document Scanning - Is valid: ${docResult.isValid}');

  // Photo capture preset (stricter blur threshold)
  final photoValidator = ImageQualityValidator(
    config: QualityConfig.photoCapture,
  );
  final photoResult = await photoValidator.validate(imageBytes);
  print('  Photo Capture - Is valid: ${photoResult.isValid}');
}

/// Example 3: Custom configuration
Future<void> customConfiguration(Uint8List imageBytes) async {
  // Create a custom configuration
  const customConfig = QualityConfig(
    blurThreshold: 150.0, // Stricter blur detection
    minBrightness: 50.0, // Higher minimum brightness
    maxBrightness: 200.0, // Lower maximum brightness
    minContrast: 60.0, // Higher contrast requirement
  );

  final validator = ImageQualityValidator(config: customConfig);
  final result = await validator.validate(imageBytes);

  print('  Config: $customConfig');
  print('  Is valid: ${result.isValid}');

  // You can also modify existing configs
  final modifiedConfig = QualityConfig.cardScanning.copyWith(
    blurThreshold: 100.0, // Override just the blur threshold
  );
  print('  Modified config blur threshold: ${modifiedConfig.blurThreshold}');
}

/// Example 4: Individual quality checks
void individualChecks(Uint8List imageBytes) {
  final validator = ImageQualityValidator();

  // Check only blur
  final blurResult = validator.checkBlur(imageBytes);
  print('  Blur Check:');
  print('    - Is blurry: ${blurResult.isBlurry}');
  print('    - Variance: ${blurResult.variance.toStringAsFixed(2)}');
  print('    - Confidence: ${blurResult.confidence.toStringAsFixed(2)}');

  // Check only brightness
  final brightnessResult = validator.checkBrightness(imageBytes);
  print('  Brightness Check:');
  print('    - Level: ${brightnessResult.level}');
  print(
      '    - Average brightness: ${brightnessResult.averageBrightness.toStringAsFixed(2)}');

  // Check only contrast
  final contrastResult = validator.checkContrast(imageBytes);
  print('  Contrast Check:');
  print('    - Has good contrast: ${contrastResult.hasGoodContrast}');
  print('    - Score: ${contrastResult.contrastScore.toStringAsFixed(2)}');
}

/// Example 5: Using detectors directly
void directDetectorUsage(Uint8List imageBytes) {
  // Use BlurDetector directly
  const blurDetector = BlurDetector(threshold: 120.0);
  final blurResult = blurDetector.detect(imageBytes);
  print('  BlurDetector result: ${blurResult.message}');

  // Use BrightnessAnalyzer directly
  const brightnessAnalyzer = BrightnessAnalyzer(
    minBrightness: 45.0,
    maxBrightness: 210.0,
  );
  final brightnessResult = brightnessAnalyzer.analyze(imageBytes);
  print('  BrightnessAnalyzer result: ${brightnessResult.message}');

  // Use ContrastAnalyzer directly
  const contrastAnalyzer = ContrastAnalyzer(minContrast: 55.0);
  final contrastResult = contrastAnalyzer.analyze(imageBytes);
  print('  ContrastAnalyzer result: ${contrastResult.message}');
}

/// Example 6: Demonstrates how to use with real file images
void demonstrateFileUsage() {
  print('  To use with a real image file:');
  print('''
  // Read image from file
  final file = File('path/to/image.jpg');
  final imageBytes = await file.readAsBytes();

  // Validate the image
  final validator = ImageQualityValidator(
    config: QualityConfig.cardScanning,
  );
  final result = await validator.validate(imageBytes);

  if (result.isValid) {
    // Proceed with image processing
    print('Image quality is good!');
  } else {
    // Show error to user
    print('Please retake the photo: \${result.errorMessage}');
  }
''');
}

/// Creates a sample image with a checkerboard pattern for demonstration
img.Image _createSampleImage() {
  final image = img.Image(width: 200, height: 200);

  // Create a checkerboard pattern (good contrast, sharp edges)
  for (var y = 0; y < 200; y++) {
    for (var x = 0; x < 200; x++) {
      final isWhite = ((x ~/ 20) + (y ~/ 20)) % 2 == 0;
      final value = isWhite ? 200 : 80;
      image.setPixel(x, y, img.ColorRgba8(value, value, value, 255));
    }
  }

  return image;
}
