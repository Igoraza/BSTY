import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/loading_animations.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../screens/main/main_page.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/theme/colors.dart';
import '../../enums.dart';
import '../../models/verify_otp_args.dart';
import '../../services/auth_provider.dart';
import '../initial/ac_created.dart';
import '../initial_profile_steps/select_dob_page.dart';

class VerifyOtp extends StatelessWidget {
  const VerifyOtp(this.args, {Key? key}) : super(key: key);

  final VerifyOtpArgs args;

  static const String routeName = '/verify-otp';

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    String otp = '';

    /// [ Functions ]
    void verifyOtp(BuildContext context, String otp) {
      final authProvider = context.read<AuthProvider>();
      try {
        (args.isEmail
                ? authProvider.verifyEmailOtp(context)
                : authProvider.verifyOtp(context, otp: otp, args: args))
            .then((value) {
          if (value) {
            showSnackBar('OTP verified successfully.');
            args.isLoggingIn
                ? Navigator.of(context).pushNamedAndRemoveUntil(
                    MainPage.routeName, (route) => false)
                : args.isEmail
                    ? Navigator.of(context)
                        .pushReplacementNamed(SelectDob.routeName)
                    : Navigator.pushReplacementNamed(
                        context, AccountCreated.routeName);
          }
        });
      } catch (e) {
        showSnackBar(e.toString());
      }
    }

    /// [ Widgets ]
    final pinCodeField = PinCodeTextField(
      length: 4,
      obscureText: false,
      animationType: AnimationType.fade,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.circle,
        fieldHeight: 60,
        fieldWidth: 60,
        activeColor: AppColors.lighterGrey,
        activeFillColor: AppColors.lighterGrey,
        selectedColor: AppColors.lighterGrey,
        selectedFillColor: AppColors.lighterGrey,
        inactiveColor: AppColors.lighterGrey,
        inactiveFillColor: AppColors.lighterGrey,
      ),
      textStyle: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(color: AppColors.pink),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      onCompleted: (otp) => verifyOtp(context, otp),
      onChanged: (value) => otp = value,
      beforeTextPaste: (text) {
        debugPrint("Allowing to paste $text");
        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
        //but you can show anything you want here, like your pop up saying wrong paste format or etc
        return true;
      },
      appContext: context,
    );

    final continueBtn = Consumer<AuthProvider>(builder: (_, authProvider, __) {
      return StadiumButton(
          gradient: AppColors.buttonBlue,
          visualDensity: VisualDensity.standard,
          onPressed: authProvider.authStatus == AuthStatus.checking
              ? null
              : () => verifyOtp(context, otp),
          child: authProvider.authStatus == AuthStatus.checking
              ? const BtnLoadingAnimation()
              : Text('Verify Now',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: AppColors.white)));
    });

    return BackgroundImage(
        child: Scaffold(
            appBar: AppBar(title: const Text('OTP Verification')),
            body: Padding(
                padding: EdgeInsets.all(appWidth * 0.05)
                    .copyWith(bottom: appHeight * 0.05),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: ListView(children: [
                        SizedBox(height: appHeight * 0.06),
                        SvgPicture.asset(
                            'assets/images/auth/${args.isEmail ? 'ac_recovery_otp.svg' : 'otp_verify.svg'}'),
                        SizedBox(height: appHeight * 0.03),
                        Container(
                            padding: EdgeInsets.all(appHeight * 0.02),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(children: [
                              Text(
                                'An OTP has been sent to',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                '+${args.isEmail ? args.email! : args.phone!}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(height: appHeight * 0.025),
                              pinCodeField,
                              SizedBox(height: appHeight * 0.025),
                              Text(
                                'I didn\'t receive code.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const ResendOtpAndTimeLeft()
                            ]))
                      ])),
                      continueBtn
                    ]))));
  }
}

class ResendOtpAndTimeLeft extends StatefulWidget {
  const ResendOtpAndTimeLeft({Key? key}) : super(key: key);

  @override
  State<ResendOtpAndTimeLeft> createState() => _ResendOtpAndTimeLeftState();
}

class _ResendOtpAndTimeLeftState extends State<ResendOtpAndTimeLeft> {
  bool _isResendEnabled = true;
  int _timeLeft = 0;
  late Timer _timer;

  void _startTimer() {
    _timeLeft = 20;
    setState(() => _isResendEnabled = false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        setState(() => _isResendEnabled = true);
      } else {
        setState(() => _timeLeft--);
        debugPrint('$_timeLeft sec left');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextButton(
          onPressed: _isResendEnabled ? () => _startTimer() : null,
          child: const Text('Resend Code')),
      _isResendEnabled
          ? const SizedBox.shrink()
          : Text('$_timeLeft sec left',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: AppColors.disabled))
    ]);
  }
}
