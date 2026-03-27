abstract class ImagePickerEvent {
  List<Object?> get props => [];
}

// pick image from gallery
class PickImageEvent extends ImagePickerEvent {}

// pick image from camera
class PickCameraImageEvent extends ImagePickerEvent {}

// pick barcode from gallery
class PickBarcodeEvent extends ImagePickerEvent {}

// pick barcode from camera
class PickCameraBarcodeEvent extends ImagePickerEvent {}

// pick face from gallery
class PickFaceImageEvent extends ImagePickerEvent {}

// pick face from camera
class PickFaceCameraEvent extends ImagePickerEvent {}

// pick object from gallery
class PickObjectImageEvent extends ImagePickerEvent {}

// pick object from camera
class PickObjectCameraEvent extends ImagePickerEvent {}

// pick text image from gallery
class PickTextRecognitionImageEvent extends ImagePickerEvent {}

// pick text image from camera
class PickTextRecognitionCameraEvent extends ImagePickerEvent {}

// pick pose image from gallery
class PickPoseImageEvent extends ImagePickerEvent {}

// pick pose image from camera
class PickPoseCameraEvent extends ImagePickerEvent {}
