class InitialProfileModel {
  String? dob;
  String? height;
  String? gender;
  String? orientation;
  String? interests;
  String? fit;
  bool displayOrientation;
  bool displayGender;

  InitialProfileModel({
    this.dob,
    this.height,
    this.gender,
    this.orientation,
    this.interests,
    this.fit,
    this.displayOrientation = true,
    this.displayGender = true,
  });

  Map<String, String> toJson() => {
        'dob': dob ?? '',
        'height': height ?? '',
        'gender': gender ?? '',
        'orientation': orientation ?? '',
        'interests': interests ?? '',
        'fit': fit ?? ''
      };
}
