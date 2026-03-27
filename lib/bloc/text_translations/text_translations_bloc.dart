import 'dart:io';

import 'package:flutter_ai_ml/bloc/text_translations/text_translations_event.dart';
import 'package:flutter_ai_ml/bloc/text_translations/text_translations_state.dart';
import 'package:flutter_ai_ml/model/language_model.dart';
import 'package:flutter_ai_ml/utils/constansts.dart';
import 'package:flutter_ai_ml/utils/functions.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TextTranslationsBloc extends Bloc<TextTranslationsEvent, TextTranslationsState> {
  final modelManager = OnDeviceTranslatorModelManager();
  OnDeviceTranslator onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english, targetLanguage: TranslateLanguage.english);
  final LanguageIdentifier languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final SpeechToText speechToText = SpeechToText();
  ImagePicker imagePicker = ImagePicker();
  dynamic currentStateData;
  SupportedLanguage localLanguage = SupportedLanguage(code: enUS, name: 'English (United States)');
  TextTranslationsBloc() : super(TextTranslationsInitial()) {
    on<LoadLanguagesEvent>(loadAvailableLanguages);
    on<SelectLanguageEvent>(selectLanguage);
    on<InputTextEvent>(onInputTranslateText);
    on<ToggleSpeechDropdownEvent>(toggleSpeechDropdown);
    // for speech
    on<StartSpeechRecognitionEvent>(startSpeechRecognition);
    on<StopSpeechRecognitionEvent>(stopSpeechRecognition);
    on<SpeechRecognitionResultEvent>(handleSpeechResult);
    on<SelectSpeechLocaleEvent>(onSelectSpeechLocale);
    on<SelectSpeechLanguageEvent>(selectSpeechLanguage);

    // image pick camera and gallery
    // on<PickTranslationImageEvent>(chooseTextImageFromGallery);
    // on<PickTranslationCameraEvent>(chooseTextImageFromCamera);
  }

  loadAvailableLanguages(LoadLanguagesEvent event, emit) async {
    final languageList = supportedLanguageMap.entries
        .map((e) => SupportedLanguage(code: e.key, name: e.value))
        .toList();

    final defaultLang = languageList.firstWhere(
      (lang) => lang.code == engLang,
      orElse: () => languageList.first,
    );
    final speechLanguageList = supportedSpeechLanguageMap.entries
        .map((e) => SupportedLanguage(code: e.key, name: e.value))
        .toList();

    final defaultSpeechLang = speechLanguageList.firstWhere(
          (lang) => lang.code == '',
      orElse: () => speechLanguageList.first,
    );

    emit(LanguageLoaded(
      languages: languageList,
      selectedLanguage: defaultLang,
      speechLocales: speechLanguageList,
      selectedSpeechLanguage: defaultSpeechLang
    ));
  }

  selectLanguage(SelectLanguageEvent event, emit) {
    if (state is! LanguageLoaded) return;
    final currentState = state as LanguageLoaded;

    emit(LanguageLoaded(
      languages: currentState.languages,
      selectedLanguage: event.selectedLanguage,
      speechLocales: currentState.speechLocales,
      selectedSpeechLanguage: currentState.selectedSpeechLanguage,
    ));
  }

  selectSpeechLanguage(SelectSpeechLanguageEvent event, emit) {
    if (state is! LanguageLoaded) return;
    final currentState = state as LanguageLoaded;
    localLanguage = event.selectedSpeechLanguage;
    emit(LanguageLoaded(
      languages: currentState.languages,
      selectedLanguage: currentState.selectedLanguage,
      speechLocales: currentState.speechLocales,
      selectedSpeechLanguage: event.selectedSpeechLanguage
    ));
  }

   onInputTranslateText(InputTextEvent event, emit) async {
     if (state is! LanguageLoaded) return;
     final currentState = state as LanguageLoaded;

     final languageService = LanguageService(
       languageIdentifier: languageIdentifier,
       modelManager: modelManager,
     );

     try {
       final detectedCode = await languageService.detectLanguageCode(event.inputText);
       if (detectedCode == null) {
         emit(LanguageLoaded(
           languages: currentState.languages,
           selectedLanguage: currentState.selectedLanguage,
           speechLocales: currentState.speechLocales,
           selectedSpeechLocaleId: currentState.selectedSpeechLocaleId,
           error: "Could not detect language.",
           selectedSpeechLanguage: currentState.selectedSpeechLanguage,
         ));
         return;
       }

       final sourceLang = mapBcpCodeToTranslateLanguage(detectedCode);
       final targetLang = mapBcpCodeToTranslateLanguage(currentState.selectedLanguage.code);

       if (sourceLang == null || targetLang == null) {
         emit(LanguageLoaded(
           languages: currentState.languages,
           selectedLanguage: currentState.selectedLanguage,
           speechLocales: currentState.speechLocales,
           selectedSpeechLocaleId: currentState.selectedSpeechLocaleId,
           selectedSpeechLanguage: currentState.selectedSpeechLanguage,
           error: "Unsupported language(s).",
         ));
         return;
       }

       final needsModelDownload = await languageService.requiresModelDownload(
         sourceLang.bcpCode,
         targetLang.bcpCode,
       );

       if (needsModelDownload) {
         emit(LanguageLoaded(
           languages: currentState.languages,
           selectedLanguage: currentState.selectedLanguage,
           speechLocales: currentState.speechLocales,
           selectedSpeechLocaleId: currentState.selectedSpeechLocaleId,
           selectedSpeechLanguage: currentState.selectedSpeechLanguage,
           isLangLoading: true,
         ));

         await languageService.downloadMissingModels(
           sourceLang.bcpCode,
           targetLang.bcpCode,
         );
       }

       final translator = OnDeviceTranslator(
         sourceLanguage: sourceLang,
         targetLanguage: targetLang,
       );

       final translatedText = await translator.translateText(event.inputText);

       emit(LanguageLoaded(
         languages: currentState.languages,
         selectedLanguage: currentState.selectedLanguage,
         translatedText: translatedText,
         detectedLanguageCode: detectedCode,
         recognizedText: event.inputText,
         speechLocales: currentState.speechLocales,
         selectedSpeechLocaleId: currentState.selectedSpeechLocaleId,
         selectedSpeechLanguage: currentState.selectedSpeechLanguage,
         isListening: currentState.isListening,
         isLangLoading: false,
         error: null,
       ));
     } catch (e) {
       emit(LanguageLoaded(
         languages: currentState.languages,
         selectedLanguage: currentState.selectedLanguage,
         speechLocales: currentState.speechLocales,
         selectedSpeechLanguage: currentState.selectedSpeechLanguage,
         selectedSpeechLocaleId: currentState.selectedSpeechLocaleId,
         error: "Translation failed.",
       ));
     }
  }

  toggleSpeechDropdown(ToggleSpeechDropdownEvent event, Emitter emit) {
    if (state is! LanguageLoaded) return;
    final current = state as LanguageLoaded;

    emit(LanguageLoaded(
      languages: current.languages,
      selectedLanguage: current.selectedLanguage,
      speechLocales: current.speechLocales,
      selectedSpeechLanguage: current.selectedSpeechLanguage,
      translatedText: current.translatedText,
      detectedLanguageCode: current.detectedLanguageCode,
      recognizedText: current.recognizedText,
      isLangLoading: current.isLangLoading,
      isListening: current.isListening,
      error: current.error,
      selectedSpeechLocaleId: current.selectedSpeechLocaleId,
      showSpeechDropdown: true,
    ));
  }


  // speech to text
  Future<void> startSpeechRecognition(StartSpeechRecognitionEvent event, emit) async {
    final isAvailable = await speechToText.initialize();
    if (!isAvailable || state is! LanguageLoaded) return;

    final current = state as LanguageLoaded;


    await speechToText.listen(
      localeId: current.selectedSpeechLanguage!.code,
      onResult: (result) {
        add(SpeechRecognitionResultEvent(result.recognizedWords));
      },
    );
    emit(LanguageLoaded(
      languages: current.languages,
      selectedLanguage: current.selectedLanguage,
      translatedText: current.translatedText,
      detectedLanguageCode: current.detectedLanguageCode,
      error: current.error,
      isLangLoading: current.isLangLoading,
      recognizedText: current.recognizedText,
      isListening: true,
      selectedSpeechLocaleId: current.selectedSpeechLanguage.code,
      selectedSpeechLanguage: current.selectedSpeechLanguage,
      speechLocales: current.speechLocales
    ));
  }
  Future<void> stopSpeechRecognition(StopSpeechRecognitionEvent event, emit) async {
    await speechToText.stop();
  }
  Future<void> handleSpeechResult(SpeechRecognitionResultEvent event, emit) async {
    add(InputTextEvent(event.recognizedText));
  }

  void onSelectSpeechLocale(SelectSpeechLocaleEvent event, Emitter emit) {
    if (state is! LanguageLoaded) return;
    final current = state as LanguageLoaded;

    emit(LanguageLoaded(
      languages: current.languages,
      selectedLanguage: current.selectedLanguage,
      translatedText: current.translatedText,
      detectedLanguageCode: current.detectedLanguageCode,
      error: current.error,
      isLangLoading: current.isLangLoading,
      recognizedText: current.recognizedText,
      speechLocales: current.speechLocales,
      selectedSpeechLocaleId: event.localeId,
      selectedSpeechLanguage: current.selectedSpeechLanguage,
    ));
  }


  // text recognition gallery image
  chooseTextImageFromGallery(PickTranslationImageEvent event, emit) async {
    if (state is! LanguageLoaded) return;
    final current = state as LanguageLoaded;

    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        // final labelData = await getLabels(file);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getTextFromCameraImage(inputImage);
        // add(InputTextEvent(labelData));
        emit(TranslationImageSuccess(file, labelData,current.languages,current.selectedLanguage,current.translatedText,current.detectedLanguageCode));
        /*emit(LanguageLoaded(
          languages: current.languages,
          selectedLanguage: current.selectedLanguage,
          translatedText: current.translatedText,
          detectedLanguageCode: current.detectedLanguageCode,
          error: null,
          recognizedText: current.recognizedText,
          isListening: true,
          imageText: labelData,
          selectedImage: file
        ));*/
        // emit(TranslationImageSuccess(file, labelData));
      } else {
        emit(TranslationImageError('No image selected.'));
      }
    } catch (e) {
      emit(TranslationImageError(e.toString()));
    }
  }

  // text recognition camera image
  chooseTextImageFromCamera(PickTranslationCameraEvent event, emit) async {
    try {
      final XFile? selectedImage =
      await imagePicker.pickImage(source: ImageSource.camera);

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        final inputImage = InputImage.fromFile(file);
        final labelData = await Functions().getTextFromCameraImage(inputImage);
        // emit(TranslationImageSuccess(file, labelData));
      } else {
        emit(TranslationImageError('No image selected.'));
      }
    } catch (e) {
      emit(TranslationImageError(e.toString()));
    }
  }


  TranslateLanguage? mapBcpCodeToTranslateLanguage(String bcpCode) {
    try {
      return TranslateLanguage.values.firstWhere(
        (lang) => lang.bcpCode == bcpCode,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    onDeviceTranslator.close();
    languageIdentifier.close();
    return super.close();
  }
}

class LanguageService {
  final LanguageIdentifier languageIdentifier;
  final OnDeviceTranslatorModelManager modelManager;

  LanguageService({
    required this.languageIdentifier,
    required this.modelManager,
  });

  Future<String?> detectLanguageCode(String text) async {
    try {
      return await languageIdentifier.identifyLanguage(text);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if any model is missing
  Future<bool> requiresModelDownload(String sourceBcpCode, String targetBcpCode) async {
    final sourceReady = await modelManager.isModelDownloaded(sourceBcpCode);
    final targetReady = await modelManager.isModelDownloaded(targetBcpCode);
    return !sourceReady || !targetReady;
  }

  /// Downloads models if needed
  Future<void> downloadMissingModels(String sourceBcpCode, String targetBcpCode) async {
    if (!await modelManager.isModelDownloaded(targetBcpCode)) {
      await modelManager.downloadModel(targetBcpCode);
    }
    if (!await modelManager.isModelDownloaded(sourceBcpCode)) {
      await modelManager.downloadModel(sourceBcpCode);
    }
  }
}


