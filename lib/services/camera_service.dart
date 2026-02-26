import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException('NoCamera', 'No camera available on this device.');
    }

    final CameraDescription rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      rearCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  Future<XFile> captureImage() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw CameraException('CameraNotInitialized', 'Camera is not initialized.');
    }

    if (controller.value.isTakingPicture) {
      throw CameraException('CaptureInProgress', 'Capture already in progress.');
    }

    return controller.takePicture();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
