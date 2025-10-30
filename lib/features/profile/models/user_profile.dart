// ignore_for_file: non_constant_identifier_names

class UserProfile {
  UserProfile({
    required this.id,
    this.password,
    required this.name,
    required this.username,
    this.email,
    this.phone,
    this.referral_code,
    required this.dob,
    this.bio,
    this.height,
    required this.perdectFit,
    required this.displayGender,
    this.profession,
    this.displayImage,
    required this.gender,
    required this.orientation,
    required this.interests,
  });

  final int id;
  final String? password;
  final String name;
  final String username;
  final String? email;
  final String? phone;
  final String? referral_code;
  final DateTime dob;
  final dynamic bio;
  final String? height;
  final int perdectFit;
  final bool displayGender;
  final dynamic profession;
  final String? displayImage;
  final Map<String, dynamic> gender;
  final Map<String, dynamic> orientation;
  final List<dynamic> interests;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json["id"] ?? 0,
    password: json["password"]?.toString(),
    name: json["name"]?.toString() ?? '',
    username: json["username"]?.toString() ?? '',
    email: json["email"]?.toString(),
    phone: json["phone"]?.toString(),
    referral_code: json["referral_code"]?.toString(),
    dob: DateTime.tryParse(json["dob"]?.toString() ?? '') ?? DateTime(1970),
    bio: json["bio"],
    height: json["height"]?.toString(),
    perdectFit: json["perdect_fit"] ?? 0,
    displayGender: json["display_gender"] ?? false,
    profession: json["profession"],
    displayImage: json["display_image"]?.toString(),
    gender: (json["gender"] ?? {}) as Map<String, dynamic>,
    orientation: (json["orientation"] ?? {}) as Map<String, dynamic>,
    interests: (json["interests"] ?? []) as List<dynamic>,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "password": password,
    "name": name,
    "username": username,
    "email": email,
    "phone": phone,
    "referral_code": referral_code,
    "dob": dob.toIso8601String(),
    "bio": bio,
    "height": height,
    "perdect_fit": perdectFit,
    "display_gender": displayGender,
    "profession": profession,
    "display_image": displayImage,
    "gender": gender,
    "orientation": orientation,
    "interests": interests,
  };
}
