import 'dart:io';

import 'package:flutter_ai_ml/utils/functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picker_event.dart';
import 'image_picker_state.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  ImagePicker imagePicker = ImagePicker();
  late ImageLabeler imageLabeler;

  ImagePickerBloc() : super(ImageInitial()) {
    on<PickImageEvent>(chooseImageFromGallery); // image from gallery
    on<PickCameraImageEvent>(chooseImageFromCamera);  // image from camera
    on<PickBarcodeEvent>(chooseBarcodeFromGallery); // barcode from gallery
    on<PickCameraBarcodeEvent>(chooseBarcodeFromCamera);  // barcode from camera
    on<PickFaceImageEvent>(chooseFaceFromGallery);  // face from gallery
    on<PickFaceCameraEvent>(chooseFaceFromCamera);  // face from camera
    on<PickObjectImageEvent>(chooseObjectFromGallery);  // object from gallery
    on<PickObjectCameraEvent>(chooseObjectFromCamera);  // object from camera
    on<PickTextRecognitionImageEvent>(chooseTextImageFromGallery);  // text from image
    on<PickTextRecognitionCameraEvent>(chooseTextImageFromCamera);  // text from camera
    on<PickPoseImageEvent>(choosePoseImageFromGallery);  // pose from image
    on<PickPoseCameraEvent>(choosePoseImageFromCamera);  // pose from camera
  }

  // gallery image
  chooseImageFromGallery(PickImageEvent event, emit) async {
    try {
      final XFile? selectedImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
       if (selectedImage != null) {
        final file = File(selectedImage.path);
        // final labelData = await getLabels(file);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getCameraImageLabels(inputImage);
        emit(ImagePickedSuccess(file, labelData.defaultLabels,labelData.modelLabels));
      } else {
        emit(const ImagePickedError('No image selected.'));
      }
    } catch (e) {
      emit(ImagePickedError(e.toString()));
    }
  }

  // camera image
  chooseImageFromCamera(PickCameraImageEvent event, emit) async {
    try {
      final XFile? selectedImage =
          await imagePicker.pickImage(source: ImageSource.camera);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        // final labelData = await getLabels(file);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getCameraImageLabels(inputImage);
        emit(ImagePickedSuccess(file, labelData.defaultLabels,labelData.modelLabels));
      } else {
        emit(const ImagePickedError('No image selected.'));
      }
    } catch (e) {
      emit(ImagePickedError(e.toString()));
    }
  }

  // gallery barcode
  chooseBarcodeFromGallery(PickBarcodeEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getBarcodeLabels(inputImage);
        emit(BarcodeScannerPickerSuccess(file, labelData));
      } else {
        emit(const BarcodeScannerPickerError('No image selected.'));
      }
    } catch (e) {
      emit(BarcodeScannerPickerError(e.toString()));
    }
  }

  // camera barcode
  chooseBarcodeFromCamera(PickCameraBarcodeEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.camera);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getBarcodeLabels(inputImage);
        emit(BarcodeScannerPickerSuccess(file, labelData));
      } else {
        emit(const BarcodeScannerPickerError('No image selected.'));
      }
    } catch (e) {
      emit(BarcodeScannerPickerError(e.toString()));
    }
  }


  // gallery face
  chooseFaceFromGallery(PickFaceImageEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        final inputImage = InputImage.fromFile(file);
        final faceResult = await Functions().getFaceImage(inputImage);
        final uiImage = await Functions().drawRectangleAroundImage(file);
        emit(FacePickerSuccess(file,faceResult.faces,uiImage,faceResult.faceLabel));
      } else {
        emit(const FacePickerError('No face selected.'));
      }
    } catch (e) {
      emit(FacePickerError(e.toString()));
    }
  }

  // camera face
  chooseFaceFromCamera(PickFaceCameraEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.camera);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        final inputImage = InputImage.fromFile(file);
        final faceResult = await Functions().getFaceImage(inputImage);
        final uiImage = await Functions().drawRectangleAroundImage(file);
        emit(FacePickerSuccess(file,faceResult.faces,uiImage,faceResult.faceLabel));
      } else {
        emit(const FacePickerError('No image selected.'));
      }
    } catch (e) {
      emit(FacePickerError(e.toString()));
    }
  }

  // object gallery image
 chooseObjectFromGallery(PickObjectImageEvent event,emit) async {
    try {
      final XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
      if (selectedImage == null) {
        emit(const ObjectPickerError('No image selected.'));
        return;
      }
      final file = File(selectedImage.path);
      final inputImage = InputImage.fromFile(file);
      final List<DetectedObject> detectedObjects = await Functions().getObjectImage(inputImage);
      final uiImage = await Functions().drawRectangleAroundImage(file);
      emit(ObjectPickerSuccess(file, detectedObjects, uiImage,  ));

    } catch (e) {
      emit(ObjectPickerError(e.toString()));
    }
  }
  // object camera image
 chooseObjectFromCamera(PickObjectCameraEvent event,emit) async {
    try {
      final XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.camera);
      if (selectedImage == null) {
        emit(const ObjectPickerError('No image selected.'));
        return;
      }
      final file = File(selectedImage.path);
      final inputImage = InputImage.fromFile(file);
      final List<DetectedObject> detectedObjects = await Functions().getObjectImage(inputImage);
      final uiImage = await Functions().drawRectangleAroundImage(file);
      emit(ObjectPickerSuccess(file, detectedObjects, uiImage));

    } catch (e) {
      emit(ObjectPickerError(e.toString()));
    }
  }


  // text recognition gallery image
  chooseTextImageFromGallery(PickTextRecognitionImageEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        // final labelData = await getLabels(file);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getTextFromCameraImage(inputImage);
        emit(TextRecognitionImageSuccess(file, labelData));
      } else {
        emit(const TextRecognitionImageError('No image selected.'));
      }
    } catch (e) {
      emit(TextRecognitionImageError(e.toString()));
    }
  }

  // text recognition camera image
  chooseTextImageFromCamera(PickTextRecognitionCameraEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.camera);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getTextFromCameraImage(inputImage);
        emit(TextRecognitionImageSuccess(file, labelData));
      } else {
        emit(const TextRecognitionImageError('No image selected.'));
      }
    } catch (e) {
      emit(TextRecognitionImageError(e.toString()));
    }
  }


  // gallery image
  choosePoseImageFromGallery(PickPoseImageEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        // final labelData = await getLabels(file);
        final inputImage = InputImage.fromFile(file);
        List<Pose> poses  = await Functions().getPoseCameraImageLabels(inputImage);
        final uiImage = await  Functions().convertToUiImage(file);
        emit(PoseImagePickedSuccess(file, poses,uiImage));
      } else {
        emit(const PoseImagePickedError('No image selected.'));
      }
    } catch (e) {
      emit(PoseImagePickedError(e.toString()));
    }
  }

  // camera image
  choosePoseImageFromCamera(PickPoseCameraEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.camera);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        final inputImage = InputImage.fromFile(file);
        List<Pose> poses  = await Functions().getPoseCameraImageLabels(inputImage);
        final uiImage = await  Functions().convertToUiImage(file);
        emit(PoseImagePickedSuccess(file, poses,uiImage));
      } else {
        emit(const PoseImagePickedError('No image selected.'));
      }
    } catch (e) {
      emit(PoseImagePickedError(e.toString()));
    }
  }

}
