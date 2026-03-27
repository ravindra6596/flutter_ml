import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_bloc.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_event.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'face_detection_image_screen.dart';

class FaceDetectionCameraScreen extends StatefulWidget {
  const FaceDetectionCameraScreen({super.key});

  @override
  State<FaceDetectionCameraScreen> createState() =>
      _FaceDetectionCameraScreenState();
}

class _FaceDetectionCameraScreenState extends State<FaceDetectionCameraScreen> {
  late CameraController cameraController;
  CameraImage? imageFiles;
  final String faceLabel = '';
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  List<Face> faces = [];

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
      appBar: CustomAppBar(title: faceDetectionText),
      body: BlocProvider(
        create: (context) => cameraBloc..add(InitializeCameraFace(1)),
        child: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            if (state is CameraLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CameraFaceLoadedState) {
              cameraController = state.controller;
              faces = state.faces;
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
                    left: 20,
                    top: 20,
                    child: Container(
                      color: Colors.black12,
                      child: CustomText(
                        state.faceLabel,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 20,
                    child: IconButton(
                      onPressed: () {
                        final newIndex = state.currentFaceCameraIndex == 0 ? 1 : 0;
                        cameraBloc.add(InitializeCameraFace(newIndex));
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
                            builder: (context) => FaceDetectionImageScreen(),
                          ),
                        ).then((value) => cameraBloc.add(InitializeCameraFace(0)),
                        );
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
    if (faces == null ||
        cameraController == null ||
        !cameraController.value.isInitialized) {
      return Text('');
    }

    final Size imageSize = Size(
      cameraController.value.previewSize!.height,
      cameraController.value.previewSize!.width,
    );
    CustomPainter painter =
        FaceDetectorPainter(imageSize, faces, cameraLensDirection);
    return CustomPaint(
      painter: painter,
    );
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
      this.absoluteImageSize, this.faces, this.cameraLensDirection);

  final Size absoluteImageSize;
  final List<Face> faces;
  CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          cameraLensDirection == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.right) * scaleX
              : face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          cameraLensDirection == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.left) * scaleX
              : face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY,
        ),
        paint,
      );
    }

    Paint p2 = Paint();
    p2.color = Colors.green;
    p2.style = PaintingStyle.stroke;
    p2.strokeWidth = 5;

    for (Face face in faces) {
      Map<FaceContourType, FaceContour?> con = face.contours;
      List<Offset> offsetPoints = <Offset>[];
      con.forEach((key, value) {
        if (value != null) {
          List<Point<int>>? points = value.points;
          for (Point p in points) {
            Offset offset = Offset(
                cameraLensDirection == CameraLensDirection.front
                    ? (absoluteImageSize.width - p.x.toDouble()) * scaleX
                    : p.x.toDouble() * scaleX,
                p.y.toDouble() * scaleY);
            offsetPoints.add(offset);
          }
          canvas.drawPoints(PointMode.points, offsetPoints, p2);
        }
      });
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}
