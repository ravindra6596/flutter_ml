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

class BarcodeScannerPickerScreen extends StatefulWidget {
  const BarcodeScannerPickerScreen({super.key});

  @override
  State<BarcodeScannerPickerScreen> createState() =>
      _BarcodeScannerPickerScreenState();
}

class _BarcodeScannerPickerScreenState extends State<BarcodeScannerPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CustomAppBar(title: barcodePickerText, leading: BackButtonWidget()),
      body: Center(
        child: BlocProvider(
          create: (context) => ImagePickerBloc(),
          child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<ImagePickerBloc>().add(PickBarcodeEvent());
                      },
                      child: CustomText(fileBarcodeText),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ImagePickerBloc>().add(PickCameraBarcodeEvent());
                      },
                      child: CustomText(cameraBarcodeText),
                    ),
                    if (state is ImageInitial) ...[
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 20.h,
                      )
                    ],
                    SizedBox(height: 1.h),
                    if (state is BarcodeScannerPickerSuccess) ...[
                      Container(
                        width: double.infinity,
                        height: 30.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.h),
                          image: DecorationImage(
                            image: FileImage(state.imageFile,),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CustomText(state.imageData,maxLines: 10,),
                    ] else if (state is BarcodeScannerPickerError) ...[
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
