class VerifyOtpArgs {
  final bool isLoggingIn;
  final String? name;
  final String? phone;
  final String? requestId;
  final bool isEmail;
  final String? email;

  VerifyOtpArgs({
    this.isLoggingIn = false,
    this.name,
    this.phone,
    this.requestId,
    this.isEmail = false,
    this.email,
  });
}
