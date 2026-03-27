import 'package:flutter_ai_ml/bloc/smart_reply/smart_replay_event.dart';
import 'package:flutter_ai_ml/bloc/smart_reply/smart_replay_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';

class SmartReplayBloc extends Bloc<SmartReplayEvent, SmartReplayState> {
  SmartReply smartReply = SmartReply();
  String result = '';

  SmartReplayBloc() : super(SmartReplayInitial()) {
    on<SendMessageEvent>(sendMessageToServer);
    on<ReceivedMessageEvent>(receivedMessageFromServer);
  }

  sendMessageToServer(SendMessageEvent event, emit) {
    smartReply.addMessageToConversationFromLocalUser(
        event.sendMessage.trim(), DateTime.now().millisecondsSinceEpoch);
  }

  receivedMessageFromServer(ReceivedMessageEvent event, emit) async {
    smartReply.addMessageToConversationFromRemoteUser(
        event.receivedMessage.trim(), DateTime.now().millisecondsSinceEpoch, 'userIds');
    final response = await smartReply.suggestReplies();
    List<String> suggestions = response.suggestions.map((e) => e.toString()).toList();
    emit(SmartReplayLoaded(suggestions));
  }
 }
 // if want like chat app then enable below code
class SmartReplayChatBloc extends Bloc<SmartReplayEvent, SmartReplayState> {
  final SmartReply smartReply = SmartReply();

  List<ChatMessage> messages = [];

  SmartReplayChatBloc() : super(SmartReplayInitial()) {
    on<SendMessageEvent>(sendMessageToServer);
    on<ReceivedMessageEvent>(receivedMessageFromServer);
  }

 sendMessageToServer(SendMessageEvent event,emit) {
    final text = event.sendMessage.trim();
    if (text.isEmpty) return;

    smartReply.addMessageToConversationFromLocalUser(text, DateTime.now().millisecondsSinceEpoch);
    messages.add(ChatMessage(text: text, isLocal: true));

    emit(SmartReplayChatLoaded(messages: List.from(messages), suggestions: []));
  }

  Future<void> receivedMessageFromServer(ReceivedMessageEvent event,emit) async {
    final text = event.receivedMessage.trim();
    if (text.isEmpty) return;

    smartReply.addMessageToConversationFromRemoteUser(
      text,
      DateTime.now().millisecondsSinceEpoch,
      'remote_user',
    );

    messages.add(ChatMessage(text: text, isLocal: false));

    final response = await smartReply.suggestReplies();
    final suggestions = response.suggestions.map((e) => e.toString()).toList();

    emit(SmartReplayChatLoaded(messages: List.from(messages), suggestions: suggestions));
  }
}
