import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/people/services/people_provider.dart';
import 'package:provider/provider.dart';

import '../common_widgets/custom_dialog.dart';
import '../utils/theme/colors.dart';

class LocationProvider {
  late bool serviceEnabled;
  late LocationPermission permission;
  StreamSubscription<Position>? positionStream;

  Future<bool> startTracking(BuildContext context) async {
    if (positionStream != null) positionStream!.cancel();

    bool returnVal = false;

    debugPrint('>>>>>>>>>>>>>>>\nChecking location availability');

    await Geolocator.isLocationServiceEnabled().then((value) async {
      serviceEnabled = value;
      if (!serviceEnabled) {
        /// [ Show a dialog ] asking the user to [ enable the location services ].
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            title: 'Location services are disabled.',
            desc: 'Please enable location services',
            btnText: 'Retry',
            btnColor: AppColors.black,
            showCloseBtn: true,
            allowBackBtn: false,
            onPressed: () {
              Navigator.of(context).pop();
              startTracking(context);
            },
          ),
        );
      } else {
        debugPrint('>>>>>>>>>>>>>>>lcoation service is enabled');
        await Geolocator.checkPermission().then((value) async {
          debugPrint('>>>>>>>>>>>>>>>Permission: $value');
          permission = value;
          if (permission == LocationPermission.denied) {
            /// if [ Permission Denied ] show [ dialog ].
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => CustomDialog(
                title: 'No location permissions',
                desc: 'This app needs location permissions to work properly',
                btnText: 'Allow',
                btnColor: AppColors.black,
                allowBackBtn: false,
                showCloseBtn: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.requestPermission().then(
                    (value) => startTracking(context),
                  );
                  // PeopleProvider().located(context);
                  context.read<PeopleProvider>().changeLocate();
                },
              ),
            );
          } else if (permission == LocationPermission.deniedForever) {
            /// if [ Permission Denied Forever ] show [ dialog ].
            showDialog(
              context: context,
              builder: (context) => CustomDialog(
                title: 'No location permissions',
                desc:
                    'Please enable location permissions from settings menu and click Retry',
                btnText: 'Retry',
                btnColor: AppColors.black,
                showCloseBtn: true,
                allowBackBtn: false,
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.requestPermission().then(
                    (value) => startTracking(context),
                  );
                },
              ),
            );
            // return Future.error(
            //     'Location permissions are permanently denied, we cannot request permissions.');
          } else {
            debugPrint('>>>>>>>>>>>>>>>\nLocation is available');
            debugPrint('>>>>>>>>>>>>>>>\nPermission3: $value');

            /// save location when changes more than 100 meters
            const locationSettings = LocationSettings(distanceFilter: 100);

            if (positionStream != null) positionStream!.cancel();
            positionStream =
                Geolocator.getPositionStream(
                  locationSettings: locationSettings,
                ).listen((Position? position) async {
                  return position != null
                      ? await saveUserLocation(position)
                      : debugPrint('Location is null');
                });

            returnVal = true;
          }
        });
      }
    });
    log('=======start tracking  return value ==========$returnVal');
    return returnVal;
  }

  /// [ Stop tracking location ]
  void stopTracking() {
    if (positionStream != null) positionStream?.cancel();
  }

  /// [ Save user selected location ]
  void saveUserSelectedLocation(String location) async {
    final userBox = Hive.box('user');
    userBox.put('selected_location', location);
    final result = await locationFromAddress(location);
    log('saveUserSelectedLocation');
    final position = result[0];
    userBox.put('selected_latitude', position.latitude);
    userBox.put('selected_longitude', position.longitude);
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final placemark = placemarks[0];
    userBox.put('selected_locality', placemark.locality);
    userBox.put('selected_country', placemark.country);
    log(
      'saveUserSelectedLocation ${userBox.get('selected_latitude')} ${userBox.get('selected_longitude')}',
    );
  }

  /// [ Save  user location ]
  Future<void> saveUserLocation(Position position) async {
    final userBox = Hive.box('user');
    userBox.put('user_latitude', position.latitude);
    userBox.put('user_longitude', position.longitude);
    debugPrint('Got location: ${position.latitude}, ${position.longitude}');

    // Todo : uncomment this after testing
    // final placemarks =
    //     await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemarks = await placemarkFromCoordinates(11.2588, 75.7804);
    final placemark = placemarks[0];
    final locationName = '${placemark.locality}, ${placemark.country}';
    userBox.put('locality', placemark.locality);
    userBox.put('country', placemark.country);
    userBox.put('location', locationName);
    debugPrint(
      '**********\nLocation: $locationName: ${position.latitude}, ${position.longitude}\n**********',
    );
  }

  /// [ Get user location ]
  Future<List<String>> getAutocompletePlaces(String input) async {
    final String? placesApiKey = dotenv.env['PLACES_API_KEY'];
    final String? placesBaseUrl = dotenv.env['PLACES_BASE_URL'];

    final response = await Dio().get(
      "$placesBaseUrl$input&radius=500&key=$placesApiKey",
    );
    log("Autocomplete places response: $response");
    if (response.statusCode == 200) {
      final predictions = response.data['predictions'] as List;
      final places = predictions
          .map((e) => e['description'] as String)
          .toList();
      return places;
    } else {
      throw Exception('Failed to load places');
    }
  }

  /// [ Get user selected location ] or [ user location ]
  String getSelectedLocation() {
    final userBox = Hive.box('user');
    return userBox.get('selected_location') ?? userBox.get('location') ?? '';
  }

  /// [ Get user locality and country ]
  Map<String, String> getSelectedLocalityAndCountry() {
    final userBox = Hive.box('user');
    return {
      'locality':
          userBox.get('selected_locality') ?? userBox.get('locality') ?? '',
      'country':
          userBox.get('selected_country') ?? userBox.get('country') ?? '',
    };
  }
}
