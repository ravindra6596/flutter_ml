// ignore_for_file: must_be_immutable
import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_ml/bloc/text_translations/text_translations_bloc.dart';
import 'package:flutter_ai_ml/bloc/text_translations/text_translations_event.dart';
import 'package:flutter_ai_ml/bloc/text_translations/text_translations_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/model/language_model.dart';
import 'package:flutter_ai_ml/utils/constansts.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  SupportedLanguage? supportedLanguage;
  final TextEditingController inputTextController = TextEditingController();
  TextTranslationsBloc textTranslationsBloc = TextTranslationsBloc();
  final TextEditingController searchLanguageController = TextEditingController();
  final SpeechToText speechToText = SpeechToText();
  String translatedText = '';
  dynamic isListening;
  @override
  void initState() {
    super.initState();
    textTranslationsBloc = TextTranslationsBloc()..add(LoadLanguagesEvent());
  }

  @override
  void dispose() {
    inputTextController.dispose();
    textTranslationsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => textTranslationsBloc,
      child: BlocConsumer<TextTranslationsBloc, TextTranslationsState>(
          listener: (context, state) async {
            if(state is LanguageLoaded){
              translatedText = state.translatedText ?? '';
            }
            if (state is LanguageLoaded && state.recognizedText != null) {
              inputTextController.text = state.recognizedText!;
              inputTextController.selection = TextSelection.fromPosition(
                TextPosition(offset: inputTextController.text.length),
              );
            }
          },
          builder: (context, state) {
           if(state is LanguageLoaded) {
             isListening = textTranslationsBloc.speechToText.isListening;
              return Scaffold(
                appBar: CustomAppBar(title: textTranslationText),
                body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: inputTextController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: enterTextHere,
                            labelText: state.detectedLanguageCode != null
                                ? '$detected: ${getLanguageName(state.detectedLanguageCode!)}'
                                : typeTextHere,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: onTextChanged,
                        ),
                        SizedBox(height: 1.h),
                        // from language
                        CustomText(selectSpeechLanguage,maxLines: 3,fontSize: 8.px,),
                        DropdownButton2<SupportedLanguage>(
                          underline: SizedBox(),
                          isExpanded: true,
                          isDense: true,
                          items: state.speechLocales.map((lang) {
                            return DropdownMenuItem<SupportedLanguage>(
                              value: lang,
                              child: CustomText(lang.name),
                            );
                          }).toList(),
                          value: state.selectedSpeechLanguage,
                          onChanged: (value) {
                            if (value != null) {
                              textTranslationsBloc.add(SelectSpeechLanguageEvent(value));
                              if (inputTextController.text.isNotEmpty) {
                                onTextChanged(inputTextController.text);
                              }
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            height: 6.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.h),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.h),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: searchLanguageController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                controller: searchLanguageController,
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: searchLanguage,
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: Icon(Icons.search)),
                                textInputAction: TextInputAction.search,
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              // Case-insensitive match
                              return item.value!.name.toLowerCase().contains(searchValue.toLowerCase());
                            },
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(Icons.keyboard_arrow_down),
                            openMenuIcon: Icon(Icons.keyboard_arrow_up),
                          ),
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              searchLanguageController.clear();
                            }
                          },
                        ),
                        // to language
                        SizedBox(height: 1.h),
                        CustomText(selectTranslateLanguage,maxLines: 3,fontSize: 10.px,),
                        DropdownButton2<SupportedLanguage>(
                          underline: SizedBox(),
                          isExpanded: true,
                          isDense: true,
                          items: state.languages.map((lang) {
                            return DropdownMenuItem<SupportedLanguage>(
                              value: lang,
                              child: CustomText(lang.name),
                            );
                          }).toList(),
                          value: state.selectedLanguage,
                          onChanged: (value) {
                            if (value != null) {
                              textTranslationsBloc.add(SelectLanguageEvent(value));
                              if (inputTextController.text.isNotEmpty) {
                                onTextChanged(inputTextController.text);
                              }
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            height: 6.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.h),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.h),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: searchLanguageController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                controller: searchLanguageController,
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: searchLanguage,
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: Icon(Icons.search)),
                                textInputAction: TextInputAction.search,
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              // Case-insensitive match
                              return item.value!.name.toLowerCase().contains(searchValue.toLowerCase());
                            },
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(Icons.keyboard_arrow_down),
                            openMenuIcon: Icon(Icons.keyboard_arrow_up),
                          ),
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              searchLanguageController.clear();
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (state.translatedText != null)
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(1.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1.h),
                                ),
                                child: SelectableText(
                                  state.translatedText!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: IconButton(
                                    onPressed: () => copyTextToClipboard(
                                        state.translatedText ?? ''),
                                    icon: Icon(Icons.copy)),
                              ),
                            ],
                          ),
                        if(state.isLangLoading)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment:MainAxisAlignment.center,
                            children: [
                              CustomText('Language model is downloading...'),
                              SizedBox(height: 1.h),
                              Center(child: CircularProgressIndicator(),),
                            ],
                          ),
                        if (state.error != null)
                          CustomText(
                            state.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        Visibility(
                          visible: false,
                          child: Row(
                            children: [
                              IconButton(onPressed: (){
                                if(inputTextController.text.isNotEmpty){
                                  inputTextController.clear();
                                }
                                textTranslationsBloc.add(PickTranslationImageEvent());
                              }, icon: Icon(Icons.image_search)),
                              IconButton(onPressed: (){
                                if(inputTextController.text.isNotEmpty){
                                  inputTextController.clear();
                                  translatedText = '';
                                }
                                textTranslationsBloc.add(PickTranslationCameraEvent());
                              }, icon: Icon(Icons.camera_alt)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                floatingActionButton: Opacity(
                  opacity: state.selectedSpeechLanguage.code.isEmpty ? .5 : 1,
                  child: AvatarGlow(
                    startDelay: const Duration(milliseconds: 100),
                    glowColor: Colors.green,
                    glowShape: BoxShape.circle,
                    animate: isListening,
                    curve: Curves.fastOutSlowIn,
                    duration: Duration(milliseconds: 2000),
                    repeat: true,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        if(state.selectedSpeechLanguage.code.isEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: CustomText(defaultSelLang(state.selectedSpeechLanguage.name),maxLines: 2,)),
                          );
                        }else{
                          if (isListening) {
                            textTranslationsBloc.add(StopSpeechRecognitionEvent());
                          } else {
                            textTranslationsBloc.add(StartSpeechRecognitionEvent());
                          }
                        }
                     },
                      child: Icon(
                        (isListening)
                            ? Icons.mic_rounded
                            : Icons.mic_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }

            return SizedBox();
          }
      ),
    );
  }

  /// Debounce the translation
  Timer? debounce;

  void onTextChanged(String text) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      textTranslationsBloc.add(InputTextEvent(text));
    });
  }

  String getLanguageName(String code) {
    return supportedLanguageMap[code] ?? code;
  }

  // Function to copy text to clipboard
  Future<void> copyTextToClipboard(String textToCopy) async {
    await Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: CustomText(textCopy)),
    );
  }
}
