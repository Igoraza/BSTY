// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/auth/pages/verification/verify_phone_page.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/features/people/models/image_model.dart';
import 'package:bsty/main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../api/api_helper.dart';
import '../../../api/endpoints.dart';
import '../../../common_widgets/buy_plan_dialog.dart';
import '../../../services/locatoin_provider.dart';
import '../../../utils/constants/plan_price_details.dart';
import '../../../utils/functions.dart';
import '../../../utils/global_keys.dart';
import '../../auth/pages/initial_profile_steps/select_media.dart';
import '../../common/force_update_page.dart';
import '../../map/models/map_user.dart';
import '../models/likes_model.dart';
import '../models/person.dart';
import '../models/person_profile.dart';

class PeopleProvider with ChangeNotifier {
  final dio = Api().api;

  int? _lastActionId;

  int? selectedId;

  bool _isLocated = false;

  bool _isLoding = false;

  final isAtLimit = ValueNotifier(false);

  bool get isLoading => _isLoding;
  set isLoading(bool value) {
    _isLoding = value;
    notifyListeners();
  }

  dynamic _dir;
  dynamic get direction => _dir;
  set direction(dynamic value) {
    _dir = value;
    notifyListeners();
  }

  int _peplId = -1;
  int get currentId => _peplId;
  set currentId(int value) {
    _peplId = value;
    notifyListeners();
  }

  List<LikesModel> _likedList = [];
  List<LikesModel> get likedList => _likedList;
  set likedList(List<LikesModel> value) {
    _likedList = value;
    notifyListeners();
  }

  List<LikesModel> _favList = [];
  List<LikesModel> get favList => _favList;
  set favList(List<LikesModel> value) {
    _favList = value;
    notifyListeners();
  }

  get isLocated => _isLocated;

  double? latitude;
  double? longitude;
  String radius = '30';
  String interested = '3';
  String restrict = '0';
  String ageStart = '18';
  String ageEnd = '40';

  void clearData() {
    latitude = null;
    longitude = null;
    radius = '30';
    interested = '3';
    restrict = '0';
    ageStart = '18';
    ageEnd = '40';
  }

  final PlanPriceDetails planDetails = PlanPriceDetails();

  void changeLocate() async {
    _isLocated = true;
    Hive.box('user').put('allowed', true);
    notifyListeners();
  }

