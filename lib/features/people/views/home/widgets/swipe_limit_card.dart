import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../../common_widgets/circle_container.dart';
import '../../../../../utils/theme/colors.dart';

class SwipeLimitCard extends StatelessWidget {
  const SwipeLimitCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final userImage = Hive.box('user').get('display_image') ?? '';

    return Container(
        width: size.width * 0.85,
        height: size.height * 0.525,
        padding: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: AppColors.buttonBlueVertical,
        ),
        child: Column(children: [
          Expanded(
              child: Center(
                  child: Stack(alignment: Alignment.center, children: [
            /// [Ripple] layers on back of user image
            CircleContainer(
                size: size.width * 0.7, opacity: 0.1, color: AppColors.white),
            CircleContainer(
                size: size.width * 0.6, opacity: 0.1, color: AppColors.white),
            CircleContainer(
                size: size.width * 0.5, opacity: 0.1, color: AppColors.white),
            CircleContainer(
                size: size.width * 0.4, opacity: 0.1, color: AppColors.white),

            /// [User Image]
            Container(
                width: size.width * 0.3,
                height: size.width * 0.3,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CachedNetworkImage(
                    imageUrl: userImage,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(
                        Icons.person_rounded,
                        size: size.width * 0.25,
                        color: AppColors.white)))
          ]))),
          Text('Explore more..?',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: AppColors.white, fontSize: 24)),
          const SizedBox(height: 4),
          Text('Update your preferences\n& Try again!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.white))
        ]));
  }
}
