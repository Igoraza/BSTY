// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:bsty/common_widgets/confirm_block.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/common_widgets/detailed_report_dialog.dart';
import 'package:bsty/common_widgets/details_textfield_report.dart';
import 'package:bsty/features/auth/services/initial_profile_provider.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/buy_plan_dialog.dart';
import '../../../../common_widgets/custom_icon_btn.dart';
import '../../../../common_widgets/exceed_like_limit.dart';
import '../../../../common_widgets/loading_animations.dart';
import '../../../../common_widgets/matched_dialog.dart';
import '../../../../common_widgets/snapshot_error.dart';
import '../../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../../utils/constants/plan_price_details.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/global_keys.dart';
import '../../../../utils/theme/colors.dart';
import '../../models/person_profile.dart';
import '../../services/people_provider.dart';
import 'widgets/person_details_images_and_title.dart';
import 'widgets/person_details_interests.dart';
import 'widgets/report_dialog.dart';

class PersonDetailedPage extends StatefulWidget {
  const PersonDetailedPage({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  final int userId;
  final String userName;
  final String userImage;

  static const routeName = '/detailed-page';

  static const reportReasons = [
    'Sexual Content',
    'Abusive Content',
    'Violent Content',
    'Inappropriate Content',
    'Spam or Misleading',
  ];

  static const reportOptions = ['Report only', 'Block only', 'Report & Block'];

  @override
  State<PersonDetailedPage> createState() => _PersonDetailedPageState();
}

class _PersonDetailedPageState extends State<PersonDetailedPage> {
  late Future personProfileFuture;

  final PlanPriceDetails planDetails = PlanPriceDetails();

  final TextEditingController reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    personProfileFuture = context.read<PeopleProvider>().fetchPersonProfile(
      context,
      widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    final planExpired = Hive.box('user').get('plan_expired') ?? true;
    final userPlan = Hive.box('user').get('plan') ?? 1;

    final peopleProvider = context.watch<PeopleProvider>();
    final profileProvider = context.read<InitialProfileProvider>();

    final List userActionButtons = [
      {
        'icon': 'assets/svg/ui_icons/star.svg',
        'onTap': () {
          final swipesBalance = Hive.box('user').get('swipes_balance');
          // TODO: Uncomment this
          // if (swipesBalance != 0 || !planExpired) {
          peopleProvider.sendUserAction(context, widget.userId, '1').then((
            res,
          ) {
            debugPrint('=========>> User Action Response: $res');
            if (res['status']) {
              showSnackBar('Liked ${widget.userName}');
              if (res['match']) {
                showDialog(
                  context: context,
                  builder: (_) => MatchedDialog(
                    id: widget.userId,
                    name: widget.userName,
                    image: widget.userImage,
                    pushId: res['push_id'] ?? '',
                    matchId: res['match_id'],
                    chatid: res['chat_id'],
                  ),
                );
              }
            } else if (!res['status']) {
              log('null--------');
            }
          });
          // } else {
          //   showDialog(
          //     context: context,
          //     builder: (context) => const ExceedLikeDialog(),
          //   );
          // }
        },
      },
      {
        'icon': 'assets/svg/ui_icons/fav.svg',
        'onTap': () {
          final superLikesBalance = Hive.box('user').get('super_like_balance');

          //TODO: Uncomment this
          // if (userPlan > 2 && !planExpired) {
          // if (superLikesBalance == 0) {
          //   showDialog(
          //     context: context,
          //     builder: (context) => BuyPlanDialog(
          //       title: 'SuperLikes',
          //       desc: 'Buy SuperLikes As Needed !',
          //       img: 'assets/svg/upgrade_dialog/super_likes.svg',
          //       btnText: 'Buy Now',
          //       paymentList: planDetails.payLikes,
          //     ),
          //   );
          // } else {

          peopleProvider.sendUserAction(context, widget.userId, '2').then((
            value,
          ) {
            if (value['status']) {
              showSnackBar('Superliked ${widget.userName}');
            }
          });
          // }
          // } else {
          //   // showDialog(
          //   //   context: context,
          //   //   builder: (context) => UpgradePlanDialog(),
          //   // );

          //   Navigator.pushNamed(context, UpgradePlanScreen.routeName);
          //   return;
          // }
        },
      },
    ];

    /// [Widgets]

    final reportButton = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: AppColors.orangeRedH,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(12.0),
          //     side: const BorderSide(color: Colors.red),),
          // backgroundColor: AppColors.alertRed,
          foregroundColor: AppColors.white,
        ),
        onPressed: () {
          profileProvider.report = "NA";
          profileProvider.reason = "NA";
          profileProvider.incident = "NA";
          profileProvider.detailsReport = "NA";
          // showDialog(
          //   context: context,
          //   builder: (context) => DetailedReportDialog(options: [],
          //       title: "What would you like to report?", isint: true),
          // );
          showDialog(
            context: context,
            builder: (context) {
              return ReportDialog(
                options: PersonDetailedPage.reportOptions,
                isint: true,
                userId: widget.userId,
                onSubmint: () {
                  log(peopleProvider.selectedId.toString());
                  if (peopleProvider.selectedId == null) {
                    showSnackBar('Select anything to continue !');
                    return;
                  }
                  navigatorKey.currentState!.pop();
                  if (peopleProvider.selectedId == 1 ||
                      peopleProvider.selectedId == 3) {
                    List<String> reportKind = [
                      "Bio",
                      "Profile Photo",
                      "Messages",
                      "Personal",
                    ];

                    List<String> reasonKind = [
                      "Fake Profile",
                      "Scam",
                      "Nudity",
                      "Selling Something",
                      'Sexual Content',
                      'Abusive Content',
                      'Violent Content',
                      'Inappropriate Content',
                      'Spam or Misleading',
                    ];

                    List<String> incidents = [
                      "Nudity",
                      "Sextortion",
                      "Sexually Explicit",
                      "Illegal",
                    ];
                    showDialog(
                      context: context,
                      builder: (context) => DetailedReportDialog(
                        reportController: reportController,
                        options: reportKind,
                        title: "What would you like to report?",
                        isint: true,
                        onSubmit: () {
                          if (reportController.text.isEmpty) {
                            showSnackBar('Select one Item');
                            return;
                          }
                          profileProvider.report = reportController.text;
                          reportController.clear();
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => DetailedReportDialog(
                              reportController: reportController,
                              options: reasonKind,
                              isint: false,
                              title: "What is the reason?",
                              onSubmit: () {
                                log("ssssss${reportController.text}");
                                if (reportController.text.isEmpty) {
                                  showSnackBar('Select one Item');
                                  return;
                                }
                                profileProvider.reason = reportController.text;
                                reportController.clear();
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => DetailedReportDialog(
                                    reportController: reportController,
                                    options: incidents,
                                    isint: true,
                                    title: "Tell us the incident",
                                    onSubmit: () {
                                      if (reportController.text.isEmpty) {
                                        showSnackBar('Select one Item');
                                        return;
                                      }
                                      profileProvider.incident =
                                          reportController.text;
                                      reportController.clear();
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) => DetailedTextFieldReportDialog(
                                          title: "Tell us the details if any",
                                          onSubmit: () async {
                                            log(profileProvider.detailsReport);
                                            Response
                                            response = await profileProvider
                                                .reportAndBlock(
                                                  widget.userId,
                                                  '',
                                                  peopleProvider.selectedId!,
                                                );
                                            Navigator.pop(context);
                                            peopleProvider.selectedId = null;
                                            if (response.statusCode == 200) {
                                              showDialog(
                                                context: context,
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
                            ),
                          );
                        },
                      ),
                    );
                    // log('$content ${peopleProvider.selectedId}');

                    //  log('content {peopleProvider.selectedId}');
                    // profileProvider.reportAndBlock(widget.userId!,
                    //     content, peopleProvider.selectedId!);
                    // navigatorKey.currentState!.pop();
                  } else if (peopleProvider.selectedId == 2) {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        onSubmint: () async {
                          Response response = await profileProvider
                              .reportAndBlock(
                                widget.userId,
                                '',
                                peopleProvider.selectedId!,
                              );
                          Navigator.pop(context);
                          peopleProvider.selectedId = null;
                          if (response.statusCode == 200) {
                            showDialog(
                              context: context,
                              builder: (context) => CustomDialog(
                                image: SvgPicture.asset(
                                  "assets/svg/dialog/report_done.svg",
                                ),
                                title: "Done!",
                                subTitle: "This user has been blocked",
                                desc:
                                    "We won't tell ${profileProvider.personNme} you blocked them",
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }
                },
              );
            },
          );
        },
        child: Text(
          'Block/Report',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
    log(profileProvider.visible.toString());
    return BackgroundImage(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned(
              top: appHeight * 0.03,
              child: CustomIconBtn(
                onTap: () {
                  profileProvider.visible = !profileProvider.visible;
                  log(profileProvider.visible.toString());
                  navigatorKey.currentState!.pop();
                },
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: FutureBuilder(
                  future: personProfileFuture,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return mainLoadingAnimationDark;
                    }
                    if (snapshot.hasError) {
                      String errorMsg = '';

                      /// chieck if [ connection error ]
                      if (snapshot.error.toString().contains(
                        'SocketException',
                      )) {
                        errorMsg =
                            'Error retrieving profiles.\nPlease check your internet connection';
                      } else {
                        errorMsg = 'Error retrieving profiles. Try again later';
                      }

                      return SnapshotErrorWidget(errorMsg);
                    }
                    final person = snapshot.data['person'] as PersonProfile;
                    final images = snapshot.data['images'].reversed.toList();
                    profileProvider.personNme = person.name;
                    // log(personProfileFuture.toString());
                    return ColoredBox(
                      color: AppColors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              PersonDetailsImagesAndTitle(person, images),
                              Positioned(
                                top: appHeight * 0.03,
                                child: CustomIconBtn(
                                  onTap: () {
                                    profileProvider.visible = false;
                                    // log(profileProvider.visible.toString());
                                    navigatorKey.currentState!.pop();
                                  },
                                  bgColor: AppColors.white,
                                  child: const Icon(Icons.arrow_back_rounded),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                              appHeight * 0.03,
                            ).copyWith(top: 0),
                            child: Column(
                              children: [
                                Text(
                                  '${person.gender['title'] ?? ''}'
                                  '${person.gender['title'] != null && person.location != null ? ',' : ''}'
                                  '${person.location ?? ''}',
                                  textAlign: TextAlign.center,
                                ),
                                // const SizedBox(height: 10),
                                // SvgPicture.asset(
                                //     'assets/svg/detailed/location.svg'),
                                // const SizedBox(height: 10),
                                // const Text('20 Miles Away'),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: appHeight * 0.06,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              'Account',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.pureBlack,
                                                  ),
                                            ),
                                            SizedBox(height: appHeight * 0.005),
                                            Text(getPlanName(person.plan)),
                                          ],
                                        ),
                                      ),
                                      const VerticalDivider(
                                        color: AppColors.lightGrey,
                                        width: 1,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              'Orientation',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.pureBlack,
                                                  ),
                                            ),
                                            SizedBox(height: appHeight * 0.005),
                                            Text(
                                              '${person.orientation['title']}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const VerticalDivider(
                                        color: AppColors.lightGrey,
                                        width: 1,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Joined Date ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.pureBlack,
                                                  ),
                                            ),
                                            SizedBox(height: appHeight * 0.005),
                                            Text(
                                              DateFormat('dd-MM-yyyy').format(
                                                DateTime.parse(person.created),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                PersonDetailsInterestChips(
                                  interests: person.interests
                                      .map((e) => e['title'])
                                      .toList(),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Bio',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      person.bio != null && person.bio != ''
                                          ? person.bio ?? ''
                                          : 'No bio',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(color: AppColors.grey),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 40,
                                  color: AppColors.lightGrey,
                                ),
                                reportButton,
                                const Divider(
                                  height: 40,
                                  color: AppColors.lightGrey,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: userActionButtons
                                      .map(
                                        (e) => CustomIconBtn(
                                          padding: EdgeInsets.zero,
                                          size: appWidth * 0.15,
                                          onTap: e['onTap'],
                                          boxShadow: const [
                                            BoxShadow(
                                              color: AppColors.lightGrey,
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                          child: SvgPicture.asset(e['icon']),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SizedBox(height: appHeight * 0.03),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
