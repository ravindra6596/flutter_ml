import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/model/language_model.dart';
import 'package:flutter_ai_ml/utils/constansts.dart';
import 'package:flutter_ai_ml/utils/functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

abstract class TranslationEvent {}

class LoadLanguages extends TranslationEvent {}

class SelectTargetLanguage extends TranslationEvent {
  final SupportedLanguage language;
  SelectTargetLanguage(this.language);
}

class TranslateTextInput extends TranslationEvent {
  final String text;
  TranslateTextInput(this.text);
}

class StartSpeechRecognition extends TranslationEvent {}

class StopSpeechRecognition extends TranslationEvent {}

class SpeechRecognitionResult extends TranslationEvent {
  final String recognizedText;
  SpeechRecognitionResult(this.recognizedText);
}

class PickImageForTranslation extends TranslationEvent {}

class PickImageFromCamera extends TranslationEvent {}
abstract class TranslationState {}

// Initial / Loading languages
class LanguageLoading extends TranslationState {}

class LanguageLoaded extends TranslationState {
  final List<SupportedLanguage> languages;
  final SupportedLanguage selectedLanguage;
  LanguageLoaded(this.languages, this.selectedLanguage);
}

// Text Input related states
class TextInputTranslating extends TranslationState {}

class TextInputTranslated extends TranslationState {
  final String inputText;
  final String detectedLanguageCode;
  final String translatedText;

  TextInputTranslated({
    required this.inputText,
    required this.detectedLanguageCode,
    required this.translatedText,
  });
}

class TextInputTranslationError extends TranslationState {
  final String error;
  TextInputTranslationError(this.error);
}

// Speech related states
class SpeechRecognitionStarted extends TranslationState {}

class SpeechRecognitionResultState extends TranslationState {
  final String recognizedText;
  SpeechRecognitionResultState(this.recognizedText);
}

class SpeechRecognitionStopped extends TranslationState {}

class SpeechRecognitionError extends TranslationState {
  final String error;
  SpeechRecognitionError(this.error);
}

// Image related states
class ImagePicking extends TranslationState {}

class ImagePickedTranslated extends TranslationState {
  final File imageFile;
  final String recognizedText;
  final String translatedText;

  ImagePickedTranslated({
    required this.imageFile,
    required this.recognizedText,
    required this.translatedText,
  });
}

