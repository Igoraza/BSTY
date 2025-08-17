import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/common_widgets/background_image.dart';
import 'package:bsty/common_widgets/stadium_button.dart';
import 'package:bsty/features/profile/pages/verify_identity_page.dart';
import 'package:bsty/screens/main/main_page.dart';
import 'package:bsty/utils/global_keys.dart';
import 'package:bsty/utils/theme/colors.dart';

class UnderReview extends StatefulWidget {
  const UnderReview({super.key});

  static const routeName = '/under-review';

  @override
  State<UnderReview> createState() => _UnderReviewState();
}

class _UnderReviewState extends State<UnderReview> {
  final userImg = Hive.box('user').get('display_image') ?? '';

  final userName = Hive.box('user').get('name') ?? 'user';

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final userBox = Hive.box('user');
    final verificationStatus = userBox.get('verification_status');
    log(verificationStatus.toString());
    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            verificationStatus == 1
                ? "Verified"
                : verificationStatus == 3
                    ? "Rejected"
                    : "Under Review",
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(15),
            height: screenH * 0.7,
            width: screenW,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  width: screenW * 0.6,
                  height: screenH * 0.1,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: screenH * 0.06,
                        width: screenH * 0.06,
                        decoration: BoxDecoration(
                          // color: AppColors.grey,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CachedNetworkImage(
                            imageUrl: userImg,
                            fit: BoxFit.fill,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontSize: 14),
                              overflow: TextOverflow.fade,
                            ),
                            // Text(
                            //   'Submitted on 12-05-2023',
                            //   style: Theme.of(context)
                            //       .textTheme
                            //       .bodyMedium!
                            //       .copyWith(fontSize: 9),
                            //   overflow: TextOverflow.fade,
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenW * 0.12,
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            SizedBox(
                              height: screenH * 0.04,
                            ),
                            VerificationStep(
                              height: screenH,
                              image: SvgPicture.asset(
                                'assets/svg/verification/check_all.svg',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                              // width: 200,
                              child: DashLineView(
                                dashColor: AppColors.medBlue,
                                direction: Axis.vertical,
                                // dashHeight: 8,
                              ),
                            ),
                            VerificationStep(
                              height: screenH,
                              image: SvgPicture.asset(
                                'assets/svg/verification/user_male.svg',
                                color: verificationStatus >= 2 ||
                                        verificationStatus == 1
                                    ? null
                                    : AppColors.grey.withOpacity(.3),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                              // width: 200,
                              child: DashLineView(
                                dashColor: AppColors.medBlue,
                                direction: Axis.vertical,
                                // dashHeight: 8,
                              ),
                            ),
                            // VerificationStep(
                            //   height: screenH,
                            //   image: SvgPicture.asset(
                            //     'assets/svg/verification/review_search.svg',
                            //     color: verificationStatus == 1
                            //         ? null
                            //         : AppColors.grey.withOpacity(.3),
                            //     fit: BoxFit.scaleDown,
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 20,
                            //   // width: 200,
                            //   child: DashLineView(
                            //     dashColor: AppColors.medBlue,
                            //     direction: Axis.vertical,
                            //     // dashHeight: 8,
                            //   ),
                            // ),
                            VerificationStep(
                              height: screenH,
                              image: verificationStatus == 1
                                  ? SvgPicture.asset(
                                      'assets/svg/verification/review_done.svg',
                                      fit: BoxFit.scaleDown,
                                    )
                                  : verificationStatus == 3
                                      ? SvgPicture.asset(
                                          'assets/svg/verification/rejected.svg',
                                          fit: BoxFit.scaleDown,
                                        )
                                      : Icon(
                                          Icons.info,
                                          color: AppColors.grey.withOpacity(.3),
                                        ),
                            ),
                            SizedBox(
                              height: screenH * 0.04,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Received',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontSize: 12,
                                    color: AppColors.medBlue,
                                  ),
                            ),
                            Text(
                              'Selfie Evaluation',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontSize: 12,
                                    color: AppColors.medBlue.withOpacity(
                                      verificationStatus >= 2 ||
                                              verificationStatus == 1
                                          ? 1
                                          : .3,
                                    ),
                                  ),
                            ),
                            // Text(
                            //   'Identity Verification',
                            //   style: Theme.of(context)
                            //       .textTheme
                            //       .titleMedium!
                            //       .copyWith(
                            //         fontSize: 12,
                            //         color: AppColors.medBlue.withOpacity(
                            //           verificationStatus == 1 ? 1 : .3,
                            //         ),
                            //       ),
                            // ),
                            Text(
                              verificationStatus == 3
                                  ? 'Verification Rejected!'
                                  : 'Account Verified!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontSize: 12,
                                    color: AppColors.medBlue.withOpacity(
                                      verificationStatus == 1 ||
                                              verificationStatus == 3
                                          ? 1
                                          : .3,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: screenW * 0.1,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenW * 0.8,
                  child: StadiumButton(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    gradient: AppColors.buttonBlueVertical,
                    child: Text(
                      verificationStatus == 3
                          ? 'Re-Submit to Verify'
                          : 'Continue Swiping',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 14,
                            color: AppColors.white,
                          ),
                    ),
                    onPressed: () {
                      if (verificationStatus == 3) {
                        navigatorKey.currentState!
                            .pushNamed(VerifyIdentityPage.routeName)
                            .then((value) {
                          setState(() {});
                        });
                      } else {
                        navigatorKey.currentState!.pushNamedAndRemoveUntil(
                            MainPage.routeName, (route) => false);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VerificationStep extends StatelessWidget {
  const VerificationStep({
    super.key,
    required this.height,
    required this.image,
  });

  final double height;
  final Widget image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.06,
      width: height * 0.06,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: image,
    );
  }
}

class DashLineView extends StatelessWidget {
  final double dashHeight;
  final double dashWith;
  final Color dashColor;
  final double fillRate; // [0, 1] totalDashSpace/totalSpace
  final Axis direction;

  const DashLineView(
      {super.key,
      this.dashHeight = 2,
      this.dashWith = 2,
      this.dashColor = Colors.black,
      this.fillRate = 0.5,
      this.direction = Axis.horizontal});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxSize = direction == Axis.horizontal
            ? constraints.constrainWidth()
            : constraints.constrainHeight();
        final dCount = (boxSize * fillRate / dashWith).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: direction,
          children: List.generate(dCount, (_) {
            return SizedBox(
              width: direction == Axis.horizontal ? dashWith : dashHeight,
              height: direction == Axis.horizontal ? dashHeight : dashWith,
              child: DecoratedBox(
                decoration: BoxDecoration(color: dashColor),
              ),
            );
          }),
        );
      },
    );
  }
}
