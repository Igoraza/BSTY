import 'dart:developer';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/common_widgets/buy_plan_dialog.dart';
import 'package:bsty/common_widgets/custom_icon_btn.dart';
import 'package:bsty/common_widgets/upgrade_plan_dialog.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/services/in_app.dart/in_app_provider.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/stadium_button.dart';
import '../../../utils/constants/plan_price_details.dart';
import '../../../utils/theme/colors.dart';

class Credits extends StatelessWidget {
  const Credits({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final authPro = context.read<AuthProvider>();

    // final superLikes = Hive.box('user').get('super_like_balance') ?? 0;
    // final profileBoost = Hive.box('user').get('profile_boost_balance') ?? 0;
    // final audioCall = Hive.box('user').get('audio_call_balance') ?? 0;
    // final videoCall = Hive.box('user').get('video_call_balance') ?? 0;
    // log(profileBoost.runtimeType.toString());
    // final inAppProvider = context.read<InAppProvider>();
    // List<Map<String, dynamic>> data = [
    //   {
    //     'icon': 'assets/svg/settings/superlike.svg',
    //     'title': 'super likes',
    //     'count': superLikes.toString(),
    //     'bg': AppColors.borderBlue,
    //   },
    //   {
    //     'icon': 'assets/svg/settings/boost.svg',
    //     'title': 'boosts',
    //     // 'count': context.read<InAppProvider>().boost.toString(),
    //     'count': profileBoost.toString(),
    //     'bg': AppColors.borderBlue,
    //   },
    //   {
    //     'icon': 'assets/svg/chat/mic_enabled.svg',
    //     'title': 'minutes of voice',
    //     'count': audioCall.toString(),
    //     'bg': AppColors.borderBlue,
    //   },
    //   {
    //     'icon': 'assets/svg/chat/video_enabled.svg',
    //     'title': 'minutes of video',
    //     'count': videoCall.toString(),
    //     'bg': AppColors.borderBlue,
    //   },
    // ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height * 0.02),
      child: Container(
        // height: mq.height * 0.001,
        margin: EdgeInsets.all(mq.width * 0.07),
        padding: EdgeInsets.all(mq.width * 0.07),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 20.0)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<InAppProvider>(
              builder: (context, inAppPro, _) {
                final List<Map<String, dynamic>> data = [
                  {
                    'icon': 'assets/svg/settings/superlike.svg',
                    'title': 'super likes',
                    'count': inAppPro.superLikes.toString(),
                    'bg': AppColors.borderBlue,
                  },
                  {
                    'icon': 'assets/svg/settings/boost.svg',
                    'title': 'boosts',
                    'count': inAppPro.boost.toString(),
                    'bg': AppColors.borderBlue,
                  },
                  {
                    'icon': 'assets/svg/chat/mic_enabled.svg',
                    'title': 'minutes of voice',
                    'count': inAppPro.audioCall.toString(),
                    'bg': AppColors.borderBlue,
                  },
                  {
                    'icon': 'assets/svg/chat/video_enabled.svg',
                    'title': 'minutes of video',
                    'count': inAppPro.videoCall.toString(),
                    'bg': AppColors.borderBlue,
                  },
                ];
                return GridView.count(
                  crossAxisCount: authPro.isTab ? 3 : 2,
                  shrinkWrap: true,
                  childAspectRatio: authPro.isTab ? 1 / 1.48 : 1 / 1.3,
                  crossAxisSpacing: authPro.isTab
                      ? mq.width * 0.05
                      : mq.width * 0.07,
                  mainAxisSpacing: authPro.isTab
                      ? mq.width * 0.06
                      : mq.width * 0.07,
                  children: data
                      .map(
                        (e) => CreditCard(
                          icon: e['icon'],
                          title: e['title'],
                          count:
                              //  e['title'] == 'boosts'
                              //     ? inAppPr.boost.toString()
                              //     :
                              e['count'],
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            StadiumButton(
              text: 'Buy all in one plans',
              gradient: AppColors.orangeYelloH,
              padding: EdgeInsets.symmetric(
                horizontal: mq.width * 0.1,
                vertical: 10,
              ),
              onPressed: () {
                // showDialog(
                //     context: context,
                //     builder: (context) => UpgradePlanDialog());

                Navigator.pushNamed(context, UpgradePlanScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCard extends StatelessWidget {
  const CreditCard({
    super.key,
    required this.icon,
    required this.title,
    this.count = '0',
    this.bgColor = AppColors.borderBlue,
  });

  final String icon;
  final String title;
  final String count;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;

    final PlanPriceDetails planDetails = PlanPriceDetails();

    final mq = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          padding: EdgeInsets.all(mq.width * 0.04),
          margin: EdgeInsets.all(mq.width * 0.01),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(icon, width: mq.width * 0.1),
              const SizedBox(height: 7),
              Text(count, style: textTheme.titleMedium),
              const SizedBox(height: 7),
              Text(
                '${title.toUpperCase()} LEFT',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        CustomIconBtn(
          onTap: () {
            log("Title : $title");
            log("User plan : $userPlan");
            // if (userPlan > 2 && !planExpired) {
            if (title == 'super likes') {
              showDialog(
                context: context,
                builder: (context) => BuyPlanDialog(
                  title: 'SuperLikes',
                  desc: 'Buy SuperLikes As Needed !',
                  img: 'assets/svg/upgrade_dialog/super_likes.svg',
                  btnText: 'Buy Now',
                  paymentList: planDetails.payLikes,
                ),
              );
            } else if (title == 'boosts') {
              showDialog(
                context: context,
                builder: (context) => BuyPlanDialog(
                  title: 'Boosts',
                  desc: 'Buy Profile Boosts As Needed !',
                  img: 'assets/svg/upgrade_dialog/profile_boosts.svg',
                  btnText: 'Buy Now',
                  paymentList: planDetails.payBoosts,
                ),
              );
            } else if (title == 'minutes of voice') {
              // if (userPlan > 2 && !planExpired) {
              showDialog(
                context: context,
                builder: (context) => BuyPlanDialog(
                  // title: 'Minute Of Voice',
                  desc: 'Buy Audio Minutes As Needed !',
                  img: 'assets/svg/upgrade_dialog/minute.svg',
                  btnText: 'Buy Now',
                  paymentList: planDetails.payAudio,
                ),
              );
              // } else {
              //   // showDialog(
              //   //   context: context,
              //   //   builder: (context) => UpgradePlanDialog(),
              // }
            } else if (title == 'minutes of video') {
              // if (userPlan > 2 && !planExpired) {
              showDialog(
                context: context,
                builder: (context) => BuyPlanDialog(
                  // title: 'Minute Of Voice',
                  desc: 'Buy Video Minutes As Needed !',
                  img: 'assets/svg/upgrade_dialog/telephone.svg',
                  btnText: 'Buy Now',
                  paymentList: planDetails.payVideo,
                ),
              );
              // } else {
              // showDialog(
              //   context: context,
              //   builder: (context) => UpgradePlanDialog(),
              // );
              // Navigator.pushNamed(context, UpgradePlanScreen.routeName);
              // }
            }
            // showDialog(
            //     context: context,
            //     builder: (context) => const BuyPlanDialog(
            //           title: 'SuperLikes',
            //           desc: 'Buy SuperLikes As Needed !',
            //           img: 'assets/svg/upgrade_dialog/super_likes.svg',
            //           btnText: 'Buy Now',
            //         ));
          },
          bgColor: bgColor,
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(0),
          size: 24,
          child: const Icon(Icons.add, color: AppColors.white, size: 16),
        ),
      ],
    );
  }
}
