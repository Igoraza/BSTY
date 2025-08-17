import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../utils/functions.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/call.dart';
import '../../call/pages/ongoing_call_page.dart';

class CallTile extends StatelessWidget {
  const CallTile({Key? key, required this.call}) : super(key: key);

  final Call call;

  @override
  Widget build(BuildContext context) {
    final int currentUserid = Hive.box('user').get('id');
    final bool isIncoming = call.user.id != currentUserid;
    final CallUser user = isIncoming ? call.user : call.targetUser;
    final size = MediaQuery.of(context).size;

    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;

    return ListTile(
        onTap: () {
          debugPrint('Call Tile tapped');
        },
        // Background color of the tile is commented out because it is
        // displaying under the appbar while scrolling

        // tileColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: CircleAvatar(
            radius: size.width * 0.07,
            backgroundImage: CachedNetworkImageProvider(user.displayImage)),
        title: Text(user.name),
        subtitle: Row(children: [
          Icon(
            size: 18,
            isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded,
            color: isIncoming ? AppColors.orange : AppColors.teal,
          ),
          const SizedBox(width: 5),
          Text(timeago.format(DateTime.parse(call.created)))
        ]),

        /// [ actionType: 1 => Audio Call, 2 => Video Call ]
        trailing: CircleAvatar(
            radius: 20,
            backgroundColor:
                call.actionType == 2 ? AppColors.pink : AppColors.teal,
            child: IconButton(
                onPressed: () {
                  if (userPlan > 2 && !planExpired) {
                    Navigator.of(context)
                        .pushNamed(OnGoingCallPage.routeName, arguments: {
                      'callId': call.id,
                      'targetUser': user,
                      'isIncoming': false,
                      'isVideo': call.actionType == 2 ? true : false
                    });
                  } else {
                    showUpgradePlanDialog();
                  }
                },
                icon: Icon(call.actionType == 2 ? Icons.videocam : Icons.call,
                    color: Colors.white))));
  }
}
