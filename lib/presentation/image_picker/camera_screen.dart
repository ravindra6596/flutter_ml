import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_bloc.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_event.dart';
import 'package:flutter_ai_ml/bloc/real_camera/camera_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_text.dart';
import 'package:flutter_ai_ml/presentation/image_picker/image_picker_screen.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
      appBar: CustomAppBar(title: imageLabeling),
      body: BlocProvider(
        create: (context) => cameraBloc..add(InitializeCamera(0)),
        child: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            if (state is CameraLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CameraLoadedState) {
              cameraController = state.controller;
              return Stack(
                children: [
                  CameraPreview(state.controller),
                  Positioned(
                    left: 20,
                    top: 10,
                    child: Container(
                      color: Colors.black12,
                      child: CustomText(
                        state.cameraLabelName.toUpperCase(),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.px,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 40,
                    child: Container(
                      color: Colors.black12,
                      child: CustomText(
                        state.cameraLabel,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 20,
                    child: IconButton(
                        onPressed: () {
                          final newIndex = state.currentIndex == 0 ? 1 : 0;
                          cameraBloc.add(InitializeCamera(newIndex));
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
                            builder: (context) => ImagePickerScreen(),
                          ),
                        ).then((_)  {
                          cameraBloc.add(InitializeCamera(0));
                        });
                        cameraBloc.add(DisposeCameraEvent());
                        cameraController.stopImageStream();
                        cameraController.dispose();
                      },
                      icon: Icon(
                        Icons.image_outlined,
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
