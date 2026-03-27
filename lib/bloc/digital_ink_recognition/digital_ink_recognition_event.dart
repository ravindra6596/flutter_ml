import 'dart:ui';

import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
abstract class DigitalInkEvent {}

class InitializeInkModelEvent extends DigitalInkEvent {
  final String languageCode;
  InitializeInkModelEvent(this.languageCode);
}

class UpdateCurrentStrokeEvent extends DigitalInkEvent {
  final List<Offset> points;
  UpdateCurrentStrokeEvent(this.points);
}

class AddStrokeEvent extends DigitalInkEvent {
  final Stroke stroke;
  AddStrokeEvent(this.stroke);
}

class ClearInkEvent extends DigitalInkEvent {}

class RecognizeInkEvent extends DigitalInkEvent {}
