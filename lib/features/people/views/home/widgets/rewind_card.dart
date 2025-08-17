import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/matched_dialog.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../services/people_provider.dart';
import 'profile_card.dart';

class RewindedCard extends StatelessWidget {
  const RewindedCard({super.key, required this.lastCard});

  final ProfileCard? lastCard;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    void sendUserAction(int action, int userId) {
      final peopleProvider = context.read<PeopleProvider>();
      switch (action) {
        case 1:
          peopleProvider.sendUserRewind(context, userId, '1').then((value) {
            debugPrint('=========>> User Action Response: $value');
            log('ree================== $value');
            log('ree================== ${value['status']}');
            log('ree================== ${value['match']}');
            if (value['match']) {
              showDialog(
                  context: context,
                  builder: (_) => MatchedDialog(
                        id: userId,
                        name: lastCard!.person.name,
                        image: lastCard!.person.displayImage,
                        pushId: value['push_id'] ?? '',
                        matchId: value['match_id'],
                        chatid: value['chat_id'],
                      ));
            }
          });
          break;
        case 2:
          peopleProvider.sendUserRewind(context, userId, '2');
          break;
        case 3:
          peopleProvider.sendUserRewind(context, userId, '3');
          break;
      }
      Navigator.of(context).pop();
    }

    final List actions = [
      {
        'icon': 'assets/svg/ui_icons/star.svg',
        'onTap': () => {sendUserAction(1, lastCard!.person.id)}
      },
      {
        'icon': 'assets/svg/ui_icons/fav.svg',
        'onTap': () => {sendUserAction(2, lastCard!.person.id)}
      },
      {
        'icon': 'assets/svg/ui_icons/dislike.svg',
        'onTap': () => {sendUserAction(3, lastCard!.person.id)}
      },
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: double.infinity,
              height: mq.height * 0.6,
              child: lastCard!),
          SizedBox(height: mq.height * 0.02),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(30)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions
                    .map((e) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: e['onTap'] as void Function()?,
                            child: SvgPicture.asset(e['icon']))))
                    .toList()),
          ),
        ],
      ),
    );
  }
}
