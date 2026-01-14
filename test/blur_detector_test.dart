import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:test/test.dart';

void main() {
  group('BlurDetector', () {
    late BlurDetector detector;

    setUp(() {
      detector = const BlurDetector(threshold: 100.0);
    });

    test('should create detector with default threshold', () {
      const defaultDetector = BlurDetector();
      expect(defaultDetector.threshold, 100.0);
    });

    test('should create detector with custom threshold', () {
      const customDetector = BlurDetector(threshold: 200.0);
      expect(customDetector.threshold, 200.0);
    });

    test('should detect sharp image with high contrast edges', () {
      // Create a sharp image with clear edges (checkerboard pattern)
      final image = img.Image(width: 100, height: 100);

      // Create checkerboard pattern (sharp edges)
      for (var y = 0; y < 100; y++) {
        for (var x = 0; x < 100; x++) {
          final isWhite = ((x ~/ 10) + (y ~/ 10)) % 2 == 0;
          final color = isWhite
              ? img.ColorRgba8(255, 255, 255, 255)
              : img.ColorRgba8(0, 0, 0, 255);
          image.setPixel(x, y, color);
        }
      }

      final result = detector.detectFromImage(image);

      // High contrast checkerboard should have high variance (not blurry)
      expect(result.variance, greaterThan(0));
      expect(result.threshold, 100.0);
    });

    test('should detect blurry image with uniform color', () {
      // Create a uniform gray image (no edges = blurry detection)
      final image = img.Image(width: 100, height: 100);

      for (var y = 0; y < 100; y++) {
        for (var x = 0; x < 100; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }

      final result = detector.detectFromImage(image);

      // Uniform image should have zero/low variance (blurry)
      expect(result.isBlurry, true);
      expect(result.variance, lessThan(100.0));
    });

    test('should return BlurResult with all fields populated', () {
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(100, 100, 100, 255));
        }
      }

      final result = detector.detectFromImage(image);

      expect(result.variance, isA<double>());
      expect(result.confidence, greaterThanOrEqualTo(0.5));
      expect(result.confidence, lessThanOrEqualTo(1.0));
      expect(result.threshold, 100.0);
      expect(result.message, isNotEmpty);
    });

    test('should throw ArgumentError for invalid image bytes', () {
      expect(
        () => detector.detect(Uint8List.fromList([1, 2, 3])),
        throwsArgumentError,
      );
    });

    test('detect should work with valid encoded image bytes', () {
      final image = img.Image(width: 10, height: 10);
      for (var y = 0; y < 10; y++) {
        for (var x = 0; x < 10; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = detector.detect(bytes);

      expect(result, isA<BlurResult>());
    });
  });
}
