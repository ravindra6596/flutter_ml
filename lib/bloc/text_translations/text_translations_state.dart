import 'dart:io';

import 'package:flutter_ai_ml/model/language_model.dart';

class TextTranslationsState {}

class TextTranslationsInitial extends TextTranslationsState {}

class TextTranslationsLangLoading extends TextTranslationsState {}

class LanguageLoaded extends TextTranslationsState {
  final List<SupportedLanguage> languages;
  final SupportedLanguage selectedLanguage;
  final String? translatedText;
  final String? detectedLanguageCode;
  final String? error;
  final bool isLangLoading;
  final String? recognizedText;
  final String? selectedSpeechLocaleId;
  final SupportedLanguage selectedSpeechLanguage;
  final List<SupportedLanguage> speechLocales;
  final bool isListening;
  final bool showSpeechDropdown;

  LanguageLoaded({
    required this.languages,
    required this.selectedLanguage,
    this.translatedText,
    this.detectedLanguageCode,
    this.error,
    this.isLangLoading = false,
    this.recognizedText,
    this.selectedSpeechLocaleId,
    required this.selectedSpeechLanguage,
    required this.speechLocales,
    this.isListening = false,
    this.showSpeechDropdown = false
  });
}

// image picker from gallery and camera

class TranslationImageSuccess extends TextTranslationsState {
  final File imageFile;
  final String imageData;
  final List<SupportedLanguage>? languages;
  final SupportedLanguage? selectedLanguage;
  final String? translatedText;
  final String? detectedLanguageCode;
  TranslationImageSuccess(this.imageFile, this.imageData,
     this.languages,
      this.selectedLanguage,
      this.translatedText,
      this.detectedLanguageCode,);

  List<Object?> get props => [imageFile, imageData];
}

class TranslationImageError extends TextTranslationsState {
  final String error;

  TranslationImageError(this.error);

  List<Object?> get props => [error];
}
