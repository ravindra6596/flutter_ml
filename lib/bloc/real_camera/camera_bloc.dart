import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_ai_ml/main.dart';
import 'package:flutter_ai_ml/utils/assets_file.dart';
import 'package:flutter_ai_ml/utils/functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? cameraController;
  bool isCameraOpen = false;
  ImageLabeler imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  CameraImage? cameraImage;
  int cameraIndex = 0;
  int barcodeIndex = 0;
  int faceCameraIndex = 0;
  int objectCameraIndex = 0;
  int textCameraIndex = 0;
  int poseCameraIndex = 0;
  FaceDetectionResult? faceResult;
  ObjectDetector  objectDetector = ObjectDetector(options: ObjectDetectorOptions(mode: DetectionMode.stream, classifyObjects: true, multipleObjects: true));
  bool isDetecting = false;
  TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);
  PoseDetector poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));

  CameraBloc()
      : imageLabeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: 0.6),
        ),
        super(CameraInitial()) {
    on<InitializeCamera>(onInitializeCamera); // image from live camera
    on<CameraLabelDetected>(onUpdateCameraLabel);// image data label detected
    on<InitializeBarcode>(onInitializeBarCode);// barcode from live camera
    on<BarcodeLabelDetected>(onUpdateBarcodeLabel); // barcode label
    on<InitializeCameraFace>(onInitializeFaceCamera);// face from live camera
    on<CameraFaceLabelDetected>(onUpdateFaceCameraLabel); // face label
    on<InitializeCameraObject>(onInitializeObjectCamera); // objects from live camera
    on<CameraImageStreamEvent>(onUpdateObjectLabeled); // object labels
    on<InitializeTextCamera>(onInitializeTextRecCamera);// texts from live camera
    on<CameraTextStreamEvent>(onUpdateTextRecLabeled); // text labels
    on<InitializePoseCamera>(onInitializePoseRecCamera);// pose from live camera
    on<CameraPoseStreamEvent>(onUpdatePoseRecLabeled);// pose labels
    on<DisposeCameraEvent>(onDisposeCamera);// dispose camera
  }
