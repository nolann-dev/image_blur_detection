import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:test/test.dart';

void main() {
  group('ImageQualityValidator', () {
    late ImageQualityValidator validator;

    setUp(() {
      validator = ImageQualityValidator();
    });

    test('should create validator with default config', () {
      expect(validator.config.blurThreshold, 100.0);
      expect(validator.config.minBrightness, 40.0);
      expect(validator.config.maxBrightness, 220.0);
      expect(validator.config.minContrast, 50.0);
    });

    test('should create validator with custom config', () {
      final customValidator = ImageQualityValidator(
        config: const QualityConfig(
          blurThreshold: 150.0,
          minBrightness: 50.0,
          maxBrightness: 200.0,
          minContrast: 60.0,
        ),
      );

      expect(customValidator.config.blurThreshold, 150.0);
      expect(customValidator.config.minBrightness, 50.0);
      expect(customValidator.config.maxBrightness, 200.0);
      expect(customValidator.config.minContrast, 60.0);
    });

    test('should create validator with preset config', () {
      final cardValidator = ImageQualityValidator(
        config: QualityConfig.cardScanning,
      );

      expect(cardValidator.config.blurThreshold, 80.0);
      expect(cardValidator.config.minBrightness, 35.0);
      expect(cardValidator.config.maxBrightness, 230.0);
      expect(cardValidator.config.minContrast, 40.0);
    });

    test('should validate good quality image', () async {
      // Create a high-quality image (good contrast, optimal brightness, sharp)
      final image = img.Image(width: 100, height: 100);

      // Create a pattern with good contrast and edges
      for (var y = 0; y < 100; y++) {
        for (var x = 0; x < 100; x++) {
          final isWhite = ((x ~/ 10) + (y ~/ 10)) % 2 == 0;
          final value = isWhite ? 200 : 80;
          image.setPixel(x, y, img.ColorRgba8(value, value, value, 255));
        }
      }

      final result = await validator.validateFromImage(image);

      expect(result.blurResult, isA<BlurResult>());
      expect(result.brightnessResult, isA<BrightnessResult>());
      expect(result.contrastResult, isA<ContrastResult>());
      expect(result.brightnessResult.isOptimal, true);
      expect(result.contrastResult.hasGoodContrast, true);
    });

    test('should detect dark image issue', () async {
      // Create a very dark image
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(10, 10, 10, 255));
        }
      }

      final result = await validator.validateFromImage(image);

      expect(result.isValid, false);
      expect(result.brightnessResult.level, BrightnessLevel.tooDark);
      expect(result.issues, contains(contains('dark')));
    });

    test('should detect bright image issue', () async {
      // Create a very bright image
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(250, 250, 250, 255));
        }
      }

      final result = await validator.validateFromImage(image);

      expect(result.isValid, false);
      expect(result.brightnessResult.level, BrightnessLevel.tooBright);
      expect(result.issues, contains(contains('bright')));
    });

    test('should detect low contrast issue', () async {
      // Create a low contrast image (uniform gray)
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }

      final result = await validator.validateFromImage(image);

      expect(result.isValid, false);
      expect(result.contrastResult.hasGoodContrast, false);
      expect(result.issues, contains(contains('contrast')));
    });

    test('should return all issues in QualityResult', () async {
      // Create a problematic image (low contrast, uniform)
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }

      final result = await validator.validateFromImage(image);

      expect(result.issues, isA<List<String>>());
      expect(result.summary, contains('issues detected'));
    });

    test('checkBlur should return BlurResult', () {
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = validator.checkBlur(bytes);

      expect(result, isA<BlurResult>());
    });

    test('checkBrightness should return BrightnessResult', () {
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = validator.checkBrightness(bytes);

      expect(result, isA<BrightnessResult>());
    });

    test('checkContrast should return ContrastResult', () {
      final image = img.Image(width: 50, height: 50);
      for (var y = 0; y < 50; y++) {
        for (var x = 0; x < 50; x++) {
          image.setPixel(x, y, img.ColorRgba8(128, 128, 128, 255));
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = validator.checkContrast(bytes);

      expect(result, isA<ContrastResult>());
    });

    test('validate should throw ArgumentError for invalid image bytes',
        () async {
      expect(
        () async => validator.validate(Uint8List.fromList([1, 2, 3])),
        throwsArgumentError,
      );
    });
  });

  group('QualityConfig', () {
    test('should have correct default values', () {
      const config = QualityConfig();

      expect(config.blurThreshold, 100.0);
      expect(config.minBrightness, 40.0);
      expect(config.maxBrightness, 220.0);
      expect(config.minContrast, 50.0);
    });

    test('cardScanning preset should have relaxed values', () {
      expect(QualityConfig.cardScanning.blurThreshold, 80.0);
      expect(QualityConfig.cardScanning.minBrightness, 35.0);
      expect(QualityConfig.cardScanning.maxBrightness, 230.0);
      expect(QualityConfig.cardScanning.minContrast, 40.0);
    });

    test('documentScanning preset should have moderate values', () {
      expect(QualityConfig.documentScanning.blurThreshold, 120.0);
      expect(QualityConfig.documentScanning.minBrightness, 45.0);
      expect(QualityConfig.documentScanning.maxBrightness, 215.0);
      expect(QualityConfig.documentScanning.minContrast, 55.0);
    });

    test('photoCapture preset should have stricter blur threshold', () {
      expect(QualityConfig.photoCapture.blurThreshold, 200.0);
      expect(QualityConfig.photoCapture.minBrightness, 30.0);
      expect(QualityConfig.photoCapture.maxBrightness, 235.0);
      expect(QualityConfig.photoCapture.minContrast, 45.0);
    });

    test('copyWith should create new config with updated values', () {
      const original = QualityConfig();
      final modified = original.copyWith(blurThreshold: 200.0);

      expect(modified.blurThreshold, 200.0);
      expect(modified.minBrightness, original.minBrightness);
      expect(modified.maxBrightness, original.maxBrightness);
      expect(modified.minContrast, original.minContrast);
    });
  });
}
