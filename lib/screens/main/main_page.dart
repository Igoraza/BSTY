import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/features/chat_and_call/views/chat_messages/pages/chat_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_image.dart';
import '../../features/chat_and_call/models/chat.dart';
import '../../features/chat_and_call/views/call/pages/incoming_call_page.dart';
import '../../features/chat_and_call/views/call/pages/ongoing_call_page.dart';
import '../../features/chat_and_call/views/chats_sectiion/chats_section.dart';
import '../../features/map/map_page.dart';
import '../../features/people/views/explore/explore_page.dart';
import '../../features/people/views/home/home_page.dart';
import '../../features/settings/settings_page.dart';
import '../../utils/functions.dart';
import '../../utils/global_keys.dart';
import '../../utils/theme/colors.dart';
import 'widgets/bottom_nav_bg.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key, this.matchIndex}) : super(key: key);
  int? matchIndex;
  static const routeName = '/main';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// [ Bottom Navigation Bar Buttons ]
  // final bottomNavButtons = [
  //   'home',
  //   'subtitles',
  //   'boundary',
  //   'chat',
  //   'settings',
  // ];

  final bottomNavButtons = [
    'home',
    'explore',
    'location',
    'message',
    'account',
  ];

  final filledBottomNavButtons = [
    'home_filled',
    'explore_filled',
    'location_filled',
    'message_filled',
    'account_filled',
  ];

  final ValueNotifier<int> valueNotifier = ValueNotifier(0);

  // final String? appId = dotenv.env['AGORA_APP_ID'];

  //   final bottomNavButtons = [
  //   {
  //     'icon': 'bottom_nav_swipe.svg',
  //     'is_svg': true,
  //   },
  //   {
  //     'icon': 'bottom_nav_explore.png',
  //     'is_svg': false,
  //   },
  //   {
  //     'icon': '',
  //     'is_svg': false,
  //   },
  //   {
  //     'icon': 'bottom_nav_chat.svg',
  //     'is_svg': true,
  //   },
  //   {
  //     'icon': 'bottom_nav_settings.png',
  //     'is_svg': false,
  //   },
  // ];

  final screens = [
    const HomePage(),
    const ExplorePage(),
    const MapPage(),
    const ChatsSection(),
    const SettingsPage(),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // initOneSignal();
  }

  // Future<void> initOneSignal() async {
  //   if (!mounted) return;

  //   //Remove this method to stop OneSignal Debugging
  //   OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  //   final appId = dotenv.env['ONE_SIGNAL_APP_ID'];
  //   OneSignal.shared.setAppId(appId!);

  //   final pushId = Hive.box('user').get('push_id');
  //   OneSignal.shared
  //       .setExternalUserId(pushId)
  //       .then((value) => debugPrint(value.toString()));

  //   // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  //   OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //     if (accepted) {
  //       debugPrint('User accepted notifications');
  //     } else {
  //       showSnackBar(
  //           'Please enable notifications to receive calls and other updates');
  //     }
  //   });
  //   OneSignal.shared.setNotificationWillShowInForegroundHandler(
  //       (OSNotificationReceivedEvent event) {
  //     // Will be called whenever a notification is received in foreground
  //     // Display Notification, pass null param for not displaying the notification

  //     final data = event.notification.additionalData;
  //     debugPrint('===================>>Notification received: $data');

  //     switch (data!['type']) {
  //       case 'chat':
  //         event.complete(null);
  //         break;

  //       case 'match':
  //         event.complete(event.notification);
  //         break;

  //       case 'call':
  //         // showCallkitIncoming(data);
  //         event.complete(null);
  //         // event.complete(event.notification);
  //         break;

  //       default:
  //         event.complete(event.notification);
  //         break;
  //     }
  //   });

  //   OneSignal.shared
  //       .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
  //     // Will be called whenever a notification is opened/button pressed.
  //     // var notificationJson = result.notification.jsonRepresentation();
  //     // var notificationData = jsonDecode(notificationJson);
  //     // var additionalData = notificationData['os_data']['additionalData'];
  //     // debugPrint("additionalData: $additionalData");

  //     final data = result.notification.additionalData;
  //     debugPrint('===================>>Notification opened: $data');
  //     // if (data!['type'] == 'call') {
  //     //   debugPrint(
  //     //       "===================Call notification: ${data['action_type']}");
  //     //   if (result.action!.type == OSNotificationActionType.actionTaken) {
  //     //     debugPrint("Button pressed with id: ${result.action!.actionId}");
  //     //     navigatorKey.currentState!.pushNamed(
  //     //       OnGoingCallPage.routeName,
  //     //       arguments: {
  //     //         'callId': int.parse(data['call_id']),
  //     //         'isIncoming': true,
  //     //         'isVideo': int.parse(data['action_type']) == 2 ? true : false,
  //     //         'user_image': data['user_image'] ?? '',
  //     //         'user_name': data['user_name'] ?? ''
  //     //       },
  //     //     );
  //     //   } else {
  //     //     debugPrint("===================Call Notification opened $data");
  //     //     navigatorKey.currentState!.pushNamed(
  //     //       IncomingCall.routeName,
  //     //       arguments: {
  //     //         'callId': int.parse(data['call_id']),
  //     //         'isVideo': int.parse(data['action_type']) == 2,
  //     //         'user_image': data['user_image'] ?? '',
  //     //         'user_name': data['user_name'] ?? ''
  //     //       },
  //     //     );
  //     //   }
  //     // } else
  //     if (data!['type'] == 'chat') {
  //       final chat = Chat(
  //           targetId: data['target_id'],
  //           name: data['name'],
  //           image: data['image'],
  //           pushId: data['pushId'],
  //           matchId: data['matchId'],
  //           chatId: data['chatId']);
  //       navigatorKey.currentState!
  //           .pushNamed(ChatPage.routeName, arguments: chat);
  //     } else if (data['type'] == 'match') {
  //       navigatorKey.currentContext!.read<AuthProvider>().fromMatch = true;
  //       navigatorKey.currentState!.pushNamedAndRemoveUntil(
  //           MainPage.routeName, arguments: 3, (route) => false);
  //     } else {
  //       debugPrint("===================Type is not call: ${data['type']}");
  //     }
  //   });

  //   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  //     // Will be called whenever the permission changes
  //     // (ie. user taps Allow on the permission prompt in iOS)
  //   });

  //   OneSignal.shared
  //       .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
  //     // Will be called whenever the subscription changes
  //     // (ie. user gets registered with OneSignal and gets a user ID)
  //   });

  //   OneSignal.shared.setEmailSubscriptionObserver(
  //       (OSEmailSubscriptionStateChanges emailChanges) {
  //     // Will be called whenever then user's email subscription changes
  //     // (ie. OneSignal.setEmail(email) is called and the user gets registered
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authPro = context.read<AuthProvider>();
    if (widget.matchIndex != null) {
      valueNotifier.value = 3;
      widget.matchIndex = null;
    }
    // log('user index main ${widget.navIndex.toString()}');
    return BackgroundImage(
      child: Scaffold(
        extendBody: true,
        body: ValueListenableBuilder<int>(
          valueListenable: valueNotifier,
          builder: (context, value, _) {
            return screens[valueNotifier.value];

            // Stack(
            //   children: [
            //     Container(
            //       margin: EdgeInsets.only(bottom: size.width * 0.18),
            //       child: screens[valueNotifier.value],
            //     ),
            //     Positioned(
            //       bottom: 0,
            //       left: 0,
            //       child: SizedBox(
            //         width: size.width,
            //         height: authPro.isTab
            //             ? size.width * 0.2
            //             : size.width * 0.25,
            //         child: Stack(
            //           children: [
            //             CustomPaint(
            //               size: Size(size.width, size.width * 0.25),
            //               painter: BottomNavCustomPainter(),
            //             ),
            //             Container(
            //               width: size.width,
            //               height: size.height * 0.2,
            //               padding: EdgeInsets.only(
            //                 top: size.height * 0.01,
            //                 bottom: size.height * 0.03,
            //               ),
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
            //                 crossAxisAlignment: CrossAxisAlignment.end,
            //                 children: List.generate(
            //                   bottomNavButtons.length,
            //                   (index) => InkWell(
            //                     /// [Change the screen ] when the bottom navigation bar button is tappe
            //                     onTap: () => valueNotifier.value = index,
            //                     child: index == 2
            //                         ? Container(
            //                             padding: EdgeInsets.all(
            //                               size.width * 0.025,
            //                             ),
            //                             margin: const EdgeInsets.only(
            //                               bottom: 20,
            //                             ),
            //                             decoration: BoxDecoration(
            //                               shape: BoxShape.circle,
            //                               color: AppColors.deepOrange,
            //                               gradient: value == 2
            //                                   ? null
            //                                   : AppColors.buttonBlue,
            //                             ),
            //                             child: SvgPicture.asset(
            //                               'assets/svg/bottom_nav/boundary.svg',
            //                             ),
            //                           )
            //                         : index == 0
            //                         ? SvgPicture.asset(
            //                             // 'assets/icons/${bottomNavButtons[index]['icon']}',
            //                             'assets/svg/bottom_nav/${bottomNavButtons[index]}.svg',
            //                             color: value == index
            //                                 ? null
            //                                 : AppColors.lightGrey,
            //                           )
            //                         : Padding(
            //                             padding: const EdgeInsets.fromLTRB(
            //                               10,
            //                               10,
            //                               10,
            //                               0,
            //                             ),
            //                             child: SvgPicture.asset(
            //                               // 'assets/icons/${bottomNavButtons[index]['icon']}',
            //                               'assets/svg/bottom_nav/${bottomNavButtons[index]}.svg',
            //                               color: value == index
            //                                   ? AppColors.deepOrange
            //                                   : AppColors.lightGrey,
            //                             ),
            //                           ),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // );
          },
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: valueNotifier,
          builder: (context, value, _) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Container(
                width: size.width,
                height: size.height * 0.08,
                // padding: EdgeInsets.only(
                //   top: size.height * 0.01,
                //   bottom: size.height * 0.03,
                // ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    bottomNavButtons.length,
                    (index) => InkWell(
                      /// [Change the screen ] when the bottom navigation bar button is tappe
                      onTap: () => valueNotifier.value = index,
                      child:
                          // index == 2
                          //     ? Container(
                          //         padding: EdgeInsets.all(size.width * 0.025),
                          //         margin: const EdgeInsets.only(bottom: 20),
                          //         decoration: BoxDecoration(
                          //           shape: BoxShape.circle,
                          //           color: AppColors.deepOrange,
                          //           gradient: value == 2
                          //               ? null
                          //               : AppColors.buttonBlue,
                          //         ),
                          //         child: SvgPicture.asset(
                          //           'assets/svg/bottom_nav/boundary.svg',
                          //         ),
                          //       )
                          //     :
                          CircleAvatar(
                            radius: size.height * 0.03,
                            backgroundColor: value == index
                                ? Colors.pink
                                : AppColors.white,
                            child: Center(
                              child: SvgPicture.asset(
                                // 'assets/icons/${bottomNavButtons[index]['icon']}',
                                'assets/svg/bottom_nav/${value == index ? filledBottomNavButtons[index] : bottomNavButtons[index]}.svg',
                                height: size.height * 0.035,
                                width: size.height * 0.035,
                                color: value == index
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
