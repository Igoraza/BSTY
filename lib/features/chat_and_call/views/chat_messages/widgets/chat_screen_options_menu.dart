// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:bsty/features/chat_and_call/models/chat.dart';
import 'package:bsty/features/chat_and_call/services/call_provider.dart';
import 'package:bsty/features/chat_and_call/services/chat_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/connect_call_dialog.dart';
import '../../../../../utils/functions.dart';
import '../../../../../utils/global_keys.dart';
import '../../../../../utils/theme/colors.dart';
import '../../widgets/chat_report_dialog.dart';
import 'chat_screen_alert_dialog.dart';

class ChatScreenOptionsMenu extends StatelessWidget {
  final Chat chat;
  final String? chatId;
  const ChatScreenOptionsMenu({
    super.key,
    required this.chat,
    this.chatId,
  });

  static const reportReasons = [
    'Sexual Content',
    'Abusive Content',
    'Violent Content',
    'Inappropriate Content',
    'Spam or Misleading',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    void showConfirmDialog({
      String? title,
      String? content,
      VoidCallback? onConfirm,
    }) =>
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => ChatScreenAlertDialog(
                  title: title,
                  content: content,
                  onConfirm: onConfirm,
                ));

    final options = [
      // {
      //   'text': 'Clear history',
      //   'ontap': () {
      //     // await ChatProvider().clearChat(chatId);
      //     Navigator.of(context).pop();
      //     showConfirmDialog(
      //       content:
      //           "You won't be able to see this conversation again. Do you want to clear ?",
      //       onConfirm: () {
      //         debugPrint('Clear history');
      //       },
      //     );
      //   },
      // },
      {
        'text': 'Unmatch',
        'ontap': () {
          showConfirmDialog(
            content:
                "You won't be able to chat or contact with this person again. Do you want to unmatch ?",
            onConfirm: () async {
              final chatProvider = context.read<ChatProvider>();
              await chatProvider.unMatch(chat);

              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Navigator.pushNamed(context, ChatPage.routeName, arguments: chat);
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(builder: (context) => MainPage()),
              //     (Route<dynamic> route) => false);
              // Navigator.of(context).pop();
            },
          );
        },
      },
      {
        'text': 'Call settings',
        'ontap': () {
          // Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => ConnectCallDialog(
              chat: chat,
              showCloseBtn: false,
              title: "Connect for a real-time\nchemistry check with a call",
              desc:
                  'Once mutual interest is established,\nyou can initiate a video/audio call and connect with each other',
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                final callProvider = context.read<CallsProvider>();
                final chatProvider = context.read<ChatProvider>();
                final response = await callProvider.updateCallSettings(
                  chat,
                );
                bool audio = callProvider.isCallAllowed;
                bool video = callProvider.isVideoAllowed;
                String message = '';
                if (response.statusCode == 200) {
                  if (audio && video) {
                    message =
                        "I would like to have a conversation with you over voice and video call. Please enable permission in call settings if it hasn't been enabled already";
                    // 'I would like to have a conversation with you over a voice and video call, Please allow me to call you in Call Settings';
                    chatProvider.sendMessage(
                        chatProvider.inChatID ?? chatId ?? chat.chatId!,
                        message,
                        chat);
                  } else if (audio && !video) {
                    message =
                        "I would like to have a conversation with you over voice call. Please enable permission in call settings if it hasn't been enabled already";
                    chatProvider.sendMessage(
                        chatProvider.inChatID ?? chatId ?? chat.chatId!,
                        message,
                        chat);
                  } else if (!audio && video) {
                    message =
                        "I would like to have a conversation with you over video call. Please enable permission in call settings if it hasn't been enabled already";
                    chatProvider.sendMessage(
                        chatProvider.inChatID ?? chatId ?? chat.chatId!,
                        message,
                        chat);
                  }

                  showSnackBar('Call settings Updated!');
                } else {
                  showSnackBar('Something went wrong, Try again later!');
                }

                // log(callProvider.isCallAllowed.toString());
              },
            ),
          );
        },
      },
      {
        'text': 'Block & Report',
        'ontap': () {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => ChatReportDialog(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50)),
              userId: chat.targetId,
              options: reportReasons,
              onSubmint: (() {
                Navigator.pop(context);
                showConfirmDialog(
                  content:
                      "You won't be able to see or contact this person anymore. Do you want to block ?",
                  onConfirm: () {
                    Future.delayed(const Duration(seconds: 1),
                        () => showSnackBar('You have blocked this person'));
                  },
                );
              }),
            ),
          );
        }
      }
    ];

    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      alignment: Alignment.topRight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.only(right: 20, top: 20, left: size.width * 0.5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (e) => InkWell(
                onTap: e['ontap'] as void Function(),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    e['text'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
