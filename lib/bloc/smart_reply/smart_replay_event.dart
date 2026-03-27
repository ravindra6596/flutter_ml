class SmartReplayEvent {}

class SendMessageEvent extends SmartReplayEvent {
  String sendMessage;

  SendMessageEvent(this.sendMessage);
}

class ReceivedMessageEvent extends SmartReplayEvent {
  String receivedMessage;

  ReceivedMessageEvent(this.receivedMessage);
}
