abstract class EntityExtractionEvent {}

class InputEntityTextEvent extends EntityExtractionEvent {
  final String inputText;

  InputEntityTextEvent(this.inputText);
}