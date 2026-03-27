import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

abstract class EntityExtractionState {}

class EntityExtractionInitial extends EntityExtractionState {}

class EntityExtractionLoading extends EntityExtractionState {}

class EntityExtractionLoaded extends EntityExtractionState {
  final List<EntityAnnotation> annotations;

  EntityExtractionLoaded(this.annotations);
}

class EntityExtractionError extends EntityExtractionState {
  final String message;

  EntityExtractionError(this.message);
}