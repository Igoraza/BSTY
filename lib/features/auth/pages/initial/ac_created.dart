import 'package:flutter/material.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/primary_button.dart';
import '../../../../utils/theme/colors.dart';
import '../verification/verify_phone_page.dart';

class AccountCreated extends StatelessWidget {
  static const String routeName = '/ac-created';
  const AccountCreated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    return BackgroundImage(
      child: Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/auth/ac_created.png',
                      width: appWidth * 0.5,
                      height: appHeight * 0.2,
                    ),
                    SizedBox(height: appHeight * 0.05),
                    Container(
                        padding: EdgeInsets.all(appHeight * 0.02),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ]),
                        child: Column(children: [
                          SizedBox(height: appHeight * 0.03),
                          Text('Account Created!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: AppColors.pink,
                                  )),
                          SizedBox(height: appHeight * 0.04),
                          Text('Your account has been created\nsuccessfully.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: AppColors.disabled)),
                          SizedBox(height: appHeight * 0.04),
                          PrimaryBtn(
                              width: appWidth,
                              text: 'Complete Profile',
                              gradient: AppColors.buttonBlue,
                              onPressed: () => Navigator.pushNamed(
                                    context,
                                    VerifyPhone.routeName,
                                  )),
                          SizedBox(height: appHeight * 0.02),
                        ])),
                    SizedBox(height: appHeight * 0.04),
                  ]))),
    );
  }
}
