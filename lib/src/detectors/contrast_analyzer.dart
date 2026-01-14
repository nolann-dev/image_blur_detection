import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/contrast_result.dart';

/// Analyzes image contrast using histogram-based standard deviation.
///
/// Calculates the standard deviation of pixel luminance values to determine
/// the contrast level of an image. Images with low standard deviation have
/// poor contrast (flat histogram), while high standard deviation indicates
/// good contrast (wide histogram spread).
class ContrastAnalyzer {
  /// Minimum acceptable contrast score (standard deviation).
  /// Images below this value are considered low contrast.
  final double minContrast;

  /// Creates a [ContrastAnalyzer] with the given threshold.
  ///
  /// The [minContrast] value represents the minimum standard deviation
  /// of pixel luminance values for acceptable contrast. Default is 50.0.
  const ContrastAnalyzer({this.minContrast = 50.0});

  /// Analyzes contrast of an image from raw bytes.
  ///
  /// Returns a [ContrastResult] containing the contrast analysis.
  /// Throws an [ArgumentError] if the image cannot be decoded.
  ContrastResult analyze(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ArgumentError('Cannot decode image from provided bytes');
    }
    return analyzeFromImage(image);
  }

  /// Analyzes contrast of an already decoded image.
  ///
  /// Returns a [ContrastResult] containing the contrast analysis.
  ContrastResult analyzeFromImage(img.Image image) {
    final contrastScore = _calculateContrast(image);

    return ContrastResult(
      hasGoodContrast: contrastScore >= minContrast,
      contrastScore: contrastScore,
      threshold: minContrast,
    );
  }

  /// Calculates the contrast score using standard deviation of luminance.
  double _calculateContrast(img.Image image) {
    final luminanceValues = <double>[];

    // Collect all luminance values
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        luminanceValues.add(img.getLuminance(pixel).toDouble());
      }
    }

    if (luminanceValues.isEmpty) return 0.0;

    // Calculate mean
    var sum = 0.0;
    for (final value in luminanceValues) {
      sum += value;
    }
    final mean = sum / luminanceValues.length;

    // Calculate standard deviation
    var sumSquaredDiff = 0.0;
    for (final value in luminanceValues) {
      final diff = value - mean;
      sumSquaredDiff += diff * diff;
    }
    final variance = sumSquaredDiff / luminanceValues.length;
    final standardDeviation = math.sqrt(variance);

    return standardDeviation;
  }
}
