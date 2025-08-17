import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/theme/colors.dart';

class TextMsgBubble extends StatelessWidget {
  const TextMsgBubble({
    Key? key,
    required this.msg,
    this.isNextSame = true,
    required this.isSent,
    this.showTime = false,
  }) : super(key: key);

  final DocumentSnapshot msg;
  final bool isSent;
  final bool? isNextSame;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: appSize.width * 0.04,
        vertical: appSize.height * 0.01,
      ),
      constraints: BoxConstraints(
        maxWidth: appSize.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isSent
            ? msg['text'] == 'Message was deleted !'
                ? AppColors.grey
                : AppColors.blue
            : msg['text'] == 'Message was deleted !'
                ? AppColors.grey
                : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: isSent
              ? Radius.circular(appSize.width * 0.05)
              : const Radius.circular(0),
          topRight: isSent
              ? const Radius.circular(0)
              : Radius.circular(appSize.width * 0.05),
          bottomLeft: Radius.circular(appSize.width * 0.05),
          bottomRight: Radius.circular(appSize.width * 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(msg['text'],
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: isSent
                        ? AppColors.white
                        : msg['text'] == 'Message was deleted !'
                            ? AppColors.white
                            : AppColors.black,
                  )),
          if (showTime) ...[
            const SizedBox(height: 5),
            Text(DateFormat('hh:mm a').format(msg['time'].toDate()),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isSent ? AppColors.lightGrey : AppColors.grey,
                    )),
          ],
        ],
      ),
    );
  }
}
