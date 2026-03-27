import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_bloc.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_event.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_state.dart';
import 'package:flutter_ai_ml/custom_widgets/back_button_widget.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TextRecognitionsPickerScreen extends StatefulWidget {
  const TextRecognitionsPickerScreen({super.key});

  @override
  State<TextRecognitionsPickerScreen> createState() => _TextRecognitionsPickerScreenState();
}

class _TextRecognitionsPickerScreenState extends State<TextRecognitionsPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: textRecognitionsText,leading: BackButtonWidget(),),
      body: Center(
        child: BlocProvider(
                create: (context) => ImagePickerBloc(),
                child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Column(
                        children: [
                          if(state is ImageInitial)...[
                            Icon(Icons.image,size: 20.h,)
                          ],
                          ElevatedButton(
                            onPressed: () {
                              context.read<ImagePickerBloc>().add(PickTextRecognitionImageEvent());
                            },
                            child: CustomText(fileImageText),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ImagePickerBloc>().add(PickTextRecognitionCameraEvent());
                            },
                            child: CustomText(cameraImageText),
                          ),
                          SizedBox(height: 1.h),
                          if (state is TextRecognitionImageSuccess) ...[
                            Container(
                              width: double.infinity,
                              height: 30.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1.h),
                                image: DecorationImage(
                                  image: FileImage(state.imageFile),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SelectableText(
                              state.imageData,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ]
                          else if (state is ObjectPickerError) ...[
                            CustomText('Error: ${state.error}', maxLines: 5),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
class ObjectPainter extends CustomPainter {
  List<DetectedObject> objectList = [];
  dynamic imageFile;
  ObjectPainter(  this.objectList, this.imageFile );

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint p = Paint();
    p.color = Colors.green;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 4;

    for (DetectedObject rectangle in objectList) {
      canvas.drawRect(rectangle.boundingBox, p);
      var list = rectangle.labels;
      for(Label label in list){
        log("${label.text}   ${label.confidence.toStringAsFixed(2)}");
        TextSpan span = TextSpan(text: label.text,style: TextStyle(fontSize: 25.px,color: Colors.blue));
        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left,textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(rectangle.boundingBox.left,rectangle.boundingBox.top));
        break;
      }
    }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}