// enum MsgType { text, image, video, audio, file }

class ChatMsg {
  final String text;
  // final MsgType msgType;
  final DateTime time;
  final bool isSent;

  ChatMsg({
    required this.text,
    // required this.msgType,
    required this.time,
    required this.isSent,
  });
}

List<ChatMsg> demoMsgs = [
  ChatMsg(
    text: "Hello, how are you?",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 10)),
    isSent: true,
  ),
  ChatMsg(
    text: "I am fine",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 9)),
    isSent: false,
  ),
  ChatMsg(
    text: "what about you?",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 9)),
    isSent: false,
  ),
  ChatMsg(
    text: "I am also fine.",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 8)),
    isSent: true,
  ),
  ChatMsg(
    text: "Hello, how are you?",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 5)),
    isSent: false,
  ),
  ChatMsg(
    text: "I am fine",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
    isSent: true,
  ),
  ChatMsg(
    text: "what about you?",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
    isSent: true,
  ),
  ChatMsg(
    text: "I am also fine.",
    // msgType: MsgType.text,
    time: DateTime.now().subtract(const Duration(minutes: 1)),
    isSent: false,
  ),
];
