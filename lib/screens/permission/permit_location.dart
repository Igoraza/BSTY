// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/common_widgets/background_image.dart';
import 'package:bsty/features/people/views/home/home_page.dart';
import 'package:bsty/screens/main/main_page.dart';
import 'package:bsty/services/locatoin_provider.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/loading_animations.dart';
import '../../common_widgets/stadium_button.dart';
import '../../features/people/services/people_provider.dart';
import '../../utils/global_keys.dart';

class PermitLocation extends StatefulWidget {
  const PermitLocation({super.key});

  static const routeName = '/permit_location';

  @override
  State<PermitLocation> createState() => _PermitLocationState();
}

class _PermitLocationState extends State<PermitLocation>
    with WidgetsBindingObserver {
  bool isGranted = true;
  bool isClicked = false;

  @override
  void initState() {
    // checkPermission();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // checkPermission() async {
  //   PermissionStatus status = await Permission.location.request();
  //   if (status.isPermanentlyDenied) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => CustomDialog(
  //         showCloseBtn: false,
  //         allowBackBtn: false,
  //         title: "Unable to connect",
  //         subTitle:
  //             'To use BSTY, you need to enable your location sharing so we can show you who\'s around.',
  //         desc:
  //             "Go to Settings > BSTY > Location > Enable Location While Using the App",
  //         btnText: "Open settings",
  //         btnGradient: AppColors.orangeRedH,
  //         onPressed: () async {
  //           await openAppSettings().then((value) {
  //             if (value && status.isGranted) {
  //               navigatorKey.currentState!.pop();
  //             }
  //           });
  //         },
  //       ),
  //     );
  //   }
  // }

  checkPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isPermanentlyDenied) {
      setState(() {
        isGranted = false;
      });
    } else {
      setState(() {
        isGranted = true;
      });
    }
  }

  String desc =
      'We want to access your location only to provide a better experience by helping you find new friends nearby.';

  String title = 'Get Started';
  final peopleProvider = navigatorKey.currentContext!.read<PeopleProvider>();

  Future<bool> askPermission() async {
    peopleProvider.isLoading = true;
    final locationProvider = context.read<LocationProvider>();

    PermissionStatus status = await Permission.location.request();
    if (status.isDenied == true) {
      peopleProvider.isLoading = false;
      askPermission();
    } else if (status.isGranted) {
      StreamSubscription<Position>? positionStream;
      await locationProvider.startTracking(context).then((value) {
        if (positionStream != null) positionStream!.cancel();
        const locationSettings = LocationSettings(distanceFilter: 100);
        positionStream =
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((Position? position) async {
          return position != null
              ? await locationProvider.saveUserLocation(position)
              : debugPrint('Location is null');
        });
        peopleProvider.isLoading = false;
        setState(() {
          title = 'Continue';
        });
      });
      // log(status.toString());
      return true;
    } else if (status.isPermanentlyDenied) {
      peopleProvider.isLoading = false;
      isClicked = true;
      checkPermission();
      // final userBox = Hive.box('user');
      // final latitude = userBox.get('user_latitude');
      // final longitude = userBox.get('user_longitude');
      // log('spermission location -----------${latitude.toString()} ${longitude.toString()}');
      // if (latitude != null && longitude != null) {
      //   Navigator.pushReplacementNamed(context, MainPage.routeName);
      //   return false;
      // } else {

      // }
      // checkPermission();
      // showDialog(
      //   context: context,
      //   builder: (context) => CustomDialog(
      //     showCloseBtn: false,
      //     allowBackBtn: false,
      //     title: "Unable to connect",
      //     desc:
      //         'To use BSTY, you need to enable your location sharing so we can show you who\'s around.',
      //     subTitle:
      //         "Go to Settings>BSTY>Location>Enable Location While Using the App",
      //     btnText: "Open settings",
      //     btnGradient: AppColors.orangeRedH,
      //   ),
      // );
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('Current state = $state');
    if (isClicked) {
      checkPermission();
    }
    // checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    // log(permission.name);
    // if (permission == LocationPermission.whileInUse) {
    //   log(permission.index.toString());
    //   final userBox = Hive.box('user');
    //   log("${userBox.get('user_latitude')}        ${userBox.get('user_longitude')}");
    // }

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Share your location')),
        body: isGranted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: appWidth * 1,
                  ),
                  Container(
                    width: appWidth * .8,
                    height: appHeight * 0.5,
                    // margin: EdgeInsets.symmetric(horizontal: appWidth * 0.02),
                    // padding: EdgeInsets.all(appWidth * 0.05),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/permission/permission.svg',
                            height: appHeight * 0.24,
                          ),
                          // SizedBox(height: appHeight * 0.04),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              desc,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    // color: AppColors.disabled,
                                    fontWeight: FontWeight.normal,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: appHeight * .14,
                  ),
                  // PrimaryBtn(
                  //     text: title,
                  //     gradient: AppColors.buttonBlue,
                  //     width: appWidth * 0.75,
                  //     onPressed: () async {
                  //       if (title == 'Continue') {
                  //         final userBox = Hive.box('user');
                  //         final latitude = userBox.get('user_latitude');
                  //         final longitude = userBox.get('user_longitude');
                  //         log('spermission permit location -----------${latitude.toString()} ${longitude.toString()}');
                  //         Navigator.pushReplacementNamed(
                  //             context, MainPage.routeName);
                  //       }
                  //       await askPermission();
                  //     }),
                  Consumer<PeopleProvider>(builder: (_, peopleProvider, __) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: appWidth * .16, right: appWidth * .16),
                      child: StadiumButton(
                          visualDensity: VisualDensity.standard,
                          gradient: AppColors.buttonBlue,
                          onPressed: peopleProvider.isLoading == true
                              ? null
                              : () async {
                                  if (title == 'Continue') {
                                    final userBox = Hive.box('user');
                                    final latitude =
                                        userBox.get('user_latitude');
                                    final longitude =
                                        userBox.get('user_longitude');
                                    final guideLatitude =
                                        Hive.box('guide').get('user_latitude');
                                    final guideLongitude =
                                        Hive.box('guide').get('user_longitude');
                                    final location =
                                        Hive.box('guide').get('location');

                                    ///  the location geting null after continuos logout
                                    if (longitude == null &&
                                        latitude == null &&
                                        guideLongitude != null &&
                                        guideLatitude != null) {
                                      userBox.put(
                                          'user_latitude', guideLatitude);
                                      userBox.put(
                                          'user_longitude', guideLongitude);
                                      userBox.put('location', location);
                                    }
                                    Navigator.pushReplacementNamed(
                                        context, MainPage.routeName);
                                  }
                                  await askPermission();
                                },
                          child: peopleProvider.isLoading == true
                              ? const BtnLoadingAnimation()
                              : Text(title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: AppColors.white))),
                    );
                  }),
                ],
              )
            : const Center(child: NoPermisssionWidget()),
      ),
    );
  }
}
