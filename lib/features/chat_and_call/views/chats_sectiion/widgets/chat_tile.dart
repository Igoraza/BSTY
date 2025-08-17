import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bsty/features/chat_and_call/services/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../utils/theme/colors.dart';
import '../../../models/chat.dart';
import '../../chat_messages/pages/chat_page.dart';

class ChatTile extends StatelessWidget {
  const ChatTile(this.chat, {super.key});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    final chatProvider = context.read<ChatProvider>();
    log(chat.isBlocked.toString());
    return ListTile(
        visualDensity: VisualDensity.compact,
        onTap: () {
          // final chatProvider = context.read<ChatProvider>();
          // if (chat.chatId == null) {
          //   String? chatId;
          //   chatId ??= await chatProvider.createNewChat();
          //   log('chat id --- $chatId');
          //   // setState(() => messagesSteram = chatProvider.messagesStream(chatId!));
          // }
          Navigator.pushNamed(context, ChatPage.routeName, arguments: chat);
          // if (chat.isBlocked != null && chat.isBlocked == true) {
          log('isBlocked ${chat.isBlocked}');
          log('isSent ${chat.isSent}');
          chatProvider.isBlocked = chat.isBlocked!;
          chatProvider.isSent = chat.isSent;
          // }
          //     .then((value) {
          //   context.read<ChatProvider>().getMatches();
          // });
        },
        leading: Stack(children: [
          CircleAvatar(
              radius: appWidth * 0.08,
              foregroundImage: CachedNetworkImageProvider(
                chat.image,
              ),
              child: const Icon(Icons.person_rounded)),

          /// [Online status]
          // if (isOnline) ...[
          //   Positioned(
          //       top: appWidth * 0.005,
          //       right: appWidth * 0.015,
          //       child: Container(
          //           width: appWidth * 0.03,
          //           height: appWidth * 0.03,
          //           decoration: const BoxDecoration(
          //               border: Border.fromBorderSide(
          //                   BorderSide(color: AppColors.white)),
          //               color: AppColors.teal,
          //               shape: BoxShape.circle)))
          // ]
        ]),
        title: Text(chat.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: chat.lastMsg == ''
            ? null
            : Text(
                chat.lastMsg,
                style: Theme.of(context).textTheme.bodyMedium!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
        trailing:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          if (chat.time != null)
            Text(timeago.format(chat.time!, locale: 'en_short')),
          if (chat.unread > 0)
            CircleAvatar(
              radius: appWidth * 0.025,
              backgroundColor: AppColors.pink,
              child: Center(
                child: Text(
                  chat.unread.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
        ]));
  }
}
