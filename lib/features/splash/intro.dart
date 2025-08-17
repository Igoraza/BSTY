// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/screens/permission/permit_location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_image.dart';
import '../../screens/main/main_page.dart';
import '../auth/pages/initial/sign_in_page.dart';
import 'splash_screen.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/';

  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  /// [ startTimer ] is used to start the timer for the [ Intro Screen ].
  startTimer() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, route);
  }

  Future<bool> getAlreadyViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isViewed = prefs.getBool('isViewed') ?? false;
    debugPrint('isViewed: $isViewed');
    return isViewed;
  }

  /// [ route ] is used to route to the [ Splash Screen ] after the [ duration ].
  route() async {
    if (!mounted) return;
    await Hive.openBox('guide');
    await Hive.openBox('user').then((value) async {
      /// return [ MainPage ] if [ isLoggedIn ]
      if (Hive.box('user').get('isLoggedIn', defaultValue: false)) {
        debugPrint('Route changed to Home page');
        PermissionStatus status = await Permission.location.status;
        final userBox = Hive.box('user');
        if (status.isGranted) {
          // final latitude = userBox.get('user_latitude');
          // final longitude = userBox.get('user_longitude');
          Navigator.pushReplacementNamed(context, MainPage.routeName);
          return;
        } else {
          final latitude = userBox.get('user_latitude');
          final longitude = userBox.get('user_longitude');

          if (latitude != null && longitude != null) {
            Navigator.pushReplacementNamed(context, MainPage.routeName);
            return;
          }
          Navigator.pushReplacementNamed(context, PermitLocation.routeName);
          return;
        }
      } else {
        switch (await getAlreadyViewed()) {
          case true:
            debugPrint('Route changed to Sign in page');
            Navigator.pushReplacementNamed(context, SignInPage.routeName);
            break;

          case false:
            debugPrint('Route changed to Splash Screen');
            Navigator.pushReplacementNamed(context, SplashScreen.routeName);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    final authPro = context.read<AuthProvider>();
    // double tabView500 = 400;

    if (MediaQuery.of(context).size.width >= 600) {
      authPro.isTab = true;
    } else {
      authPro.isTab = false;
    }

    return BackgroundImage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SvgPicture.asset('assets/svg/logo/logo.svg'),
          // SizedBox(height: appHeight * 0.025),
          // SvgPicture.asset('assets/svg/logo/dots.svg'),
          Image.asset('assets/icons/bsty_logo.png', height: appHeight * 0.11),
          SvgPicture.asset('assets/svg/logo/dots.svg'),
        ],
      ),
    );
  }
}
