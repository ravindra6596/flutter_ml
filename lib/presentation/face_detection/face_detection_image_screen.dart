// ignore_for_file: must_be_immutable
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_bloc.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_event.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_state.dart';
import 'package:flutter_ai_ml/custom_widgets/back_button_widget.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FaceDetectionImageScreen extends StatefulWidget {
  const FaceDetectionImageScreen({super.key });


  @override
  State<FaceDetectionImageScreen> createState() =>
      _FaceDetectionImageScreenState();
}

class _FaceDetectionImageScreenState extends State<FaceDetectionImageScreen> {
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: faceDetectionText,
        leading: BackButtonWidget(),
      ),
      body: Center(
        child: BlocProvider(
          create: (context) => ImagePickerBloc(),
          child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  children: [
                    if (state is ImageInitial) ...[
                      Icon(
                        Icons.face,
                        size: 20.h,
                      )
                    ],
                    ElevatedButton(
                      onPressed: () {
                        context.read<ImagePickerBloc>().add(PickFaceImageEvent());
                      },
                      child: CustomText(fileFaceText),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ImagePickerBloc>().add(PickFaceCameraEvent());
                      },
                      child: CustomText(cameraImageText),
                    ),
                    SizedBox(height: 1.h),
                    if (state is FacePickerSuccess) ...[
                      FittedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1.h),
                          child: SizedBox(
                            width: state.decodedImage.width.toDouble(),
                            height: state.decodedImage.height.toDouble(),
                            child: CustomPaint(
                              painter: FaceRectPainter(state.faces, state.decodedImage),
                             /* child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1.h),
                                  image: DecorationImage(
                                    image: FileImage(state.imageFile),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),*/
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CustomText(state.faceLabel),
                    ] else if (state is FacePickerError) ...[
                      CustomText('Error: ${state.error}', maxLines: 5),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FaceRectPainter extends CustomPainter {
  List<Face> faceList = [];
  dynamic imageFaceSize;

  FaceRectPainter(this.faceList, this.imageFaceSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFaceSize != null) {
      canvas.drawImage(imageFaceSize, Offset.zero, Paint());
    }
    Paint paintRect = Paint();
    paintRect.color = Colors.red;
    paintRect.strokeWidth = 2;
    paintRect.style = PaintingStyle.stroke;

    for (Face face in faceList) {
      canvas.drawRect(face.boundingBox, paintRect);
    }

    Paint paintFaceControl = Paint();
    paintFaceControl.color = Colors.green;
    paintFaceControl.strokeWidth = 4;
    paintFaceControl.style = PaintingStyle.stroke;

    Paint paintFaceControls = Paint();
    paintFaceControls.color = Colors.yellow;
    paintFaceControls.strokeWidth = 4;
    paintFaceControls.style = PaintingStyle.stroke;

    for (Face face in faceList) {
      Map<FaceContourType, FaceContour?> contours = face.contours;
      List<Offset> offsetPoints = <Offset>[];
      contours.forEach(
        (key, value) {
          List<Point<int>>? points = value?.points;
          for (Point point in points! ) {
            Offset offset = Offset(point.x.toDouble(), point.y.toDouble());
            offsetPoints.add(offset);
          }
          canvas.drawPoints(PointMode.points, offsetPoints, paintFaceControl);
        },
      );
      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      /*final FaceLandmark leftEar = face.landmarks[FaceLandmarkType.leftEar]!;
      if (leftEar != null) {
        final Point<int> leftEarPos = leftEar.position;
        canvas.drawRect(
            Rect.fromLTWH(leftEarPos.x.toDouble() - 5, leftEarPos.y.toDouble() - 5, 10, 10),
            paintFaceControls);
      }*/
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}