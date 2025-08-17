class ReferredPeepsModel {
  final String id;
  final String? avatar;
  final String numberOrMail;
  final bool verified;

  ReferredPeepsModel({
    required this.id,
    required this.avatar,
    required this.numberOrMail,
    this.verified = false,
  });
}
