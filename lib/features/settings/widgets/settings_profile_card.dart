import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/auth/widgets/url_open.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants/web_view_urls.dart';
import '../../../utils/global_keys.dart';
import '../../../utils/theme/colors.dart';
import '../../auth/services/initial_profile_provider.dart';
import '../../profile/pages/edit_profile.dart';
import '../pages/refer_and_earn/refer_earn_page.dart';
import '../pages/settings_inner_page.dart';

class SettingsProfileCard extends StatefulWidget {
  const SettingsProfileCard({Key? key}) : super(key: key);

  @override
  State<SettingsProfileCard> createState() => _SettingsProfileCardState();
}

class _SettingsProfileCardState extends State<SettingsProfileCard> {
  bool isCompleted = true;

  bool isVerified = false;

  final userId = Hive.box('user').get('id') ?? '';
  final userName = Hive.box('user').get('name') ?? 'user';
  final userPlan = Hive.box('user').get('plan') ?? '1';
  final userImg = Hive.box('user').get('display_image') ?? '';
  final verified = Hive.box('user').get('verification_status') ?? 0;
  final completed = Hive.box('user').get('profile_completed') ?? false;
  final planExpired = Hive.box('user').get('plan_expired') ?? true;

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

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    return Container(
      width: appWidth,
      margin: EdgeInsets.all(appWidth * 0.04),
      padding: EdgeInsets.only(top: appHeight * 0.01, bottom: appHeight * 0.01),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 12.0,
              offset: Offset(0, 8),
            )
          ]),
      child: Column(children: [
        Stack(children: [
          CircleAvatar(
            radius: appWidth * 0.12,
            backgroundColor:
                completed == true ? AppColors.borderBlue : AppColors.deepOrange,
            child: Container(
              width: appWidth * 0.22,
              height: appWidth * 0.22,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: userImg,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          /// show [ blue tick ] if user is verified
          // if (verified == 1)
          //   Positioned(
          //       bottom: 0,
          //       right: 0,
          //       child: Container(
          //           width: appWidth * 0.07,
          //           height: appWidth * 0.07,
          //           decoration: const BoxDecoration(
          //               color: AppColors.borderBlue,
          //               shape: BoxShape.circle,
          //               border: Border.fromBorderSide(
          //                   BorderSide(color: AppColors.white, width: 2))),
          //           child: Icon(Icons.check_rounded,
          //               color: AppColors.white, size: appWidth * 0.04)))
          if (verified == 1)
            Positioned(
              right: 3,
              bottom: 5,
              child: Container(
                width: appWidth * 0.06,
                // height: appWidth * 0.02,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.white),
                child: ClipRect(
                  child: Image.asset(
                    'assets/images/verified.png',
                    color: AppColors.borderBlue,
                    // width: appWidth * .06,
                  ),
                ),
              ),
            )
        ]),
        SizedBox(height: appHeight * 0.01),
        Text(userName, style: Theme.of(context).textTheme.titleMedium),
        Text('Metfie ${planExpired ? 'Basic' : planToString()} User',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: AppColors.grey)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('id: '),
          GestureDetector(
              onTap: () => debugPrint('Copy ID'),
              child: Text("TM${userId.toString().padLeft(5, '0')}",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.blue, fontWeight: FontWeight.bold)))
        ]),
        isCompleted
            ? const SizedBox.shrink()
            : SizedBox(height: appHeight * 0.015),
        isCompleted
            // show [ edit profile button ] if profile is completed
            ? IconButton(
                onPressed: () =>
                    navigatorKey.currentState!.pushNamed(EditProfile.routeName),
                icon:
                    SvgPicture.asset('assets/svg/settings/edit.svg', width: 24),
              )
            // show [ profile completion percentage ] if profile is not completed
            : CircularPercentIndicator(
                radius: appWidth * 0.06,
                lineWidth: 10,
                percent: 0.6,
                center:
                    Text('60%', style: Theme.of(context).textTheme.bodySmall),
                // progressColor: AppColors.toggleBlue,
                linearGradient: AppColors.orangeYelloH,
                reverse: true,
                backgroundColor: AppColors.lightGrey,
                animation: true,
                animationDuration: 1200,
                circularStrokeCap: CircularStrokeCap.round,
                footer: TextButton(
                    onPressed: () async {
                      await Navigator.of(context)
                          .pushNamed(EditProfile.routeName);
                      setState(() {});
                    },
                    child: Text('Complete Profile',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: AppColors.blue))),
              ),
        const Divider(height: 4),
        Row(children: [
          Expanded(
              child: TextButton(
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .pushNamed(SettingsInnerPage.routeName);
                    await context
                        .read<InitialProfileProvider>()
                        .getProfileConfig();
                  },
                  child: Column(children: [
                    SvgPicture.asset('assets/svg/settings/cog.svg'),
                    const SizedBox(height: 8),
                    Text('Settings',
                        style: Theme.of(context).textTheme.bodySmall)
                  ]))),
          Expanded(
              child: TextButton(
                  onPressed: () {
                    debugPrint('Refer & Earn');
                    Navigator.of(context).pushNamed(ReferEarnPage.routeName);
                  },
                  child: Column(children: [
                    SvgPicture.asset('assets/svg/settings/earn.svg'),
                    const SizedBox(height: 8),
                    Text('Refer & Earn',
                        style: Theme.of(context).textTheme.bodySmall)
                  ]))),
          Expanded(
              child: TextButton(
                  onPressed: () async {
                    // openWebsite();
                    openBrowser(WebViewUrls.safetyModules);
                    // navigatorKey.currentState!.pushNamed(WebViewPage.routeName,
                    //     arguments: WebViewUrls.safetyModules);
                  },
                  // => navigatorKey.currentState!
                  //     .pushNamed(HowToGuidePages.routeName),
                  child: Column(children: [
                    SvgPicture.asset('assets/svg/settings/safety.svg'),
                    const SizedBox(height: 8),
                    Text('Safety Module',
                        style: Theme.of(context).textTheme.bodySmall)
                  ])))
        ])
      ]),
    );
  }
}
