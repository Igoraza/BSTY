import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../api/api_helper.dart';
import '../../api/endpoints.dart';
import '../../common_widgets/background_image.dart';
import '../../common_widgets/loading_animations.dart';
import '../../common_widgets/snapshot_error.dart';
import '../../utils/theme/colors.dart';
import 'notification.dart';
import 'widgets/notif_appbar.dart';
import 'widgets/notification_tile.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static const routeName = '/notifications';

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final dio = Api().api;
  late Future _future;

  @override
  void initState() {
    super.initState();
    _future = dio.get(Endpoints.myNotifications);
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    return BackgroundImage(
      child: Scaffold(
        backgroundColor: AppColors.black.withOpacity(0.7),
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: NotifsAppBar(),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot snapshot) {
            log("Getting notification : ${snapshot.connectionState}");
            log("Notification data : ${snapshot.data}");
            if (snapshot.connectionState != ConnectionState.done) {
              return mainLoadingAnimationLight;
            }
            if (snapshot.hasError) {
              String errorMsg = '';

              debugPrint(snapshot.error.toString());
              log("Notification error : ${snapshot.error}");

              /// chieck if [ connection error ]
              if (snapshot.error.toString().contains('SocketException')) {
                errorMsg =
                    'Error retrieving Notifications.\nPlease check your internet connection';
              } else {
                errorMsg = 'Error retrieving Notifications. Try again later';
              }

              return SnapshotErrorWidget(errorMsg, color: AppColors.white);
            }
            final notifsJson = jsonDecode(
              snapshot.data.toString(),
            )['notifications'];
            final notifs = notifsJson
                .map((e) => NotificationModel.fromJson(e))
                .toList();

            return ListView.separated(
              padding: EdgeInsets.all(appHeight * 0.02),
              itemCount: notifs.length,
              itemBuilder: (_, i) => NotificationTile(notifs[i]),
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            );
          },
        ),
      ),
    );
  }
}