  /// fetch [ people ] from the server for the [ home page cards ]
  Future<List<dynamic>> fetchPeople(
    BuildContext context, {
    bool isMap = false,
  }) async {
    /// [ returnVal ] is a list of all the people in the app.
    List<dynamic> returnVal = [];

    try {
      final locationProvider = context.read<LocationProvider>();

      /// [ userBox ] is the box that contains the user's data.
      final userBox = Hive.box('user');

      final userLatitude = userBox.get('user_latitude');
      final userLongitude = userBox.get('user_longitude');

      // Start tracking the user's location
      if (userLatitude == null && userLongitude == null) {
        await locationProvider.startTracking(context).then((value) async {
          if (!value) {
            debugPrint('Tracking failed');
          } else {
            context.read<PeopleProvider>().changeLocate();
            // log('################# ${value}');
            debugPrint('Tracking started:');
          }
        });
      }

      latitude = userBox.get('selected_latitude', defaultValue: null);
      longitude = userBox.get('selected_longitude', defaultValue: null);
      if (latitude == null || longitude == null) {
        latitude = userBox.get('user_latitude', defaultValue: 1.0);
        longitude = userBox.get('user_longitude', defaultValue: 1.0);
      }

      final locationMap = locationProvider.getSelectedLocalityAndCountry();
      String? fcm = await notifyC.storeToken();
      final data = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'interested': interested,
        'restrict': restrict,
        'age_start': ageStart,
        'age_end': ageEnd,
        'location': locationMap['locality'],
        'country': locationMap['country'],
        'fcm': fcm,
      };
      // log('fcm ---- ${fcm.toString()}');
      final options = Options(extra: {'data': data});
      final response = await dio.post(
        isMap ? Endpoints.userHomeMap : Endpoints.userHome,
        data: FormData.fromMap(data),
        options: options,
      );

      debugPrint(
        '=====================> FetchPeopleRes: ${response.data['plan']}',
      );
      if (response.data['status']) {
        if (isMap) {
          final people = response.data['users']
              .map<MapUser>((e) => MapUser.fromJson(e))
              .toList();
          returnVal = people;
        } else {
          final int? minAppVersion = response.data['min_app_version'];
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          debugPrint(
            '=====================> Checkign version: $minAppVersion > ${packageInfo.buildNumber}',
          );
          // if (minAppVersion != null &&
          //     minAppVersion > int.parse(packageInfo.buildNumber)) {
          //   navigatorKey.currentState!.pushNamedAndRemoveUntil(
          //       ForceUpdatePage.routeName, (route) => false);
          //   // return ;
          // }
          log('++==========${response.data.toString()}');

          debugPrint(
            '=====================> Plan: ${response.data['plan_expired']}',
          );

          userBox.put('plan', response.data['plan'] ?? 1);
          userBox.put('plan_expired', response.data['plan_expired'] ?? true);
          userBox.put('referral_code', response.data['referral_code']);
          userBox.put(
            'super_like_balance',
            response.data['super_like_balance'] ?? 0,
          );
          userBox.put('swipes_balance', response.data['swipes_balance'] ?? 0);
          userBox.put(
            'profile_boost_balance',
            response.data['profile_boost_balance'] ?? 0,
          );
          userBox.put(
            'audio_call_balance',
            response.data['audio_call_balance'] ?? 0,
          );
          userBox.put(
            'video_call_balance',
            response.data['video_call_balance'] ?? 0,
          );
          userBox.put(
            'verification_status',
            response.data['verification_status'] ?? 0,
          );
          userBox.put('plan_expiry', response.data['plan_expiry'] ?? '');
          userBox.put(
            'profile_completed',
            response.data['profile_completed'] ?? false,
          );
          userBox.put('plan_duration', response.data['plan_duration'] ?? 0);
          if (!response.data['profile_completed']) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              VerifyPhone.routeName,
              (route) => false,
            );
          } else if (!response.data['images_uploaded']) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              SelectMedia.routeName,
              (route) => false,
            );
          } else {
            List<dynamic> people = [];
            final peopleJson = response.data['users'] as List<dynamic>;
            debugPrint('=====================> People json: $peopleJson');
            people = peopleJson
                .where((e) => e['age'] != null && e['display_image'] != null)
                .map((e) => Person.fromJson(e))
                .toList();

            log("People after conversion${people}");
            if (people.isEmpty) {
              isAtLimit.value = true;
            } else {
              isAtLimit.value = false;
            }
            returnVal = people;
          }
        }
      } else {
        debugPrint(response.statusMessage);
      }
      log("Returning value -- $returnVal");
      return returnVal;
    } catch (error) {
      log("fetch people error $error");
      rethrow;
    }
  }

  /// send the user action [ like, super like, dislike ] to the server
  Future<dynamic> sendUserAction(
    BuildContext context,
    int userId,
    String action,
  ) async {
    final userBox = Hive.box('user');
    final data = FormData.fromMap({
      'user_id': '$userId',
      'action_type': action,
    });
    try {
      debugPrint('======>> Sending user action: $action');
      final response = await dio.post(Endpoints.userAction, data: data);
      if (response.data['status']) {
        debugPrint('User action sent: $response');
        _lastActionId = response.data['action_id'];
        // log('sendUserAction ${response.data.toString()}');
        userBox.put('swipes_balance', response.data['swipes_balance']);
        if (action == '2') {
          // log(action);
          userBox.put(
            'super_like_balance',
            response.data['super_like_balance'],
          );
        }
        return response.data;
      } else if (response.data['status'] == false) {
        log(response.data.toString());
        if (response.data['message'] == 'Already interacted this user') {
          showSnackBar('You have already interacted with this person !');
        }

        return response.data;
      } else {
        debugPrint(response.statusMessage);
      }
    } catch (error) {
      debugPrint('Err: $error');
    }
  }

  Future<dynamic> sendUserRewind(
    BuildContext context,
    int userId,
    String action,
  ) async {
    final data = FormData.fromMap({
      'user_id': '$userId',
      'action_type': action,
      'action_id': _lastActionId,
    });
    try {
      debugPrint('======>> Sending user action: $action for $_lastActionId');
      final response = await dio.post(Endpoints.userRewind, data: data);
      if (response.data['status']) {
        debugPrint('======>> Rewind action sent: $response');
        _lastActionId = response.data['action_id'];
        return response.data;
      } else {
        debugPrint(response.statusMessage);
      }
    } catch (error) {
      debugPrint('Err: $error');
    }
  }

  void userBoost(BuildContext context) async {
    try {
      final userTokens = await AuthProvider().retrieveUserTokens();
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final response = await dio.get(
        Endpoints.userBoost,
        options: Options(headers: headers),
      );
      log('======>> Boost: $response');

      if (response.data['status']) {
        showSnackBar('Your profile is boosted successfully');
      } else {
        showDialog(
          context: context,
          builder: (context) => BuyPlanDialog(
            title: 'Boosts',
            desc: 'Buy Profile Boosts As Needed !',
            img: 'assets/svg/upgrade_dialog/profile_boosts.svg',
            btnText: 'Buy Now',
            paymentList: planDetails.payBoosts,

            //  kProductIds: ['bsty_plus'],
          ),
        );
        // showSnackBar('Boost is not available');
      }
    } catch (error) {
      debugPrint('Boost Err: $error');
    }
  }

  /// fetch [ detailed profile ] of an [ individual ]
  Future<Map<String, dynamic>?> fetchPersonProfile(
    BuildContext context,
    int userId,
  ) async {
    final data = {'user_id': '$userId'};
    final options = Options(extra: {'data': data});

    try {
      final response = await dio.post(
        Endpoints.getProfile,
        data: FormData.fromMap(data),
        options: options,
      );
      //  log('=====================> Person Profile Res: ${response.data['user']}');

      debugPrint(
        '=====================> Person Profile Res: ${response.data.keys}',
      );

      if (response.data['status']) {
        final personJson = response.data['user'];
        final person = PersonProfile.fromJson(personJson);
        final imagesJson = response.data['images'];
        final images = imagesJson.map((e) => e['image']).toList();
        // log('=====================> Person Profile Res: ${imagesJson}');
        final imgs = imagesJson
            .map((e) => ImageModel(e['id'], e['image']))
            .toList();
        log('=====================> Person Profile Res: ${imgs}');
        // debugPrint(
        //     '=====================> Person Profile: ${jsonEncode(person.toJson())}');
        return {'person': person, 'images': imgs};
      } else {
        debugPrint(response.statusMessage);
        throw Exception(response.statusMessage);
      }
    } catch (error) {
      debugPrint('Person Profile Err: $error');
      rethrow;
    }
  }

  /// get the [ list of ] people who [ liked ] you
  Future<List<LikesModel>> fetchLikes(BuildContext context) async {
    try {
      log("Fetching likes.......");
      final response = await dio.get(Endpoints.likes);
      if (response.data['status']) {
        final likesJson = response.data['user_actions'] as List<dynamic>;
        final likes = likesJson.map((e) => LikesModel.fromJson(e)).toList();
        likedList = likes;
        return likes;
      } else {
        debugPrint(response.statusMessage);
        throw Exception(response.statusMessage);
      }
    } catch (error) {
      debugPrint('Err: $error');
      rethrow;
    }
  }

  /// get the [ list of ] people who [ super liked ] you
  Future<List<LikesModel>> fetchSuperLikes(BuildContext context) async {
    try {
      final response = await dio.get(Endpoints.superLikes);
      if (response.data['status']) {
        final superLikesJson = response.data['user_actions'] as List<dynamic>;
        final superLikes = superLikesJson
            .map((e) => LikesModel.fromJson(e))
            .toList();
        log(superLikes.length.toString());
        favList = superLikes;
        return superLikes;
      } else {
        debugPrint(response.statusMessage);
        throw Exception(response.statusMessage);
      }
    } catch (error) {
      debugPrint('Err: $error');
      rethrow;
    }
  }

  /// get the [ list of ] people who [ viewed your profile ]
  Future<List<LikesModel>> fetchProfileViews(BuildContext context) async {
    try {
      final response = await dio.get(Endpoints.profileViews);
      if (response.data['status']) {
        final profileViewsJson = response.data['user_actions'] as List<dynamic>;
        final profileViews = profileViewsJson
            .map((e) => LikesModel.fromJson(e))
            .toList();
        return profileViews;
      } else {
        debugPrint(response.statusMessage);
        throw Exception(response.statusMessage);
      }
    } catch (error) {
      debugPrint('Err: $error');
      rethrow;
    }
  }
}
