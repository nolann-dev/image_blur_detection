import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/blur_result.dart';

/// Detects blur in images using the Laplacian variance method.
///
/// The Laplacian variance method works by applying a Laplacian filter
/// to detect edges in the image, then calculating the variance of the
/// result. Sharp images have high variance (many strong edges), while
/// blurry images have low variance (edges are smoothed out).
class BlurDetector {
  /// The threshold below which an image is considered blurry.
  /// Higher values require sharper images.
  final double threshold;

  /// Creates a [BlurDetector] with the given threshold.
  ///
  /// The [threshold] determines the sensitivity of blur detection.
  /// Typical values range from 50 to 500, with 100 being a good default.
  const BlurDetector({this.threshold = 100.0});

  /// Detects blur in an image from raw bytes.
  ///
  /// Returns a [BlurResult] containing the blur detection result.
  /// Throws an [ArgumentError] if the image cannot be decoded.
  BlurResult detect(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ArgumentError('Cannot decode image from provided bytes');
    }
    return detectFromImage(image);
  }

  /// Detects blur in an already decoded image.
  ///
  /// Returns a [BlurResult] containing the blur detection result.
  BlurResult detectFromImage(img.Image image) {
    // Convert to grayscale for edge detection
    final grayscale = img.grayscale(image);

    // Apply Laplacian filter to detect edges
    // Laplacian kernel: [0, 1, 0, 1, -4, 1, 0, 1, 0]
    final laplacian = _applyLaplacian(grayscale);

    // Calculate variance of the Laplacian result
    final variance = _calculateVariance(laplacian);

    // Calculate confidence based on how far the variance is from threshold
    final confidence = _calculateConfidence(variance);

    return BlurResult(
      isBlurry: variance < threshold,
      variance: variance,
      confidence: confidence,
      threshold: threshold,
    );
  }

  /// Applies the Laplacian filter to detect edges.
  List<double> _applyLaplacian(img.Image grayscale) {
    final width = grayscale.width;
    final height = grayscale.height;
    final result = <double>[];

    // Laplacian kernel
    const kernel = [0, 1, 0, 1, -4, 1, 0, 1, 0];

    // Apply convolution (skip borders)
    for (var y = 1; y < height - 1; y++) {
      for (var x = 1; x < width - 1; x++) {
        var sum = 0.0;
        var kernelIndex = 0;

        for (var ky = -1; ky <= 1; ky++) {
          for (var kx = -1; kx <= 1; kx++) {
            final pixel = grayscale.getPixel(x + kx, y + ky);
            final luminance = img.getLuminance(pixel);
            sum += luminance * kernel[kernelIndex];
            kernelIndex++;
          }
        }

        result.add(sum);
      }
    }

    return result;
  }

  /// Calculates the variance of the Laplacian values.
  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;

    // Calculate mean
    var sum = 0.0;
    for (final value in values) {
      sum += value;
    }
    final mean = sum / values.length;

    // Calculate variance
    var sumSquaredDiff = 0.0;
    for (final value in values) {
      final diff = value - mean;
      sumSquaredDiff += diff * diff;
    }

    return sumSquaredDiff / values.length;
  }

  /// Calculates confidence based on distance from threshold.
  double _calculateConfidence(double variance) {
    // Map variance to confidence (0.0 - 1.0)
    // Far from threshold = high confidence
    // Close to threshold = low confidence
    final distance = (variance - threshold).abs();
    final maxDistance = threshold * 2;

    // Use sigmoid-like function for smooth confidence curve
    final normalized = math.min(distance / maxDistance, 1.0);
    return 0.5 + (normalized * 0.5);
  }
}
