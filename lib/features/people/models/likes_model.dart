class LikesModel {
  LikesModel({
    required this.id,
    required this.user,
    required this.actionType,
    required this.created,
    required this.deleted,
    required this.targetUser,
  });

  final int id;
  final LikedUser user;
  final int actionType;
  final String created;
  final bool deleted;
  final int targetUser;

  factory LikesModel.fromJson(Map<String, dynamic> json) => LikesModel(
        id: json["id"],
        user: LikedUser.fromJson(json["user"]),
        actionType: json["action_type"],
        created: json["created"],
        deleted: json["deleted"],
        targetUser: json["target_user"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "action_type": actionType,
        "created": created,
        "deleted": deleted,
        "target_user": targetUser,
      };
}

class LikedUser {
  LikedUser({
    required this.id,
    required this.name,
    required this.displayImage,
    this.profession,
    this.location,
    required this.age,
  });

  final int id;
  final String name;
  final String displayImage;
  final dynamic profession;
  final dynamic location;
  final int age;

  factory LikedUser.fromJson(Map<String, dynamic> json) => LikedUser(
        id: json["id"],
        name: json["name"],
        displayImage: json["display_image"],
        profession: json["profession"],
        location: json["location"],
        age: json["age"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "display_image": displayImage,
        "profession": profession,
        "location": location,
        "age": age,
      };
}
