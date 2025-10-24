import 'dart:io';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:bsty/features/profile/pages/under_review_page.dart';
import 'package:bsty/features/settings/pages/manage_earnings/redemption_request.dart';
import 'package:bsty/features/settings/pages/manage_earnings/transaction_history.dart';
import 'package:bsty/features/settings/pages/manage_earnings/your_referrals.dart';
import 'package:bsty/screens/permission/permit_location.dart';

import '../../features/how_to_guide/how_to_guide.dart';
import '../../features/profile/pages/check_selfie_quality_page.dart';
import '../../features/profile/pages/take_selfie_page.dart';
import '../features/auth/models/verify_otp_args.dart';
import '../features/auth/pages/initial/ac_created.dart';
import '../features/auth/pages/initial/ac_recovery_page.dart';
import '../features/auth/pages/initial/sign_in_page.dart';
import '../features/auth/pages/initial/sign_in_email_page.dart';
import '../features/auth/pages/initial_profile_steps/height_page.dart';
import '../features/auth/pages/initial_profile_steps/select_dob_page.dart';
import '../features/auth/pages/initial_profile_steps/select_gender_page.dart';
import '../features/auth/pages/initial_profile_steps/select_interests.dart';
import '../features/auth/pages/initial_profile_steps/select_media.dart';
import '../features/auth/pages/initial_profile_steps/select_orientation_page.dart';
import '../features/auth/pages/initial_profile_steps/select_perfect_fit.dart';
import '../features/auth/pages/verification/verify_phone_page.dart';
import '../features/auth/pages/verification/verify_otp_page.dart';
import '../features/chat_and_call/models/call.dart';
import '../features/chat_and_call/models/chat.dart';
import '../features/chat_and_call/views/call/pages/incoming_call_page.dart';
import '../features/chat_and_call/views/call/pages/ongoing_call_page.dart';
import '../features/chat_and_call/views/chat_messages/pages/chat_page.dart';
import '../features/common/force_update_page.dart';
import '../features/membership/pages/all_plans_details_carousel.dart';
import '../features/membership/pages/credits_and_renewal.dart';
import '../features/notification/notification_page.dart';
import '../features/people/views/detailed/person_details_page.dart';
import '../features/people/views/explore/explore_page.dart';
import '../features/profile/pages/edit_profile.dart';
import '../features/profile/pages/verify_identity_page.dart';
import '../features/settings/pages/manage_earnings/manage_earnings.dart';
import '../features/settings/pages/refer_and_earn/refer_earn_page.dart';
import '../features/settings/pages/settings_inner_page.dart';
import '../features/splash/intro.dart';
import '../features/splash/splash_screen.dart';
import '../features/webview/webview.dart';
import '../screens/main/main_page.dart';

class MyRoutes {
  static Route<dynamic> myRoutes(RouteSettings settings) {
    // arguments
    final args = settings.arguments;

    /// [ routeName ] is the name of the route and it will be [ switched ] according to the [ routes ].

    switch (settings.name) {
      /// [ Intro Screen]
      case '/':
        // return MaterialPageRoute(builder: (context) => const SelectInterest());
        return MaterialPageRoute(builder: (context) => const IntroScreen());

      /// [ Splash Screen ]
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

      /// [ Login Screen ]
      case SignInPage.routeName:
        return MaterialPageRoute(builder: (context) => SignInPage());

      /// [ Signin Screen ]
      case EmailSignInPage.routeName:
        return MaterialPageRoute(builder: (context) => EmailSignInPage());

      /// [ Verify OTP Screen ]
      case VerifyOtp.routeName:
        return MaterialPageRoute(
          builder: (context) => VerifyOtp(args as VerifyOtpArgs),
        );

      /// [ Verify Phone Screen ]
      case VerifyPhone.routeName:
        return MaterialPageRoute(builder: (context) => const VerifyPhone());

      /// [ Account Recovery Screen ]
      case AccountRecovery.routeName:
        return MaterialPageRoute(builder: (context) => const AccountRecovery());

      /// [ Account Created Screen ]
      case AccountCreated.routeName:
        return MaterialPageRoute(builder: (context) => const AccountCreated());

      /// [ Select DOB Screen ]
      case SelectDob.routeName:
        return MaterialPageRoute(builder: (context) => const SelectDob());

      /// [ Select Height Screen ]
      case SelectHeight.routeName:
        return MaterialPageRoute(builder: (context) => const SelectHeight());

      /// [Select Gender Screen ]
      case SelectGender.routeName:
        return MaterialPageRoute(builder: (context) => const SelectGender());

      /// [ Select Orientation Screen ]
      case SelectOrientation.routeName:
        return MaterialPageRoute(
          builder: (context) => const SelectOrientation(),
        );

      /// [ Select Interest Screen ]
      case SelectInterest.routeName:
        return MaterialPageRoute(builder: (context) => const SelectInterest());

      /// [ Select Media Screen ]
      case SelectMedia.routeName:
        return MaterialPageRoute(builder: (context) => const SelectMedia());

      /// [ Select Perfect Fit Screen ]
      case PerfectFit.routeName:
        return MaterialPageRoute(builder: (context) => const PerfectFit());

      /// [ Main Screen ]
      case MainPage.routeName:
        return MaterialPageRoute(
          builder: (context) => MainPage(matchIndex: args as int?),
        );

      /// [ Detailed Screen ]
      case PersonDetailedPage.routeName:
        final data = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => PersonDetailedPage(
            userId: data['id'] as int,
            userName: data['name'] as String,
            userImage: data['image'] as String,
          ),
        );

      /// [ Explore Screen ]
      case ExplorePage.routeName:
        return MaterialPageRoute(builder: (context) => const ExplorePage());

      /// [ Chat Screen ]
      case ChatPage.routeName:
        return MaterialPageRoute(builder: (context) => ChatPage(args as Chat));

      /// [ How to guide pages ]
      case HowToGuidePages.routeName:
        return MaterialPageRoute(builder: (context) => const HowToGuidePages());

      /// [ Incoming Call Screen]
      case IncomingCall.routeName:
        final data = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => IncomingCall(
            callId: data['callId'] as int,
            isVideo: data['isVideo'] as bool,
            targetUserName: data['user_name'] as String,
            targetUserImage: data['user_image'] as String?,
          ),
        );

