import 'dart:developer';
import 'dart:io';

import 'package:bsty/features/auth/models/verify_otp_args.dart';
import 'package:bsty/features/auth/pages/verification/verify_otp_page.dart';
import 'package:bsty/features/auth/pages/verification/verify_phone_page.dart';
import 'package:bsty/features/auth/widgets/phone_number_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/loading_animations.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../utils/constants/web_view_urls.dart';
import '../../../../utils/global_keys.dart';
import '../../../../utils/theme/colors.dart';
import '../../../webview/webview.dart';
import '../../enums.dart';
import '../../services/auth_provider.dart';
import 'sign_in_email_page.dart';

class SignInPage extends StatelessWidget {
  static const String routeName = '/login';

  SignInPage({Key? key}) : super(key: key);

  final _phoneNum = TextEditingController();
  final _phoneCode = TextEditingController(text: '+91');

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    /// [ Functions ]

    Future<void> signIn() async {
      log("Signing in");
      final authProvider = context.read<AuthProvider>();
      final reqId = DateTime.now().millisecondsSinceEpoch.toString();
      final phone = _phoneCode.text.substring(1) + _phoneNum.text;
      await authProvider.login(context, phone, reqId).then((requestId) {
        if (requestId != null) {
          Navigator.pushNamed(
            context,
            VerifyOtp.routeName,
            arguments: VerifyOtpArgs(
              isLoggingIn: true,
              phone: phone,
              requestId: requestId,
            ),
          );
        }
      });
    }

    /// [ Widgets ]

    final gapV025 = SizedBox(height: appHeight * 0.025);

    // ignore: unused_local_variable
    final switchToSignUp = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account?'),
        TextButton(
          onPressed: () =>
              // Navigator.pushNamed(context, EmailSignInPage.routeName),
              Navigator.pushNamed(context, VerifyPhone.routeName),
          child: Text(
            'Sign Up',
            style: Theme.of(context).textTheme.titleMedium!.merge(
              const TextStyle(
                color: AppColors.toggleBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );

    final termsAndConditions = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'By using our mobile app, you agree to our\n',
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.merge(const TextStyle(height: 2)),
        children: <TextSpan>[
          TextSpan(
            text: 'Terms of use',
            style: Theme.of(context).textTheme.bodySmall!.merge(
              const TextStyle(
                decoration: TextDecoration.underline,
                color: AppColors.toggleBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                navigatorKey.currentState!.pushNamed(
                  WebViewPage.routeName,
                  arguments: WebViewUrls.termsOfService,
                );
              },
          ),
          TextSpan(text: ' & ', style: Theme.of(context).textTheme.bodySmall!),
          TextSpan(
            text: 'Privacy Policy',
            style: Theme.of(context).textTheme.bodySmall!.merge(
              const TextStyle(
                decoration: TextDecoration.underline,
                color: AppColors.toggleBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                navigatorKey.currentState!.pushNamed(
                  WebViewPage.routeName,
                  arguments: WebViewUrls.privacyPolicy,
                );
              },
          ),
        ],
      ),
    );

    final signInWithGoogleBtn = Consumer<AuthProvider>(
      builder: (_, authProvider, __) => StadiumButton(
        gradient: AppColors.buttonBlue,
        onPressed: () {
          // log(authProvider.authStatus.toString());
          if (authProvider.authStatus != AuthStatus.checking) {
            authProvider.signInWithGoogle();
          }
        },
        child: authProvider.authStatus == AuthStatus.checking
            ? const BtnLoadingAnimation()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.google, color: AppColors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Sign in',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: AppColors.white),
                  ),
                ],
              ),
      ),
    );

    final signInWithAppleBtn = Consumer<AuthProvider>(
      builder: (_, authProvider, __) => StadiumButton(
        gradient: AppColors.buttonBlue,
        onPressed: authProvider.isLoading == true
            ? null
            : authProvider.signInWithApple,
        child: authProvider.isLoading
            ? const BtnLoadingAnimation()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.apple, color: AppColors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Sign in',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: AppColors.white),
                  ),
                ],
              ),
      ),
    );

    final signInWithEmailBtn = StadiumButton(
      gradient: AppColors.buttonBlue,
      onPressed: () {
        Navigator.pushNamed(context, EmailSignInPage.routeName);
        // Navigator.pushNamed(context, VerifyPhone.routeName);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.email),
          const SizedBox(width: 10),
          Text(
            'Sign in',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );

    final signInWithPhoneNumberBtn = StadiumButton(
      gradient: AppColors.buttonBlue,
      onPressed: () {
        Navigator.pushNamed(context, VerifyPhone.routeName);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone),
          const SizedBox(width: 10),
          Text(
            'Sign in',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );

    /// This is currently hidden because we are not using phone number login
    final signInBtn = Consumer<AuthProvider>(
      builder: (_, authProvider, __) => StadiumButton(
        visualDensity: VisualDensity.standard,
        gradient: AppColors.buttonBlue,
        onPressed: authProvider.authStatus == AuthStatus.checking
            ? null
            : signIn,
        child: authProvider.authStatus == AuthStatus.checking
            ? const BtnLoadingAnimation()
            : Text(
                'Continue',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: AppColors.white),
              ),
      ),
    );

    return BackgroundImage(
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ✅ keeps screen moving up
        appBar: AppBar(title: const Text('Sign in')),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: appWidth * 0.05,
              right: appWidth * 0.05,
              top: appWidth * 0.02,
              // bottom: MediaQuery.of(
              //   context,
              // ).viewInsets.bottom, // ✅ adds space for keyboard
            ),
            child: SingleChildScrollView(
              // ✅ make full content scrollable
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: appHeight * 0.45,
                    child: Image.asset('assets/images/auth/login.png'),
                  ),
                  signInWithGoogleBtn,
                  if (Platform.isIOS) SizedBox(height: appHeight * 0.01),
                  if (Platform.isIOS)
                    Row(
                      children: [
                        SizedBox(width: appWidth * 0.03),
                        const Expanded(child: Divider(color: AppColors.grey)),
                        SizedBox(width: appWidth * 0.03),
                        Text(
                          'or',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: AppColors.grey),
                        ),
                        SizedBox(width: appWidth * 0.03),
                        const Expanded(child: Divider(color: AppColors.grey)),
                        SizedBox(width: appWidth * 0.03),
                      ],
                    ),
                  if (Platform.isIOS) SizedBox(height: appHeight * 0.01),
                  if (Platform.isIOS) signInWithAppleBtn,
                  SizedBox(height: appHeight * 0.01),
                  if (Platform.isIOS)
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        EmailSignInPage.routeName,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 10.0,
                        ),
                        child: Text(
                          'Log in with email and password',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  SizedBox(height: appHeight * 0.01),
                  Container(
                    padding: EdgeInsets.all(appHeight * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Enter your phone number to login',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        gapV025,
                        PhoneNumberField(
                          phoneCodeController: _phoneCode,
                          phoneNumController: _phoneNum,
                          onSubmitted: (value) {
                            signIn();
                          },
                        ),
                        gapV025,
                        switchToSignUp,
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Spacer(),
                  termsAndConditions,
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
