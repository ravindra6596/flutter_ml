import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ImageLabelsResult {
  final String defaultLabels;
  final String modelLabels;

  ImageLabelsResult({
    required this.defaultLabels,
    required this.modelLabels,
  });
}
class ObjectDetectionResult {
  final List<DetectedObject> defaultObjects;
  final List<DetectedObject> modelObjects;

  ObjectDetectionResult({
    required this.defaultObjects,
    required this.modelObjects,
  });
}
