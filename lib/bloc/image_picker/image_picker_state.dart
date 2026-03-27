import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class ImagePickerState {
  const ImagePickerState();

  List<Object?> get props => [];
}

class ImageInitial extends ImagePickerState {}

// image picker from gallery and camera
class ImagePickedSuccess extends ImagePickerState {
  final File imageFile;
  final String imageData;
  final String modelData;

  const ImagePickedSuccess(this.imageFile, this.imageData,this.modelData);

  @override
  List<Object?> get props => [imageFile, imageData,modelData];
}

class ImagePickedError extends ImagePickerState {
  final String error;

  const ImagePickedError(this.error);

  @override
  List<Object?> get props => [error];
}

// barcode picker from gallery and camera
class BarcodeScannerPickerSuccess extends ImagePickerState {
  final File imageFile;
  final String imageData;

  const BarcodeScannerPickerSuccess(this.imageFile, this.imageData);

  @override
  List<Object?> get props => [imageFile, imageData];
}

class BarcodeScannerPickerError extends ImagePickerState {
  final String error;

  const BarcodeScannerPickerError(this.error);

  @override
  List<Object?> get props => [error];
}

// face picker from gallery and camera

class FacePickerSuccess extends ImagePickerState {
  final File imageFile;
  final List<Face> faces;
  final ui.Image decodedImage;  // Here, I use ui.Image so the UI can access and repaint the decoded image directly from the Bloc without needing the setState method for painting.
  final String faceLabel;

  const FacePickerSuccess(this.imageFile, this.faces,this.decodedImage,this.faceLabel);

  @override
  List<Object?> get props => [imageFile, faces,decodedImage,faceLabel];
}

class FacePickerError extends ImagePickerState {
  final String error;

  const FacePickerError(this.error);

  @override
  List<Object?> get props => [error];
}

// Object picker from gallery and camera

class ObjectPickerSuccess extends ImagePickerState {
  final File imageFile;
  final List<DetectedObject> detectedObjects;
  final ui.Image decodedImage;  // Here, I use ui.Image so the UI can access and repaint the decoded image directly from the Bloc without needing the setState method for painting.


  const ObjectPickerSuccess(this.imageFile, this.detectedObjects,this.decodedImage );

  @override
  List<Object?> get props => [imageFile, detectedObjects,decodedImage ];
}

class ObjectPickerError extends ImagePickerState {
  final String error;

  const ObjectPickerError(this.error);

  @override
  List<Object?> get props => [error];
}

// image picker from gallery and camera
class TextRecognitionImageSuccess extends ImagePickerState {
  final File imageFile;
  final String imageData;

  const TextRecognitionImageSuccess(this.imageFile, this.imageData);

  @override
  List<Object?> get props => [imageFile, imageData];
}

class TextRecognitionImageError extends ImagePickerState {
  final String error;

  const TextRecognitionImageError(this.error);

  @override
  List<Object?> get props => [error];
}

// image picker from gallery and camera
class PoseImagePickedSuccess extends ImagePickerState {
  final File imageFile;
  final List<Pose> poses;
  final ui.Image uiImage;

  const PoseImagePickedSuccess(this.imageFile, this.poses,this.uiImage);

  @override
  List<Object?> get props => [imageFile, poses,uiImage];
}

class PoseImagePickedError extends ImagePickerState {
  final String error;

  const PoseImagePickedError(this.error);

  @override
  List<Object?> get props => [error];
}