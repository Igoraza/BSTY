import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/features/chat_and_call/views/chat_messages/widgets/chat_screen_alert_dialog.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/global_keys.dart';
import '../../../../auth/services/auth_provider.dart';
import '../../../services/chat_provider.dart';
import 'text_msg_bubble.dart';

class MsgsList extends StatefulWidget {
  const MsgsList(
      {Key? key, required this.msgs, this.image, required this.chatId})
      : super(key: key);

  final List<DocumentSnapshot> msgs;
  final String? image;
  final String chatId;

  @override
  State<MsgsList> createState() => _MsgsListState();
}

class _MsgsListState extends State<MsgsList> {
  final ScrollController _scrollController = ScrollController();

  _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  loadLastSeen() {
    chatProvider.lastmessagelable.addListener(() {
      setState(() {});
    });
  }

  bool checkActive = false;
  late ChatProvider chatProvider;
  @override
  Widget build(BuildContext context) {
    if (!checkActive) {
      setState(() {
        checkActive = true;
      });
      chatProvider = context.read<ChatProvider>();
    }
    final size = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    log("111111${chatProvider.isBlocked.toString()}");
    log("111111${chatProvider.isSent.toString()}");
    return Consumer<ChatProvider>(builder: (context, chatPrr, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      return Center(
          child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03, vertical: size.height * 0.01),
        itemCount: (chatPrr.isBlocked && chatPrr.isSent) || chatPrr.isMutual!
            ? widget.msgs.length + 1
            : widget.msgs.length,
        itemBuilder: (context, index) => (chatPrr.isBlocked &&
                    chatPrr.isSent &&
                    widget.msgs.length == index) ||
                (chatPrr.isMutual && widget.msgs.length == index)
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomDialog(
                            desc:
                                "Unblock ${chatPrr.currentTargetName} to send a message",
                            btnText: "Unblock",
                            btnGradient: AppColors.orangeRedH,
                            onPressed: () async {
                              log("message");
                              await chatPrr.unBlockUser();
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                      child: Container(
                          // width: 200,
                          // height: 30,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Center(
                            child: Text(
                              'You blocked this Contact. Tap to unblock',
                              style: TextStyle(
                                color: AppColors.black,
                              ),
                            ),
                          )),
                    ),
                    // Container(
                    //     // width: 200,
                    //     // height: 30,
                    //     margin: const EdgeInsets.symmetric(vertical: 4),
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 14, vertical: 4),
                    //     decoration: const BoxDecoration(
                    //       color: AppColors.lightGrey,
                    //       borderRadius: BorderRadius.all(Radius.circular(10)),
                    //     ),
                    //     child: const Center(
                    //       child: Text(
                    //         'You unblocked this Contact.',
                    //         style: TextStyle(
                    //           color: AppColors.black,
                    //         ),
                    //       ),
                    //     )),
                  ],
                ),
              )
            : MsgTile(
                widget.msgs[index],
                isSent:
                    widget.msgs[index]['sender'] == Hive.box('user').get('id'),
                image: widget.image,
                prevMsg: index > 0 ? widget.msgs[index - 1] : null,
                nextMsg: index < widget.msgs.length - 1
                    ? widget.msgs[index + 1]
                    : null,
                chatId: widget.chatId,
                index: index,
                msgLnth: widget.msgs.length,
              ),
      ));
    });
  }
}

class MsgTile extends StatelessWidget {
  const MsgTile(
    this.msg, {
    Key? key,
    this.nextMsg,
    this.prevMsg,
    this.image,
    required this.isSent,
    required this.chatId,
    required this.index,
    required this.msgLnth,
  }) : super(key: key);

  final DocumentSnapshot msg;
  final String? image;
  final DocumentSnapshot? prevMsg;
  final DocumentSnapshot? nextMsg;
  final bool isSent;
  final String chatId;
  final int index;
  final int msgLnth;

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;
    final isPrevSame = prevMsg?['sender'] == msg['sender'];
    final isNextSame = nextMsg?['sender'] == msg['sender'];
    final authProvider = context.read<AuthProvider>();
    final token =
        authProvider.retrieveUserTokens().then((value) => value['access']);
    final ChatProvider chatProvider = context.read<ChatProvider>();
    final DateTime? lastMsgSeen = chatProvider.lastMsgSeen;

    return Padding(
      padding: EdgeInsets.only(top: isPrevSame ? 5 : 20),
      child: GestureDetector(
        onLongPress: () {
          log({msgLnth - 1 == index ? true : false}.toString());
          if (isSent) {
            if (msg['text'] != 'Message was deleted !') {
              showConfirmDialog(
                  content: "Do you want to delete this message ?",
                  onConfirm: () {
                    chatProvider.deleteChat(
                        chatId, msg.id, msgLnth - 1 == index ? true : false);
                    log(msg.id.toString());
                    log(msg.metadata.toString());
                  });
            }
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg['time'].toDate().day != prevMsg?['time'].toDate().day) ...[
              const SizedBox(height: 10),
              Text(
                DateFormat('d MMMM yyyy').format(msg['time'].toDate()),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
            ],
            Row(
              mainAxisAlignment:
                  isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isSent) ...[
                  !isPrevSame
                      ? CircleAvatar(
                          radius: appSize.width * 0.05,
                          foregroundImage: isPrevSame
                              ? null
                              : CachedNetworkImageProvider(image ?? '',
                                  headers: {'Authorization': 'Bearer $token'}),
                          child: const Icon(Icons.person_rounded))
                      : SizedBox(width: appSize.width * 0.1),
                  SizedBox(width: appSize.width * 0.03),
                ],
                TextMsgBubble(
                  msg: msg,
                  isNextSame: isNextSame,
                  isSent: isSent,
                  showTime: !isNextSame ||
                      nextMsg?['time']
                          .toDate()
                          .subtract(const Duration(minutes: 1))
                          .isAfter(msg['time'].toDate()),
                ),
              ],
            ),
            if (isSent &&
                lastMsgSeen != null &&
                lastMsgSeen.isAtSameMomentAs(msg['time'].toDate()))
              const Align(
                  alignment: Alignment.centerRight, child: Text('seen   ')),
          ],
        ),
      ),
    );
  }

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
}
