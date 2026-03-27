import 'dart:ui';

import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

abstract class DigitalInkState {}

class DigitalInkInitial extends DigitalInkState {}

class DigitalInkLoading extends DigitalInkState {}

class DigitalInkDrawing extends DigitalInkState {
  final List<Stroke> allStrokes;
  final List<Offset> currentStroke;

  DigitalInkDrawing({
    required this.allStrokes,
    required this.currentStroke,
  });
}

class DigitalInkRecognized extends DigitalInkState {
  final List<RecognitionCandidate> candidates;
  final List<Stroke> allStrokes;
  final List<Offset> currentStroke;

  DigitalInkRecognized(this.candidates, {required this.allStrokes, required this.currentStroke});
}


class DigitalInkError extends DigitalInkState {
  final String error;
  DigitalInkError(this.error);
}
