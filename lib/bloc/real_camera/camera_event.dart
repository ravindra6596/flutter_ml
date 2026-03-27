import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

abstract class CameraEvent {
  const CameraEvent();

  List<Object?> get props => [];
}

// start camera
class InitializeCamera extends CameraEvent {
  final int cameraIndex;
  InitializeCamera(this.cameraIndex);
}
class DisposeCameraEvent extends CameraEvent {}
// camera label detected
class CameraLabelDetected extends CameraEvent {
  final String label;
  final String modelLabel;
  CameraLabelDetected(this.label,this.modelLabel);
}

// start barcode camera
class InitializeBarcode extends CameraEvent {
  final int barcodeIndex;
  InitializeBarcode(this.barcodeIndex);
}

// barcode label
class BarcodeLabelDetected extends CameraEvent {
  final String label;
  BarcodeLabelDetected(this.label);
}
// start live face camera
class InitializeCameraFace extends CameraEvent {
  final int faceCameraIndex;
  InitializeCameraFace(this.faceCameraIndex);
}

// face labels
class CameraFaceLabelDetected extends CameraEvent {
  final String label;
  final List<Face> faces;
  CameraFaceLabelDetected(this.label, this.faces);
}

// start object camera
class InitializeCameraObject extends CameraEvent {
  final int objectCameraIndex;
  InitializeCameraObject(this.objectCameraIndex);
}


class CameraImageStreamEvent extends CameraEvent {
  final CameraImage image;

  const CameraImageStreamEvent(this.image);

  @override
  List<Object?> get props => [image];
}

// start text recognition camera
class InitializeTextCamera extends CameraEvent {
  final int textCameraIndex;
  InitializeTextCamera(this.textCameraIndex);
}


class CameraTextStreamEvent extends CameraEvent {
  final CameraImage image;

  const CameraTextStreamEvent(this.image);

  @override
  List<Object?> get props => [image];
}
// start pose recognition camera
class InitializePoseCamera extends CameraEvent {
  final int poseCameraIndex;
  InitializePoseCamera(this.poseCameraIndex);
}


class CameraPoseStreamEvent extends CameraEvent {
  final CameraImage image;

  const CameraPoseStreamEvent(this.image);

  @override
  List<Object?> get props => [image];
}