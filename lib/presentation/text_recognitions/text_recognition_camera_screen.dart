import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_bloc.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_event.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/presentation/text_recognitions/text_recognitions_picker_screen.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


class TextRecognitionCameraScreen extends StatefulWidget {
  const TextRecognitionCameraScreen({super.key});

  @override
  State<TextRecognitionCameraScreen> createState() =>
      _TextRecognitionCameraScreenState();
}

class _TextRecognitionCameraScreenState extends State<TextRecognitionCameraScreen> {
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
      appBar: CustomAppBar(title: textRecognitionsText),
      body: BlocProvider(
        create: (context) => cameraBloc..add(InitializeTextCamera(0)),
        child: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            if (state is CameraLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CameraTextLoadedState) {
              cameraController = state.controller;
              return Stack(
                children: [
                  CameraPreview(state.controller),
                  Positioned(
                    left: 0,
                    top: 0,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 250,
                    /*child: Container(
                    color: Colors.black12,
                        child: CustomText(state.recognizedText.text,color: Colors.white,),
                    ),*/
                    child: CustomPaint(
                      painter: TextRecognitionPainter(
                          state.controller.value.previewSize!,
                          state.recognizedText),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 20,
                    child: IconButton(
                      onPressed: () {
                        final newIndex = state.currentTextCameraIndex == 0 ? 1 : 0;
                        cameraBloc.add(InitializeTextCamera(newIndex));
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
                            builder: (context) => TextRecognitionsPickerScreen(),
                          ),
                        ).then((value) {
                          cameraBloc.add(InitializeTextCamera(0));
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
}

class TextRecognitionPainter extends CustomPainter {
  TextRecognitionPainter(this.absoluteImageSize, this.recognizedText);

  final Size absoluteImageSize;
  final RecognizedText recognizedText;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.brown;

    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      /*canvas.drawRect(
        Rect.fromLTRB(
          block.boundingBox.left * scaleX,
          block.boundingBox.top * scaleY,
          block.boundingBox.right * scaleX,
          block.boundingBox.bottom * scaleY,
        ),
        paint,
      );*/

      TextSpan span = TextSpan(
          text: block.text,
          style: const TextStyle(fontSize: 20, color: Colors.white));
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(block.boundingBox.left * scaleX, block.boundingBox.top * scaleY));

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
  }

  @override
  bool shouldRepaint(TextRecognitionPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.recognizedText != recognizedText;
  }
}