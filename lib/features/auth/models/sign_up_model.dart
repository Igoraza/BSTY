class SignUpModel {
  SignUpModel({
    required this.name,
    required this.phone,
    required this.requestId,
  });

  final String name;
  final String phone;
  final String requestId;

  factory SignUpModel.fromJson(Map<String, dynamic> json) => SignUpModel(
        name: json["name"],
        phone: json["phone"],
        requestId: json["request_id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "request_id": requestId,
      };
}
