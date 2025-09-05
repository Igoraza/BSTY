import 'dart:developer';
import 'dart:ui';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/common_widgets/upgrade_plan_dialog.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/boxed_text.dart';
import '../../../../../common_widgets/stadium_button.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/likes_model.dart';
import '../../detailed/person_details_page.dart';

class ProfileViewCard extends StatelessWidget {
  const ProfileViewCard(this.user, {super.key});

  final LikedUser user;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final authPro = context.read<AuthProvider>();

    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;

    log('${userPlan > 2 && !planExpired}');

    return GestureDetector(
      onTap: () => {
        if (userPlan > 2 && !planExpired)
          {
        Navigator.pushNamed(
          context,
          PersonDetailedPage.routeName,
          arguments: {
            'id': user.id,
            'name': user.name,
            'image': user.displayImage,
          },
        ),
        }
      },
      child: Container(
        // padding: EdgeInsets.all(appWidth * 0.02),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: AppColors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(appWidth * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset('assets/svg/online/active.svg'),

                      /// [ Person Image ]
                      CircleAvatar(
                        radius: authPro.isTab
                            ? (appWidth / 4) - (appWidth * 0.158)
                            : (appWidth / 4) - (appWidth * 0.12),
                        foregroundImage: CachedNetworkImageProvider(
                          user.displayImage,
                        ),
                      ),
                      SvgPicture.asset('assets/svg/online/heart.svg'),
                    ],
                  ),
                  SizedBox(height: appHeight * 0.01),

                  /// [ Profile name ]
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.bodyLarge!.merge(
                      const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: appHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: SvgPicture.asset('assets/svg/explore/info.svg'),
                      ),
                      BoxedText(
                        text: '${user.age}',
                        padding: EdgeInsets.symmetric(
                          horizontal: appWidth * 0.04,
                          vertical: 4,
                        ),
                      ),
                      SvgPicture.asset('assets/svg/explore/comment.svg'),
                    ],
                  ),
                ],
              ),
            ),
            if (planExpired)
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  // padding: EdgeInsets.all(appWidth * 0.02),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    // color: A
                    // ppColors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        // height: appHeight * 0.04,
                        // width: appWidth * 0.02,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: appHeight * 0.02,
                            right: appHeight * 0.02,
                            bottom: appHeight * 0.02,
                          ),
                          child: FittedBox(
                            alignment: Alignment.bottomCenter,
                            child: StadiumButton(
                              // margin: EdgeInsets.only(top: appHeight * 0.1),
                              padding: EdgeInsets.only(
                                left: appHeight * 0.02,
                                right: appHeight * 0.02,
                              ),
                              onPressed: () {
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => UpgradePlanDialog(),
                                // );

                                Navigator.pushNamed(
                                  context,
                                  UpgradePlanScreen.routeName,
                                );
                              },
                              text: 'See Who Viewed You !',
                              visualDensity: VisualDensity.standard,
                              gradient: AppColors.orangeYelloH,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
