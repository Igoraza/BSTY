import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/features/chat_and_call/views/chats_sectiion/pages/matches_page.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/custom_icon_btn.dart';
import '../../../../utils/global_keys.dart';
import '../../../../utils/theme/colors.dart';
import '../../../notification/notification_page.dart';
import 'pages/calls_history.dart';
import 'pages/recent_chats.dart';

class ChatsSection extends StatefulWidget {
  const ChatsSection({super.key});

  @override
  State<ChatsSection> createState() => _ChatsSectionState();
}

class _ChatsSectionState extends State<ChatsSection>
    with TickerProviderStateMixin {
  late TabController? controller;
  @override
  void initState() {
    super.initState();
    final authProvider = navigatorKey.currentContext!.read<AuthProvider>();
    controller = TabController(
      initialIndex: authProvider.fromMatch ? 2 : 0,
      length: 3,
      vsync: this,
    );
    authProvider.fromMatch = false;
  }

  @override
  Widget build(BuildContext context) {
    /// [ Widgets ]
    final tabBtns = TabBar(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      labelColor: AppColors.white,
      unselectedLabelColor: AppColors.black,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      indicatorWeight: 0,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: AppColors.buttonBlue,
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonBlue.colors[0].withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      tabs: const [
        Tab(text: 'Recent Chat'),
        Tab(text: 'Call'),
        Tab(text: 'Matches'),
      ],
    );

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          actions: [
            CustomIconBtn(
              onTap: () => navigatorKey.currentState!.pushNamed(
                NotificationPage.routeName,
              ),
              child: SvgPicture.asset('assets/svg/ui_icons/bell.svg'),
            ),
          ],
          bottom: tabBtns,
        ),
        body: TabBarView(
          controller: controller,
          children:
              // const
              [RecentChats(), CallsHistory(), MatchesPage()],
        ),
      ),
    );
  }
}
