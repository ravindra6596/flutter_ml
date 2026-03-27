import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_bloc.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_event.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/presentation/object_detection/object_picker_screen.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';


class ObjectDetectionCameraScreen extends StatefulWidget {
  const ObjectDetectionCameraScreen({super.key});

  @override
  State<ObjectDetectionCameraScreen> createState() =>
      _ObjectDetectionCameraScreenState();
}

class _ObjectDetectionCameraScreenState extends State<ObjectDetectionCameraScreen> {
  late CameraController cameraController;
  CameraImage? imageFiles;
  final String faceLabel = '';
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;

  List<DetectedObject> detectedObjects = [];
  CameraBloc cameraBloc = CameraBloc();
  @override
  void initState() {
    super.initState();
    cameraBloc = CameraBloc();
  }
  @override
  void dispose() {
    cameraBloc.add(DisposeCameraEvent());
    cameraBloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: objectDetectorText),
      body: BlocProvider(
        create: (context) => cameraBloc..add(InitializeCameraObject(0)),
        child: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            if (state is CameraLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CameraObjectLoadedState) {
              cameraController = state.controller;
              detectedObjects = state.detectedObjects;
              return Stack(
                children: [
                  CameraPreview(state.controller),
                  Positioned(
                    left: 0,
                    top: 0,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 250,
                    child: drawRectAroundFace(),
                  ),
                  Positioned(
                    right: 10,
                    top: 20,
                    child: IconButton(
                      onPressed: () {
                        final newIndex = state.currentFaceCameraIndex == 0 ? 1 : 0;
                        cameraBloc.add(InitializeCameraObject(newIndex));
                      },
                      icon: Icon(
                        Icons.flip_camera_android_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ObjectPickerScreen(),
                          ),
                        ).then((value) {
                          cameraBloc.add(InitializeCameraObject(0));
                        },);
                        cameraBloc.add(DisposeCameraEvent());
                        cameraController.stopImageStream();
                        cameraController.dispose();
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is CameraError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget drawRectAroundFace() {
    if (detectedObjects == null || cameraController == null ||
        !cameraController.value.isInitialized) {
      return Text('');
    }

    final Size imageSize = Size(
      cameraController.value.previewSize!.height,
      cameraController.value.previewSize!.width,
    );
    CustomPainter painter =  ObjectDetectorPainter(imageSize, detectedObjects);
    return CustomPaint(
      painter: painter,
    );
  }
}


class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(this.absoluteImageSize, this.objects);

  final Size absoluteImageSize;
  final List<DetectedObject> objects;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green;

    for (DetectedObject detectedObject in objects) {
      canvas.drawRect(
        Rect.fromLTRB(
          detectedObject.boundingBox.left * scaleX,
          detectedObject.boundingBox.top * scaleY,
          detectedObject.boundingBox.right * scaleX,
          detectedObject.boundingBox.bottom * scaleY,
        ),
        paint,
      );

      var list = detectedObject.labels;
      for (Label label in list) {
        log("Object labels - ${label.text}   ${label.confidence.toStringAsFixed(2)}");
        TextSpan span = TextSpan(
            text: label.text,
            style: const TextStyle(fontSize: 25, color: Colors.blue));
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(
            canvas,
            Offset(detectedObject.boundingBox.left * scaleX,
                detectedObject.boundingBox.top * scaleY));
        break;
      }
    }
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.objects != objects;
  }
}

