import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/custom_icon_btn.dart';
import '../../../../utils/theme/colors.dart';
import 'pages/liked_list.dart';
import 'pages/profile_views_grid.dart';
import 'pages/super_likes_list.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static const routeName = '/explore-page';

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const topNavIcons = [
    'thumbOutline.svg',
    'heartOutline.svg',
    // 'tvOutline.svg',
    'eyeOutline.svg',
  ];

  final exploreScreens = [
    const LikedList(),
    const FavList(),
    // const WatchList(),
    const ProfileViewsGrid(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    final authPro = context.read<AuthProvider>();

    return Scaffold(
      /// explore page [Custom Navbar on top]
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(authPro.isTab ? appWidth * 0.1 : appWidth * 0.15),
        child: AppBar(
            leading: Container(
              padding: EdgeInsets.only(
                  left: authPro.isTab ? appWidth * 0.02 : appWidth * 0.05),
              child: SvgPicture.asset('assets/svg/logo/logo.svg'),
            ),
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: topNavIcons
                    .map((icon) => CustomIconBtn(
                        size: authPro.isTab ? appWidth * 0.06 : appWidth * 0.1,
                        onTap: () {
                          setState(
                              () => _currentIndex = topNavIcons.indexOf(icon));
                        },
                        bgColor: _currentIndex == topNavIcons.indexOf(icon)
                            ? null
                            : AppColors.white,
                        gradient: _currentIndex == topNavIcons.indexOf(icon)
                            ? AppColors.pinkVertical
                            : null,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                        child: SvgPicture.asset(
                            'assets/svg/explore/topnav/$icon',
                            color: _currentIndex == topNavIcons.indexOf(icon)
                                ? AppColors.white
                                : AppColors.black)))
                    .toList()),
            actions: [
              Container(
                  padding: EdgeInsets.only(right: appWidth * 0.05),
                  child: CustomIconBtn(
                      size: appWidth * 0.1,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/notifications'),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      child: SvgPicture.asset('assets/svg/ui_icons/bell.svg')))
            ]),
      ),
      body: exploreScreens[_currentIndex],
    );
  }
}
