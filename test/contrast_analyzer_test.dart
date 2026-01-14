import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:test/test.dart';

void main() {
  group('ContrastAnalyzer', () {
    late ContrastAnalyzer analyzer;

    setUp(() {
      analyzer = const ContrastAnalyzer(minContrast: 50.0);
    });

    test('should create analyzer with default threshold', () {
      const defaultAnalyzer = ContrastAnalyzer();
      expect(defaultAnalyzer.minContrast, 50.0);
    });

    test('should create analyzer with custom threshold', () {
      const customAnalyzer = ContrastAnalyzer(minContrast: 75.0);
      expect(customAnalyzer.minContrast, 75.0);
    });

    test('should detect high contrast image', () {
      // Create a high contrast image (black and white checkerboard)
      final image = img.Image(width: 100, height: 100);
      for (var y = 0; y < 100; y++) {
        for (var x = 0; x < 100; x++) {
          final isWhite = ((x ~/ 10) + (y ~/ 10)) % 2 == 0;
          final color = isWhite
              ? img.ColorRgba8(255, 255, 255, 255)
              : img.ColorRgba8(0, 0, 0, 255);
          image.setPixel(x, y, color);
        }
      }

      final result = analyzer.analyzeFromImage(image);

      expect(result.hasGoodContrast, true);
      expect(result.contrastScore, greaterThan(50.0));
    });

    test('should detect low contrast image', () {
      // Create a low contrast image (uniform gray)
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }

      final result = analyzer.analyzeFromImage(image);

      expect(result.hasGoodContrast, false);
      expect(result.contrastScore, lessThan(50.0));
    });

    test('should detect slightly varying low contrast image', () {
      // Create an image with very slight variations (still low contrast)
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          final value = 125 + (x % 5);
          image.setPixel(x, y, img.ColorRgba8(value, value, value, 255));
        }
      }

      final result = analyzer.analyzeFromImage(image);

      // Small variations should still result in low contrast
      expect(result.contrastScore, lessThan(50.0));
    });

    test('should return ContrastResult with all fields populated', () {
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(100, 100, 100, 255));
        }
      }

      final result = analyzer.analyzeFromImage(image);

      expect(result.contrastScore, isA<double>());
      expect(result.threshold, 50.0);
      expect(result.message, isNotEmpty);
    });

    test('should throw ArgumentError for invalid image bytes', () {
      expect(
        () => analyzer.analyze(Uint8List.fromList([1, 2, 3])),
        throwsArgumentError,
      );
    });

    test('analyze should work with valid encoded image bytes', () {
      final image = img.Image(width: 10, height: 10);
      for (var y = 0; y < 10; y++) {
        for (var x = 0; x < 10; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = analyzer.analyze(bytes);

      expect(result, isA<ContrastResult>());
    });
  });
}
