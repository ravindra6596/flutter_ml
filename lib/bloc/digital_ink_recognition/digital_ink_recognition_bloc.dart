import 'dart:ui';

import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

import 'digital_ink_recognition_event.dart';
import 'digital_ink_recognition_state.dart';


class DigitalInkBloc extends Bloc<DigitalInkEvent, DigitalInkState> {
  final DigitalInkRecognizerModelManager modelManager = DigitalInkRecognizerModelManager();
  DigitalInkRecognizer digitalInkRecognizer = DigitalInkRecognizer(languageCode: enUS);
  Ink ink = Ink();
  List<Stroke> allStrokes = [];
  List<Offset> currentPoints = [];

  DigitalInkBloc() : super(DigitalInkInitial()) {
    on<InitializeInkModelEvent>(onInit);
    on<UpdateCurrentStrokeEvent>(onUpdateCurrentStroke);
    on<AddStrokeEvent>(onAddStroke);
    on<ClearInkEvent>(onClearInk);
    on<RecognizeInkEvent>(onRecognize);
  }

  onInit(InitializeInkModelEvent event, emit) async {
    try {
      final langCode = event.languageCode;
      final downloaded = await modelManager.isModelDownloaded(langCode);
      if (!downloaded) {
        await modelManager.downloadModel(langCode);
      }
      digitalInkRecognizer = DigitalInkRecognizer(languageCode: langCode);

      // Emit drawing state with empty strokes to start
      emit(DigitalInkDrawing(allStrokes: [], currentStroke: []));
    } catch (e) {
      emit(DigitalInkError("Model init failed: $e"));
    }
  }

   onUpdateCurrentStroke(UpdateCurrentStrokeEvent event, Emitter<DigitalInkState> emit) {
    currentPoints = event.points;
    emit(DigitalInkDrawing(allStrokes: allStrokes, currentStroke: currentPoints));
  }

   onAddStroke(AddStrokeEvent event, Emitter<DigitalInkState> emit) {
    allStrokes = List.from(allStrokes)..add(event.stroke);
    currentPoints = [];
    ink.strokes = allStrokes;
    emit(DigitalInkDrawing(allStrokes: allStrokes, currentStroke: currentPoints));
  }

   onClearInk(ClearInkEvent event, Emitter<DigitalInkState> emit) {
    allStrokes = [];
    currentPoints = [];
    ink = Ink();
    emit(DigitalInkDrawing(allStrokes: [], currentStroke: []));
  }

  onRecognize(RecognizeInkEvent event, emit) async {
    emit(DigitalInkLoading());
    try {
      final candidates = await digitalInkRecognizer.recognize(ink);
      emit(DigitalInkRecognized(
        candidates,
        allStrokes: allStrokes,
        currentStroke: currentPoints,
      ));
    } catch (e) {
      emit(DigitalInkError("Recognition failed: $e"));
    }
  }

  @override
  Future<void> close() {
    digitalInkRecognizer.close();
    return super.close();
  }
}
