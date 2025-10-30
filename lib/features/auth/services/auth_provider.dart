import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/features/auth/pages/initial_profile_steps/select_dob_page.dart';
import 'package:bsty/features/auth/pages/verification/verify_phone_page.dart';
import 'package:bsty/screens/permission/permit_location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../api/endpoints.dart';
import '../../../screens/main/main_page.dart';
import '../../../services/locatoin_provider.dart';
import '../../../utils/functions.dart';
import '../../../utils/global_keys.dart';
import '../../splash/intro.dart';
import '../enums.dart';
import '../models/sign_up_model.dart';
import '../models/verify_otp_args.dart';
import '../pages/initial/sign_in_page.dart';

enum OtpType { phone, email }

class AuthProvider with ChangeNotifier {
  AuthStatus authStatus = AuthStatus.notRegistered;

  bool fromMatch = false;

  bool _isTyped = false;

  bool get istyped => _isTyped;
  set istyped(bool value) {
    _isTyped = value;
    notifyListeners();
  }

  String requestId = "";

  bool _passVisible = false;
  bool get passVisible => _passVisible;
  set passVisible(bool value) {
    _passVisible = value;
    notifyListeners();
  }

  bool isTab = false;
  // bool get isTab => _isTab;
  // set isTab(bool value) {
  //   _isTab = value;
  //   notifyListeners();
  // }

  // save if user is logged in or not locally
  void saveLoggedInStatus(bool status) {
    final authBox = Hive.box('user');
    authBox.put('isLoggedIn', status);
  }

  // get if user is logged in or not from local storage
  bool retrieveLoggedInStatus() {
    final authBox = Hive.box('user');
    return authBox.get('loggedIn', defaultValue: false);
  }

  //loading animation in apple signin
  bool _isLoding = false;
  bool get isLoading => _isLoding;
  set isLoading(bool value) {
    _isLoding = value;
    notifyListeners();
  }

