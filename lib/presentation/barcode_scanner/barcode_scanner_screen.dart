import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_bloc.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_event.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/presentation/barcode_scanner/barcode_picker_screen.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late CameraController cameraController;
  CameraBloc cameraBloc = CameraBloc();
  @override
  void initState() {
    super.initState();
    cameraBloc = CameraBloc();
  }
  @override
  void dispose() {
    cameraBloc.add(DisposeCameraEvent());
    cameraBloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: barcodeScannerText),
      body: BlocProvider(
        create: (context) => cameraBloc..add(InitializeBarcode(0)),
        child: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            if (state is CameraLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BarcodeLoadedState) {
              cameraController = state.controller;
              return Stack(
                children: [
                  CameraPreview(state.controller),
                  Positioned(
                    left: 10,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black12,
                      width: 80.w,
                      child: CustomText(
                        state.barcodeLabel,
                        maxLines: 100,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 20,
                    child: IconButton(
                      onPressed: () {
                        final newIndex = state.currentBarcodeIndex == 0 ? 1 : 0;
                        cameraBloc.add(InitializeBarcode(newIndex));
                      },
                      icon: Icon(
                        Icons.flip_camera_android_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarcodeScannerPickerScreen(),
                          ),
                        ).then((value) => cameraBloc.add(InitializeBarcode(0)),
                        );
                        cameraBloc.add(DisposeCameraEvent());
                        cameraController.stopImageStream();
                        cameraController.dispose();
                      },
                      icon: Icon(
                        Icons.qr_code,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is CameraError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
