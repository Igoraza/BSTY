class PersonProfile {
  PersonProfile({
    required this.id,
    required this.interests,
    required this.orientation,
    required this.gender,
    required this.name,
    required this.username,
    this.email,
    this.phone,
    required this.dob,
    this.bio,
    this.height,
    required this.perdectFit,
    required this.plan,
    this.planExpiry,
    this.lastSwipe,
    required this.swipesBalance,
    required this.audioCallBalance,
    required this.videoCallBalance,
    required this.profileBoostBalance,
    required this.superLikeBalance,
    required this.displayGender,
    this.profession,
    this.location,
    required this.isActive,
    this.pushId,
    this.displayImage,
    this.created,
  });

  final int id;
  final List<dynamic> interests;
  final Map<String, dynamic> orientation;
  final Map<String, dynamic> gender;
  final String name;
  final String username;
  final String? email;
  final String? phone;
  final DateTime dob;
  final dynamic bio;
  final String? height;
  final int perdectFit;
  final int plan;
  final dynamic planExpiry;
  final dynamic lastSwipe;
  final int swipesBalance;
  final int audioCallBalance;
  final int videoCallBalance;
  final int profileBoostBalance;
  final int superLikeBalance;
  final bool displayGender;
  final dynamic profession;
  final dynamic location;
  final bool isActive;
  final String? pushId;
  final String? displayImage;
  final String? created;

  factory PersonProfile.fromJson(Map<String, dynamic> json) {
    return PersonProfile(
      id: json["id"] ?? 0,
      interests: json["interests"] ?? [],
      orientation: (json["orientation"] ?? {}) as Map<String, dynamic>,
      gender: (json["gender"] ?? {}) as Map<String, dynamic>,
      name: json["name"]?.toString() ?? '',
      username: json["username"]?.toString() ?? '',
      email: json["email"]?.toString(),
      phone: json["phone"]?.toString(),
      dob: DateTime.tryParse(json["dob"]?.toString() ?? '') ?? DateTime(1970),
      bio: json["bio"],
      height: json["height"]?.toString(),
      perdectFit: json["perdect_fit"] ?? 0,
      plan: json["plan"] ?? 0,
      planExpiry: json["plan_expiry"],
      lastSwipe: json["last_swipe"],
      swipesBalance: json["swipes_balance"] ?? 0,
      audioCallBalance: json["audio_call_balance"] ?? 0,
      videoCallBalance: json["video_call_balance"] ?? 0,
      profileBoostBalance: json["profile_boost_balance"] ?? 0,
      superLikeBalance: json["super_like_balance"] ?? 0,
      displayGender: json["display_gender"] ?? false,
      profession: json["profession"],
      location: json["location"],
      isActive: json["is_active"] ?? false,
      pushId: json["push_id"]?.toString(),
      displayImage: json["display_image"]?.toString(),
      created: json["created"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "interests": interests,
    "orientation": orientation,
    "gender": gender,
    "name": name,
    "username": username,
    "email": email,
    "phone": phone,
    "dob": dob.toIso8601String(),
    "bio": bio,
    "height": height,
    "perdect_fit": perdectFit,
    "plan": plan,
    "plan_expiry": planExpiry,
    "last_swipe": lastSwipe,
    "swipes_balance": swipesBalance,
    "audio_call_balance": audioCallBalance,
    "video_call_balance": videoCallBalance,
    "profile_boost_balance": profileBoostBalance,
    "super_like_balance": superLikeBalance,
    "display_gender": displayGender,
    "profession": profession,
    "location": location,
    "is_active": isActive,
    "push_id": pushId,
    "display_image": displayImage,
    "created": created,
  };
}
