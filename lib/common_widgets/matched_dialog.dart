import 'package:align_positioned/align_positioned.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/chat_and_call/models/chat.dart';
import '../features/chat_and_call/views/chat_messages/pages/chat_page.dart';
import '../utils/global_keys.dart';
import '../utils/theme/colors.dart';
import 'stadium_button.dart';

class MatchedDialog extends StatelessWidget {
  const MatchedDialog({
    Key? key,
    required this.name,
    required this.image,
    required this.id,
    required this.pushId,
    required this.matchId,
    this.chatid,
  }) : super(key: key);

  final int id;
  final String name;
  final String image;
  final String pushId;
  final int matchId;
  final String? chatid;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final userImage = Hive.box('user').get('display_image');

    return Dialog(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(mq.width * 0.05),
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/svg/dialog/confity.webp'),
              alignment: Alignment.bottomCenter,
              fit: BoxFit.cover),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: mq.width * 0.07),
            const Text(
              "It's a Match !",
              style: TextStyle(
                  fontSize: 26,
                  color: AppColors.deepOrange,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text(
              "You and $name have liked each other",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: mq.width * 0.07),
            SizedBox(
              height: mq.width * 0.5,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset('assets/svg/dialog/matched_heart.svg',
                      height: mq.width * 0.5),
                  AlignPositioned(
                    dx: mq.width * -0.15,
                    child: CircleAvatar(
                      radius: mq.width * 0.17,
                      backgroundImage: CachedNetworkImageProvider(userImage),
                    ),
                  ),
                  AlignPositioned(
                    dx: mq.width * 0.15,
                    child: CircleAvatar(
                      radius: mq.width * 0.17,
                      backgroundImage: CachedNetworkImageProvider(image),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: mq.width * 0.07),
            StadiumButton(
              onPressed: () {
                final chat = Chat(
                    targetId: id,
                    name: name,
                    image: image,
                    pushId: pushId,
                    matchId: matchId,
                    chatId: chatid);
                navigatorKey.currentState!
                    .pushReplacementNamed(ChatPage.routeName, arguments: chat);
              },
              text: 'Send Message',
              visualDensity: VisualDensity.standard,
              gradient: AppColors.orangeYelloH,
            ),
            const SizedBox(height: 10),
            TextButton(
                onPressed: () => navigatorKey.currentState!.pop(),
                child: const Text('Keep Exploring!'))
          ],
        ),
      ),
    );
  }
}
