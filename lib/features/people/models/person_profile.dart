class PersonProfile {
  PersonProfile({
    required this.id,
    required this.interests,
    required this.orientation,
    required this.gender,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.dob,
    this.bio,
    required this.height,
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
    required this.pushId,
    required this.displayImage,
    required this.created,
  });

  final int id;
  final List<dynamic> interests;
  final Map orientation;
  final Map gender;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final DateTime dob;
  final dynamic bio;
  final String height;
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
  final String created;

  factory PersonProfile.fromJson(Map<String, dynamic> json) => PersonProfile(
        id: json["id"],
        interests: json["interests"],
        orientation: json["orientation"],
        gender: json["gender"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        dob: DateTime.parse(json["dob"]),
        bio: json["bio"],
        height: json["height"],
        perdectFit: json["perdect_fit"],
        plan: json["plan"],
        planExpiry: json["plan_expiry"],
        lastSwipe: json["last_swipe"],
        swipesBalance: json["swipes_balance"],
        audioCallBalance: json["audio_call_balance"],
        videoCallBalance: json["video_call_balance"],
        profileBoostBalance: json["profile_boost_balance"],
        superLikeBalance: json["super_like_balance"],
        displayGender: json["display_gender"],
        profession: json["profession"],
        location: json["location"],
        isActive: json["is_active"],
        pushId: json["push_id"],
        displayImage: json["display_image"],
        created: json["created"],
      );
}
