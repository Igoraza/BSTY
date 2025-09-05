import 'dart:developer';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:bsty/common_widgets/change_plan_dialog.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/stadium_button.dart';
import '../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../utils/theme/colors.dart';

class ChangePlan extends StatelessWidget {
  const ChangePlan({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final userBox = Hive.box('user');
    final userImage = userBox.get('display_image');
    final userPlan = userBox.get('plan');
    final planExpired = userBox.get('plan_expired') ?? true;
    final planExpiry = userBox.get('plan_expiry') ?? '';
    final planDuration = userBox.get('plan_duration');
    final authPro = context.read<AuthProvider>();

    log(userPlan.toString());

    const oneToNine = [
      "zero",
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine",
      "ten",
      "eleven",
      "twelve",
    ];

    String expiryDate = '';
    if (planExpiry != '') {
      log(planExpiry.toString());
      // DateTime parseDate =
      //     DateFormat("yyyy-MM-dd'T'HH:mm:ss:SS'Z'").parse(planExpiry);

      var inputDate = DateTime.parse(planExpiry.toString());
      // var outputFormat = DateFormat('dd/MM/yyyy hh:mm a');
      expiryDate = DateFormat.yMMMMd().add_jm().format(inputDate);
      // outputFormat.format(inputDate);

      // log(inputDate.toString());
      if (inputDate.isBefore(DateTime.now())) {
        expiryDate = 'Expired !';
      }

      // log(expiryDate);
    }

    String planToString() {
      switch (userPlan) {
        case 1:
          return 'Basic';
        case 2:
          return 'Lite';
        case 3:
          return 'Plus';
        case 4:
          return 'Premium';
        default:
          return '';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height * 0.06),
      child: Container(
        margin: EdgeInsets.all(mq.width * 0.05),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: mq.width * 0.15,
                  foregroundImage: CachedNetworkImageProvider(userImage),
                ),
                SvgPicture.asset(
                  'assets/svg/avatar/avatar_bg.svg',
                  height: mq.width * 0.35,
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.01),
            SvgPicture.asset('assets/svg/avatar/avatar_shadow.svg'),
            SizedBox(height: mq.height * 0.04),
            Text(
              'You are a ${planExpired ? "Basic" : planToString()} User',
              style: textTheme.titleMedium,
            ),
            SizedBox(height: mq.height * 0.01),
            if (expiryDate != '')
              Text(
                'Current Plan: ${oneToNine[planDuration].toUpperCase()} Month',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge!.copyWith(
                  color: AppColors.deepOrange,
                ),
              ),
            SizedBox(height: mq.height * 0.04),
            StadiumButton(
              text: 'Change',
              gradient: AppColors.orangeYelloH,
              onPressed: () {
                // showPaymentNotAvailableDialog();
                showDialog(
                  context: context,
                  builder: (context) => ChangePlanDialog(
                    controller: userPlan < 4 || planExpired
                        ? PageController(initialPage: 0)
                        : PageController(initialPage: 1),
                  ),
                );
              },
            ),
            if (userPlan < 4 || planExpired) SizedBox(height: mq.height * 0.03),
            // if (userPlan != 4 || !planExpired)
            if (userPlan < 4 || planExpired)
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      // thickness: 4,
                      // height: 4,
                      // indent: mq.height * 0.2,
                      // endIndent: mq.height * 0.2,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    'Or',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: AppColors.black),
                  ),
                  const Expanded(child: Divider(color: AppColors.grey)),
                ],
              ),
            if (userPlan < 4 || planExpired) SizedBox(height: mq.height * 0.03),
            if (userPlan < 4 || planExpired)
              StadiumButton(
                padding: authPro.isTab
                    ? EdgeInsets.symmetric(
                        horizontal: mq.width * 0.15,
                        vertical: mq.width * 0.03,
                      )
                    : EdgeInsets.symmetric(horizontal: mq.width * 0.1),
                text: 'Get BSTY Premium',
                gradient: AppColors.orangeYelloH,
                onPressed: () {
                  // showPaymentNotAvailableDialog();
                  // showDialog(
                  //     context: context,
                  //     builder: (context) => UpgradePlanDialog(
                  //           title: 'Premium',
                  //         ));

                  Navigator.pushNamed(
                    context,
                    UpgradePlanScreen.routeName,
                    arguments: "Premium",
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
