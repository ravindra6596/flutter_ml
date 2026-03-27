import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_ml/main.dart';
import 'package:flutter_ai_ml/model/image_data.dart';
import 'package:flutter_ai_ml/utils/assets_file.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Functions {
  late ImageLabeler imageLabeler;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);

  final orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // get image from camera and convert it
  InputImage? inputImageFromCameraImage(CameraImage image, CameraController cameraController,int cameraIndex) {
    // Use a single, consistent camera description
    final camera = cameras[cameraIndex];
    if (!cameraController.value.isInitialized) {
      return null;
    }

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    // Determine the rotation based on platform
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final deviceOrientation = cameraController.value.deviceOrientation;
      var rotationCompensation = orientations[deviceOrientation];

      if (rotationCompensation == null) {
        return null;
      }

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }

      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) {
      return null;
    }

    // Handle the specific YUV420_888 format conversion on Android
    if (Platform.isAndroid && image.format.raw == 35) {
      final nv21Bytes = convertYUV420toNV21(image);
      return InputImage.fromBytes(
        bytes: nv21Bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    }

    // Handle iOS and other formats
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      dev.log('Unsupported image format: ${image.format.raw}');
      return null;
    }

    final allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    dev.log('inputImage $bytes');
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }


  /// Helper function to convert a YUV420_888 CameraImage to NV21 format.
  Uint8List convertYUV420toNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    // Get image planes
    final Uint8List y = image.planes[0].bytes;
    final Uint8List u = image.planes[1].bytes;
    final Uint8List v = image.planes[2].bytes;
    final Uint8List nv21 = Uint8List(width * height * 3 ~/ 2);
    final int yLen = y.length;
    nv21.setRange(0, yLen, y);
    int uvIndex = yLen;
    for (int i = 0; i < u.length; i += uvPixelStride) {
      nv21[uvIndex++] = v[i];
      nv21[uvIndex++] = u[i];
    }
    return nv21;
  }

  // get image labels from gallery and camera
  /*getCameraImageLabels(InputImage inputImage) async {
    final options = ImageLabelerOptions(confidenceThreshold: 0.6);
    imageLabeler = ImageLabeler(options: options);
    final labels = await imageLabeler.processImage(inputImage);
    await imageLabeler.close();
    // object name
    final modelPath = await Functions().getModelPath(mobileNet);
    final optionsData = LocalLabelerOptions(modelPath: modelPath);
    imageLabeler = ImageLabeler(options: optionsData);
    final imageData = await imageLabeler.processImage(inputImage);
    dev.log('optionsData ${imageData.map((e) => e.label,)}');
    if (labels.isEmpty) return 'No labels detected';

    return labels
        .map((label) =>
    '${label.label} - ${label.confidence.toStringAsFixed(2)}')
        .join('\n');
  }*/

  Future<ImageLabelsResult> getCameraImageLabels(InputImage inputImage) async {
    // Default model
    final defaultOptions = ImageLabelerOptions(confidenceThreshold: 0.6);
    imageLabeler = ImageLabeler(options: defaultOptions);
    dev.log('defaultOptions ${defaultOptions.confidenceThreshold}');
    final defaultLabels = await imageLabeler.processImage(inputImage);
    await imageLabeler.close();

    // Custom model
    final modelPath = await getModelPath(mobileNet);
    final customOptions = LocalLabelerOptions(modelPath: modelPath);
    imageLabeler = ImageLabeler(options: customOptions);
    final modelLabels = await imageLabeler.processImage(inputImage);
    await imageLabeler.close();

    final defaultStr = defaultLabels.isEmpty
        ? 'No default labels found.'
        : defaultLabels
        .map((e) => '${e.label} - ${e.confidence.toStringAsFixed(2)}')
        .join('\n');

    final modelStr = modelLabels.isEmpty
        ? ''
        : modelLabels
        .map((e){
      dev.log('Title Model ${e.confidence.toStringAsFixed(2)}');
      return '${e.label} - ${e.confidence.toStringAsFixed(2)}';
    })
        .join('\n');

    return ImageLabelsResult(
      defaultLabels: defaultStr,
      modelLabels: modelStr,
    );
  }



  // get barcode labels from gallery and camera
  getBarcodeLabels(InputImage inputImage) async {
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    final barcodeScanner = BarcodeScanner(formats: formats);
     final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

    String result = '';
    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      // final Rect boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;

      // See API reference for complete list of supported types
      switch (type) {
        case BarcodeType.wifi:
          final barcodeWifi = barcode.value as BarcodeWifi;
          result = 'Wi-Fi: ${barcodeWifi.ssid} ${barcodeWifi.password}';
          break;

        case BarcodeType.url:
          final barcodeUrl = barcode.value as BarcodeUrl;
          result =  'URL: ${barcodeUrl.url}';
          break;

        case BarcodeType.email:
          final barcodeEmail = barcode.value as BarcodeEmail;
          result = 'Email: ${barcodeEmail.address ?? ''}';
          break;

        case BarcodeType.phone:
          final barcodePhone = barcode.value as BarcodePhone;
          result = 'Phone: ${barcodePhone.number ?? ''}';
          break;

        case BarcodeType.sms:
          final barcodeSms = barcode.value as BarcodeSMS;
          result = 'SMS: ${barcodeSms.message ?? ''}';
          break;

        case BarcodeType.text:
          final barcodeText = barcode.value as String?;
          result = 'Text: ${barcodeText ?? 'N/A'}';
          break;

        case BarcodeType.contactInfo:
          final contact = barcode.value as BarcodeContactInfo;
          String email = '';
          email = contact.emails.map((email) =>
          '${email.address} - ${email.subject} ${email.body} - ${email.type}').join('\t');
          String phoneNumber = '';
          phoneNumber = contact.phoneNumbers.map((phone) => '${phone.number} ${phone.type}').join('');
          String address = '';
          address = contact.addresses.map((add) => add.addressLines.first,).join(',');
          result = 'Contact: \n${contact.firstName ?? ''} ${contact.lastName ?? ''}\n'
              '${contact.organizationName ?? ''} \n$phoneNumber\n'
              '$email ${contact.prefix ?? ''}\n$address'
              '\nURL: ${contact.urls.first ?? ''}';
          break;

        case BarcodeType.geoCoordinates:
          final geo = barcode.value as BarcodeGeoPoint;
          result = 'Geo Coordinates: ${geo.latitude}, ${geo.longitude}';
          break;

        case BarcodeType.calendarEvent:
          final event = barcode.value as BarcodeCalenderEvent;
          result = 'Event: ${event.summary ?? ''}';
          break;

        case BarcodeType.driverLicense:
          final license = barcode.value as BarcodeDriverLicense;
          result = 'License: ${license.licenseNumber ?? ''}';
          break;

        case BarcodeType.isbn:
        case BarcodeType.product:
          result = 'Code: ${barcode.rawValue ?? ''}';
          break;

        case BarcodeType.unknown:
          result = 'Unknown type';
          break;
      }
    }
    await barcodeScanner.close();

    if (barcodes.isEmpty) return 'No labels detected';

    return result;
  }

  // get face image from gallery and camera
  Future<FaceDetectionResult> getFaceImage(InputImage inputImage) async {
    final options = FaceDetectorOptions(enableLandmarks: true,enableClassification: true,enableContours: true,enableTracking: true);
    final faceDetector = FaceDetector(options: options);
    final faces = await faceDetector.processImage(inputImage);
    String faceLabel = '';
    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      final double? rotX = face.headEulerAngleX; // Head is tilted up and down rotX degrees
      final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
      final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
      if (leftEar != null) {
        final Point<int> leftEarPos = leftEar.position;
      }

      // If classification was enabled with FaceDetectorOptions:
      if (face.smilingProbability != null) {
        final double smileProb = face.smilingProbability!;
        dev.log('Face Probability: $smileProb');
        if (smileProb > 0.8) {
          faceLabel = 'Smiling';
        } else if (smileProb > 0.4) {
          faceLabel = 'Serious';
        } else if (smileProb > 0.5) {
          faceLabel = 'Angry';
        } else {
          faceLabel = 'Sad';
        }
      }


      // If face tracking was enabled with FaceDetectorOptions:
      if (face.trackingId != null) {
        final int? id = face.trackingId;
      }
          }
    await faceDetector.close();
    return FaceDetectionResult(faces: faces, faceLabel: faceLabel);
  }

  drawRectangleAroundImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = await decodeImageFromList(bytes);
    return decoded;
  }

  getObjectImage(InputImage inputImage) async {
    final modelPath = await getModelPath(objectLabeler);
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.single,  // use single for static image
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
      confidenceThreshold: 0.25,  // tune this
      maximumLabelsPerObject: 3,
    );
    // Configure object detector options
    final options1 = ObjectDetectorOptions(
      classifyObjects: true,
      mode: DetectionMode.single,
      multipleObjects: true,
    );

    // Create the detector
    final objectDetector = ObjectDetector(options: options);

    try {
      // Process the input image to detect objects
      final List<DetectedObject> objects = await objectDetector.processImage(inputImage);
      dev.log('No labels found for this object');
      // Log detected labels for debugging
      for (DetectedObject detectedObject in objects) {
        final rect = detectedObject.boundingBox;
        final trackingId = detectedObject.trackingId;
        if (detectedObject.labels.isEmpty) {
          dev.log('No labels found for this object');
        } else {
          for (Label label in detectedObject.labels) {
            dev.log('Object detected: ${label.text} with confidence: ${label.confidence}');

          }
        }
      }

      return objects;
    } finally {
      await objectDetector.close();
    }
  }

  /*Future<ObjectDetectionResult> getObjectImage(InputImage inputImage) async {
    // Default detector
    final defaultOptions = ObjectDetectorOptions(
      classifyObjects: true,
      mode: DetectionMode.single,
      multipleObjects: true,
    );
    final defaultDetector = ObjectDetector(options: defaultOptions);
    final defaultObjects = await defaultDetector.processImage(inputImage);
    await defaultDetector.close();

    // Custom local model
    final modelPath = await getModelPath(objectLabeler);
    final customOptions = LocalObjectDetectorOptions(
      mode: DetectionMode.single,  // use single for static image
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
      confidenceThreshold: 0.25,  // tune this
      maximumLabelsPerObject: 3,
    );
    final customDetector = ObjectDetector(options: customOptions);
    final modelObjects = await customDetector.processImage(inputImage);
    await customDetector.close();

    dev.log('defaultObjects count = ${defaultObjects.length}');
    for (var obj in defaultObjects) {
      dev.log('default bbox: ${obj.boundingBox}, labels: ${obj.labels.map((e) => e.text)}');
    }

    dev.log('modelObjects count = ${modelObjects.length}');
    for (var obj in modelObjects) {
      dev.log('model bbox: ${obj.boundingBox}, labels: ${obj.labels.map((e) => e.text)}');
    }

    return ObjectDetectionResult(
      defaultObjects: defaultObjects,
      modelObjects: modelObjects,
    );
  }
*/

  // get object labels models
  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  // get text recognition from image and camera file
  // get image labels from gallery and camera
  getTextFromCameraImage(InputImage inputImage) async {
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    await textRecognizer.close();
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
    return text;
  }

  // get image labels from gallery and camera
 getPoseCameraImageLabels(InputImage inputImage) async {
    final options = PoseDetectorOptions(mode: PoseDetectionMode.single);
    final poseDetector = PoseDetector(options: options);
    final List<Pose> poses = await poseDetector.processImage(inputImage);
    await poseDetector.close();

    return poses; // ✅ Always return a list (even if empty)
  }

  Future<ui.Image>  convertToUiImage(File file) async {
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

}

class FaceDetectionResult {
  late final List<Face> faces;
  late final String faceLabel;

  FaceDetectionResult({
    required this.faces,
    required this.faceLabel,
  });
}
