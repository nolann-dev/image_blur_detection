import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/brightness_level.dart';
import '../models/brightness_result.dart';

/// Analyzes image brightness to detect underexposed or overexposed images.
///
/// Uses luminance calculation to determine the average brightness of an image
/// and classifies it as too dark, optimal, or too bright based on configured
/// thresholds.
class BrightnessAnalyzer {
  /// Minimum acceptable brightness value (0-255 scale).
  /// Images below this value are considered too dark.
  final double minBrightness;

  /// Maximum acceptable brightness value (0-255 scale).
  /// Images above this value are considered too bright.
  final double maxBrightness;

  /// Creates a [BrightnessAnalyzer] with the given thresholds.
  ///
  /// The [minBrightness] and [maxBrightness] values should be between 0 and 255.
  /// Default values are 40.0 and 220.0 respectively.
  const BrightnessAnalyzer({
    this.minBrightness = 40.0,
    this.maxBrightness = 220.0,
  });

  /// Analyzes brightness of an image from raw bytes.
  ///
  /// Returns a [BrightnessResult] containing the brightness analysis.
  /// Throws an [ArgumentError] if the image cannot be decoded.
  BrightnessResult analyze(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ArgumentError('Cannot decode image from provided bytes');
    }
    return analyzeFromImage(image);
  }

  /// Analyzes brightness of an already decoded image.
  ///
  /// Returns a [BrightnessResult] containing the brightness analysis.
  BrightnessResult analyzeFromImage(img.Image image) {
    final averageBrightness = _calculateAverageBrightness(image);
    final level = _classifyBrightness(averageBrightness);

    return BrightnessResult(
      level: level,
      averageBrightness: averageBrightness,
      minThreshold: minBrightness,
      maxThreshold: maxBrightness,
    );
  }

  /// Calculates the average brightness of the image.
  double _calculateAverageBrightness(img.Image image) {
    var totalLuminance = 0.0;
    var pixelCount = 0;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        totalLuminance += img.getLuminance(pixel);
        pixelCount++;
      }
    }

    if (pixelCount == 0) return 0.0;
    return totalLuminance / pixelCount;
  }

  /// Classifies the brightness level based on thresholds.
  BrightnessLevel _classifyBrightness(double brightness) {
    if (brightness < minBrightness) {
      return BrightnessLevel.tooDark;
    } else if (brightness > maxBrightness) {
      return BrightnessLevel.tooBright;
    }
    return BrightnessLevel.optimal;
  }
}
