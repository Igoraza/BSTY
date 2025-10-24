import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../api/api_helper.dart';
import '../../../api/endpoints.dart';
import '../../../utils/functions.dart';
import '../../../utils/global_keys.dart';
import '../../auth/services/initial_profile_provider.dart';
import '../models/user_profile.dart';

class EditProfileProvider extends ChangeNotifier {
  String? name;
  DateTime? dob;
  String? bio;
  int? gender;
  String? height;

  String? profession;
  int? orientation;
  List<dynamic> interests = [];

  List? allGenders;
  List? allOrientations;
  List? allInterests;

  List<File?> pickedImages = [null];
  List<int> deletedImages = [];
  int serverImageCount = 0;

  final dio = Api().api;

  int verificationStatus = 0;

  bool _isLoding = false;
  bool get isLoading => _isLoding;
  set isLoading(bool value) {
    _isLoding = value;
    notifyListeners();
  }

  void setGender(int genderId) {
    if (gender != genderId) {
      gender = genderId;
      notifyListeners();
    }
  }

  void setOrientation(int orientationId) {
    if (orientation != orientationId) {
      orientation = orientationId;
      notifyListeners();
    }
  }

  void toggleInterest(int interestId) {
    if (interests.contains(interestId)) {
      interests.remove(interestId);
    } else {
      interests.add(interestId);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchMyProfile() async {
    try {
      log(">>>>>>>>>>>>>>>>>>>>Getting profile<<<<<<<<<<<<<<<<<<<<<<<<<<<");
      final response = await dio.get(Endpoints.getMyProfile);
      final data = response.data;

      log(
        ">>>>>>>>>>>>>>>>>>>>Profile response : ${response}<<<<<<<<<<<<<<<<<<<<<<<<<<<",
      );

      if (response.statusCode == 200 && data['status']) {
        final user = UserProfile.fromJson(data['user']);
        final images = data['images'];
        serverImageCount = images.length;
        log('-----------${user.referral_code}');
        gender = user.gender['id'];
        orientation = user.orientation['id'];
        interests = user.interests.map((e) => e['id']).toList();
        height = user.height;
        dob = user.dob;
        allGenders = data['genders'];
        allOrientations = data['orientations'];
        allInterests = data['interests'];
        return {'profile': user, 'images': images};
      } else {
        throw Exception('Error fetching profile');
      }
    } catch (e) {
      debugPrint('Err: $e');
      rethrow;
    }
  }

  Future<void> updateProfile() async {
    final data = FormData.fromMap({
      'name': name,
      'bio': bio,
      'height': height,
      'dob': DateFormat('yyyy-MM-dd').format(dob!),
      'profession': profession,
      'gender': gender,
      'orientation': orientation,
      'interests': interests.join('#'),
    });
    try {
      showSnackBar('Updating profile...');
      final response = await dio.post(Endpoints.updateFullProfile, data: data);
      final resData = response.data;
      debugPrint('Res - updateUserData: $resData');
      if (response.statusCode == 200 && resData['status'] == 'success') {
        Hive.box('user').put('name', name);
        if (deletedImages.isNotEmpty) {
          log('deleteUserImages ${deletedImages.length}');
          deleteUserImages();
          deletedImages = [];
        }
        if (pickedImages.length > 1) {
          await uploadMedia();
          pickedImages = [null];
        }
        showSnackBar('Profile updated successfully');
        return;
      } else {
        throw Exception('Error updating profile');
      }
    } catch (e) {
      debugPrint('Err: $e');
      rethrow;
    }
  }

  Future<void> deleteUserImages() async {
    for (var element in deletedImages) {
      log('deleteUserImages element ${element.toString()}');
      final data = FormData.fromMap({'image_id': element.toString()});
      final response = await dio.post(Endpoints.deleteUserImage, data: data);
      final resData = response.data;
      if (response.statusCode == 200 && resData['status'] == 'success') {
        debugPrint('Image deleted successfully');
      } else {
        throw Exception('Error deleting image');
      }
    }
  }

  Future<void> uploadMedia() async {
    final validImages = pickedImages.where((image) => image != null).toList();
    if (validImages.length + serverImageCount < 2) {
      showSnackBar('Please add at least 2 images');
    } else {
      navigatorKey.currentContext!
          .read<InitialProfileProvider>()
          .uploadUserImages(navigatorKey.currentContext!, validImages)
          .then((value) {
            if (value) {
              debugPrint('Images uploaded successfully');
            } else {
              showSnackBar('Something went wrong while uploading images');
            }
          });
    }
  }

  Future<int?> uploadImage(File img) async {
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(img.path),
    });
    final userTokens = await AuthProvider().retrieveUserTokens();

    final headers = {"Authorization": "Bearer ${userTokens['access']}"};
    int? returnVal;
    try {
      isLoading = true;
      final response = await dio.post(
        Endpoints.userVerify,
        data: formData,
        options: Options(headers: headers),
      );
      log(response.toString());
      if (response.statusCode == 200) {
        final userBox = Hive.box('user');
        userBox.put('verification_status', 2);
        showSnackBar('Verification on process !');
      } else {
        showSnackBar('Something went wrong, Try again');
      }
      returnVal = response.statusCode!;
      isLoading = false;
      log(response.statusCode.toString());
    } catch (error) {
      debugPrint('uploadImage =====$error');
    }
    return returnVal;
  }
}