// live image & labels
  onInitializeCamera(InitializeCamera event, emit) async {
    emit(CameraLoading());
    try {
      final controller = CameraController(
        cameras[event.cameraIndex],
        ResolutionPreset.high,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      cameraController = controller;
      cameraIndex = event.cameraIndex;
      controller.startImageStream((image) {
        if (!isCameraOpen) {
          isCameraOpen = true;
          processImage(image);
        }
      });

      emit(CameraLoadedState(controller, "",'', event.cameraIndex));
    } catch (e) {
      emit(CameraError("Camera init failed: $e"));
    }
  }

  onUpdateCameraLabel(CameraLabelDetected event, emit) {
    if (state is CameraLoadedState) {
      final currentState = state as CameraLoadedState;
      if (currentState.cameraLabel != event.label) {
        emit(CameraLoadedState(
            currentState.controller, event.label,event.modelLabel, cameraIndex));
      }
    }
    isCameraOpen = false;
  }

  // barcode & labels
  onInitializeBarCode(InitializeBarcode event, emit) async {
    emit(CameraLoading());
    try {
      final controller = CameraController(
        cameras[event.barcodeIndex],
        ResolutionPreset.high,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      cameraController = controller;
      barcodeIndex = event.barcodeIndex;
      controller.startImageStream((image) async {
        if (!isCameraOpen) {
          isCameraOpen = true;
          final inputImage = Functions()
              .inputImageFromCameraImage(image, cameraController!, cameraIndex);
          final labelData = await Functions().getBarcodeLabels(inputImage!);
          add(BarcodeLabelDetected(labelData));
        }
      });

      emit(BarcodeLoadedState(controller, "", event.barcodeIndex));
    } catch (e) {
      emit(CameraError("Camera init failed: $e"));
    }
  }

  onUpdateBarcodeLabel(BarcodeLabelDetected event, emit) {
    if (state is BarcodeLoadedState) {
      final currentState = state as BarcodeLoadedState;
      if (currentState.barcodeLabel != event.label) {
        emit(BarcodeLoadedState(
            currentState.controller, event.label, barcodeIndex));
      }
    }
    isCameraOpen = false;
  }

  // live face detection & labels

  onInitializeFaceCamera(InitializeCameraFace event, emit) async {
    emit(CameraLoading());

    try {
      final controller = CameraController(
        cameras[event.faceCameraIndex],
        ResolutionPreset.high,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      cameraController = controller;
      faceCameraIndex = event.faceCameraIndex;
      controller.startImageStream((image) async {
        if (!isCameraOpen) {
          isCameraOpen = true;
          final inputImage = Functions().inputImageFromCameraImage(
              image, cameraController!, faceCameraIndex);
          final faceResults = await Functions().getFaceImage(inputImage!);
          faceResult = faceResults;
          cameraImage = image;
          log('Face Bloc - ${faceResults.faces.length}');
          if (!isClosed) {
            add(CameraFaceLabelDetected(faceResults.faceLabel, faceResults.faces));
          }
        }
      });
      await emit(
          CameraFaceLoadedState(controller, '', event.faceCameraIndex, []));
    } catch (e) {
      log('Live $e');
      emit(CameraError("Camera init failed: $e"));
    }
  }

  onUpdateFaceCameraLabel(CameraFaceLabelDetected event, emit) {
    if (state is CameraFaceLoadedState) {
      final currentState = state as CameraFaceLoadedState;
      if (currentState.faceLabel != event.label) {
        emit(CameraFaceLoadedState(
          currentState.controller,
          event.label,
          faceCameraIndex,
          faceResult!.faces,
        ));
      }
    }
    isCameraOpen = false;
  }

  // live object detection
   onInitializeObjectCamera(InitializeCameraObject event, emit) async {
    emit(CameraLoading());


    objectCameraIndex = event.objectCameraIndex;
    final modelPath = await Functions().getModelPath(objectLabeler);
    try {
      objectDetector = ObjectDetector(
        options: LocalObjectDetectorOptions(
          mode: DetectionMode.stream,
          classifyObjects: true,
          multipleObjects: true,
          modelPath: modelPath,
        ),
      );

       cameraController = CameraController(
        cameras[objectCameraIndex],
        ResolutionPreset.high,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
      // start image stream
      cameraController!.startImageStream((CameraImage image) {
        if (!isDetecting) {
          isDetecting = true;
          add(CameraImageStreamEvent(image));
        }
      });

      // initial loaded state with no objects
      emit(CameraObjectLoadedState(cameraController!,'',objectCameraIndex,  []));
    } catch (e) {
      emit(CameraError('Camera initialization failed: $e'));
    }
  }

   onUpdateObjectLabeled(CameraImageStreamEvent event,emit) async {
    if (objectDetector == null || cameraController == null) {
      isDetecting = false;
      return;
    }

    try {
      final inputImage = Functions().inputImageFromCameraImage(
        event.image,
        cameraController!,
        objectCameraIndex,
      );
      if (inputImage == null) {
        isDetecting = false;
        return;
      }

      final List<DetectedObject> results = await objectDetector!.processImage(inputImage);

      if (state is CameraObjectLoadedState) {
        final current = state as CameraObjectLoadedState;
        emit(CameraObjectLoadedState( current.controller, current.objectLabel,current.currentFaceCameraIndex, results));
      }

    } catch (e, stack) {
      log('Detection error: $e', error: e, stackTrace: stack);
      // optionally emit error state or just ignore
    } finally {
      isDetecting = false;
    }
  }

  // live text detection & labels
   onInitializeTextRecCamera(InitializeTextCamera event, emit) async {
    emit(CameraLoading());

    textCameraIndex = event.textCameraIndex;
    try {
        cameraController = CameraController(
        cameras[textCameraIndex],
        ResolutionPreset.high,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
      // start text image stream
      cameraController!.startImageStream((CameraImage image) {
        if (!isDetecting) {
          isDetecting = true;
          add(CameraTextStreamEvent(image));
        }
      });
        RecognizedText recognizedText = RecognizedText(text: '', blocks: []);
      // initial loaded state with no text image
      emit(CameraTextLoadedState(cameraController!,textCameraIndex,  recognizedText));
    } catch (e) {
      emit(CameraError('Camera initialization failed: $e'));
    }
  }

   onUpdateTextRecLabeled(CameraTextStreamEvent event,emit) async {
    try {
      final inputImage = Functions().inputImageFromCameraImage(
        event.image,
        cameraController!,
        textCameraIndex,
      );
      if (inputImage == null) {
        isDetecting = false;
        return;
      }

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      if (state is CameraTextLoadedState) {
        final current = state as CameraTextLoadedState;
        emit(CameraTextLoadedState( current.controller, current.currentTextCameraIndex, recognizedText));
      }

    } catch (e) {
      emit(CameraError(e.toString()));
    } finally {
      isDetecting = false;
    }
  }


  // live pose detection & labels
  onInitializePoseRecCamera(InitializePoseCamera event, emit) async {
    emit(CameraLoading());

    try {
    poseCameraIndex = event.poseCameraIndex;
      final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
      poseDetector = PoseDetector(options: options);

      cameraController = CameraController(cameras[poseCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,);
      await cameraController!.initialize();

      await cameraController!.startImageStream((image) {
        if (!isDetecting) {
           isDetecting = true;
           add(CameraPoseStreamEvent(image));
         }
      });

      emit(CameraPoseLoadedState(cameraController!,poseCameraIndex,[]));
    } catch (e) {
      log("Failed to initialize camera: $e");
      emit(CameraError("Failed to initialize camera: $e"));
    }
  }

  onUpdatePoseRecLabeled(CameraPoseStreamEvent event, emit) async {
    try {
      if (cameraController == null || !cameraController!.value.isInitialized) {
        return;
      }

      final inputImage = Functions().inputImageFromCameraImage(
        event.image,
        cameraController!,
        poseCameraIndex,
      );

      if (inputImage == null) {
        isDetecting = false;
        return;
      }

       final List<Pose> poses = await Functions().getPoseCameraImageLabels(inputImage);
      if (state is CameraPoseLoadedState) {
        final current = state as CameraPoseLoadedState;
      emit(CameraPoseLoadedState(current.controller, current.currentPoseCameraIndex, poses));
        }
    } catch (e) {
      log("Pose detection failed: $e");
      emit(CameraError("Pose detection failed: $e"));
    } finally {
      isDetecting = false;
    }
  }
 // dispose camera
  onDisposeCamera(DisposeCameraEvent event, emit)async{
    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
    }
    emit(CameraInitial());
  }

  // image labels
  Future<void> processImage(CameraImage image) async {
    final inputImage = Functions().inputImageFromCameraImage(
      image,
      cameraController!,
      cameraIndex,
    );

    if (inputImage == null) {
      log("InputImage is null");
      isCameraOpen = false;
      return;
    }

    try {
      // Process default labels
      final defaultOptions = ImageLabelerOptions(confidenceThreshold: 0.6);
      final defaultLabeler = ImageLabeler(options: defaultOptions);
      final labels = await defaultLabeler.processImage(inputImage);
      await defaultLabeler.close();

      if (labels.isEmpty) {
        isCameraOpen = false;
        return;
      }

      // Process custom model labels
      final modelPath = await Functions().getModelPath(mobileNet);
      final customOptions = LocalLabelerOptions(modelPath: modelPath);
      final customLabeler = ImageLabeler(options: customOptions);
      final modelLabels = await customLabeler.processImage(inputImage);
      await customLabeler.close();

      // Format default labels text
      final labelText = labels
          .map((e) => '${e.label}   ${e.confidence.toStringAsFixed(2)}')
          .join('\n');

      // Format custom model labels text
      final modelData = modelLabels.isEmpty
          ? ''
          : modelLabels
          .map((e) => '${e.label} - ${e.confidence.toStringAsFixed(2)}')
          .join('\n');
      add(CameraLabelDetected(labelText, modelData));
    } catch (e) {
      log("Image processing failed: $e");
    }
  }

  // dispose controllers
  @override
  Future<void> close() {
    cameraController?.dispose();
    imageLabeler.close();
    poseDetector.close();
    objectDetector.close();
    textRecognizer.close();
    return super.close();
  }
}
