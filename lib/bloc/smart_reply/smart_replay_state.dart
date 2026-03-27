class SmartReplayState {}

class SmartReplayInitial extends SmartReplayState {}

class SmartReplayLoaded extends SmartReplayState {
  List<String> suggestions;

  SmartReplayLoaded(this.suggestions);
}

class SmartReplayError extends SmartReplayState {
  String error;

  SmartReplayError(this.error);
}
// for smart reply chat

class ChatMessage {
  final String text;
  final bool isLocal;

  ChatMessage({required this.text, required this.isLocal});
}
class SmartReplayChatLoaded extends SmartReplayState {
  final List<ChatMessage> messages;
  final List<String> suggestions;

  SmartReplayChatLoaded({
    required this.messages,
    required this.suggestions,
  });
}
