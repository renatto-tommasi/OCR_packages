import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/camera_service.dart';
import 'services/ocr_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OcrCameraApp());
}

class OcrCameraApp extends StatelessWidget {
  const OcrCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'On-device OCR Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const OcrCameraScreen(),
    );
  }
}

class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({super.key});

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

class _OcrCameraScreenState extends State<OcrCameraScreen> {
  final CameraService _cameraService = CameraService();
  final OcrService _ocrService = OcrService();

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  XFile? _capturedImage;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        throw Exception('Camera permission denied. Please allow access.');
      }

      await _cameraService.initialize();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.description ?? 'Camera unavailable.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _captureAndRecognize() async {
    setState(() {
      _errorMessage = null;
      _isProcessing = true;
    });

    try {
      final image = await _cameraService.captureImage();
      final text = await _ocrService.processImage(image.path);

      if (!mounted) return;
      setState(() {
        _capturedImage = image;
        _recognizedText =
            text.isEmpty ? 'No text detected in the captured image.' : text;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to capture or process image: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
      _recognizedText = '';
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraService.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('On-device OCR')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _ErrorState(
                    message: _errorMessage!,
                    onRetry: _setupCamera,
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _capturedImage == null
                            ? (controller != null && controller.value.isInitialized
                                ? CameraPreview(controller)
                                : const Center(
                                    child: Text('Camera is unavailable.'),
                                  ))
                            : Image.file(
                                File(_capturedImage!.path),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_capturedImage != null) ...[
                                const Text(
                                  'Detected Text',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _recognizedText,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ] else
                                const Spacer(),
                              if (_isProcessing)
                                const Center(child: CircularProgressIndicator())
                              else
                                ElevatedButton.icon(
                                  onPressed: _capturedImage == null
                                      ? _captureAndRecognize
                                      : _retake,
                                  icon: Icon(_capturedImage == null
                                      ? Icons.camera_alt
                                      : Icons.refresh),
                                  label: Text(
                                    _capturedImage == null ? 'Capture' : 'Retake',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
