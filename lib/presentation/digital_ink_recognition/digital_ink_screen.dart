import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/digital_ink_recognition/digital_ink_recognition_bloc.dart';
import 'package:flutter_ai_ml/bloc/digital_ink_recognition/digital_ink_recognition_event.dart';
import 'package:flutter_ai_ml/bloc/digital_ink_recognition/digital_ink_recognition_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_button.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DigitalInkScreen extends StatefulWidget {
  const DigitalInkScreen({super.key});

  @override
  State<DigitalInkScreen> createState() => _DigitalInkScreenState();
}

class _DigitalInkScreenState extends State<DigitalInkScreen> {
  Stroke convertOffsetsToStroke(List<Offset> points) {
    int base = DateTime.now().millisecondsSinceEpoch;
    return Stroke()
      ..points = points.map((p) {
        return StrokePoint(x: p.dx, y: p.dy, t: base++);
      }).toList();
  }
  final TextEditingController searchLanguageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DigitalInkBloc()..add(InitializeInkModelEvent(enUS)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Digital Ink Recognition")),
        body: BlocBuilder<DigitalInkBloc, DigitalInkState>(
          builder: (context, state) {
            final bloc = context.read<DigitalInkBloc>();
            List<Stroke> strokes = [];
            List<Offset> currentStroke = [];

            if (state is DigitalInkDrawing) {
              strokes = state.allStrokes;
              currentStroke = state.currentStroke;
            } else if (state is DigitalInkRecognized) {
              strokes = state.allStrokes;
              currentStroke = state.currentStroke;
            }
            return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 2.h,horizontal: 2.w),
              child: Column(
                children: [
                  SizedBox(height: 1.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2.h)
                    ),
                    height: 50.h,
                    child: GestureDetector(
                      onPanStart: (details) {
                        bloc.add(UpdateCurrentStrokeEvent([details.localPosition]));
                      },
                      onPanUpdate: (details) {
                        final newPoints = List<Offset>.from(currentStroke)
                          ..add(details.localPosition);
                        bloc.add(UpdateCurrentStrokeEvent(newPoints));
                      },
                      onPanEnd: (details) {
                        if (currentStroke.isNotEmpty) {
                          final stroke = convertOffsetsToStroke(currentStroke);
                          bloc.add(AddStrokeEvent(stroke));
                        }
                      },
                      child: CustomPaint(
                        painter: InkPainter(strokes, currentStroke),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        onPressed: () {
                          bloc.add(RecognizeInkEvent());
                        },
                        text: recognize,
                      ),
                      CustomButton(
                        onPressed: () {
                          bloc.add(ClearInkEvent());
                        },
                        text: clear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state is DigitalInkLoading) const CircularProgressIndicator(),
                  if (state is DigitalInkRecognized)
                    ...state.candidates.map(
                          (e) => CustomText(e.text),
                    ),
                  if (state is DigitalInkError)
                    Text(state.error, style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class InkPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Offset> current;

  InkPainter(this.strokes, this.current);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = Offset(stroke.points[i].x, stroke.points[i].y);
        final p2 = Offset(stroke.points[i + 1].x, stroke.points[i + 1].y);
        canvas.drawLine(p1, p2, paint);
      }
    }

    for (int i = 0; i < current.length - 1; i++) {
      canvas.drawLine(current[i], current[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
