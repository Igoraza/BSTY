class Call {
  Call({
    required this.id,
    required this.user,
    required this.targetUser,
    required this.actionType,
    required this.channelName,
    required this.channelTokenCall,
    this.channelTokenReceive,
    required this.created,
  });

  final int id;
  final CallUser user;
  final CallUser targetUser;
  final int actionType;
  final String channelName;
  final String channelTokenCall;
  final dynamic channelTokenReceive;
  final String created;

  factory Call.fromJson(Map<String, dynamic> json) => Call(
        id: json["id"],
        user: CallUser.fromJson(json["user"]),
        targetUser: CallUser.fromJson(json["target_user"]),
        actionType: json["action_type"],
        channelName: json["channel_name"] ?? '',
        channelTokenCall: json["channel_token_call"] ?? '',
        channelTokenReceive: json["channel_token_receive"] ?? '',
        created: json["created"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "target_user": targetUser.toJson(),
        "action_type": actionType,
        "channel_token_call": channelTokenCall,
        "channel_token_receive": channelTokenReceive,
        "created": created,
      };
}

class CallUser {
  CallUser({
    required this.id,
    required this.name,
    required this.displayImage,
  });

  final int id;
  final String name;
  final String displayImage;

  factory CallUser.fromJson(Map<String, dynamic> json) => CallUser(
        id: json["id"],
        name: json["name"],
        displayImage: json["display_image"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "display_image": displayImage,
      };
}