      /// [ Audio Call Screen]
      case OnGoingCallPage.routeName:
        final data = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => OnGoingCallPage(
            callId: data['callId'] as int,
            targetUser: data['targetUser'] as CallUser?,
            targetUserId: data['targetUserId'] as int?,
            isIncoming: data['isIncoming'] as bool,
            isVideo: data['isVideo'] as bool,
            targetUserImg: data['user_image'] as String?,
            targetUserName: data['user_name'] as String?,
            isOutgoing: data['isOutgoing'] as bool?,
            targetPushId: data['targetPushId'],
          ),
        );

      /// [ Verify Identity]
      case VerifyIdentityPage.routeName:
        return MaterialPageRoute(
          builder: (context) => const VerifyIdentityPage(),
        );

      /// [ Selfie Screen ]
      case TakeSelfiePage.routeName:
        return MaterialPageRoute(
          builder: (context) =>
              TakeSelfiePage(cameras: args as List<CameraDescription>?),
        );

      /// [ Check Selfie Quality Screen ]
      case CheckSelfieQualityPage.routeName:
        return MaterialPageRoute(
          builder: (context) => CheckSelfieQualityPage(selfie: args as File),
        );

      /// [ Notification Screen ]
      case NotificationPage.routeName:
        return MaterialPageRoute(
          builder: (context) => const NotificationPage(),
        );

      /// [ Settings Inner Screen ]
      case SettingsInnerPage.routeName:
        return MaterialPageRoute(
          builder: (context) => const SettingsInnerPage(),
        );

      /// [ All Plans Carousel Page ]
      case AllPlansDetails.routeName:
        return MaterialPageRoute(
          builder: (context) =>
              AllPlansDetails(controller: args as PageController),
        );

      /// [ Refer and Earn Page ]
      case ReferEarnPage.routeName:
        return MaterialPageRoute(builder: (context) => const ReferEarnPage());

      /// [ Manage Earnings Page ]
      case ManageEarningsPage.routeName:
        return MaterialPageRoute(
          builder: (context) => const ManageEarningsPage(),
        );

      case EditProfile.routeName:
        return MaterialPageRoute(builder: (context) => const EditProfile());

      case WebViewPage.routeName:
        return MaterialPageRoute(
          builder: (context) => WebViewPage(args as String),
        );

      case CreditsAndRenewal.routeName:
        return MaterialPageRoute(
          builder: (context) => const CreditsAndRenewal(),
        );

      case ForceUpdatePage.routeName:
        return MaterialPageRoute(builder: (context) => const ForceUpdatePage());

      /// [ access location ]
      case PermitLocation.routeName:
        return MaterialPageRoute(builder: (context) => const PermitLocation());

      case UnderReview.routeName:
        return MaterialPageRoute(builder: (context) => const UnderReview());

      case TransactionHistory.routeName:
        return MaterialPageRoute(
          builder: (context) => const TransactionHistory(),
        );

      case RedemptionRequest.routeName:
        return MaterialPageRoute(
          builder: (context) => const RedemptionRequest(),
        );

      case YourReferrals.routeName:
        return MaterialPageRoute(builder: (context) => const YourReferrals());

      case UpgradePlanScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => UpgradePlanScreen(title: args as String?),
        );

      /// [ If no route is found ] then return a [ MaterialPageRoute ] with a [ Intro Screen ] as the [ builder ].
      default:
        return MaterialPageRoute(builder: (context) => const IntroScreen());
    }
  }
}
