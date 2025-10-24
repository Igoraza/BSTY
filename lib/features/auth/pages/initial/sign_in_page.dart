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
      final authProvider = context.read<AuthProvider>();
      final reqId = DateTime.now().millisecondsSinceEpoch.toString();
      final phone = _phoneCode.text.substring(1) + _phoneNum.text;
      await authProvider.login(context, phone, reqId).then((value) {
        if (value) {
          Navigator.pushNamed(
            context,
            VerifyOtp.routeName,
            arguments: VerifyOtpArgs(
              isLoggingIn: true,
              phone: phone,
              requestId: reqId,
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
              Navigator.pushNamed(context, EmailSignInPage.routeName),
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

    final termsAndConditions = Center(
      child: RichText(
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
            TextSpan(
              text: ' & ',
              style: Theme.of(context).textTheme.bodySmall!,
            ),
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
        appBar: AppBar(title: const Text('Sign in')),
        body: Padding(
          padding: EdgeInsets.all(
            appWidth * 0.05,
          ).copyWith(bottom: appHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/auth/login.png'),
                    // SizedBox(height: appHeight * 0.05),
                    signInWithGoogleBtn,
                    if (Platform.isIOS) SizedBox(height: appHeight * 0.01),
                    if (Platform.isIOS)
                      Row(
                        children: [
                          SizedBox(width: appWidth * 0.03),
                          const Expanded(
                            child: Divider(
                              // thickness: 4,
                              // height: 4,
                              // indent: appWidth * 0.2,
                              // endIndent: appWidth * 0.2,
                              color: AppColors.grey,
                            ),
                          ),
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

                    Platform.isIOS
                        ? Row(
                            children: [
                              SizedBox(width: appWidth * 0.03),
                              const Expanded(
                                child: Divider(
                                  // thickness: 4,
                                  // height: 4,
                                  // indent: appWidth * 0.2,
                                  // endIndent: appWidth * 0.2,
                                  color: AppColors.grey,
                                ),
                              ),
                              SizedBox(width: appWidth * 0.03),
                              Text(
                                'or',
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(color: AppColors.grey),
                              ),
                              SizedBox(width: appWidth * 0.03),
                              const Expanded(
                                child: Divider(color: AppColors.grey),
                              ),
                              SizedBox(width: appWidth * 0.03),
                            ],
                          )
                        : const SizedBox.shrink(),
                    SizedBox(height: appHeight * 0.01),
                    signInWithEmailBtn,
                    SizedBox(height: appHeight * 0.02),
                    signInWithPhoneNumberBtn,
                    Platform.isIOS
                        ? InkWell(
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
                          )
                        : const SizedBox.shrink(),

                    /// This is currently commented out because we are not using phone number login
                    // Container(
                    //     padding: EdgeInsets.all(appHeight * 0.02),
                    //     decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(20)),
                    //     child: Column(children: [
                    //       Text(
                    //         'Enter your phone number to login',
                    //         style: Theme.of(context).textTheme.bodyLarge,
                    //       ),
                    //       gapV025,
                    //       PhoneNumberField(
                    //           phoneCodeController: _phoneCode,
                    //           phoneNumController: _phoneNum),
                    //       gapV025,
                    //       switchToSignUp
                    //     ]))
                  ],
                ),
              ),
              termsAndConditions,
              gapV025,
              // signInBtn
            ],
          ),
        ),
      ),
    );
  }
}
