import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../utils/global_keys.dart';
import '../../../utils/theme/colors.dart';
import '../../people/views/detailed/person_details_page.dart';
import '../models/map_user.dart';

class MapItem extends StatelessWidget {
  const MapItem({super.key, required this.user, required this.index});

  final MapUser user;
  final int index;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () {
            if (userPlan == 4 && !planExpired) {
              navigatorKey.currentState!.pushNamed(
                PersonDetailedPage.routeName,
                arguments: {
                  'id': user.id,
                  'name': user.name,
                  'image': user.image,
                },
              );
            } else {
              showDialog(
                  context: context,
                  builder: (context) => UpgradePlanDialog(
                        title: 'Premium',
                      ));
            }
          },
          child: CircleAvatar(
            radius: size.width * 0.055,
            backgroundColor: AppColors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: size.width * 0.05,
                  foregroundImage: CachedNetworkImageProvider(user.image),
                ),
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.005),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size.width * 0.05),
                  ),
                  child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(size.width * 0.05),
                      child: BackdropFilter(
                          filter: userPlan == 4 && !planExpired
                              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                              : ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            // height: appHeight * 0.04,
                            // width: appWidth * 0.02,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.0),
                            ),
                          ))),
                ),
              ],
            ),
          ),
        ),
        // if (userPlan == 4 && !planExpired)
        Text(userPlan == 4 && !planExpired ? user.name : '',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: AppColors.white)),
        // if (userPlan == 4 && !planExpired)
        Text(
            userPlan == 4 && !planExpired
                ? '${user.distance.toString()} miles'
                : '',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: AppColors.white))
      ],
    );
  }
}
