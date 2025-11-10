import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/utils/functions.dart';
import 'package:provider/provider.dart';

import '../../../api/api_helper.dart';
import '../../../api/endpoints.dart';
import '../enums.dart';
import '../models/initial_profile_model.dart';
import 'auth_provider.dart';

class InitialProfileProvider with ChangeNotifier {
  AuthStatus authStatus = AuthStatus.done;
  double uploadProgress = 0;

  String personNme = 'User';

  String report = "NA";
  String reason = "NA";
  String incident = "NA";
  String detailsReport = "NA";

  bool _visible = false;
  bool get visible => _visible;
  set visible(bool value) {
    _visible = value;
    notifyListeners();
  }

  bool _isLoding = false;
  bool get isLoading => _isLoding;
  set isLoading(bool value) {
    _isLoding = value;
    notifyListeners();
  }

  final _dio = Api().api;
  final _initialProfile = InitialProfileModel(
    gender: '',
    orientation: '1',
    fit: '1',
    interests: '',
  );

  InitialProfileModel get initialProfile => _initialProfile;

  set dob(String dob) => _initialProfile.dob = dob;
  set height(String height) => _initialProfile.height = height;
  set interests(String interests) => _initialProfile.interests = interests;

  String get gender => _initialProfile.gender!;
  bool get displayGender => _initialProfile.displayGender;
  String get orientation => _initialProfile.orientation!;
  bool get displayOrientation => _initialProfile.displayOrientation;
  String get fit => _initialProfile.fit!;
  String get interests => _initialProfile.interests!;

  String _shoMe = 'Everyone';
  String get showMe => _shoMe;
  set showMe(String value) {
    _shoMe = value;
    notifyListeners();
  }

  bool _notifi = true;
  bool get notification => _notifi;
  set notification(bool value) {
    _notifi = value;
    notifyListeners();
  }

  bool _incong = false;
  bool get incognito => _incong;
  set incognito(bool value) {
    _incong = value;
    notifyListeners();
  }

  set gender(String gender) {
    _initialProfile.gender = gender;
    notifyListeners();
  }

  set orientation(String orientation) {
    _initialProfile.orientation = orientation;
    notifyListeners();
  }

  set fit(String fit) {
    _initialProfile.fit = fit;
    notifyListeners();
  }

  void toggleDisplayGender() {
    _initialProfile.displayGender = !_initialProfile.displayGender;
    notifyListeners();
  }

  void toggleDisplayOrientation() {
    _initialProfile.displayOrientation = !_initialProfile.displayOrientation;
    notifyListeners();
  }

  // Get data from server to display
  Future<List> getGenderList() async {
    log("Getting genders..............");
    final response = await _dio.get(Endpoints.gendersList);
    log("Genders response : $response");
    return response.data['genders'];
  }

  Future<List> getOrientationsList() async {
    final response = await _dio.get(Endpoints.orientationsList);
    return response.data['orientations'];
  }

  Future<List> getInterestsList() async {
    final response = await _dio.get(Endpoints.interestsList);
    return response.data['interests'];
  }

