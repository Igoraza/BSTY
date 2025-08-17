class Chat {
  final String lastMsg;
  final bool isSent;
  final String image;
  final int unread;
  final String name;
  final int targetId;
  final DateTime? time;
  final String? chatId;
  final String pushId;
  final DateTime? lastMsgSeen;
  final int? matchId;
  final bool? isBlocked;
  final bool? isMutual;

  Chat({
    this.lastMsg = '',
    this.chatId,
    this.isSent = false,
    this.image = '',
    this.unread = 0,
    required this.name,
    required this.targetId,
    this.time,
    this.pushId = '',
    this.lastMsgSeen,
    this.matchId,
    this.isBlocked,
    this.isMutual,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chat_id'],
      lastMsg: json['last_msg'] ?? '',
      isSent: json['is_sent'] ?? false,
      image: json['image'] ?? '',
      unread: json['unread'] ?? 0,
      name: json['name'] ?? '',
      targetId: json['target_id'] ?? 0,
      time: json['time'] != null ? (json['time']).toDate() : null,
      pushId: json['push_id'] ?? '',
      lastMsgSeen: json['last_msg_seen'] != null
          ? (json['last_msg_seen']).toDate()
          : null,
      matchId: json['match_id'],
      isBlocked: json['isBlocked'] ?? false,
      isMutual: json['isMutual'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_id'] = chatId;
    data['last_msg'] = lastMsg;
    data['is_sent'] = isSent;
    data['image'] = image;
    data['unread'] = unread;
    data['name'] = name;
    data['target_id'] = targetId;
    data['time'] = time;
    data['push_id'] = pushId;
    data['last_msg_seen'] = lastMsgSeen;
    data['match_id'] = matchId;
    data['isBlocked'] = isBlocked;
    data['isMutual'] = isMutual;
    return data;
  }
}
