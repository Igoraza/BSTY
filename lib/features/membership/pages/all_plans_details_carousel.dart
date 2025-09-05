import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/common_widgets/upgrade_plan_dialog.dart';

import '../../../common_widgets/background_image.dart';
import '../../../common_widgets/stadium_button.dart';
import '../../../utils/theme/colors.dart';

class AllPlansDetails extends StatelessWidget {
  final PageController? controller;
  const AllPlansDetails({Key? key, this.controller}) : super(key: key);

  static const routeName = '/all-plans-details';

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    int currentIndex = 0;

    final featuresPre = [
      'Unlimited Swipes !',
      'Unlimited Rewinds !',
      'See Who Likes You !',
      'Priority Likes !',
      '5 Superlikes per month !',
      '5 Profile Boosts per month !',
      'More audio & video call minutes',
      'Incognito mode',
      'No advertisements',
      'BSTY passport',
    ];
    final featuresPlus = [
      'Unlimited Swipes !',
      'Unlimited Rewinds !',
      'See Who Likes You !',
      '2 Superlikes per month !',
      '2 Profile Boosts per month !',
      'Priority Likes !',
      'Profile navigation',
      'Incognito mode',
    ];

    final List<Map<String, dynamic>> plans = [
      // {
      //   'title': 'Lite',
      //   'price': '299',
      //   'icon': 'assets/svg/membership/crown_lite.svg',
      //   'features': '1',
      // },
      {
        'title': 'Plus',
        'price': 199,
        'icon': 'assets/svg/membership/crownPlus.svg',
        'features': '5',
      },
      {
        'title': 'Premium',
        'price': 599,
        'icon': 'assets/svg/membership/crown_premium.svg',
        'features': '10',
      },
    ];

    // void showPaymentNotAvailableDialog() {
    //   showDialog(
    //       context: context,
    //       builder: (context) => Dialog(
    //             child: Padding(
    //               padding: const EdgeInsets.all(16.0),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Text(
    //                     "Payment option is not currently available. We'll be adding it soon",
    //                     textAlign: TextAlign.center,
    //                     style: Theme.of(context).textTheme.titleMedium,
    //                   ),
    //                   const SizedBox(height: 20),
    //                   StadiumButton(
    //                     text: 'Ok',
    //                     bgColor: AppColors.black,
    //                     onPressed: () => Navigator.of(context).pop(),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ));
    // }

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Membership')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              // height: appHeight * 0.7,
              child: PageView.builder(
                controller: controller,
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  // log(index.toString());
                  currentIndex = index;
                  return Container(
                    margin: EdgeInsets.all(appWidth * 0.1),
                    padding: EdgeInsets.all(appWidth * 0.1),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      // border: Border.all(color: AppColors.white),
                      border: Border.all(color: AppColors.pink),
                      borderRadius: BorderRadius.circular(30),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: AppColors.black.withOpacity(0.2),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 5),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          plans[index]['icon']!,
                          height: appWidth * 0.2,
                        ),
                        SizedBox(height: appHeight * 0.01),
                        Text(
                          plans[index]['title']!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: appHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            plans.length,
                            (i) => Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == i
                                    ? AppColors.disabled
                                    : AppColors.lightGrey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: appHeight * 0.02),
                        Text(
                          'Starting @ INR ${plans[index]['price']!}/-',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: appHeight * 0.03),
                        Expanded(
                          child: ListView(
                            children: List.generate(
                              plans[index]['title']! == 'Plus'
                                  ? featuresPlus.length
                                  : featuresPre.length,
                              (i) => Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: appHeight * 0.005,
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      i < int.parse(plans[index]['features']!)
                                          ? 'assets/svg/membership/feature_check.svg'
                                          : 'assets/svg/membership/feature_lock.svg',
                                    ),
                                    SizedBox(width: appWidth * 0.03),
                                    Expanded(
                                      child: Text(
                                        plans[index]['title']! == 'Plus'
                                            ? featuresPlus[i]
                                            : featuresPre[i],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            StadiumButton(
              onPressed: () {
                // log(currentIndex.toString());
                if (currentIndex == 0) {
                  Navigator.pushNamed(context, UpgradePlanScreen.routeName);
                  // showDialog(
                  //     context: context,
                  //     builder: (context) => UpgradePlanDialog());
                } else if (currentIndex == 1) {
                  // showDialog(
                  //   context: context,
                  //   builder: (context) => UpgradePlanDialog(title: 'Premium'),
                  // );

                  Navigator.pushNamed(
                    context,
                    UpgradePlanScreen.routeName,
                    arguments: "Premium",
                  );
                }
              },
              text: 'Subscribe Now',
              gradient: AppColors.orangeYelloH,
            ),
            SizedBox(height: appHeight * 0.04),
          ],
        ),
      ),
    );
  }
}