  // Submit user data ( dob, gender, etc ... ) to server
  Future<bool> submitInitialProfile(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    bool returnVal = false;
    final token = authProvider.retrieveUserTokens().then(
      (value) => value['access'],
    );

    authStatus = AuthStatus.checking;
    notifyListeners();

    try {
      var formData = FormData.fromMap(_initialProfile.toJson());
      await _dio
          .post(
            Endpoints.updateProfile,
            data: formData,
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': Headers.jsonContentType,
              },
            ),
          )
          .then((response) {
            if (response.statusCode == 200 &&
                response.data['status'] == 'success') {
              returnVal = true;
              authStatus = AuthStatus.done;
              notifyListeners();
            } else {
              returnVal = false;
            }
          });
    } on DioException catch (error) {
      debugPrint('Initial Profile Error: ${error.message}');
      debugPrint('Initial Profile Error response: ${error.response}');
      returnVal = false;
    } catch (error) {
      debugPrint('Initial Profile Error: $error');
      returnVal = false;
    }

    authStatus = AuthStatus.done;
    notifyListeners();
    return returnVal;
  }

  // Upload user images to server
  Future<bool> uploadUserImages(
    BuildContext context,
    List<File?> images,
  ) async {
    log("Uploading user images");
    bool returnVal = false;

    authStatus = AuthStatus.checking;
    notifyListeners();

    for (File? img in images) {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(img!.path),
      });
      try {
        final response = await _dio.post(
          Endpoints.addUserImage,
          data: formData,
          // options: Options(headers: headers),
          onSendProgress: (int sent, int total) {
            uploadProgress = sent / total;
            debugPrint('Upload Progress: $sent/$total/2 = $uploadProgress');
            notifyListeners();
          },
        );
        log('===========Initial Profile Images Response: ${response.data}');
        if (response.statusCode == 200 &&
            response.data['status'] == 'success') {
          final displayImage = response.data['display_image '];
          debugPrint('Display Image: $displayImage');
          if (displayImage != null && displayImage != '') {
            final userBox = Hive.box('user');
            log('display image $displayImage');
            userBox.put('display_image', displayImage);
          }
          authStatus = AuthStatus.done;
          notifyListeners();
          returnVal = true;
        } else {
          authStatus = AuthStatus.done;
          notifyListeners();
          returnVal = false;
        }
      } catch (error) {
        debugPrint('Error: $error');
        authStatus = AuthStatus.done;
        notifyListeners();
        returnVal = false;
      }
    }

    authStatus = AuthStatus.done;
    notifyListeners();
    return returnVal;
  }

  getProfileConfig() async {
    try {
      isLoading = true;
      final userTokens = await AuthProvider().retrieveUserTokens();
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final response = await _dio.get(
        Endpoints.profileConfig,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        showMe = response.data['show_me'];
        notification = response.data['notification'];
        incognito = response.data['incognito'];
        log(response.data.toString());
      } else {
        debugPrint(
          'getProfileConfig response.statusCode ${response.statusCode}',
        );
      }
      isLoading = false;
    } catch (e) {
      debugPrint('getProfileConfig error $e');
    }
  }

  updateIncognito(bool value) async {
    final userTokens = await AuthProvider().retrieveUserTokens();
    final headers = {"Authorization": "Bearer ${userTokens['access']}"};
    final data = FormData.fromMap({'incognito': value ? 1 : 0});
    final response = await _dio.post(
      Endpoints.updateIncognito,
      data: data,
      options: Options(headers: headers),
    );
    // if (response.statusCode == 200) {
    // showMe = response.data['show_me'];
    // notification = response.data['notification'];
    // incognito = response.data['incognito'];
    log(response.data.toString());
    log(response.statusCode.toString());
    // }
  }

  updateNotific(bool value) async {
    final userTokens = await AuthProvider().retrieveUserTokens();
    final headers = {"Authorization": "Bearer ${userTokens['access']}"};
    final data = FormData.fromMap({'notification': value ? 1 : 0});
    final response = await _dio.post(
      Endpoints.updateNotification,
      data: data,
      options: Options(headers: headers),
    );
    log(response.data.toString());
    log(response.statusCode.toString());
    // }
  }

  updateShowMe(int value) async {
    final userTokens = await AuthProvider().retrieveUserTokens();
    final headers = {"Authorization": "Bearer ${userTokens['access']}"};
    final data = FormData.fromMap({'gender': value});
    final response = await _dio.post(
      Endpoints.updateShowMe,
      data: data,
      options: Options(headers: headers),
    );
    log(response.data.toString());
    log(response.statusCode.toString());
    // }
  }

  sendQuery(String title, String content) async {
    try {
      isLoading = true;
      final userTokens = await AuthProvider().retrieveUserTokens();
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final data = FormData.fromMap({'title': title, 'content': content});
      final response = await _dio.post(
        Endpoints.sendQuery,
        data: data,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        showSnackBar('Your message has been sent !');
      } else {
        showSnackBar('Something went wrong, Please try again later');
      }
      isLoading = false;
      log("sendQuery ${response.data.toString()}");
      log(response.statusCode.toString());
    } catch (e) {
      debugPrint("sendQuery Error $e");
    }
  }

  reportAndBlock(
    int userId,
    String title,
    int selectedId, {
    int? userImg,
  }) async {
    try {
      isLoading = true;
      final userTokens = await AuthProvider().retrieveUserTokens();
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final data = FormData.fromMap({
        'user_id': userId,
        'details': detailsReport,
        'reason': title.isEmpty ? reason : title,
        'flag': selectedId,
        'what': report,
        'incident': incident,
        'user_image': userImg ?? 0,
      });
      log("FormData${data.fields}");
      final response = await _dio.post(
        Endpoints.reportAndBlock,
        data: data,
        options: Options(headers: headers),
      );
      report = "NA";
      reason = "NA";
      incident = "NA";
      detailsReport = "NA";
      log('message${response.data}');
      if (response.statusCode == 200) {
        if (selectedId != null && selectedId != 2) {
          showSnackBar('This user has been reported');
        }
      } else {
        showSnackBar('Something went wrong, Please try again later');
      }
      isLoading = false;
      return response;
    } catch (e) {
      debugPrint("sendQuery Error $e");
    }
  }
}
