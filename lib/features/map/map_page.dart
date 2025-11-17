import 'dart:math';

import 'package:align_positioned/align_positioned.dart';
import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_image.dart';
import '../../common_widgets/custom_icon_btn.dart';
import '../../common_widgets/loading_animations.dart';
import '../../common_widgets/snapshot_error.dart';
import '../../common_widgets/upgrade_plan_dialog.dart';
import '../../utils/global_keys.dart';
import '../../utils/theme/colors.dart';
import '../people/services/people_provider.dart';
import '../people/views/home/widgets/filter_bottom_sheet.dart';
import 'models/map_user.dart';
import 'widgets/distance_slider.dart';
import 'widgets/map_item.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  static const routeName = '/map-page';

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ValueNotifier<String> radius = ValueNotifier('30');
  late Future peopleFuture;
  final peopleProvider = navigatorKey.currentContext!.read<PeopleProvider>();

  final userPlan = Hive.box('user').get('plan') ?? 1;
  final planExpired = Hive.box('user').get('plan_expired') ?? true;

  bool isGranted = true;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    // checkPermission();
    peopleFuture = peopleProvider.fetchPeople(context, isMap: true);
    radius.value = context.read<PeopleProvider>().radius;
  }

  Future<dynamic> showFilterBottomSheet(BuildContext context, Size size) async {
    final shouldRefresh = await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: size.height * 0.8,
        minHeight: size.height * 0.6,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (_) => FilterBottomSheet(size: size),
    );

    if (shouldRefresh ?? false) {
      radius.value = peopleProvider.radius;
      _refresh();
    }
  }

  void _refresh() {
    setState(() {
      peopleFuture = peopleProvider.fetchPeople(context, isMap: true);
    });
  }

  // checkPermission() async {
  //   PermissionStatus status = await Permission.location.request();
  //   if (status.isPermanentlyDenied) {
  //     setState(() {
  //       isGranted = false;
  //     });
  //   } else {
  //     setState(() {
  //       isGranted = true;
  //     });
  //   }
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   super.didChangeAppLifecycleState(state);
  //   print('Current state = $state');
  //   await checkPermission();
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  // Future<List<MapUser>> fetchUsers(int radius) async {
  //   debugPrint('=====================>> Getting Users');
  //   final dio = Api().api;
  //   final userBox = Hive.box('user');

  //   double? latitude;
  //   double? longitude;

  //   latitude = userBox.get('selected_latitude', defaultValue: null);
  //   longitude = userBox.get('selected_longitude', defaultValue: null);

  //   if (latitude == null || longitude == null) {
  //     latitude = userBox.get('user_latitude', defaultValue: -13.9626);
  //     longitude = userBox.get('user_longitude', defaultValue: 33.7741);
  //   }

  //   final data = {
  //     'latitude': latitude,
  //     'longitude': longitude,
  //     'radius': radius
  //   };
  //   final options = Options(extra: {'data': data});

  //   try {
  //     final response = await dio.post(Endpoints.userHomeMap,
  //         data: FormData.fromMap(data), options: options);
  //     if (response.statusCode == 200) {
  //       final users = response.data['users']
  //           .map<MapUser>((e) => MapUser.fromJson(e))
  //           .toList();
  //       return users;
  //     } else {
  //       throw Exception('Failed to load users');
  //     }
  //   } catch (e) {
  //     debugPrint('=====================>> MapUsers: $e');
  //     throw Exception('Failed to load users');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final appBar = AppBar(
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset('assets/svg/logo/logo.svg'),
      ),
      actions: [
        // if (userPlan == 4 && !planExpired)
        CustomIconBtn(
          onTap: () {
            // TODO:Uncomment this
            if (userPlan == 4 && !planExpired) {
              showFilterBottomSheet(context, size);
            } else {
              // showDialog(
              //   context: context,
              //   builder: (context) => UpgradePlanDialog(title: 'Premium'),
              // );

              Navigator.pushNamed(
                context,
                UpgradePlanScreen.routeName,
                arguments: "Premium",
              );
            }
          },
          child: SvgPicture.asset('assets/svg/ui_icons/options.svg'),
        ),
        // CustomIconBtn(
        //     onTap: () => debugPrint('Close'),
        //     child: const Icon(Icons.close_rounded))
      ],
    );

    final mappedUsers = FutureBuilder(
      future: peopleFuture,
      builder: (_, AsyncSnapshot snapshot) {
        // if (!isGranted) {
        //   return Center(
        //     child: Container(
        //         // height: size.height * 0.1,
        //         // width: size.width * 0.6,
        //         decoration: BoxDecoration(
        //             color: AppColors.white.withOpacity(.8),
        //             borderRadius: BorderRadius.circular(15)),
        //         child: NoPermisssionWidget()),
        //   );
        // }
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.08),
            child: mainLoadingAnimationDark,
          );
        }
        if (snapshot.hasError) {
          String errorMsg = '';

          if (snapshot.error.toString().contains('SocketException')) {
            errorMsg =
                'Error retrieving profiles.\nPlease check your internet connection';
          } else {
            errorMsg = 'Error retrieving profiles. Try again later';
            debugPrint(
              '=====================>> MapUsers Error: ${snapshot.error}',
            );
          }

          return AlignPositioned(
            dy: -size.height * 0.14,
            child: SnapshotErrorWidget(errorMsg, color: AppColors.white),
          );
        }
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.08),
              child: Container(
                height: size.height * 0.1,
                width: size.width * 0.6,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'No profiles found,\nTry changing your filters',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        final List<MapUser> usersList = snapshot.data;
        usersList.removeWhere((element) => element.image == '');

        if (usersList.isEmpty) {
          return Center(
            child: Container(
              height: size.height * 0.1,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  'No profiles found,\nTry changing your filters',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final maxDist = usersList.map((e) => e.distance).reduce(max);

        // organize users into 3 groups based on distance

        final closeUsers = usersList
            .where((element) => element.distance <= maxDist * 0.3)
            .toList();

        final mediumUsers = usersList
            .where(
              (element) =>
                  element.distance > maxDist * 0.3 &&
                  element.distance <= maxDist * 0.6,
            )
            .toList();

        final farUsers = usersList
            .where(
              (element) =>
                  element.distance > maxDist * 0.6 &&
                  element.distance <= maxDist,
            )
            .toList();

        final farUsers1 = farUsers.sublist(0, farUsers.length ~/ 2);
        final farUsers2 = farUsers.sublist(farUsers.length ~/ 2);

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            /// [ First Ring]
            for (int i = 0; i < closeUsers.length; i++)
              AlignPositioned(
                dx: size.width * 0.22,
                rotateDegrees: 360 / closeUsers.length * i,
                child: AlignPositioned(
                  rotateDegrees: -360 / closeUsers.length * i,
                  child: MapItem(user: closeUsers[i], index: i),
                ),
              ),

            /// [ Second Ring]
            for (int i = 0; i < mediumUsers.length; i++)
              AlignPositioned(
                dx: size.width * 0.42,
                rotateDegrees: 45 + 360 / mediumUsers.length * i,
                child: AlignPositioned(
                  rotateDegrees: -(45 + 360 / mediumUsers.length * i),
                  child: MapItem(user: mediumUsers[i], index: i),
                ),
              ),

            /// [ Third Ring Bottom Half]
            for (int i = 0; i < farUsers1.length; i++)
              AlignPositioned(
                dx: size.width * 0.65,
                rotateDegrees: 60 + 50 / (farUsers1.length - 1) * i,
                child: AlignPositioned(
                  rotateDegrees: -(60 + 50 / (farUsers1.length - 1) * i),
                  child: MapItem(user: farUsers1[i], index: i),
                ),
              ),

            /// [ Third Ring Top Half]
            for (int i = 0; i < farUsers2.length; i++)
              AlignPositioned(
                dx: size.width * 0.65,
                rotateDegrees: 235 + 70 / (farUsers2.length - 1) * i,
                child: AlignPositioned(
                  rotateDegrees: -(235 + 70 / (farUsers2.length - 1) * i),
                  child: MapItem(user: farUsers2[i], index: i),
                ),
              ),
          ],
        );
      },
    );

    final userImage = Hive.box('user').get('display_image');

    return BackgroundImage(
      image: 'assets/images/map/map_bg.png',
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          clipBehavior: Clip.none,
          children:
              //  userPlan == 4 && !planExpired
              //     ?
              [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.08),
                        child: SvgPicture.asset(
                          'assets/images/map/ripples.svg',
                          fit: BoxFit.cover,
                        ),
                      ),

                      /// [User Image]
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.08),
                        child: CircleAvatar(
                          radius: size.width * 0.06,
                          backgroundColor: AppColors.borderBlue,
                          child: CircleAvatar(
                            radius: size.width * 0.054,
                            foregroundImage: userImage != null
                                ? CachedNetworkImageProvider(userImage)
                                : null,
                          ),
                        ),
                      ),

                      /// map [ People at random positions ] in distance radius
                      mappedUsers,
                    ],
                  ),
                ),

                /// [ Distance Slider ]
                Positioned(
                  left: 0,
                  bottom: size.height * 0.09,
                  child: DistanceSlider(radius: radius, refresh: _refresh),
                ),
              ],
          // : [const UpgradePlanDialog()],
        ),
      ),
    );
  }
}
