import 'dart:developer';

import 'package:bsty/features/auth/models/sign_up_model.dart';
import 'package:bsty/features/auth/models/verify_otp_args.dart';
import 'package:bsty/features/auth/pages/initial_profile_steps/select_dob_page.dart';
import 'package:bsty/features/auth/pages/verification/verify_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/loading_animations.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../utils/constants/input_decorations.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/theme/colors.dart';
import '../../enums.dart';
import '../../services/auth_provider.dart';
import '../../widgets/phone_number_field.dart';

class VerifyPhone extends StatefulWidget {
  static const String routeName = '/verify-email';
  const VerifyPhone({Key? key}) : super(key: key);

  static final formkey = GlobalKey<FormState>();

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final _phoneNum = TextEditingController(text: '');

  final _phoneCode = TextEditingController(text: '+91');

  final _referralCode = TextEditingController();

  final _nameController = TextEditingController();

  Future<void>? validatePhone(BuildContext context) async {
    log("Validating phone");
    if (VerifyPhone.formkey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        showSnackBar('User Name is required');
        return;
      }
      VerifyPhone.formkey.currentState!.save();
      if (_phoneNum.text.isEmpty) {
        showSnackBar('Phone number is required');
        return;
      }
      if (!_phoneNum.text.contains(RegExp("^[0-9]+\$"))) {
        showSnackBar('Enter a valid phone number');
        return;
      }

      final reqId = DateTime.now().millisecondsSinceEpoch.toString();
      final phone = _phoneCode.text.substring(1) + _phoneNum.text;
      final userData = SignUpModel(
        name: _nameController.text,
        phone: phone,
        requestId: reqId,
      );
     
      context.read<AuthProvider>().signUp(context, userData).then((requestId) {
        log("Request id $requestId");
        if (requestId != null) {
          Navigator.pushNamed(
            context,
            VerifyOtp.routeName,
            arguments: VerifyOtpArgs(
              isLoggingIn: false,
              name: _nameController.text,
              phone: phone,
              requestId: requestId,
            ),
          );
          // Navigator.of(context).pushReplacementNamed(SelectDob.routeName);
        }
      });
      await AuthProvider().updatePhone(
        context,
        phone: _phoneCode.text + _phoneNum.text,
        referralCode: _referralCode.text,
      );
      log('------validate phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appHeight = MediaQuery.of(context).size.height;
    final appWidth = MediaQuery.of(context).size.width;
    // _nameController.text = widget.name;
    // late String email;

    /// [ Functions ]

    // void sendEmailOtp() async {
    //   if (formkey.currentState!.validate()) {
    //     formkey.currentState!.save();
    //     context.read<AuthProvider>().verifyEmail(context, email).then((value) {
    //       if (value) {za
    //         Navigator.of(context).pushReplacementNamed(SelectDob.routeName);
    //       }
    //     });
    //   }
    // }

    // [ Widgets ]

    final verifyBtn = Consumer<AuthProvider>(
      builder: (_, authProvider, __) => StadiumButton(
        visualDensity: VisualDensity.standard,
        gradient: AppColors.buttonBlue,
        onPressed: () async {
          await validatePhone(context);
        },
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

    final formFields = Form(
      key: VerifyPhone.formkey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: kInputDecoration.copyWith(
              hintText: 'Name',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset('assets/images/auth/referral_code.svg'),
              ),
            ),
          ),
          SizedBox(height: appHeight * 0.02),
          PhoneNumberField(
            phoneCodeController: _phoneCode,
            phoneNumController: _phoneNum,
          ),
        ],
      ),
      //  TextFormField(
      //     decoration: kInputDecoration.copyWith(
      //         hintText: 'Email ID',
      //         prefixIcon: const Icon(Icons.email_rounded)),
      //     keyboardType: TextInputType.emailAddress,
      //     validator: (val) => EmailValidator.validate(val!)
      //         ? null
      //         : 'Please enter a valid email address',
      //     onSaved: (val) => email = val ?? ''
      //     ),
    );

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Phone Number')),
        body: Padding(
          padding: EdgeInsets.all(
            appWidth * 0.05,
          ).copyWith(bottom: appHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: appHeight * 0.06),
                      SvgPicture.asset('assets/images/auth/ac_recovery.svg'),
                      SizedBox(height: appHeight * 0.03),
                      Container(
                        padding: EdgeInsets.all(appHeight * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // const Text(
                            //     'We will send a mail to the email address you registered to regain your account. Just enter your email.',
                            //     textAlign: TextAlign.center),
                            // SizedBox(height: appHeight * 0.02),
                            formFields,
                            SizedBox(height: appHeight * 0.02),
                            // TextField(
                            //   controller: _referralCode,
                            //   decoration: kInputDecoration.copyWith(
                            //     hintText: 'Enter Referral Code',
                            //     prefixIcon: Padding(
                            //       padding: const EdgeInsets.all(16.0),
                            //       child: SvgPicture.asset(
                            //         'assets/images/auth/referral_code.svg',
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: appHeight * 0.025),
              verifyBtn,
            ],
          ),
        ),
      ),
    );
  }
}
