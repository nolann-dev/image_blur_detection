import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:test/test.dart';

void main() {
  group('BrightnessAnalyzer', () {
    late BrightnessAnalyzer analyzer;

    setUp(() {
      analyzer = const BrightnessAnalyzer(
        minBrightness: 40.0,
        maxBrightness: 220.0,
      );
    });

    test('should create analyzer with default thresholds', () {
      const defaultAnalyzer = BrightnessAnalyzer();
      expect(defaultAnalyzer.minBrightness, 40.0);
      expect(defaultAnalyzer.maxBrightness, 220.0);
    });

    test('should create analyzer with custom thresholds', () {
      const customAnalyzer = BrightnessAnalyzer(
        minBrightness: 50.0,
        maxBrightness: 200.0,
      );
      expect(customAnalyzer.minBrightness, 50.0);
      expect(customAnalyzer.maxBrightness, 200.0);
    });

    test('should detect dark image as tooDark', () {
      // Create a very dark image
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(20, 20, 20, 255));
        }
      }

      final result = analyzer.analyzeFromImage(image);

      expect(result.level, BrightnessLevel.tooDark);
      expect(result.isOptimal, false);
      expect(result.averageBrightness, lessThan(40.0));
    });

    test('should detect bright image as tooBright', () {
      // Create a very bright image
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(250, 250, 250, 255));
        }
      }

      final result = analyzer.analyzeFromImage(image);

      expect(result.level, BrightnessLevel.tooBright);
      expect(result.isOptimal, false);
      expect(result.averageBrightness, greaterThan(220.0));
    });

    test('should detect optimal brightness', () {
      // Create an image with medium brightness
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }

      final result = analyzer.analyzeFromImage(image);

      expect(result.level, BrightnessLevel.optimal);
      expect(result.isOptimal, true);
      expect(result.averageBrightness, greaterThanOrEqualTo(40.0));
      expect(result.averageBrightness, lessThanOrEqualTo(220.0));
    });

    test('should return BrightnessResult with all fields populated', () {
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(100, 100, 100, 255));
        }
      }

      final result = analyzer.analyzeFromImage(image);

      expect(result.averageBrightness, isA<double>());
      expect(result.minThreshold, 40.0);
      expect(result.maxThreshold, 220.0);
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

      expect(result, isA<BrightnessResult>());
    });
  });
}
