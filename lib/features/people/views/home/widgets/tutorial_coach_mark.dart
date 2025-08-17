import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> createTargets(GlobalKey _containerKey, Size size) {
  List<TargetFocus> targets = [];
  targets.add(
    TargetFocus(
      identify: '_containerKey',
      keyTarget: _containerKey,

      // targetPosition: TargetPosition(),
      // alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
              top: size.height * 0.22,
              bottom: size.height * 0.3,
              left: 30,
              right: 30),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/guide/swipe_right.svg'),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Text(
                  "LIKE BY SWIPING RIGHT",
                  style: TextStyle(
                    color: Colors.transparent,
                    fontSize: 22,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.amber.shade900,
                    decorationThickness: 2,
                    shadows: const [
                      Shadow(color: AppColors.white, offset: Offset(0, -5))
                    ],
                  ),
                ),
                const Text(
                  "Matching requires mutual liking.\nGive it a try!",
                  style: TextStyle(
                    color: AppColors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
      shape: ShapeLightFocus.RRect,
      radius: 30,
    ),
  );
  targets.add(
    TargetFocus(
      identify: '_containerKey',
      keyTarget: _containerKey,
      // targetPosition: TargetPosition(),
      // alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
              top: size.height * 0.22,
              bottom: size.height * 0.3,
              left: 30,
              right: 30),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/guide/swipe_left.svg'),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Text(
                  "PASS BY SWIPING LEFT",
                  style: TextStyle(
                    color: Colors.transparent,
                    fontSize: 22,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.amber.shade900,
                    decorationThickness: 2,
                    shadows: const [
                      Shadow(color: AppColors.white, offset: Offset(0, -5))
                    ],
                  ),
                ),
                const Text(
                  "If you're not into them, swipe left to\npass. It's your secret.",
                  style: TextStyle(
                    color: AppColors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
      shape: ShapeLightFocus.RRect,
      radius: 30,
    ),
  );
  return targets;
}
