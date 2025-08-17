// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/chat_and_call/models/chat.dart';
import 'package:bsty/features/chat_and_call/services/call_provider.dart';
import 'package:bsty/utils/constants/plan_price_details.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/buy_plan_dialog.dart';
import '../../../../../common_widgets/custom_icon_btn.dart';
import '../../../../../common_widgets/upgrade_plan_dialog.dart';
import '../../../services/chat_provider.dart';
import '../../call/pages/ongoing_call_page.dart';
import 'chat_screen_options_menu.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Chat chat;
  final String? chatId;
  const ChatAppBar({
    Key? key,
    required this.chat,
    this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    final callProvider = context.read<CallsProvider>();
    final id = chatProvider.currentTargetId ?? 0;
    final name = chatProvider.currentTargetName ?? '';
    final image = chatProvider.currentTargetImage ?? '';

    final PlanPriceDetails planDetails = PlanPriceDetails();

    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;

    final userBox = Hive.box('user');

    bool? isAudio = userBox.get('audio_allowed');
    bool? isVideo = userBox.get('video_allowed');

    final audioBalance = userBox.get('audio_call_balance');
    final videoBalance = userBox.get('video_call_balance');

    return AppBar(
      centerTitle: false,
      title: Text(name, overflow: TextOverflow.fade),
      actions: [
        CustomIconBtn(
            onTap: () {
              if (userPlan > 2 && !planExpired) {
                if (audioBalance != 0) {
                  Navigator.of(context)
                      .pushNamed(OnGoingCallPage.routeName, arguments: {
                    'callId': 0,
                    'targetUserId': id,
                    'isIncoming': false,
                    'isVideo': false,
                    'user_image': image,
                    'user_name': name,
                    'isOutgoing': true,
                  });
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => BuyPlanDialog(
                            // title: 'Minute Of Voice',
                            desc: 'Buy Audio Minutes As Needed !',
                            img: 'assets/svg/upgrade_dialog/minute.svg',
                            btnText: 'Buy Now',
                            paymentList: planDetails.payAudio,
                          ));
                }
              } else {
                showDialog(
                    context: context,
                    builder: (context) => UpgradePlanDialog());
              }
            },
            child: const Icon(Icons.call_rounded)),
        CustomIconBtn(
            onTap: () {
              if (userPlan > 2 && !planExpired) {
                if (videoBalance != 0) {
                  Navigator.of(context)
                      .pushNamed(OnGoingCallPage.routeName, arguments: {
                    'callId': 0,
                    'targetUserId': id,
                    'isIncoming': false,
                    'isVideo': true,
                    'user_image': image,
                    'user_name': name,
                    'isOutgoing': true,
                  });
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => BuyPlanDialog(
                            // title: 'Minute Of Voice',
                            desc: 'Buy Video Minutes As Needed !',
                            img: 'assets/svg/upgrade_dialog/telephone.svg',
                            btnText: 'Buy Now',
                            paymentList: planDetails.payVideo,
                          ));
                }
              } else {
                showDialog(
                    context: context,
                    builder: (context) => UpgradePlanDialog());
                return;
              }
            },
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset('assets/svg/chat/video_cam.svg')),
        IconButton(
          onPressed: () async {
            if (isAudio != null || isVideo == null) {
              await callProvider.getCallSettings(chat);
            } else {
              callProvider.isCallAllowed = isAudio!;
              callProvider.isVideoAllowed = isVideo;
            }
            showDialog(
              context: context,
              builder: (ctx) => ChatScreenOptionsMenu(
                chat: chat,
              ),
            );
          },
          icon: const Icon(Icons.more_vert),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
