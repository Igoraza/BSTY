import 'dart:developer';
import 'dart:ui';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/boxed_text.dart';
import '../../../../../common_widgets/buy_plan_dialog.dart';
import '../../../../../common_widgets/exceed_like_limit.dart';
import '../../../../../common_widgets/matched_dialog.dart';
import '../../../../../common_widgets/stadium_button.dart';
import '../../../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../../../utils/constants/plan_price_details.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/likes_model.dart';
import '../../../services/people_provider.dart';
import '../../detailed/person_details_page.dart';

class MainCard extends StatelessWidget {
  const MainCard(
    this.user, {
    Key? key,
    required this.isFav,
    required this.index,
  }) : super(key: key);
  final int index;
  final LikedUser user;
  final bool isFav;

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;
    final peopleProvider = context.read<PeopleProvider>();
    final authPro = context.read<AuthProvider>();

    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;

    final PlanPriceDetails planDetails = PlanPriceDetails();

    // log('${userPlan > 2 && !planExpired}');

    ImageFilter? filter;

    if (userPlan > 2 && !planExpired) {
      filter = ImageFilter.blur(sigmaX: 0, sigmaY: 0);
    } else {
      filter = ImageFilter.blur(sigmaX: 16, sigmaY: 16);
    }

    final reaction = ValueNotifier(0);

    final List cardButtons = [
      {
        'icon': 'assets/svg/ui_icons/star.svg',
        'onTap': () {
          final swipesBalance = Hive.box('user').get('swipes_balance');
          // if (!planExpired || swipesBalance != 0) {
          //   peopleProvider.sendUserAction(context, user.id, '1');
          //   reaction.value = 1;
          // } else {
          //   showDialog(
          //       context: context,
          //       builder: (context) => const ExceedLikeDialog());
          // }
          if (swipesBalance != 0 || !planExpired) {
            peopleProvider.sendUserAction(context, user.id, '1').then((res) {
              debugPrint('=========>> User Action Response: $res');
              log('ree================== $res');
              log('ree================== ${res['status']}');
              log('ree================== ${res['match']}');
              reaction.value = 1;
              if (res['status']) {
                if (res['match']) {
                  showDialog(
                    context: context,
                    builder: (_) => MatchedDialog(
                      id: user.id,
                      name: user.name,
                      image: user.displayImage,
                      pushId: res['push_id'] ?? '',
                      matchId: res['match_id'],
                      chatid: res['chat_id'],
                    ),
                  );
                }
                if (!isFav) {
                  peopleProvider.likedList.removeAt(index);
                  peopleProvider.likedList = peopleProvider.likedList;
                } else if (isFav) {
                  peopleProvider.favList.removeAt(index);
                  peopleProvider.favList = peopleProvider.favList;
                }
              } else if (!res['status']) {
                log('null--------');
              }
            });
          } else {
            showDialog(
              context: context,
              builder: (context) => const ExceedLikeDialog(),
            );
          }
        },
      },
      {
        'icon': 'assets/svg/ui_icons/fav.svg',
        'onTap': () {
          final superLikesBalance = Hive.box('user').get('super_like_balance');
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
              peopleProvider.sendUserAction(context, user.id, '2').then((res) {
                if (res['status']) {
                  if (!isFav) {
                    peopleProvider.likedList.removeAt(index);
                    peopleProvider.likedList = peopleProvider.likedList;
                  } else if (isFav) {
                    peopleProvider.favList.removeAt(index);
                    peopleProvider.favList = peopleProvider.favList;
                  }
                }
              });
              reaction.value = 2;
            }
          }
        },
      },
      {
        'icon': 'assets/svg/ui_icons/dislike.svg',
        'onTap': () {
          reaction.value = 3;
          peopleProvider.sendUserAction(context, user.id, '3').then((res) {
            if (res['status']) {
              if (!isFav) {
                peopleProvider.likedList.removeAt(index);
                peopleProvider.likedList = peopleProvider.likedList;
              } else if (isFav) {
                peopleProvider.favList.removeAt(index);
                peopleProvider.favList = peopleProvider.favList;
              }
            }
          });
        },
      },
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: () {
            if (userPlan > 2 && !planExpired) {
              Navigator.pushNamed(
                context,
                PersonDetailedPage.routeName,
                arguments: {
                  'id': user.id,
                  'name': user.name,
                  'image': user.displayImage,
                },
              );
            }
          },
          child: Container(
            padding: EdgeInsets.all(appHeight * 0.02),
            margin: const EdgeInsets.only(bottom: 30),
            height: authPro.isTab ? appWidth * 1 : appWidth / 4 * 5,
            width: authPro.isTab ? appWidth * 0.8 : double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              // padding: EdgeInsets.all(appHeight * 0.02),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(user.displayImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: filter,
                  child: Column(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: reaction,
                          builder: (_, value, __) {
                            if (value == 0) {
                              return const SizedBox();
                            }
                            IconData icon;
                            switch (value) {
                              case 1:
                                icon = Icons.thumb_up_alt_rounded;
                                break;
                              case 2:
                                icon = Icons.favorite_rounded;
                                break;
                              case 3:
                                icon = Icons.close_rounded;
                                break;
                              default:
                                icon = Icons.thumb_up_alt_rounded;
                            }
                            return TweenAnimationBuilder(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: value != 0 ? 1.0 : 0.0,
                              ),
                              duration: const Duration(milliseconds: 200),
                              builder:
                                  (
                                    BuildContext context,
                                    double opacity,
                                    Widget? child,
                                  ) {
                                    return Opacity(
                                      opacity: opacity,
                                      child: child,
                                    );
                                  },
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0),
                                    ],
                                    center: Alignment.center,
                                    radius: 0.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  icon,
                                  color: AppColors.white,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      if (userPlan > 2 && !planExpired && !isFav)
                        GestureDetector(
                          // TODO: Add onTap
                          onDoubleTap: () {},
                          child: BoxedText(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(color: AppColors.white),
                                ),
                                const SizedBox(width: 10),
                                SvgPicture.asset(
                                  'assets/svg/ui_icons/info.svg',
                                  color: AppColors.lighterGrey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (userPlan > 2 && !planExpired)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (user.location != null &&
                                  user.location!.isNotEmpty)
                                BoxedText(
                                  text: user.location,
                                  bgColor: AppColors.teal,
                                ),
                              if (user.profession != null &&
                                  user.profession!.isNotEmpty)
                                BoxedText(
                                  text: user.profession,
                                  bgColor: AppColors.pink,
                                ),
                              BoxedText(
                                text: 'Age ${user.age}',
                                bgColor: AppColors.purple,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        userPlan > 2 && !planExpired
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: cardButtons
                    .map(
                      (e) => GestureDetector(
                        onTap: () {
                          e['onTap']();
                          Future.delayed(
                            const Duration(seconds: 1),
                            () => reaction.value = 0,
                          );
                        },
                        child: SvgPicture.asset(e['icon']),
                      ),
                    )
                    .toList(),
              )
            : StadiumButton(
                onPressed: () {
                  // showDialog(
                  //   context: context,
                  //   builder: (context) => UpgradePlanDialog(),
                  // );

                  Navigator.pushNamed(context, UpgradePlanScreen.routeName);
                },
                padding: EdgeInsets.symmetric(
                  horizontal: appWidth * 0.2,
                  vertical: appWidth * 0.046,
                ),
                text: isFav
                    ? 'See Who SuperLiked You !'
                    : 'See Who Liked You !',
                visualDensity: VisualDensity.standard,
                gradient: AppColors.orangeYelloH,
              ),
      ],
    );
  }
}
