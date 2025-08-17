import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/primary_button.dart';
import '../../../../utils/constants/input_decorations.dart';
import '../../../../utils/theme/colors.dart';
import 'ac_created.dart';

class AccountRecovery extends StatelessWidget {
  static const routeName = '/ac-recovery';
  const AccountRecovery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    return BackgroundImage(
        child: Scaffold(
            appBar: AppBar(title: const Text('Account Recovery')),
            body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                            SizedBox(height: appHeight * 0.06),
                            SvgPicture.asset(
                                'assets/images/auth/ac_recovery.svg'),
                            SizedBox(height: appHeight * 0.03),
                            Container(
                                padding: EdgeInsets.all(appHeight * 0.02),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(children: [
                                  const Text(
                                      'We will send a mail to the email address you registered to regain your account. Just enter you email.',
                                      textAlign: TextAlign.center),
                                  SizedBox(height: appHeight * 0.02),
                                  TextField(
                                      decoration: kInputDecoration.copyWith(
                                          hintText: 'Email ID',
                                          prefixIcon:
                                              const Icon(Icons.email_rounded)),
                                      keyboardType: TextInputType.emailAddress),
                                ]))
                          ]))),
                      SizedBox(height: appHeight * 0.025),
                      PrimaryBtn(
                          text: 'Continue',
                          gradient: AppColors.buttonBlue,
                          onPressed: () {
                            debugPrint('Account created');
                            Navigator.pushNamed(
                                context, AccountCreated.routeName);
                          }),
                      SizedBox(height: appHeight * 0.04)
                    ]))));
  }
}