  // save user access and refresh tokens locally
  Future<void> saveUserToken(String access, String refresh) async {
    try {
      const secureStorage = FlutterSecureStorage();
      String? encryptionKey = await secureStorage.read(key: 'key');
      if (encryptionKey == null) {
        final key = Hive.generateSecureKey();
        await secureStorage.write(key: 'key', value: base64UrlEncode(key));
        encryptionKey = base64UrlEncode(key);
      }

      final boxKey = base64Url.decode(encryptionKey);
      final encryptedBox = await Hive.openBox(
        'tokens',
        encryptionCipher: HiveAesCipher(boxKey),
      );
      await encryptedBox.put('access', access);
      await encryptedBox.put('refresh', refresh);
      debugPrint('Saved tokens');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<Box<dynamic>?> openTokenBox() async {
    try {
      const secureStorage = FlutterSecureStorage();
      String? encryptionKey = await secureStorage.read(key: 'key');
      if (encryptionKey == null) return null;

      final boxKey = base64Url.decode(encryptionKey);
      return await Hive.openBox(
        'tokens',
        encryptionCipher: HiveAesCipher(boxKey),
      );
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  // get user access and refresh tokens from local storage
  Future<Map<String, String>> retrieveUserTokens() async {
    try {
      log("-------------Retrieving user tokens--------");
      final encryptedBox = await openTokenBox();
      if (encryptedBox == null) return {};

      final access = encryptedBox.get('access');
      final refresh = encryptedBox.get('refresh');
      log("Access token : $access");
      if (access == null || refresh == null) return {};
      return {'access': access, 'refresh': refresh};
    } catch (e) {
      debugPrint('Error: $e');
      return {};
    }
  }

  // delete user access and refresh tokens from local storage
  Future<void> deleteUserTokens() async {
    final encryptedBox = await openTokenBox();
    if (encryptedBox == null) return;
    await encryptedBox.delete('access');
    await encryptedBox.delete('refresh');
  }

  final dio = Dio();

  Future<String?> signUp(BuildContext context, SignUpModel userData) async {
    String? returnVal;
    log("Trying signup");
    authStatus = AuthStatus.checking;
    notifyListeners();

    try {
      var formData = FormData.fromMap(userData.toJson());
      log("Trying signup.......");
      await dio.post(Endpoints.signUpUrl, data: formData).then((response) {
        log("Signup response : ${response.data}");
        returnVal = response.data["request_id"];

        if (response.data['status'] == 'success') {
          showSnackBar('OTP sent to your phone number.');

          log("====== req id :: ${returnVal}");
          // return returnVal;
        } else {
          showSnackBar(response.data['message']);
          // returnVal = false;
        }
      });
    } catch (error) {
      log('Signup Error: $error');
      if (error is DioError) {
        log('Signup Error: ${error.response}');
        if (error.message!.contains('SocketException')) {
          showSnackBar('Please check your internet connection.');
        }
      }
      // returnVal = false;
    }
    authStatus = AuthStatus.done;
    notifyListeners();
    return returnVal;
  }

  Future<void> emailLogin(String email, String password) async {
    log("Trying Log in with email and pass");
    authStatus = AuthStatus.checking;
    notifyListeners();

    try {
      final userBox = Hive.box('user');
      final latitude = userBox.get('user_latitude');
      final longitude = userBox.get('user_longitude');

      log(
        "User location from Hive - latitude: $latitude, longitude: $longitude",
      );

      // 1️⃣ Firebase login
      log("Before Firebase login");
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException("Firebase login timed out");
            },
          );
      log("After Firebase login: ${user.user?.uid}");

      // 2️⃣ Prepare form data
      var formData = FormData.fromMap({"email": email, "password": password});

      // 3️⃣ Dio POST request
      log("Before Dio POST request to ${Endpoints.emailLoginUrl}");
      final response = await dio
          .post(
            Endpoints.emailLoginUrl,
            data: formData,
            options: Options(
              sendTimeout: Duration(seconds: 50),
              receiveTimeout: Duration(seconds: 50),
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException("Dio POST request timed out");
            },
          );
      log("After Dio POST request, response: ${response.data}");

      // 4️⃣ Check API response
      if (response.data['status'] == 'success') {
        log("Login successful, saving user data to Hive");
        userBox.put('id', response.data['user']['id']);
        userBox.put('name', response.data['user']['name']);
        userBox.put('push_id', response.data['user']['push_id']);
        userBox.put('display_image', response.data['user']['display_image']);
        userBox.put('plan', response.data['user']['plan'] ?? 1);

        await saveUserToken(response.data['access'], response.data['refresh']);
        saveLoggedInStatus(true);

        if (response.data['new_user'] == true) {
          log("New user detected, navigating to VerifyPhone");
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            VerifyPhone.routeName,
            (route) => false,
          );
        } else if (latitude == null && longitude == null) {
          log("No location saved, navigating to PermitLocation");
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            PermitLocation.routeName,
            (route) => false,
          );
        } else {
          log("Existing user with location, navigating to MainPage");
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            MainPage.routeName,
            (route) => false,
          );
        }

        authStatus = AuthStatus.done;
        notifyListeners();
      } else if (response.data['message'] != null) {
        log("Login failed: Invalid email or password");
        showSnackBar('Invalid email or password');
      } else {
        log("Login failed: Unknown error");
        showSnackBar('Something went wrong, please try again later');
      }
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuthException: ${e.code} - ${e.message}");
      showSnackBar("Firebase login error: ${e.message}");
    } on DioError catch (e) {
      log("DioError: ${e.type} - ${e.message}");
      showSnackBar("Network error: ${e.message}");
    } on TimeoutException catch (e) {
      log("TimeoutException: ${e.message}");
      showSnackBar("Request timed out, please try again");
    } catch (e, st) {
      log("Unexpected error: $e");
      debugPrintStack(stackTrace: st);
      showSnackBar("An unexpected error occurred");
    } finally {
      authStatus = AuthStatus.done;
      notifyListeners();
    }
  }

  Future<bool> sendCredentialsToServer(
    UserCredential firebaseUser,
    bool isApple,
    String? givenName,
  ) async {
    log("=============Sending credentials to server==========");
    bool returnVal = false;
    var formData = FormData.fromMap({
      "name": isApple
          ? givenName ?? 'user'
          : firebaseUser.user!.displayName ?? 'user',
      "email": firebaseUser.user!.email,
      "token": firebaseUser.credential!.accessToken,
    });
    try {
      log("firebase user ${firebaseUser.user}");
      log("****** form data ${formData.fields}");
      final response = await dio.post(
        !isApple
            // ? "https://api.bsty.in/api/v1/google/login/"
            ? Endpoints.googleLoginUrl
            : Endpoints.appleLoginUrl,
        data: formData,
      );
      log('===========> Google Login Data: ${response.statusCode}');
      log('===========> Google Login Data: ${response.data}');
      if (response.data['status'] == 'success') {
        final userBox = Hive.box('user');
        userBox.put('id', response.data['user']['id']);
        userBox.put('name', response.data['user']['name']);
        userBox.put('push_id', response.data['user']['push_id']);
        userBox.put('display_image', response.data['user']['display_image']);
        userBox.put('plan', response.data['user']['plan'] ?? 1);

        await saveUserToken(response.data['access'], response.data['refresh']);
        saveLoggedInStatus(true);
        returnVal = response.data['new_user'];
      } else if (response.data['message'] != null) {
        showSnackBar(response.data['message']);
      } else {
        throw (response.data);
      }
    } on DioException catch (e) {
      debugPrint('Error: Send google credentiols to server: $e');
      debugPrint('Error: Send google credentiols to server: ${e.response}');
      debugPrint(
        'Error: Send google credentiols to server: ${e.response?.statusMessage}',
      );
      debugPrint(
        'Error: Send google credentiols to server: ${e.response?.data}',
      );
    }
    return returnVal;
  }

  Future<void> signInWithGoogle() async {
    authStatus = AuthStatus.checking;
    final userBox = Hive.box('user');
    final latitude = userBox.get('user_latitude');
    final longitude = userBox.get('user_longitude');
    notifyListeners();

    try {
      // ignore: no_leading_underscores_for_local_identifiers
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email'],
        // The OAuth client id of your app. This is required.
        clientId:
            '606198864287-qhvpa9suun6lur2uainrn8jfk4ahkim0.apps.googleusercontent.com',

        // If you need to authenticate to a backend server, specify its OAuth client. This is optional.
        // serverClientId: ...,
      );
      debugPrint('===========> Google Login');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebaseUser = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      log('firebaseUser --------- ${firebaseUser.toString()}');
      if (firebaseUser.user != null) {
        final respose = await sendCredentialsToServer(
          firebaseUser,
          false,
          null,
        );
        if (respose) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            VerifyPhone.routeName,
            (route) => false,
          );
        } else {
          if (latitude == null && longitude == null) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              PermitLocation.routeName,
              (route) => false,
            );
          } else {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              MainPage.routeName,
              (route) => false,
            );
          }
        }
      }

      authStatus = AuthStatus.done;
      notifyListeners();
    } catch (error) {
      authStatus = AuthStatus.done;
      notifyListeners();
      debugPrint('===========> Google Login Error: $error');
      if (error is DioError) {
        if (error.message!.contains('SocketException')) {
          showSnackBar('Please check your internet connection.');
        }
      }
    }
    authStatus = AuthStatus.done;
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    isLoading = true;
    final userBox = Hive.box('user');
    final latitude = userBox.get('user_latitude');
    final longitude = userBox.get('user_longitude');
    notifyListeners();

    try {
      debugPrint('===========> Apple Login');
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
              '462485522944-52l4606fg03oqhq3r647vq4tuo3ndboo.apps.googleusercontent.com', // Your client ID for your Firebase project
          redirectUri: Uri.parse(
            'https://metfie-f387a.firebaseapp.com/__/auth/handler',
          ), // Your redirect URI for your Firebase project
        ),
      );
      log('------------------------------------------------------------- ');
      log('------------------------------------------------------------ ');
      log('Apple Login result ${result.toString()}');
      log('Apple Login givenName ${result.givenName.toString()}');
      // Once you get the Apple ID credential, you can use it to sign in with Firebase
      log('------------------------------------------------------------- ');
      log('------------------------------------------------------------ ');
      final appleIdCredential = OAuthProvider('apple.com').credential(
        idToken: result.identityToken,
        accessToken: result.authorizationCode,
      );
      log('Apple Login OAuthProvider ${appleIdCredential.toString()}');
      log('------------------------------------------------------------- ');
      log('------------------------------------------------------------ ');
      final firebaseUser = await FirebaseAuth.instance.signInWithCredential(
        appleIdCredential,
      );
      log('firebaseUser --------- ${firebaseUser.toString()}');
      // return userCredential;
      log('------------------------------------------------------------- ');
      log('------------------------------------------------------------ ');
      if (firebaseUser.user != null) {
        log(
          'UserCredential additionalUserInfo --------- ${firebaseUser.additionalUserInfo}',
        );
        log('UserCredential credential --------- ${firebaseUser.credential}');
        final respose = await sendCredentialsToServer(
          firebaseUser,
          true,
          result.givenName,
        );
        log('====> $respose');
        if (respose) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            VerifyPhone.routeName,
            (route) => false,
          );
        } else {
          if (latitude == null && longitude == null) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              PermitLocation.routeName,
              (route) => false,
            );
          } else {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              MainPage.routeName,
              (route) => false,
            );
          }
        }
      }
      isLoading = false;

      notifyListeners();
    } catch (error) {
      isLoading = false;

      notifyListeners();
      debugPrint('===========> Apple Login Error: $error');
      if (error is DioError) {
        if (error.message!.contains('SocketException')) {
          showSnackBar('Please check your internet connection.');
        }
      }
    }
    authStatus = AuthStatus.done;
    notifyListeners();
  }

  Future<String?> login(
    BuildContext context,
    String phone,
    String requestId,
  ) async {
    String? returnVal;

    authStatus = AuthStatus.checking;
    notifyListeners();
    try {
      var formData = FormData.fromMap({
        "phone": phone,
        "request_id": requestId,
      });
      log('phone: $phone');
      await dio.post(Endpoints.loginUrl, data: formData).then((response) {
        log('=========>> login response: ${response.data}');
        if (response.data['status'] == 'success') {
          debugPrint('========= ${response.data} =========');
          showSnackBar('OTP sent to your phone number.');
          returnVal = response.data["request_id"];
          // returnVal = true;
        } else if (response.data['message'] == 'User not found') {
          showSnackBar(
            "We couldn't find an account with this phone number. Please check your details or create a new account.",
          );
          // returnVal = false;
        } else {
          showSnackBar(response.data['message']);
          // returnVal = false;
        }
        return returnVal;
      });
    } catch (error) {
      log('Login Error: $error');
      if (error is DioException) {
        log("Login error : ${error.response}");
        if (error.message!.contains('SocketException')) {
          showSnackBar('Please check your internet connection.');
        }
      }
    }
    authStatus = AuthStatus.done;
    notifyListeners();
    return returnVal;
  }


  

  void logout() async {
    authStatus = AuthStatus.checking;
    notifyListeners();

    try {
      OneSignal.logout();
      debugPrint('===========> OneSignal User Logged Out');

      navigatorKey.currentContext!.read<LocationProvider>().stopTracking();

      /// The location getting null after continuous logout. Saving location in another box
      final latitude = Hive.box('user').get('user_latitude');
      final longitude = Hive.box('user').get('user_longitude');
      final location = Hive.box('user').get('location');
      Hive.box('guide').put('user_latitude', latitude);
      Hive.box('guide').put('user_longitude', longitude);
      Hive.box('guide').put('location', location);

      deleteUserTokens();
      Hive.box('user').clear();

      await FirebaseAuth.instance.signOut();
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }

      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        SignInPage.routeName,
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error: Logout: $e');
      showSnackBar('Error while logging out. Please try again.');
    }

    authStatus = AuthStatus.done;
    notifyListeners();
  }

  Future<bool> verifyOtp(
    BuildContext context, {
    required String otp,
    required VerifyOtpArgs args,
  }) async {
    log("Verifying otp");
    bool returnVal = false;

    authStatus = AuthStatus.checking;
    notifyListeners();

    try {
      var formData = FormData.fromMap({
        "code": otp,
        "phone": args.phone,
        "request_id": args.requestId,
      });
      log(
        "Starting verification with $otp - ${args.phone} - ${args.requestId}",
      );
      final response = await dio.post(
        args.isLoggingIn ? Endpoints.loginVerifyUrl : Endpoints.signUpVerifyUrl,
        data: formData,
      );
      log('=========Response ${response.data} =========');
      if (response.data['status'] == 'success') {
        final userBox = Hive.box('user');
        userBox.put('id', response.data['user']['id']);
        userBox.put('name', response.data['user']['name']);
        userBox.put('push_id', response.data['user']['push_id']);
        userBox.put('display_image', response.data['user']['display_image']);
        userBox.put('plan', response.data['user']['plan'] ?? 1);

        await saveUserToken(response.data['access'], response.data['refresh']);
        if (args.isLoggingIn) saveLoggedInStatus(true);

        returnVal = true;
      } else if (response.data['message'] != null) {
        showSnackBar(response.data['message']);
      } else {
        throw (response.data);
      }
    } catch (error) {
      log(
        'Error from ${args.isLoggingIn ? Endpoints.loginVerifyUrl : Endpoints.signUpVerifyUrl}: $error',
      );
      if (error is DioException) {
        log(error.response.toString());
        if (error.response?.data["message"] != null) {
          showSnackBar(error.response!.data["message"]);
        }
        if (error.message!.contains('SocketException')) {
          showSnackBar('Please check your internet connection.');
        }
      }
      returnVal = false;
    }
    authStatus = AuthStatus.done;
    notifyListeners();
    return returnVal;
  }

  Future updatePhone(
    BuildContext context, {
    required String phone,
    String? referralCode,
  }) async {
    try {
      final userTokens = await retrieveUserTokens();
      var formData = FormData.fromMap({
        "phone": phone,
        "referral_code": referralCode ?? "NA",
      });

      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      // log('------------}');
      final response = await dio.post(
        Endpoints.completeProfile,
        data: formData,
        options: Options(headers: headers),
      );
      debugPrint('------------${response.statusCode.toString()}');
      debugPrint('------------${response.data.toString()}');
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(SelectDob.routeName, (route) => false);
      } else {
        showSnackBar('Something went wrong');
      }
    } catch (error) {
      debugPrint('update phone Error: $error');
    }
  }

  Future<bool> verifyEmail(BuildContext context, String email) async {
    bool returnVal = false;

    authStatus = AuthStatus.checking;
    notifyListeners();

    try {
      final userTokens = await retrieveUserTokens();

      final headers = {"Authorization": "Bearer ${userTokens['access']}"};

      var formData = FormData.fromMap({"email": email});
      await dio
          .post(
            Endpoints.updateEmail,
            data: formData,
            options: Options(headers: headers),
          )
          .then((response) {
            if (response.statusCode == 200) {
              showSnackBar(
                'A verification link has been sent to your email address',
              );
              returnVal = true;
            } else if (response.statusCode == 401) {
              refreshToken().then((value) {
                if (value) {
                  verifyEmail(context, email);
                } else {
                  showSnackBar('Something went wrong');
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    IntroScreen.routeName,
                    (route) => false,
                  );
                }
              });
            } else {
              showSnackBar(response.data['message']);
              returnVal = false;
            }
          });
    } catch (error) {
      debugPrint('Verify Email Error: $error');
      returnVal = false;
    }
    authStatus = AuthStatus.done;
    notifyListeners();
    return returnVal;
  }

  Future<bool> verifyEmailOtp(BuildContext context) async {
    authStatus = AuthStatus.done;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      showSnackBar('Email verified successfully');
      authStatus = AuthStatus.done;
      notifyListeners();
    });
    return true;
  }

  // Refresh the access token
  Future<bool> refreshToken() async {
    try {
      final userTokens = await retrieveUserTokens();
      FormData formData = FormData.fromMap({"refresh": userTokens['refresh']});
      final response = await dio.post(Endpoints.refreshToken, data: formData);
      if (response.statusCode == 200 && response.data['access'] != null) {
        await saveUserToken(response.data['access'], userTokens['refresh']!);
      }
      debugPrint('========= Access token refreshed =========');
      return true;
    } catch (e) {
      debugPrint('refreshToken Error: $e');
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    bool returnVal = false;
    try {
      isLoading = true;
      final userTokens = await retrieveUserTokens();
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      final response = await dio.get(
        Endpoints.deleteAccount,
        options: Options(headers: headers),
      );
      log('deleteAccount: ${response.data.toString()}');
      log('deleteAccount: ${response.statusCode.toString()}');
      if (response.statusCode == 200) {
        returnVal = true;
      } else {
        showSnackBar('Something went wrong, Please try again later');
      }

      isLoading = false;
    } catch (e) {
      debugPrint('deleteAccount Error: $e');
    }
    return returnVal;
  }
}
