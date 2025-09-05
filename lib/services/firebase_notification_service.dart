import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:bsty/features/chat_and_call/views/call/pages/ongoing_call_page.dart';
import 'package:bsty/utils/global_keys.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;

class NotificationControl {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final String? serverKey = dotenv.env['FIRE_BASE_SERVER_KEY'];

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<String?> storeToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    // log(fcmToken.toString());
    return fcmToken;
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> showCallkitIncoming(
    String uuid,
    Map<String, dynamic> data,
  ) async {
    log(
      '--------------------------------------------------- setupSDKEngine $data',
    );

    CallKitParams callKitParams = CallKitParams(
      id: uuid,
      nameCaller: data['user_name'],
      appName: 'Metfie',
      avatar: data['user_image'],
      // handle: '0123456789',
      type: int.parse(data['action_type']) == 2 ? 1 : 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: 30000,
      // extra: <String, dynamic>{'userId': '1a2b3c4d'},
      // headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        // backgroundUrl: 'https://i.pravatar.cc/500',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);

    await listenTocallAction(data);
  }

  Future<void> listenTocallAction(Map<String, dynamic> data) async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:

          // callsProvider.callContext = context;

          // TODO: received an incoming call
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.actionCallAccept:
          log('====================== ======== notification accept ');
          navigatorKey.currentState!.pushNamed(
            OnGoingCallPage.routeName,
            arguments: {
              'callId': int.parse(data['call_id']),
              'isIncoming': true,
              'isVideo': int.parse(data['action_type']) == 2 ? true : false,
              'user_image': data['user_image'] ?? '',
              'user_name': data['user_name'] ?? '',
            },
          );
          log('Notification received: ACTION_CALL_ACCEPT');
          // TODO: accepted an incoming call
          // TODO: show screen calling in Flutter
          break;
        case Event.actionCallDecline:
          log('Notification received: ACTION_CALL_DECLINE');
          // final callsProvider =
          //     navigatorKey.currentContext!.read<CallsProvider>();
          // callsProvider.agoraEngine = createAgoraRtcEngine();
          // await callsProvider.setupSDKEngine(false);
          // callsProvider.leaveChannel();
          log('Need to implement 1');
          // await CallsProvider().agoraEngine.release();
          // TODO: declined an incoming call
          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
          break;
        case Event.actionCallTimeout:
          // TODO: missed an incoming call
          break;
        case Event.actionCallCallback:
          // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
          // TODO: only iOS
          break;
        case Event.actionCallToggleMute:
          // TODO: only iOS
          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: only iOS
          break;
        case Event.actionCallCustom:
          // TODO: for custom action
          break;
        case Event.actionCallConnected:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;

      // if (notification != null) {

      // log('notification recieved ${message.data.entries}');
      // log('notification data ${message.data}');
      // log('notification message $message');
      // showCallkitIncoming(const Uuid().v4(), message.data);
      if (message.data.containsKey('type')) {
        if (message.data['type'] == "call") {
          log('notification recieved ${message.data.entries}');
          log('notification message data ${message.data}');
          log('notification message type ${message.data['type']}');
          showCallkitIncoming(const Uuid().v4(), message.data);
        }
      }
      // flutterLocalNotificationsPlugin.show(
      //   notification.hashCode,
      //   notification.title,
      //   notification.body,
      //   NotificationDetails(
      //     android: AndroidNotificationDetails(
      //       channel.id,
      //       channel.name,
      //       icon: 'launch_background',
      //     ),
      //   ),
      // );
      // }
    });
  }

  void sendPushMessage() async {
    try {
      String FIRE_BASE_SERVER_KEY =dotenv.env['FIRE_BASE_SERVER_KEY']!;
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$FIRE_BASE_SERVER_KEY',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{'body': 'body', 'title': 'title'},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'screen': 'screen2',
          },
          "to":
              'dUA4rUIhTCOoOPJMA0lmWX:APA91bEFWIIF1vakZcD_1iB_yVvmRJYoHJ3FBzkAmOWFUspZgv5SJmrbg4cosJjqVNDLcDwhUGgglnHu_CQIIieiL0ghKB1k9lS_onm-7Dp7xWibAVmi0kExV_CG9LJL9USPHh0cNi43',
        }),
      );
    } catch (e) {
      debugPrint("error push notification");
    }
  }

  // for testing firebase messaging
  void sendChatPushMessage(String body, String title, String fcmToken) async {
    debugPrint("111 fcm TOken $fcmToken body $body title $title");
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      User currentUse = _auth.currentUser!;
      final uId = currentUse.uid;
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAqdGrDb4:APA91bFh2FNgPJ6Msk2INB0M-gyVXE8ooxGjPIkjxQMIjEpsd65yG_Jvu1Pu1Wx8j2j0eN73HTUW-tbPuupIx9nfAYBxNx-EZjwtYMzPc-H7Nex3o5Fb4OO8wtjA-D9cIdcak5ooLquc',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'patientId': uId,
            'screen': 'chatScreen',
          },
          "to": fcmToken,
        }),
      );
    } catch (e) {
      debugPrint("error push notification $e");
    }
  }
}
