// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:developer';
import 'dart:io';

import 'package:bsty/features/chat_and_call/models/chat.dart';
import 'package:bsty/features/chat_and_call/views/call/pages/incoming_call_page.dart';
import 'package:bsty/features/chat_and_call/views/chat_messages/pages/chat_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_portal/flutter_portal.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:bsty/services/firebase_notification_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/providers.dart';
import 'firebase_options.dart';
import 'routes/routes.dart';
import 'utils/global_keys.dart';
import 'utils/potrait_mode.dart';
import 'utils/theme/theme.dart';
import 'utils/unfocus.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  // showFlutterNotification(message);
  log('notification message data ${message.data}');
  if (message.data.containsKey('type')) {
    log('notification recieved ${message.data.entries}');
    log('notification message data ${message.data}');
    log('notification message type ${message.data['type']}');
    if (message.data['type'] == "call") {
      notifyC.showCallkitIncoming(const Uuid().v4(), message.data);
    }
  }

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  log('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
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
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  /// [ ensures that the app is initialized before running ]

  WidgetsFlutterBinding.ensureInitialized();

  /// [ initialize dependencies ]
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterError.onError = (errorDetails) {
    // If you wish to record a "non-fatal" exception, please use `FirebaseCrashlytics.instance.recordFlutterError` instead
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await Hive.initFlutter();
  await Hive.openBox('user'); // 👈 MUST open before use
  await Hive.openBox('settings'); 

  ///  load [ environment variables ] from .env file
  await dotenv.load(fileName: ".env");

  await setupOneSignal();

  //
  // try {
  //   OneSignal.initialize(dotenv.env['ONE_SIGNAL_APP_ID']!);
  // } catch (e) {
  //   log("Onesignal initialize error: $e");
  // }

  //

  // handleNotifications();

  ///  prevent screen recording and screenshots
  if (Platform.isAndroid) {
    // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  runApp(
    DevicePreview(
      enabled: false,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const BSTYApp(),
    ),
  );
  // runApp(const InApp());
}

final notifyC = NotificationControl();

Future<void> setupOneSignal() async {
  try {
    final appId = dotenv.env['ONE_SIGNAL_APP_ID'];
    if (appId == null) {
      log("❌ ONE_SIGNAL_APP_ID not found in .env");
      return;
    }

    OneSignal.initialize(appId);
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Login external user (optional)
    final pushId = Hive.box('user').get('push_id');
    if (pushId != null) {
      OneSignal.login(pushId);
      log("✅ OneSignal logged in as $pushId");
    }

    // Ask permission once
    final permissionAccepted = await OneSignal.Notifications.requestPermission(
      true,
    );
    if (permissionAccepted) {
      log("✅ Notification permission granted");
    } else {
      log("⚠️ Notification permission denied");
    }

    // Foreground handler
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final data = event.notification.additionalData;
      log("📩 Foreground notification received: $data");

      if (data != null) {
        switch (data['type']) {
          case 'chat':
            event.preventDefault(); // don’t show
            break;
          case 'call':
            event.preventDefault(); // handled internally
            break;
          default:
            event.notification.display(); // show normally
        }
      }
    });

    // Click listener (global navigation)
    OneSignal.Notifications.addClickListener((event) async {
      final data = event.notification.additionalData;
      log("🖱️ Notification opened: $data");

      if (data == null) return;

      // Prevent multiple navigations
      if (_navigatingToCall) return;
      _navigatingToCall = true;

      if (data['type'] == 'call') {
        navigatorKey.currentState?.pushNamed(
          IncomingCall.routeName,
          arguments: {
            'callId': int.parse(data['call_id'].toString()),
            'isVideo': int.parse(data['action_type'].toString()) == 2,
            'user_image': data['user_image'] ?? '',
            'user_name': data['user_name'] ?? '',
          },
        );
      } else if (data['type'] == 'chat') {
        final chat = Chat(
          targetId: data['target_id'],
          name: data['name'],
          image: data['image'],
          pushId: data['pushId'],
          matchId: data['matchId'],
          chatId: data['chatId'],
        );
        navigatorKey.currentState?.pushNamed(
          ChatPage.routeName,
          arguments: chat,
        );
      }

      // Reset guard after 2 seconds
      Future.delayed(
        const Duration(seconds: 2),
        () => _navigatingToCall = false,
      );
    });

    log("✅ OneSignal setup complete");
  } catch (e) {
    log("❌ OneSignal setup failed: $e");
  }
}

bool _navigatingToCall = false;

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
//      print('Handling a background message ${message.messageId}');
//     }

// handleNotifications() async {
//   FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       badge: true,
//       alert: true,
//       sound:
//           true); //presentation options for Apple notifications when received in the foreground.

//   FirebaseMessaging.onMessage.listen((message) async {
//     print('Got a message whilst in the FOREGROUND!');
//     return;
//   }).onData((data) {
//     print('Got a DATA message whilst in the FOREGROUND!');
//     print('data from stream: ${data.data}');
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((message) async {
//     print('NOTIFICATION MESSAGE TAPPED');
//     return;
//   }).onData((data) {
//     print('NOTIFICATION MESSAGE TAPPED');
//     print('data from stream: ${data.data}');
//   });

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   FirebaseMessaging.instance.getInitialMessage().then(
//       (value) => value != null ? _firebaseMessagingBackgroundHandler : false);
//   return;
// }

class BSTYApp extends StatefulWidget {
  const BSTYApp({super.key});

  @override
  State<BSTYApp> createState() => _BSTYAppState();
}

class _BSTYAppState extends State<BSTYApp> {
  @override
  void initState() {
    notifyC.requestPermission();
    notifyC.loadFCM();
    notifyC.listenFCM();
    // notifyC.storeToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// [ ensures portrait at all times. you can override this if necessary ]
    potraitmode();

    return MultiProvider(
      /// [ providers ] is a list of all the providers in the app.
      providers: providers,

      /// Portal is used to show 'add media' buttons on chat screen.
      child: Portal(
        child: MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'BSTY',
          navigatorKey: navigatorKey,

          /// [ Custom Theme ] for the app.
          theme: CustomTheme.lightTheme,

          builder: (context, child) => Unfocus(child: child!),

          /// [ Routes ] for the app.
          onGenerateRoute: MyRoutes.myRoutes,
        ),
      ),
    );
  }
}

class IAPConnection {
  static InAppPurchase? _instance;
  static set instance(InAppPurchase value) {
    _instance = value;
  }

  static InAppPurchase get instance {
    _instance ??= InAppPurchase.instance;
    return _instance!;
  }
}