class ImagePickingError extends TranslationState {
  final String error;
  ImagePickingError(this.error);
}
class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final LanguageIdentifier languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final ImagePicker imagePicker = ImagePicker();
  final SpeechToText speechToText = SpeechToText();

  List<SupportedLanguage> _languages = [];
  SupportedLanguage? _selectedLanguage;

  TranslationBloc() : super(LanguageLoading()) {
    on<LoadLanguages>(_onLoadLanguages);
    on<SelectTargetLanguage>(_onSelectTargetLanguage);
    on<TranslateTextInput>(_onTranslateTextInput);
    on<StartSpeechRecognition>(_onStartSpeechRecognition);
    on<StopSpeechRecognition>(_onStopSpeechRecognition);
    on<SpeechRecognitionResult>(_onSpeechRecognitionResult);
    on<PickImageForTranslation>(_onPickImageForTranslation);
    on<PickImageFromCamera>(_onPickImageFromCamera);
  }

  Future<void> _onLoadLanguages(LoadLanguages event, Emitter<TranslationState> emit) async {
    // Load languages from your map or API
    _languages = supportedLanguageMap.entries
        .map((e) => SupportedLanguage(code: e.key, name: e.value))
        .toList();
    _selectedLanguage = _languages.firstWhere((lang) => lang.code == 'en', orElse: () => _languages.first);
    emit(LanguageLoaded(_languages, _selectedLanguage!));
  }

  void _onSelectTargetLanguage(SelectTargetLanguage event, Emitter<TranslationState> emit) {
    _selectedLanguage = event.language;
    emit(LanguageLoaded(_languages, _selectedLanguage!));
  }

  Future<void> _onTranslateTextInput(TranslateTextInput event, Emitter<TranslationState> emit) async {
    emit(TextInputTranslating());

    try {
      final detectedLangCode = await languageIdentifier.identifyLanguage(event.text);

      final sourceLang = _mapBcpCodeToTranslateLanguage(detectedLangCode);
      final targetLang = _mapBcpCodeToTranslateLanguage(_selectedLanguage!.code);

      if (sourceLang == null || targetLang == null) {
        emit(TextInputTranslationError('Unsupported language'));
        return;
      }

      // Assume your translation function here - you can replace this with real translation logic
      final translatedText = await _fakeTranslate(event.text, sourceLang, targetLang);

      emit(TextInputTranslated(
        inputText: event.text,
        detectedLanguageCode: detectedLangCode,
        translatedText: translatedText,
      ));
    } catch (e) {
      emit(TextInputTranslationError('Translation failed: ${e.toString()}'));
    }
  }

  Future<void> _onStartSpeechRecognition(StartSpeechRecognition event, Emitter<TranslationState> emit) async {
    try {
      final isAvailable = await speechToText.initialize();
      if (!isAvailable) {
        emit(SpeechRecognitionError('Speech recognition not available'));
        return;
      }

      await speechToText.listen(onResult: (result) {
        add(SpeechRecognitionResult(result.recognizedWords));
      });
      emit(SpeechRecognitionStarted());
    } catch (e) {
      emit(SpeechRecognitionError('Speech recognition failed: ${e.toString()}'));
    }
  }

  Future<void> _onStopSpeechRecognition(StopSpeechRecognition event, Emitter<TranslationState> emit) async {
    await speechToText.stop();
    emit(SpeechRecognitionStopped());
  }

  void _onSpeechRecognitionResult(SpeechRecognitionResult event, Emitter<TranslationState> emit) {
    add(TranslateTextInput(event.recognizedText));
  }

  Future<void> _onPickImageForTranslation(PickImageForTranslation event, Emitter<TranslationState> emit) async {
    emit(ImagePicking());

    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        emit(ImagePickingError('No image selected'));
        return;
      }

      final file = File(pickedFile.path);
      final recognizedText = await Functions().getTextFromCameraImage(InputImage.fromFile(file));

      final detectedLangCode = await languageIdentifier.identifyLanguage(recognizedText);
      final sourceLang = _mapBcpCodeToTranslateLanguage(detectedLangCode);
      final targetLang = _mapBcpCodeToTranslateLanguage(_selectedLanguage!.code);

      if (sourceLang == null || targetLang == null) {
        emit(ImagePickingError('Unsupported language'));
        return;
      }

      final translatedText = await _fakeTranslate(recognizedText, sourceLang, targetLang);

      emit(ImagePickedTranslated(
        imageFile: file,
        recognizedText: recognizedText,
        translatedText: translatedText,
      ));
    } catch (e) {
      emit(ImagePickingError('Image picking failed: ${e.toString()}'));
    }
  }

  Future<void> _onPickImageFromCamera(PickImageFromCamera event, Emitter<TranslationState> emit) async {
    emit(ImagePicking());

    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        emit(ImagePickingError('No image captured'));
        return;
      }

      final file = File(pickedFile.path);
      final recognizedText = await Functions().getTextFromCameraImage(InputImage.fromFile(file));

      final detectedLangCode = await languageIdentifier.identifyLanguage(recognizedText);
      final sourceLang = _mapBcpCodeToTranslateLanguage(detectedLangCode);
      final targetLang = _mapBcpCodeToTranslateLanguage(_selectedLanguage!.code);

      if (sourceLang == null || targetLang == null) {
        emit(ImagePickingError('Unsupported language'));
        return;
      }

      final translatedText = await _fakeTranslate(recognizedText, sourceLang, targetLang);

      emit(ImagePickedTranslated(
        imageFile: file,
        recognizedText: recognizedText,
        translatedText: translatedText,
      ));
    } catch (e) {
      emit(ImagePickingError('Camera picking failed: ${e.toString()}'));
    }
  }

  TranslateLanguage? _mapBcpCodeToTranslateLanguage(String bcpCode) {
    try {
      return TranslateLanguage.values.firstWhere((lang) => lang.bcpCode == bcpCode);
    } catch (_) {
      return null;
    }
  }

  Future<String> _fakeTranslate(String text, TranslateLanguage source, TranslateLanguage target) async {
    // Replace with real translation code; this is a stub
    await Future.delayed(Duration(milliseconds: 300));
    return '[${target.bcpCode}] $text';
  }

  @override
  Future<void> close() {
    languageIdentifier.close();
    speechToText.stop();
    return super.close();
  }
}
class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  late final TextEditingController _controller;
  late final TranslationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = TranslationBloc()..add(LoadLanguages());
    _controller = TextEditingController();

    // Optional: listen to text changes and add event, or use onChanged on TextField
  }

  @override
  void dispose() {
    _bloc.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: Text('Translation Demo')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              BlocBuilder<TranslationBloc, TranslationState>(
                buildWhen: (previous, current) => current is LanguageLoaded,
                builder: (context, state) {
                  if (state is LanguageLoaded) {
                    return DropdownButton<SupportedLanguage>(
                      value: state.selectedLanguage,
                      items: state.languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang.name),
                        );
                      }).toList(),
                      onChanged: (lang) {
                        if (lang != null) {
                          _bloc.add(SelectTargetLanguage(lang));
                        }
                      },
                    );
                  }
                  return SizedBox();
                },
              ),
              SizedBox(height: 12),
              // Use BlocListener to show errors or translations, don't rebuild TextField
              BlocListener<TranslationBloc, TranslationState>(
                listenWhen: (previous, current) =>
                current is TextInputTranslated || current is TextInputTranslationError,
                listener: (context, state) {
                  if (state is TextInputTranslated) {
                    // optionally show snackbar or update something outside TextField
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Translation: ${state.translatedText}')),
                    );
                  }
                  if (state is TextInputTranslationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.error}')),
                    );
                  }
                },
                child: TextField(
                  controller: _controller,
                  onChanged: (text) {
                    _bloc.add(TranslateTextInput(text));
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Type text to translate',
                  ),
                ),
              ),
              SizedBox(height: 12),
              BlocBuilder<TranslationBloc, TranslationState>(
                buildWhen: (previous, current) =>
                current is TextInputTranslated || current is TextInputTranslating,
                builder: (context, state) {
                  if (state is TextInputTranslating) {
                    return CircularProgressIndicator();
                  }
                  if (state is TextInputTranslated) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Input: ${state.inputText}'),
                        Text('Detected Language: ${state.detectedLanguageCode}'),
                        Text('Translation: ${state.translatedText}', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    );
                  }
                  return SizedBox();
                },
              ),
              SizedBox(height: 12),
              // Buttons for speech and image picking remain same
              ElevatedButton(
                onPressed: () => _bloc.add(StartSpeechRecognition()),
                child: Text('Start Speech Recognition'),
              ),
              ElevatedButton(
                onPressed: () => _bloc.add(StopSpeechRecognition()),
                child: Text('Stop Speech Recognition'),
              ),
              ElevatedButton(
                onPressed: () => _bloc.add(PickImageForTranslation()),
                child: Text('Pick Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: () => _bloc.add(PickImageFromCamera()),
                child: Text('Pick Image from Camera'),
              ),
              // You can add UI to show image or speech results similarly using BlocBuilder for those states
            ],
          ),
        ),
      ),
    );
  }
}

