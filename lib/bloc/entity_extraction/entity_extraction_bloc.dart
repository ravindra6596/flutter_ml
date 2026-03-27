import 'package:flutter_ai_ml/bloc/entity_extraction/entity_extraction_event.dart';
import 'package:flutter_ai_ml/bloc/entity_extraction/entity_extraction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class EntityExtractionBloc extends Bloc<EntityExtractionEvent, EntityExtractionState> {
  EntityExtractor entityExtractor = EntityExtractor(language: EntityExtractorLanguage.english);
  final EntityExtractorModelManager modelManager = EntityExtractorModelManager();

  EntityExtractionBloc() : super(EntityExtractionInitial()) {
    on<InputEntityTextEvent>(onTextEntered);
    initModel();
  }

  Future<void> initModel() async {
    const language = EntityExtractorLanguage.english;
    final isDownloaded = await modelManager.isModelDownloaded(language.name);

    if (!isDownloaded) {
      await modelManager.downloadModel(language.name);
    }

    entityExtractor = EntityExtractor(language: language);
  }

   onTextEntered(InputEntityTextEvent event, emit) async {
    emit(EntityExtractionLoading());

    try {
      final annotations = await entityExtractor.annotateText(event.inputText);
      emit(EntityExtractionLoaded(annotations));
    } catch (e) {
      emit(EntityExtractionError("Failed to extract entities: $e"));
    }
  }

  @override
  Future<void> close() {
    entityExtractor.close();
    return super.close();
  }
}
