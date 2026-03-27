import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_bloc.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_event.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_state.dart';
import 'package:flutter_ai_ml/custom_widgets/back_button_widget.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PoseEstimationImagePickerScreen extends StatefulWidget {
  const PoseEstimationImagePickerScreen({super.key});

  @override
  State<PoseEstimationImagePickerScreen> createState() => _PoseEstimationImagePickerScreenState();
}

class _PoseEstimationImagePickerScreenState extends State<PoseEstimationImagePickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: poseEstimation,leading: BackButtonWidget(),),
      body: Center(
        child: BlocProvider(
                create: (context) => ImagePickerBloc(),
                child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Column(
                        children: [
                          if(state is ImageInitial)...[
                            Icon(Icons.image,size: 20.h,)
                          ],
                          ElevatedButton(
                            onPressed: () {
                              context.read<ImagePickerBloc>().add(PickPoseImageEvent());
                            },
                            child: CustomText(fileImageText),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ImagePickerBloc>().add(PickPoseCameraEvent());
                            },
                            child: CustomText(cameraImageText),
                          ),
                          SizedBox(height: 1.h),
                          if (state is PoseImagePickedSuccess) ...[
                            FittedBox(
                              child: SizedBox(
                                width: state.uiImage.width.toDouble(),
                                height: state.uiImage.height.toDouble(),
                                child: CustomPaint(
                                  painter: PosePainter(state.poses, state.uiImage),
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                          ]
                          else if (state is PoseImagePickedError) ...[
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
class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.imageFile);

  final List<Pose> poses;
  var imageFile;


  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses)
    {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              landmark.x,
              landmark.y
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(joint1.x, joint1.y),
            Offset(joint2.x, joint2.y),
            paintType,
        );
      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}