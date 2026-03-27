import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class CameraState {
  const CameraState();

  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraLoadedState extends CameraState {
  final CameraController controller;
  final String cameraLabel;
  final String cameraLabelName;
  final int currentIndex;
  const CameraLoadedState(this.controller, this.cameraLabel,this.cameraLabelName, this.currentIndex);

  @override
  List<Object?> get props => [controller];
}

class CameraError extends CameraState {
  final String message;

  const CameraError(this.message);

  @override
  List<Object?> get props => [message];
}

// live barcode
class BarcodeLoadedState extends CameraState {
  final CameraController controller;
  final String barcodeLabel;
  final int currentBarcodeIndex;
  const BarcodeLoadedState(
      this.controller, this.barcodeLabel, this.currentBarcodeIndex);

  @override
  List<Object?> get props => [controller];
}

// live face camera detection
class CameraFaceLoadedState extends CameraState {
  final CameraController controller;
  final int currentFaceCameraIndex;

  final String faceLabel;
  final List<Face> faces;
  const CameraFaceLoadedState(
      this.controller, this.faceLabel, this.currentFaceCameraIndex, this.faces);

  @override
  List<Object?> get props => [
        controller,
        faceLabel,
        currentFaceCameraIndex,
        faces,
      ];
}

// live object camera detection
class CameraObjectLoadedState extends CameraState {
  final CameraController controller;
  final int currentFaceCameraIndex;

  final String objectLabel;
  final List<DetectedObject> detectedObjects;
  const CameraObjectLoadedState(
      this.controller, this.objectLabel, this.currentFaceCameraIndex, this.detectedObjects);

  @override
  List<Object?> get props => [
        controller,
        objectLabel,
        currentFaceCameraIndex,
        detectedObjects,
      ];
}

// live text recognition camera detection
class CameraTextLoadedState extends CameraState {
  final CameraController controller;
  final int currentTextCameraIndex;
  final RecognizedText recognizedText;
  const CameraTextLoadedState(
      this.controller, this.currentTextCameraIndex, this.recognizedText);

  @override
  List<Object?> get props => [
        controller,
        currentTextCameraIndex,
        recognizedText,
      ];
}

// live pose recognition camera detection
class CameraPoseLoadedState extends CameraState {
  final CameraController controller;
  final int currentPoseCameraIndex;
  final List<Pose> pose;
  const CameraPoseLoadedState(
      this.controller, this.currentPoseCameraIndex, this.pose);

  @override
  List<Object?> get props => [
    controller,
    currentPoseCameraIndex,
    pose,
  ];
}