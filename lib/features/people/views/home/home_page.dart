import 'dart:async';
import 'dart:developer';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/common_widgets/buy_plan_dialog.dart';
import 'package:bsty/common_widgets/exceed_like_limit.dart';
import 'package:bsty/common_widgets/stadium_button.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/features/people/views/home/widgets/tutorial_coach_mark.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../common_widgets/custom_icon_btn.dart';
import '../../../../common_widgets/loading_animations.dart';
import '../../../../common_widgets/matched_dialog.dart';
import '../../../../common_widgets/snapshot_error.dart';
import '../../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../../utils/constants/plan_price_details.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/global_keys.dart';
import '../../../../utils/theme/colors.dart';
import '../../services/people_provider.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/profile_card.dart';
import 'widgets/rewind_card.dart';
import 'widgets/swipe_limit_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TutorialCoachMark tutorialCoachMark;
  final cardController = SwipeableCardSectionController();
  late Future peopleFuture;

  final peopleProvider = navigatorKey.currentContext!.read<PeopleProvider>();
  final userPlan = Hive.box('user').get('plan') ?? 1;
  final planExpired = Hive.box('user').get('plan_expired') ?? true;
  bool isLocated = false;
  bool guideFinished = Hive.box('guide').get('guide_finished') ?? false;

  final GlobalKey _containerKey = GlobalKey();

  bool isGranted = true;

  @override
  void initState() {
    super.initState();
    // checkPermission();
    peopleFuture = peopleProvider.fetchPeople(context);
    // isLocated = LocationProvider().startTracking(context) as bool;
  }

  // checkPermission() async {
  //   PermissionStatus status = await Permission.location.request();
  //   if (status.isPermanentlyDenied) {
  //     setState(() {
  //       isGranted = false;
  //     });
  //   } else {
  //     setState(() {
  //       isGranted = true;
  //     });
  //   }
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   // print('Current state = $state');
  //   checkPermission();
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  /// [ Show Filter Bottom Sheet ]
  Future<void> showFilterBottomSheet(BuildContext context, Size size) async {
    final shouldRefresh = await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: false,
      constraints: BoxConstraints(
        maxHeight: size.height * 0.8,
        minHeight: size.height * 0.8,
      ),
      builder: (context) => FilterBottomSheet(size: size),
    );
    if (shouldRefresh ?? false) {
      setState(() {
        peopleFuture = peopleProvider.fetchPeople(context);
      });
    }
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: createTargets(_containerKey, MediaQuery.of(context).size),
      colorShadow: AppColors.black,
      // textSkip: "SKIP",
      textStyleSkip: const TextStyle(fontSize: 16, color: AppColors.white),
      paddingFocus: 0,
      opacityShadow: 0.8,
      // showSkipInLastTarget: true,
      alignSkip: Alignment.bottomRight,
      onSkip: () {
        debugPrint("skip");
        Hive.box('guide').put('guide_finished', true);
        guideFinished = Hive.box('guide').get('guide_finished') ?? false;
        return true; // extra added
      },

      onFinish: () {
        //  final userBox = Hive.box('user');
        Hive.box('guide').put('guide_finished', true);
        guideFinished = Hive.box('guide').get('guide_finished') ?? false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authPro = context.read<AuthProvider>();

    // final userBox = Hive.box('user');
    // final latitude = userBox.get('user_latitude');
    // final longitude = userBox.get('user_longitude');
    // log('spermission home location -----------${latitude.toString()} ${longitude.toString()}');
    // peopleFuture = peopleProvider.fetchPeople(context);
    String currentCardName = '';
    String currentCardImage = '';
    ProfileCard? lastCard;

    final PlanPriceDetails planDetails = PlanPriceDetails();

    // Future.delayed(const Duration(seconds: 2), showTutorial);

    /// [ Functions ]

    void sendUserAction(Direction dir, int userId) {
      final peopleProvider = context.read<PeopleProvider>();
      switch (dir) {
        case Direction.right:
          final swipesBalance = Hive.box('user').get('swipes_balance');
          if (swipesBalance == 0 && planExpired) {
            showDialog(
              context: context,
              builder: (context) => const ExceedLikeDialog(),
            );
            // cardController.addItem(lastCard!);
          } else {
            peopleProvider.sendUserAction(context, userId, '1').then((value) {
              debugPrint('=========>> User Action Response: $value');
              if (value['status'] && value['match']) {
                showDialog(
                  context: context,
                  builder: (_) => MatchedDialog(
                    id: userId,
                    name: currentCardName,
                    image: currentCardImage,
                    pushId: value['push_id'] ?? '',
                    matchId: value['match_id'],
                    chatid: value['chat_id'],
                  ),
                );
              }
            });
          }

          break;
        case Direction.up:
          peopleProvider.sendUserAction(context, userId, '2');
          break;
        case Direction.left:
          peopleProvider.sendUserAction(context, userId, '3');
          break;
        default:
      }
    }

    /// [ Widgets ]

    final List homeButtons = [
      {
        'icon': 'assets/svg/ui_icons/reset.svg',
        'onTap': () {
          // throw Exception();
          log("User plan :  $userPlan");
          if (userPlan > 2 && !planExpired) {
            if (lastCard == null) {
              showSnackBar('Rewind not available now');
              return;
            }
            showDialog(
              context: context,
              builder: (_) => RewindedCard(lastCard: lastCard),
            );
          } else {
            // showDialog(
            //   context: context,
            //   builder: (context) => UpgradePlanDialog(),
            // );

            Navigator.pushNamed(context, UpgradePlanScreen.routeName);
            return;
          }
        },
      },
      {
        'icon': 'assets/svg/ui_icons/dislike.svg',
        'onTap': () => cardController.triggerSwipeLeft(),
      },
      {
        'icon': 'assets/svg/ui_icons/fav.svg',
        'onTap': () {
          final superLikesBalance = Hive.box('user').get('super_like_balance');
          log("User plan :  $userPlan");
          log("Super likes :  $superLikesBalance");
          if (userPlan > 2 && !planExpired) {
            if (superLikesBalance == 0) {
              showDialog(
                context: context,
                builder: (context) => BuyPlanDialog(
                  title: 'SuperLikes',
                  desc: 'Buy SuperLikes As Needed !',
                  img: 'assets/svg/upgrade_dialog/super_likes.svg',
                  btnText: 'Buy Now',
                  paymentList: planDetails.payLikes,
                ),
              );
            } else {
              cardController.triggerSwipeUp();
            }
          } else {
            // showDialog(
            //   context: context,
            //   builder: (context) => UpgradePlanDialog(),
            // );

            Navigator.pushNamed(context, UpgradePlanScreen.routeName);
            return;
          }
        },
      },
      {
        'icon': 'assets/svg/ui_icons/star.svg',
        'onTap': () {
          final swipesBalance = Hive.box('user').get('swipes_balance');
          log("User plan :  $userPlan");
          log("Swipes remaining :  $swipesBalance");
          if (!planExpired) {
            log('1');
            cardController.triggerSwipeRight();
          } else if (swipesBalance != 0) {
            log('2');
            cardController.triggerSwipeRight();
          } else {
            showDialog(
              context: context,
              builder: (context) => const ExceedLikeDialog(),
            );
          }
        },
      },
      {
        'icon': 'assets/svg/ui_icons/trend.svg',
        'onTap': () {
          // Todo : uncomment this after testing
          log("User plan :  $userPlan");
          if (userPlan > 2 && !planExpired) {
            peopleProvider.userBoost(context);
            // peopleProvider.sendUserAction(context, userId, '3');
          } else {
            // showDialog(
            //   context: context,
            //   builder: (context) => UpgradePlanDialog(),
            // );

            Navigator.pushNamed(context, UpgradePlanScreen.routeName);
            return;
          }
        },
      },
    ];

    final homeCards = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FutureBuilder(
        future: peopleFuture,
        builder: (context, AsyncSnapshot snapshot) {
          // if (!isGranted) {
          //   return const Center(
          //     child: NoPermisssionWidget(),
          //   );
          // }
          log("++++++++++++Number of people : ${snapshot.data}");
          if (snapshot.connectionState != ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.08),
              child: mainLoadingAnimationDark,
            );
          }
          if (snapshot.hasError) {
            String errorMsg = '';

            /// chieck if [ connection error ]
            if (snapshot.error.toString().contains('SocketException')) {
              errorMsg =
                  'Error retrieving profiles.\nPlease check your internet connection';
            } else {
              errorMsg = 'Error retrieving profiles. Try again later';
            }

            return SnapshotErrorWidget(errorMsg);
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SwipeLimitCard(),
              ),
            );
            // Center(
            //     child: Text('No profiles found,\nTry changing your filters',
            //         style: Theme.of(context)
            //             .textTheme
            //             .bodyLarge!
            //             .copyWith(fontWeight: FontWeight.bold),
            //         textAlign: TextAlign.center));
          }

          final List people = snapshot.data;

          log("++++++++++++Number of people : ${people.length}");

          final cards = people.map((person) => ProfileCard(person)).toList();
          final cardsWithLimit = [...cards, const SwipeLimitCard()];
          // bool allowed = Hive.box('user').get('allowed') ?? false;
          // log(cardsWithLimit.length.toString());
          return Consumer<PeopleProvider>(
            builder: (context, d, _) {
              if (!guideFinished) {
                createTutorial();
                Future.delayed(const Duration(seconds: 3), showTutorial);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  key: _containerKey,
                  children: [
                    SwipeableCardsSection(
                      cardController: cardController,
                      context: context,
                      onCardSwiped: (dir, index, widget) {
                        currentCardName = people[index].name;
                        currentCardImage = people[index].displayImage;
                        lastCard = cards[index];

                        sendUserAction(dir, people[index].id);

                        if (index < cardsWithLimit.length - 3) {
                          cardController.addItem(cardsWithLimit[index + 3]);
                        }
                        if (index == cardsWithLimit.length - 2) {
                          peopleProvider.isAtLimit.value = true;
                          cardController.enableSwipe(false);
                        }
                        d.direction = dir;
                        d.currentId = lastCard!.person.id;
                        Future.delayed(const Duration(milliseconds: 400), () {
                          d.direction = null;
                        });

                        // cardsWithLimit.insert(index - 1, lastCard!);
                      },
                      items: cardsWithLimit.sublist(
                        0,
                        cardsWithLimit.length < 3 ? 2 : 3,
                      ),
                      // changed to 0,2 range error
                      //  items: cardsWithLimit.sublist(0, 3),
                      enableSwipeUp: false,
                      enableSwipeDown: false,
                    ),
                    SizedBox(height: size.height * 0.01),

                    /// ValueListenableBuilder is used to hide the buttons
                    /// when the user has swiped through all the profiles
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset('assets/svg/logo/logo.svg'),
        ),
        title: Text('Hi ${Hive.box('user').get('name') ?? 'there'}!'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.titleBlue,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          CustomIconBtn(
            onTap: () async {
              showFilterBottomSheet(context, size);
              // navigatorKey.currentState!
              //     .pushNamed(ForceUpdatePage.routeName);

              /// [ For testing purposes ]
              // debugPrint(Hive.box('user').get('plan').toString());
              // final authProvider = context.read<AuthProvider>();
              // final tokens = await authProvider.retrieveUserTokens();
              // debugPrint('=======Tokens: $tokens');
              // authProvider.saveUserToken('fake', tokens['refresh']!);
              // final tokens2 = await authProvider.retrieveUserTokens();
              // debugPrint('+++++++Tokens: $tokens2');
              // final pushId = Hive.box('user').get('push_id');
              // debugPrint('pushId: $pushId');
            },
            child: SvgPicture.asset('assets/svg/ui_icons/options.svg'),
          ),
          CustomIconBtn(
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
            child: SvgPicture.asset('assets/svg/ui_icons/bell.svg'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // SizedBox(height: size.height * 0.02, width: double.infinity),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///[TODO] with banner ad comment this sizedbox
                SizedBox(
                  height: authPro.isTab ? size.width * 0.1 : size.width * 0.1,
                ),
                // BannerAd(size: size),
                Expanded(child: homeCards),

                ///[TODO] with banner ad  SizedBox(height: size.height * 0.05)
                SizedBox(height: size.height * 0.1),
              ],
            ),
            if (isGranted)
              Positioned(
                bottom: authPro.isTab ? size.height * 0.04 : size.height * 0.08,
                // top: size.height * 0,
                child: ValueListenableBuilder(
                  valueListenable: peopleProvider.isAtLimit,
                  builder: (_, val, __) => val
                      ? const SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: homeButtons
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: e['onTap'] as void Function()?,
                                    child: SvgPicture.asset(e['icon']),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NoPermisssionWidget extends StatelessWidget {
  const NoPermisssionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authPro = context.read<AuthProvider>();
    return SizedBox(
      height: 300,
      width: 350,
      // color: AppColors.alertRed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Unable to connect",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall!.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: 15),
          Text(
            'To use BSTY, you need to enable your location sharing so we can show you who\'s around.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Go to Settings > BSTY > Location > Enable Location While Using the App",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          SizedBox(
            // height: 70,
            child: StadiumButton(
              padding: authPro.isTab
                  ? EdgeInsets.symmetric(horizontal: 20)
                  : null,
              text: "Open settings",
              gradient: AppColors.orangeRedH,
              onPressed: () => openAppSettings(),
            ),
          ),
        ],
      ),
    );
  }
}
