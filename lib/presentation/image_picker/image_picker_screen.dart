import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_bloc.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_event.dart';
import 'package:flutter_ai_ml/bloc/image_picker/image_picker_state.dart';
import 'package:flutter_ai_ml/custom_widgets/back_button_widget.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: imagePickerText,leading: BackButtonWidget(),),
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
                              context.read<ImagePickerBloc>().add(PickImageEvent());
                            },
                            child: CustomText(fileImageText),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ImagePickerBloc>().add(PickCameraImageEvent());
                            },
                            child: CustomText(cameraImageText),
                          ),
                          SizedBox(height: 1.h),
                          if (state is ImagePickedSuccess) ...[
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
                            SizedBox(height: 1.h),
                            Container(
                              alignment: Alignment.centerLeft,
                                child: CustomText(state.modelData.toUpperCase(),fontSize: 18.px,fontWeight: FontWeight.bold,maxLines: 3,)),
                            SizedBox(height: 1.h),
                            Container(
                                alignment: Alignment.centerLeft,child: CustomText('$imageLabels\n ${state.imageData}')),
                          ]
                          else if (state is ImagePickedError) ...[
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
