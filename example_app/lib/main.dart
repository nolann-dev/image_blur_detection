import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Blur Detection Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ImageQualityScreen(),
    );
  }
}

class ImageQualityScreen extends StatefulWidget {
  const ImageQualityScreen({super.key});

  @override
  State<ImageQualityScreen> createState() => _ImageQualityScreenState();
}

class _ImageQualityScreenState extends State<ImageQualityScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  QualityResult? _result;
  bool _isLoading = false;
  String? _errorMessage;

  // Configuration
  QualityConfig _config = const QualityConfig();
  String _selectedPreset = 'Default';

  final Map<String, QualityConfig> _presets = {
    'Default': const QualityConfig(),
    'Card Scanning': QualityConfig.cardScanning,
    'Document Scanning': QualityConfig.documentScanning,
    'Photo Capture': QualityConfig.photoCapture,
    'Relaxed': QualityConfig.relaxed,
    'Strict': QualityConfig.strict,
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        final bytes = await image.readAsBytes();
        await _validateImage(bytes);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _validateImage(Uint8List bytes) async {
    try {
      final validator = ImageQualityValidator(config: _config);
      final result = await validator.validate(bytes);

      setState(() {
        _imageBytes = bytes;
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error validating image: $e';
        _isLoading = false;
      });
    }
  }

  void _updatePreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      _config = _presets[preset]!;
      // Re-validate if we have an image
      if (_imageBytes != null) {
        _isLoading = true;
      }
    });

    if (_imageBytes != null) {
      _validateImage(_imageBytes!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Quality Validator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preset selector
            _buildPresetSelector(),
            const SizedBox(height: 16),

            // Config display
            _buildConfigDisplay(),
            const SizedBox(height: 16),

            // Image picker buttons
            _buildImagePickerButtons(),
            const SizedBox(height: 16),

            // Image preview
            if (_imageBytes != null) _buildImagePreview(),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),

            // Error message
            if (_errorMessage != null) _buildErrorMessage(),

            // Results
            if (_result != null && !_isLoading) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration Preset',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPreset,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _presets.keys.map((preset) {
                return DropdownMenuItem(value: preset, child: Text(preset));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updatePreset(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigDisplay() {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Thresholds',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Blur Threshold: ${_config.blurThreshold}'),
            Text(
              'Brightness Range: ${_config.minBrightness} - ${_config.maxBrightness}',
            ),
            Text('Min Contrast: ${_config.minContrast}'),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.memory(
            _imageBytes!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          if (_result != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _result!.isValid ? Colors.green : Colors.red,
              child: Text(
                _result!.isValid ? 'QUALITY OK' : 'QUALITY ISSUES DETECTED',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(_errorMessage!)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_result!.summary),
                if (_result!.issues.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Issues:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...(_result!.issues
                      .map((issue) => Text('• $issue'))
                      .toList()),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Blur result
        _buildResultCard(
          title: 'Blur Detection',
          icon: Icons.blur_on,
          isGood: !_result!.blurResult.isBlurry,
          details: [
            'Status: ${_result!.blurResult.isBlurry ? "Blurry" : "Sharp"}',
            'Variance: ${_result!.blurResult.variance.toStringAsFixed(2)}',
            'Threshold: ${_result!.blurResult.threshold.toStringAsFixed(2)}',
            'Confidence: ${(_result!.blurResult.confidence * 100).toStringAsFixed(1)}%',
          ],
        ),

        const SizedBox(height: 12),

        // Brightness result
        _buildResultCard(
          title: 'Brightness Analysis',
          icon: Icons.brightness_6,
          isGood: _result!.brightnessResult.isOptimal,
          details: [
            'Level: ${_result!.brightnessResult.level.name}',
            'Average: ${_result!.brightnessResult.averageBrightness.toStringAsFixed(2)}',
            'Range: ${_result!.brightnessResult.minThreshold.toStringAsFixed(2)} - ${_result!.brightnessResult.maxThreshold.toStringAsFixed(2)}',
          ],
        ),

        const SizedBox(height: 12),

        // Contrast result
        _buildResultCard(
          title: 'Contrast Analysis',
          icon: Icons.contrast,
          isGood: _result!.contrastResult.hasGoodContrast,
          details: [
            'Status: ${_result!.contrastResult.hasGoodContrast ? "Good" : "Low"}',
            'Score: ${_result!.contrastResult.contrastScore.toStringAsFixed(2)}',
            'Threshold: ${_result!.contrastResult.threshold.toStringAsFixed(2)}',
          ],
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required IconData icon,
    required bool isGood,
    required List<String> details,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isGood ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isGood ? Colors.green : Colors.red),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isGood ? Icons.check_circle : Icons.cancel,
                        size: 20,
                        color: isGood ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...details.map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        detail,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
