import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/presentation/digital_ink_recognition/digital_ink_screen.dart';
import 'package:flutter_ai_ml/presentation/image_picker/camera_screen.dart';
import 'package:flutter_ai_ml/presentation/image_picker/image_picker_screen.dart';
import 'package:flutter_ai_ml/presentation/pose_estimation/pose_estimation_camera_screen.dart';
import 'package:flutter_ai_ml/presentation/pose_estimation/pose_estimation_image_picker_screen.dart';
import 'package:flutter_ai_ml/presentation/smart_replay/smart_replay_chat_screen.dart';
import 'package:flutter_ai_ml/presentation/smart_replay/smart_replay_screen.dart';
import 'package:flutter_ai_ml/presentation/speech_to_text_screen.dart';
import 'package:flutter_ai_ml/presentation/text_recognitions/text_recognition_camera_screen.dart';
import 'package:flutter_ai_ml/presentation/text_recognitions/text_recognitions_picker_screen.dart';
import 'package:flutter_ai_ml/presentation/text_translation/text_translation_screen.dart';
import 'package:flutter_ai_ml/presentation/text_translations.dart';
import 'package:flutter_ai_ml/presentation/ttf.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'barcode_scanner/barcode_picker_screen.dart';
import 'barcode_scanner/barcode_scanner_screen.dart';
import 'entity_extraction/entity_extraction_screen.dart';
import 'face_detection/face_detection_camera_screen.dart';
import 'face_detection/face_detection_image_screen.dart';
import 'object_detection/object_detection_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: flutterAiMl),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            // Image Labeling
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(),
                    ),
                );
              },
              child: CustomText(imageLabeling),
            ),
            // Barcode Scanner
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BarcodeScannerScreen(),
                    ),
                );
              },
              child: CustomText(barcodeScannerText),
            ),
            // Face detection
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceDetectionCameraScreen(),
                    ),
                );
              },
              child: CustomText(faceDetectionText),
            ),
            // Object Detection
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObjectDetectionCameraScreen(),
                    ),
                );
              },
              child: CustomText(objectDetectorText),
            ),
            // Text Recognition
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextRecognitionCameraScreen(),
                    ),
                );
              },
              child: CustomText(textRecognitionsText),
            ),
            // Pose Estimation
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoseEstimationCameraScreen(),
                  ),
                );
              },
              child: CustomText(poseEstimation),
            ),
            // Entity Extraction
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntityExtractionScreen(),
                  ),
                );
              },
              child: CustomText(entityExtraction),
            ),
            // Smart replay
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SmartReplayScreen(),
                  ),
                );
              },
              child: CustomText(smartReplayText),
            ),
            // Smart replay Chat
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SmartReplayChatScreen(),
                  ),
                );
              },
              child: CustomText(smartReplayChatText),
            ),

            // Digital Ink Recognition
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DigitalInkScreen(),
                  ),
                );
              },
              child: CustomText(digitalInkRec),
            ),
            // Text Translation
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextTranslationScreen(),
                  ),
                );
              },
              child: CustomText(textTranslationText),
            ),

            Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceDetectionImageScreen(),
                    ),
                  );
                },
                child: CustomText(faceDetectionText),
              ),
            ),
            Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePickerScreen(),
                    ),
                  );
                },
                child: CustomText(imagePickerText),
              ),
            ),
            Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BarcodeScannerPickerScreen(),
                    ),
                  );
                },
                child: CustomText(barcodePickerText),
              ),
            ),
            Visibility(
              visible: true,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TextToSpeech(),
                      ),
                  );
                },
                child: CustomText('TextToSpeech'),
              ),
            ),
            Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpeechToTextScreen(),
                      ),
                  );
                },
                child: CustomText('SpeechToText'),
              ),
            ),
            Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TranslationPage(),
                      ),
                  );
                },
                child: CustomText('TranslationPage'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
