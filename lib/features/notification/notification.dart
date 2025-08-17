//notif type enum
enum NotifType {
  // 0
  star,
  // 1
  like,
  // 2
  invitaion
}

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.sourceUser,
    required this.title,
    required this.created,
  });

  final int id;
  final SourceUser sourceUser;
  final String title;
  final DateTime created;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        sourceUser: SourceUser.fromJson(json["source_user"]),
        title: json["title"],
        created: DateTime.parse(json["created"]),
      );
}

class SourceUser {
  SourceUser({
    required this.id,
    required this.name,
    required this.displayImage,
    required this.pushId,
  });

  final int id;
  final String name;
  final String displayImage;
  final String pushId;

  factory SourceUser.fromJson(Map<String, dynamic> json) => SourceUser(
        id: json["id"],
        name: json["name"],
        displayImage: json["display_image"],
        pushId: json["push_id"],
      );
}
