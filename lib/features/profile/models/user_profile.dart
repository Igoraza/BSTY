// ignore_for_file: non_constant_identifier_names

class UserProfile {
  UserProfile({
    required this.id,
    required this.password,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.referral_code,
    required this.dob,
    this.bio = '',
    required this.height,
    required this.perdectFit,
    required this.displayGender,
    this.profession = '',
    required this.displayImage,
    required this.gender,
    required this.orientation,
    required this.interests,
  });

  final int id;
  final String password;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String? referral_code;
  final DateTime dob;
  final dynamic bio;
  final String height;
  final int perdectFit;
  final bool displayGender;
  final dynamic profession;
  final String displayImage;
  final Map gender;
  final Map orientation;
  final List<dynamic> interests;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"],
        password: json["password"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        referral_code:json["referral_code"],
        dob: DateTime.parse(json["dob"]),
        bio: json["bio"] ?? '',
        height: json["height"],
        perdectFit: json["perdect_fit"],
        displayGender: json["display_gender"],
        profession: json["profession"] ?? '',
        displayImage: json["display_image"],
        gender: json["gender"],
        orientation: json["orientation"],
        interests: List<dynamic>.from(json["interests"].map((x) => x)),
      );
}
