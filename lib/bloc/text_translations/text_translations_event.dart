import 'package:flutter_ai_ml/model/language_model.dart';

class TextTranslationsEvent {}

class InputTextEvent extends TextTranslationsEvent {
  String inputText;

  InputTextEvent(
    this.inputText
  );
}
class ToggleSpeechDropdownEvent extends TextTranslationsEvent {}

class LoadLanguagesEvent extends TextTranslationsEvent {}

class SelectLanguageEvent extends TextTranslationsEvent {
  final SupportedLanguage selectedLanguage;

  SelectLanguageEvent(this.selectedLanguage);
}
class StartSpeechRecognitionEvent extends TextTranslationsEvent {}

class StopSpeechRecognitionEvent extends TextTranslationsEvent {}
// pick text image from gallery
class PickTranslationImageEvent extends TextTranslationsEvent {}

// pick text image from camera
class PickTranslationCameraEvent extends TextTranslationsEvent {}

class SpeechRecognitionResultEvent extends TextTranslationsEvent {
  final String recognizedText;
  SpeechRecognitionResultEvent(this.recognizedText);
}
class SelectSpeechLocaleEvent extends TextTranslationsEvent {
  final String localeId;
  SelectSpeechLocaleEvent(this.localeId);
}
class SelectSpeechLanguageEvent extends TextTranslationsEvent {
  final SupportedLanguage selectedSpeechLanguage;

  SelectSpeechLanguageEvent(this.selectedSpeechLanguage);
}