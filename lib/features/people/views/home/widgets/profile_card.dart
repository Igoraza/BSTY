import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/features/people/services/people_provider.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';

import '../../../../../common_widgets/boxed_text.dart';
import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/person.dart';
import '../../detailed/person_details_page.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard(this.person, {Key? key}) : super(key: key);

  final Person person;
  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  // final int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final appHeight = MediaQuery.of(context).size.height;
    final appWidth = MediaQuery.of(context).size.width;

    final person = widget.person;
    return Consumer<PeopleProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          PersonDetailedPage.routeName,
          arguments: {
            'id': person.id,
            'name': person.name,
            'image': person.displayImage,
          },
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColors.white.withOpacity(0.5),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// [Image]
              CachedNetworkImage(
                  imageUrl: person.displayImage,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  alignment: Alignment.topCenter,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => mainLoadingAnimationLight,
                  errorWidget: (_, __, ___) => mainLoadingAnimationLight),
              Column(
                children: [
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.3),
                    ),
                    clipBehavior: Clip.hardEdge,

                    /// [Person Details]
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Column(
                        children: [
                          // widget.person.instaUrl != null
                          //     ? SvgPicture.asset(
                          //         'assets/svg/home/instagram.svg')
                          //     : const SizedBox(height: 16),
                          SizedBox(height: appHeight * 0.02),
                          BoxedText(text: '${person.name}, ${person.age}'),
                          SizedBox(height: appHeight * 0.02),
                          // Text(
                          //   'Proffession, Location',
                          //   // '${person.profession}, ${person.location}',
                          //   textAlign: TextAlign.center,
                          //   style: Theme.of(context)
                          //       .textTheme
                          //       .bodySmall!
                          //       .copyWith(color: AppColors.white),
                          // )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (provider.direction == Direction.right &&
                  provider.currentId == person.id)
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    height: appHeight * .2,
                    child: Stack(
                      alignment: Alignment.center,
                      // key: key,
                      children: <Widget>[
                        Transform.rotate(
                          angle: -.2,
                          child: Transform.scale(
                            scale: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SvgPicture.asset(
                                'assets/svg/action/like.svg',
                                width: appWidth * .48,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(20),
                        //   child: SvgPicture.asset(
                        //     'assets/svg/action/like.svg',
                        //   ),
                        // ),
                        Transform.rotate(
                          angle: -.2,
                          child: Transform.scale(
                            scale: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SvgPicture.asset(
                                'assets/svg/action/like.svg',
                                width: appWidth * .46,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SvgPicture.asset(
                    //   'assets/svg/action/like.svg',
                    // ),
                  ),
                ),

              if (provider.direction == Direction.left &&
                  provider.currentId == person.id)
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    // width: 400,
                    height: appHeight * .2,
                    child: Stack(
                      alignment: Alignment.center,
                      // key: key,
                      children: <Widget>[
                        Transform.rotate(
                          angle: .2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SvgPicture.asset(
                              'assets/svg/action/passs.svg',
                              width: appWidth * .48,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: .2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SvgPicture.asset(
                              'assets/svg/action/passs.svg',
                              width: appWidth * .46,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (provider.direction == Direction.up &&
                  provider.currentId == person.id)
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: appHeight * .08,
                    child: Stack(
                      alignment: Alignment.center,
                      // key: key,
                      children: <Widget>[
                        Transform.translate(
                          offset: const Offset(10, 10),
                          child: Transform.scale(
                            scale: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SvgPicture.asset(
                                'assets/svg/action/super_like.svg',
                                height: appHeight * .1,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SvgPicture.asset(
                            'assets/svg/action/super_like.svg',
                            height: appHeight * .08,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
