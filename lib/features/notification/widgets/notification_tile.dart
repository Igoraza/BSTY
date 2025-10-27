import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../utils/global_keys.dart';
import '../../../utils/theme/colors.dart';
import '../../people/views/detailed/person_details_page.dart';
import '../notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile(this.notification, {Key? key}) : super(key: key);

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: () => navigatorKey.currentState!.pushNamed(
        PersonDetailedPage.routeName,
        arguments: {
          'id': notification.sourceUser.id,
          'name': notification.sourceUser.name,
          'image': notification.sourceUser.displayImage,
        },
      ),
      // onTap: () {
      //   context.read<AuthProvider>().signInWithGoogle();
      // },
      isThreeLine: true,
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: CachedNetworkImageProvider(
          notification.sourceUser.displayImage ?? "",
        ),
      ),
      tileColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Text(
            notification.sourceUser.name ?? "",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          // const SizedBox(width: 4),
          // Expanded(
          //     child: Text(headline6,
          //         style: Theme.of(context)
          //             .textTheme
          //             .bodyMedium!
          //             .copyWith(color: AppColors.black.withOpacity(0.5)))),
          // const SizedBox(width: 4),
          //TODO: Add icon based on notification type
        ],
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall!.copyWith(color: AppColors.orange),
          ),
          Text(
            timeago.format(notification.created),
            style: textTheme.bodySmall!.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
