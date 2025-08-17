import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? baseUrl = dotenv.env['BASE_URL'];

class Endpoints {
  static String loginUrl = "$baseUrl/v1/otp/login/";
  static String googleLoginUrl = "$baseUrl/v1/google/login/";
  static String appleLoginUrl = "$baseUrl/v1/apple/login/";
  static String emailLoginUrl = "$baseUrl/v1/email/login/";
  static String signUpUrl = "$baseUrl/v1/otp/signup/";
  static String signUpVerifyUrl = "${signUpUrl}verify/";
  static String loginVerifyUrl = "${loginUrl}verify/";
  static String completeProfile = "$baseUrl/v1/complete/profile/";

  static String refreshToken = "$baseUrl/token/refresh/";
  static String updateEmail = "$baseUrl/v1/update/email/";

  static String gendersList = "$baseUrl/v1/get/genders/";
  static String orientationsList = "$baseUrl/v1/get/orientations/";
  static String interestsList = "$baseUrl/v1/get/interests/";

  static String updateProfile = "$baseUrl/v1/update/profile/";
  static String addUserImage = "$baseUrl/v1/add/user/image/";

  static String userHome = "$baseUrl/v2/user/home/";
  static String userAction = "$baseUrl/v1/user/action/";
  static String userRewind = "$baseUrl/v1/user/rewind/";
  static String userBoost = "$baseUrl/v1/user/boost/";
  static String getProfile = "$baseUrl/v1/get/profile/";
  static String userVerify = "$baseUrl/v1/user/verification/";

  static String likes = "$baseUrl/v1/likes/";
  static String superLikes = "$baseUrl/v1/super/likes/";
  static String profileViews = "$baseUrl/v1/profile/views/";

  static String myCalls = "$baseUrl/v1/my/calls/";
  static String initiateCall = "$baseUrl/v1/initiate/call/";
  static String getCallToken = "$baseUrl/v1/get/call/token/";
  static String callCredits = "$baseUrl/v1/call/credit/update/";

  static String getCallSettings = "$baseUrl/v1/get/call/settings/";
  static String updateCallSettings = "$baseUrl/v1/update/call/settings/";

  static String userHomeMap = "$baseUrl/v1/user/home/map/";

  static String myMatches = "$baseUrl/v1/my/matches/";

  static String unMatch = "$baseUrl/v1/unmatch/";

  static String myNotifications = "$baseUrl/v1/my/notifications/";

  static String profileConfig = "$baseUrl/v1/get/profile/config/";

  static String updateShowMe = "$baseUrl/v1/update/show_me/";
  static String updateNotification = "$baseUrl/v1/update/notification/";
  static String updateIncognito = "$baseUrl/v1/update/incognito/";

  static String getMyProfile = "$baseUrl/v1/get/my/profile/";
  static String updateFullProfile = "$baseUrl/v1/update/full/profile/";
  static String deleteUserImage = "$baseUrl/v1/delete/user/image/";

  static String initiateChat = "$baseUrl/v1/initiate/chat/";

  static String purchaseAndroid = "$baseUrl/v1/verify/purchase/android/";
  static String purchaseIos = "$baseUrl/v1/verify/purchase/ios/";

  static String deleteAccount = "$baseUrl/v1/delete/account/";

  static String sendQuery = "$baseUrl/v1/send/query/";
  static String reportAndBlock = "$baseUrl/v1/report/block/";

  static String getMep = "$baseUrl/v1/mep/";
  static String getPayoutRequests= "$baseUrl/v1/payout/requests/";
  static String transHistory = "$baseUrl/v1/transactions/";
  static String getReferrals = "$baseUrl/v1/referrals/";
  static String payRequest = "$baseUrl/v1/payout/request/";
}
