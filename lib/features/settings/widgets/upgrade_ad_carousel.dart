import 'dart:developer';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common_widgets/buy_plan_dialog.dart';
import '../../../common_widgets/stadium_button.dart';
import '../../../utils/constants/plan_price_details.dart';
import '../../../utils/theme/colors.dart';
import '../../membership/pages/all_plans_details_carousel.dart';

class UpgradeAdCarousel extends StatelessWidget {
  UpgradeAdCarousel({super.key});

  final _currentSlide = ValueNotifier<int>(0);

  final List<Map<String, dynamic>> pageTitles = [
    {
      'title': 'Upgrade to plus !',
      'subtitle': 'Most affordable pack',
      'icon': 'assets/svg/membership/crownPlus.svg',
      'gradient': AppColors.pinkPurpleH,
    },
    {
      'title': 'Upgrade to premium !',
      'subtitle': 'Feature rich pack',
      'icon': 'assets/svg/settings/crownPremium.svg',
      'gradient': AppColors.yellowOrangeH,
    },
    {
      'title': 'Get More Boosts !',
      'subtitle': 'Comes with premium',
      'icon': 'assets/svg/settings/boost.svg',
      'gradient': AppColors.redOrangeV,
    },
    {
      'title': 'Get more Super likes !',
      'subtitle': 'Comes with premium',
      'icon': 'assets/svg/settings/superlike.svg',
      'gradient': AppColors.buttonBlueVertical,
    },
    {
      'title': 'Get more Minutes !',
      'subtitle': 'Comes with premium',
      'icon': 'assets/svg/membership/get_minutes.svg',
      'gradient': AppColors.purpleH,
    },
  ];

  final PlanPriceDetails planDetails = PlanPriceDetails();

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    return Container(
      width: appWidth,
      height: appHeight * 0.3,
      margin: EdgeInsets.symmetric(horizontal: appWidth * 0.04),
      padding: EdgeInsets.symmetric(vertical: appWidth * 0.02),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Color.fromRGBO(255, 255, 255, 0.5),
      ),
      //carousel with indicator
      child: CarouselSlider(
        options: CarouselOptions(
          height: appHeight * 0.3 + 37,
          viewportFraction: 1,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index, reason) => _currentSlide.value = index,
        ),
        items: pageTitles
            .map(
              (e) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    e['icon'],
                    width: appWidth * 0.10,
                    height: appWidth * 0.10,
                  ),
                  SizedBox(height: appHeight * 0.005),
                  Text(
                    e['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: appHeight * 0.005),
                  Text(e['subtitle']),
                  SizedBox(height: appHeight * 0.015),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pageTitles.length, (i) {
                      return ValueListenableBuilder(
                        valueListenable: _currentSlide,
                        builder: (context, value, child) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentSlide.value == i
                                ? AppColors.disabled
                                : AppColors.lightGrey,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: appHeight * 0.015),
                  StadiumButton(
                    onPressed: () {
                      if (e['title'] == 'Get More Boosts !') {
                        // showDialog(
                        //     context: context,
                        //     builder: (context) => BuyPlanDialog(
                        //           title: 'Boosts',
                        //           desc:
                        //               'Buy Profile Boosts As Needed !',
                        //           img:
                        //               'assets/svg/upgrade_dialog/profile_boosts.svg',
                        //           btnText: 'Buy Now',
                        //           paymentList: planDetails.payBoosts,
                        //         ),);
                        Navigator.pushNamed(
                          context,
                          UpgradePlanScreen.routeName,
                          arguments: "Boost",
                        );
                      } else if (e['title'] == 'Get more Super likes !') {
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => BuyPlanDialog(
                        //     title: 'SuperLikes',
                        //     desc: 'Buy SuperLikes As Needed !',
                        //     img: 'assets/svg/upgrade_dialog/super_likes.svg',
                        //     btnText: 'Buy Now',
                        //     paymentList: planDetails.payLikes,
                        //   ),
                        // );

                        Navigator.pushNamed(
                          context,
                          UpgradePlanScreen.routeName,
                          arguments: "Like",
                        );
                      } else if (e['title'] == 'Get more Minutes !') {
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => BuyPlanDialog(
                        //     // title: 'Minute Of Voice',
                        //     desc: 'Buy Audio Minutes As Needed !',
                        //     img: 'assets/svg/upgrade_dialog/minute.svg',
                        //     btnText: 'Buy Now',
                        //     paymentList: planDetails.payAudio,
                        //   ),
                        // );
                        Navigator.pushNamed(
                          context,
                          UpgradePlanScreen.routeName,
                          arguments: "Minutes",
                        );
                      } else if (e['title'] == 'Upgrade to premium !') {
                        log(e['title']);
                        Navigator.of(context).pushNamed(
                          AllPlansDetails.routeName,
                          arguments: PageController(
                            initialPage: 1,
                            keepPage: true,
                            viewportFraction: 1,
                          ),
                        );
                      } else {
                        Navigator.of(context).pushNamed(
                          AllPlansDetails.routeName,
                          arguments: PageController(
                            initialPage: 0,
                            keepPage: true,
                            viewportFraction: 1,
                          ),
                        );
                      }
                    },
                    text: 'LEARN MORE',
                    gradient: e['gradient'],
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
