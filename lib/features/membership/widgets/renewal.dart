import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/stadium_button.dart';
import '../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../utils/theme/colors.dart';

class Renewal extends StatelessWidget {
  const Renewal({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final userBox = Hive.box('user');
    final userImage = userBox.get('display_image');
    final userPlan = userBox.get('plan');
    final planExpired = userBox.get('plan_expired') ?? true;
    final planExpiry = userBox.get('plan_expiry') ?? '';
    // final authPro = context.read<AuthProvider>();

    String expiryDate = '';
    if (planExpiry != '') {
      log(planExpiry.toString());
      // DateTime parseDate =
      //     DateFormat("yyyy-MM-dd'T'HH:mm:ss:SS'Z'").parse(planExpiry);

      var inputDate = DateTime.parse(planExpiry.toString()).toLocal();
      log(inputDate.isUtc.toString());
      // var outputFormat = DateFormat('dd/MM/yyyy hh:mm a');
      expiryDate = DateFormat.yMMMMd().add_jm().format(inputDate);
      // outputFormat.format(inputDate);
      //  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
// formatter.timeZone = 'Europe/Paris';
      log(expiryDate.toString());
      // log(inputDate.toString());
      if (inputDate.isBefore(DateTime.now())) {
        debugPrint(
            '----------------------------------------------------$expiryDate');
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
      padding: EdgeInsets.symmetric(vertical: mq.height * 0.08),
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
                )
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
                'Expiration Date:\n$expiryDate',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge!.copyWith(
                  color: AppColors.deepOrange,
                ),
              ),
            SizedBox(height: mq.height * 0.04),
            StadiumButton(
              text: 'Renewal',
              gradient: AppColors.orangeYelloH,
              onPressed: () {
                // showPaymentNotAvailableDialog();
                showDialog(
                    context: context,
                    builder: (context) => UpgradePlanDialog(
                          title: 'Premium',
                        ));
              },
            )
          ],
        ),
      ),
    );
  }
}
