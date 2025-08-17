import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/loading_animations.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../utils/constants/input_decorations.dart';
import '../../../../utils/constants/web_view_urls.dart';
import '../../../../utils/global_keys.dart';
import '../../../../utils/theme/colors.dart';
import '../../../webview/webview.dart';
import '../../enums.dart';
import '../../services/auth_provider.dart';

class EmailSignInPage extends StatelessWidget {
  static const String routeName = '/signin';

  EmailSignInPage({Key? key}) : super(key: key);
  static final formkey = GlobalKey<FormState>();

  // final _phoneNum = TextEditingController(text: '');
  // final _phoneCode = TextEditingController(text: '+91');

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final authPro = context.read<AuthProvider>();
    // late String displayName;

    /// [ Functions ]
    Future<void> register() async {
      FocusManager.instance.primaryFocus?.unfocus();
      if (formkey.currentState!.validate()) {
        formkey.currentState!.save();
        await authPro.emailLogin(_email.text.trim(), _password.text.trim());
      }
    }

    /// [ Widgets ]

    // final nameField = TextFormField(
    //   decoration: kInputDecoration.copyWith(hintText: 'Full Name'),
    //   keyboardType: TextInputType.name,
    //   textInputAction: TextInputAction.next,
    //   validator: (val) =>
    //       val!.length < 3 ? 'Name should be at least 3 Characters long' : null,
    //   onSaved: (val) => displayName = val ?? '',
    // );

    final emailField = TextFormField(
      controller: _email,
      decoration: kInputDecoration.copyWith(hintText: 'E-mail'),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (val) =>
          !val!.contains('@') || val.isEmpty ? 'Enter a valid E-mail' : null,
    );

    final passwordField = Consumer<AuthProvider>(
        builder: (_, authProvider, __) => TextFormField(
              controller: _password,
              obscureText: !authProvider.passVisible,
              decoration: kInputDecoration.copyWith(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                      onPressed: () {
                        authProvider.passVisible = !authProvider.passVisible;
                      },
                      icon: authProvider.passVisible
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off))),
              // textInputAction: TextInputAction.next,
              validator: (val) =>
                  val!.isEmpty ? 'Enter a valid password' : null,
            ));

    // final phoneNumField = TextFormField(
    //     decoration: kInputDecoration.copyWith(hintText: 'Phone Number'),
    //     keyboardType: TextInputType.phone,
    //     textInputAction: TextInputAction.done,
    //     validator: (val) => val!.isEmpty ? 'Phone number is required' : null,
    //     onSaved: (val) => phone = val ?? '');

    // final haveAccountText =
    //     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    //   Text(
    //     'Already have an account?',
    //     style: Theme.of(context).textTheme.bodyLarge,
    //   ),
    //   TextButton(
    //       onPressed: () => Navigator.of(context).pop(),
    //       child: Text('Sign in !',
    //           style: Theme.of(context)
    //               .textTheme
    //               .titleMedium!
    //               .copyWith(color: AppColors.toggleBlue)))
    // ]);

    final termsAndPolicyText = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'By using our mobile app, you agree to our\n',
        style: Theme.of(context).textTheme.bodySmall!.merge(
              const TextStyle(height: 2),
            ),
        children: <TextSpan>[
          TextSpan(
              text: 'Terms of use',
              style: Theme.of(context).textTheme.bodySmall!.merge(
                  const TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.toggleBlue,
                      fontWeight: FontWeight.bold)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  navigatorKey.currentState!.pushNamed(WebViewPage.routeName,
                      arguments: WebViewUrls.termsOfService);
                }),
          TextSpan(text: ' & ', style: Theme.of(context).textTheme.bodySmall!),
          TextSpan(
            text: 'Privacy Policy',
            style: Theme.of(context).textTheme.bodySmall!.merge(const TextStyle(
                decoration: TextDecoration.underline,
                color: AppColors.toggleBlue,
                fontWeight: FontWeight.bold)),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                navigatorKey.currentState!.pushNamed(WebViewPage.routeName,
                    arguments: WebViewUrls.privacyPolicy);
              },
          ),
        ],
      ),
    );

    // final referralCodeText =
    //     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    //   TextButton.icon(
    //       onPressed: () {
    //         debugPrint('Referal pop up opened');
    //         showDialog(
    //             context: context, builder: (ctx) => const ReferCodeDialog());
    //       },
    //       icon: SvgPicture.asset('assets/images/auth/referral_code.svg'),
    //       label: Text('Have a referral code?',
    //           style: Theme.of(context)
    //               .textTheme
    //               .titleSmall!
    //               .copyWith(color: AppColors.toggleBlue)))
    // ]);

    final signUpBtn = Consumer<AuthProvider>(
      builder: (_, authProvider, __) {
        return StadiumButton(
          visualDensity: VisualDensity.standard,
          gradient: AppColors.buttonBlue,
          onPressed: authProvider.authStatus == AuthStatus.checking
              ? null
              : () => register(),
          child: authProvider.authStatus == AuthStatus.checking
              ? const BtnLoadingAnimation()
              : Text(
                  'Sign in',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: AppColors.white),
                ),
        );
      },
    );

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign in')),
        body: Padding(
          padding: EdgeInsets.all(appWidth * 0.05)
              .copyWith(bottom: appHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Image.asset('assets/images/auth/signup.png',
                        height: appHeight * 0.15),
                    SizedBox(height: appHeight * 0.07),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: appHeight * 0.04),
                          padding: EdgeInsets.all(appWidth * 0.05)
                              .copyWith(top: appHeight * 0.06),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Form(
                            key: formkey,
                            child: Column(
                              children: [
                                emailField,
                                SizedBox(height: appHeight * 0.025),
                                passwordField,
                                // PhoneNumberField(
                                //     phoneCodeController: _phoneCode,
                                //     phoneNumController: _phoneNum),
                                SizedBox(height: appHeight * 0.025),
                                // referralCodeText,
                                // haveAccountText
                                GestureDetector(
                                  onTap: () {
                                    navigatorKey.currentState!.pop();
                                  },
                                  child: Text(
                                    'If you want to register a new account please use\ngoogle${Platform.isIOS ? ' or apple ' : ' '}login',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SvgPicture.asset('assets/svg/sign_up/thumb.svg',
                            height: appHeight * 0.08)
                      ],
                    )
                  ],
                ),
              ),
              termsAndPolicyText,
              SizedBox(height: appHeight * 0.025),
              signUpBtn
            ],
          ),
        ),
      ),
    );
  }
}
