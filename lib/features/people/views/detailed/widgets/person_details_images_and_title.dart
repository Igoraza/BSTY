import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/common_widgets/detailed_report_dialog.dart';
import 'package:bsty/common_widgets/details_textfield_report.dart';
import 'package:bsty/common_widgets/screen_options_menu.dart';
import 'package:bsty/features/auth/services/initial_profile_provider.dart';
import 'package:bsty/utils/functions.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/custom_icon_btn.dart';
import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../utils/global_keys.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/person_profile.dart';

class PersonDetailsImagesAndTitle extends StatelessWidget {
  PersonDetailsImagesAndTitle(this.person, this.images, {Key? key})
      : super(key: key);

  final PersonProfile person;
  final List<dynamic> images;
  final _currentPage = ValueNotifier<int>(0);
  final TextEditingController reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    // log(images.toString());
    final profileProvider = context.read<InitialProfileProvider>();

    return SizedBox(
      height: appWidth / 4 * 5.5,
      child: Stack(
        children: [
          PageView(
            onPageChanged: (index) => _currentPage.value = index,
            scrollDirection: Axis.vertical,
            children: List.generate(
              images.length,
              (index) {
                return CachedNetworkImage(
                    imageUrl: images[index].image,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => mainLoadingAnimationDark,
                    errorWidget: (context, url, error) =>
                        mainLoadingAnimationDark);
              },
            ),
          ),

          /// [Page Indicator]
          Positioned(
            top: 50,
            right: 10,
            child: SizedBox(
              width: 20,
              child: ValueListenableBuilder(
                valueListenable: _currentPage,
                builder: (_, val, __) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == val
                            ? AppColors.white
                            : AppColors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 80,
              left: 10,
              child: InkWell(
                onTap: () {
                  profileProvider.visible = !profileProvider.visible;
                  // log(images[_currentPage.value].id.toString());
                },
                child: SizedBox(
                  width: 30,
                  child: SvgPicture.asset(
                    "assets/svg/profile/flag.svg",
                    height: 25,
                  ),
                ),
              )),
          Positioned(
              bottom: 70,
              left: 40,
              child: Consumer<InitialProfileProvider>(
                  builder: (context, initiPro, child) {
                return Visibility(
                  visible: initiPro.visible,
                  child: InkWell(
                      onTap: () {
                        profileProvider.report = "NA";
                        profileProvider.reason = "NA";
                        profileProvider.incident = "NA";
                        profileProvider.detailsReport = "NA";
                        log(person.id.toString());
                        String title = "NA";
                        profileProvider.visible = false;
                        showDialog(
                          context: context,
                          builder: (context) => DetailedReportDialog(
                            reportController: reportController,
                            options: const [
                              "Nudity",
                              "Sextortion",
                              "Sexually Explicit",
                              "Illegal",
                            ],
                            isint: true,
                            title: "Why are you flagging this?",
                            onSubmit: () {
                              if (reportController.text.isEmpty) {
                                showSnackBar("Select one to continue !");
                              }
                              title = reportController.text;
                              reportController.clear();
                              Navigator.pop(context);
                              profileProvider.detailsReport = "NA";
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    DetailedTextFieldReportDialog(
                                  title: "Tell us the details if any",
                                  onSubmit: () async {
                                    Response response = await profileProvider
                                        .reportAndBlock(person.id, title, 4,
                                            userImg:
                                                images[_currentPage.value].id);
                                    Navigator.pop(context);
                                    if (response.statusCode == 200) {
                                      showDialog(
                                        context: navigatorKey.currentContext!,
                                        builder: (context) => CustomDialog(
                                          image: SvgPicture.asset(
                                            "assets/svg/dialog/report_done.svg",
                                          ),
                                          title: "Done!",
                                          subTitle:
                                              "Your report has been submitted.",
                                          desc:
                                              "We won't tell ${profileProvider.personNme} you reported them",
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 140,
                        decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Text(
                          "Flag this Image",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.black,
                                  ),
                        )),
                      )),
                );
              })),
          Positioned(
            top: appWidth / 4 * 5.5 - 60,
            child: Container(
              width: appWidth,
              height: appHeight,
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: appHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// 3dot more button
                      // IconButton(
                      //     onPressed: () => debugPrint('More'),
                      //     icon: const Icon(Icons.more_vert)),
                      SizedBox(
                        width: appWidth * 0.1,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: appWidth * 0.6,
                        child: Text(
                          '${person.name}, ${DateTime.now().year - person.dob.year}',
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(),
                      CustomIconBtn(
                        onTap: () => navigatorKey.currentState!.pop(),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        child: SvgPicture.asset(
                            'assets/svg/detailed/red_circle.svg'),
                      ),
                      SizedBox(
                        width: appWidth * 0.04,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
