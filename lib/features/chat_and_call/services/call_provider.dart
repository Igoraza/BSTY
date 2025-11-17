// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/features/chat_and_call/models/chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';

// import 'package:wakelock/wakelock.dart';

import '../../../api/api_helper.dart';
import '../../../api/endpoints.dart';
import '../../../utils/functions.dart';
import '../../../utils/global_keys.dart';
import '../../auth/services/auth_provider.dart';
import '../models/call.dart';
import '../models/enums.dart';

class CallsProvider with ChangeNotifier {
  final dio = Api().api;
  final String? appId = dotenv.env['AGORA_APP_ID'];
  late RtcEngine agoraEngine;
  late BuildContext callContext;

  // Variables
  CallStatus _callStatus = CallStatus.dialing;
  int? _remoteUid;
  String? _channelName;
  String? currentTargetPushId;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isCameraOn = true;
  bool _videoAllowed = false;
  bool _callAllowed = false;

  // Getters and Setters
  void setContext(BuildContext context) {
    callContext = context;
  }

  CallStatus get callStatus => _callStatus;
  set callStatus(CallStatus value) {
    _callStatus = value;

    notifyListeners();
  }

  set audio(bool value) {
    _callAllowed = value;
    notifyListeners();
  }

  int? get remoteUid => _remoteUid;

  String? get channelName => _channelName;

  bool get isMuted => _isMuted;
  set isMuted(bool value) {
    _isMuted = value;
    notifyListeners();
  }

  bool get isSpeaker => _isSpeaker;
  set isSpeaker(bool value) {
    _isSpeaker = value;
    notifyListeners();
  }

  bool get isCameraOn => _isCameraOn;
  set isCameraOn(bool value) {
    _isCameraOn = value;
    notifyListeners();
  }

  bool get isCallAllowed => _callAllowed;
  set isCallAllowed(bool value) {
    _callAllowed = value;
    notifyListeners();
  }

  bool get isVideoAllowed => _videoAllowed;
  set isVideoAllowed(bool value) {
    _videoAllowed = value;
    notifyListeners();
  }

  // Methods
  Future<List<Call>> fetchCallHistory(BuildContext context) async {
    final response = await dio.get(Endpoints.myCalls);
    if (response.statusCode == 200 && response.data['status']) {
      final callsJson = response.data['call_actions'] as List<dynamic>;
      List<Call> calls = callsJson.map((e) => Call.fromJson(e)).toList();
      return calls;
    } else {
      throw Exception(response.data['message']);
    }
  }

  // This function is called first when user enter the ongling call page
  Future<void> initEngine(bool isVideo) async {
    try {
      log("🔧 [initEngine] Starting Agora initialization...");
      log("🎥 Call type: ${isVideo ? 'Video Call' : 'Voice Call'}");

      agoraEngine = createAgoraRtcEngine();
      log("✅ Agora engine instance created successfully");

      // Request microphone permission
      log("🔊 Requesting microphone permission...");
      await [Permission.microphone].request();

      final micGranted = await Permission.microphone.isGranted;
      log("🎤 Microphone permission granted: $micGranted");

      if (!micGranted) {
        showSnackBar('Microphone access is required to make a call');
        navigatorKey.currentState?.pop();
        throw Exception('[initEngine] Microphone permission not granted');
      }

      // For video calls, also request camera permission
      if (isVideo) {
        log("📸 Requesting camera permission...");
        await [Permission.camera].request();

        final camGranted = await Permission.camera.isGranted;
        log("📷 Camera permission granted: $camGranted");

        if (!camGranted) {
          showSnackBar('Camera access is required to make a video call');
          navigatorKey.currentState?.pop();
          throw Exception('[initEngine] Camera permission not granted');
        }

        log("⚙️ Calling setupSDKEngine() for video...");
        await setupSDKEngine(isVideo);
        log("✅ [initEngine] setupSDKEngine() completed successfully for video");
      } else {
        log("⚙️ Calling setupSDKEngine() for voice...");
        await setupSDKEngine(isVideo);
        log("✅ [initEngine] setupSDKEngine() completed successfully for voice");
      }

      log("🎉 [initEngine] Initialization completed successfully!");
    } catch (e, stack) {
      log("❌ [initEngine] Error occurred: $e");
      log("🧱 Stack trace:\n$stack");
      showSnackBar('Failed to initialize call engine: ${e.toString()}');
      navigatorKey.currentState?.pop();
    }
  }

  // Future<void> initEngine(bool isVideo) async {
  //   log("*************Initializing calling***********");
  //   agoraEngine = createAgoraRtcEngine();
  //   await [Permission.microphone].request();

  //   if (await Permission.microphone.isGranted) {
  //     if (isVideo) {
  //       await [Permission.camera].request();

  //       if (await Permission.camera.isGranted) {
  //         await setupSDKEngine(isVideo);
  //       } else {
  //         navigatorKey.currentState!.pop();
  //         showSnackBar('Camera access is required to make a video call');
  //         throw Exception('Camera permission not granted');
  //       }
  //     } else {
  //       await setupSDKEngine(isVideo);
  //     }
  //   } else {
  //     showSnackBar('Microphone access is required to make a call');
  //     navigatorKey.currentState!.pop();
  //     throw Exception('Microphone permission not granted');
  //   }
  // }

  /// [ Initialize the Agora SDK ]
  Future<void> setupSDKEngine(bool isVideo) async {
    await agoraEngine.initialize(RtcEngineContext(appId: appId));
    if (isVideo) {
      debugPrint('=============Enable Video');
      await agoraEngine.enableVideo();
      // Wakelock.enable();
      debugPrint('=============Enable Video: Done');
    }

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          callStatus = CallStatus.ringing;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('=============User Joined: $remoteUid at $elapsed');
          _remoteUid = remoteUid;
          callStatus = CallStatus.connected;
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              _remoteUid = null;
              callStatus = CallStatus.ended;
              debugPrint(
                '=============User Offline: $remoteUid, Reason: $reason',
              );
              leaveChannel();
            },
        onLeaveChannel: (connection, state) {
          // Navigator.pop(callContext);
          leaveChannel();
        },
      ),
    );
  }

  // ✅ UPDATED sendCallNotification method with proper parameters
  void sendCallNotification({
    required String name,
    required String pushId,
    required bool isVideo,
    required String callId,
    required String image,
  }) {
    final dio = Dio();
    final apiKey = dotenv.env['ONE_SIGNAL_REST_API_KEY'];
    final appId = dotenv.env['ONE_SIGNAL_APP_ID'];
    final callsChannelId = dotenv.env['ONE_SIGNAL_CALLS_CHANNEL_ID'];

    final options = Options(
      headers: {
        'Authorization': 'Basic $apiKey',
        'Content-Type': 'application/json',
      },
    );

    // ✅ Use the actual push ID of the target user
    final data = {
      "include_external_user_ids": [pushId], // Use actual push ID
      "app_id": appId,
      "contents": {"en": "$name is calling you"},
      "headings": {"en": isVideo ? "Incoming Video Call" : "Incoming Call"},
      "data": {
        "type": "call",
        "call_id": callId,
        "action_type": isVideo ? "2" : "1",
        "user_image": image,
        "user_name": name,
      },
      "android_channel_id": callsChannelId,
      "ios_category": "CALL_INVITE",
      "priority": 10,
      "ios_sound": "call_sound.wav",
      "android_sound": "call_sound",
      // Add action buttons for call notifications
      "buttons": [
        {"id": "accept", "text": "Accept", "icon": "ic_accept_call"},
        {"id": "decline", "text": "Decline", "icon": "ic_decline_call"},
      ],
    };

    debugPrint('=============Sending call notification to: $pushId');
    debugPrint('=============Notification data: $data');

    dio
        .post(
          'https://onesignal.com/api/v1/notifications',
          data: data,
          options: options,
        )
        .then((value) {
          debugPrint(
            '====================>> Call notification sent successfully: ${value.data}',
          );
        })
        .catchError((error) {
          debugPrint('====================>> Call notification failed: $error');
        });
  }

  /// Create an [ outgoing call ]
  /// Create an [ outgoing call ]
  void makeCall(
    BuildContext context, {
    required int uid,
    required bool isVideo,
    required String userName,
    required String userImage,
    required String targetPushId, // Add this parameter
  }) async {
    debugPrint('=============Start Call: $uid, isVideo: $isVideo');
    log('=============Start Call: $uid, isVideo: $isVideo');
    try {
      final response = await createCallWithServer(id: uid, isVideo: isVideo);
      log("################## create call with server response : $response");

      if (response.isNotEmpty) {
        _channelName = response['channelName'];
        final callId = _channelName?.split('_')[1];
        debugPrint('=============Call ID: $callId');
        debugPrint('=============Make Call Response $response');

        // SEND PUSH NOTIFICATION TO THE OTHER USER
        log("%%%%%%%%%%%%%%%%%%%%%%%%%%% Sending notification");
        sendCallNotification(
          // name: userName,
          name: Hive.box('user').get('name'),
          pushId: targetPushId,
          isVideo: isVideo,
          callId: callId!,
          // image: userImage,
          image: Hive.box('user').get('display_image'),
        );

        // Join the channel
        await joinChannel(
          token: response['token'],
          channelName: _channelName!,
          isIncoming: false,
          isVideo: isVideo,
        );
        debugPrint('=============Response: $response');
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: 'No Permission',
            desc:
                'You don\'t have permission to ${isVideo ? 'video call' : 'call'} this person, Please ask him/her to give permission in Call settings',
          ),
        );
      }
    } catch (error) {
      debugPrint('=============Error: $error');
      showSnackBar('Something went wrong. Please try again later.');
      rethrow;
    }
  }

  /// Accept an [ incoming call ]
  void answerCall(
    BuildContext context, {
    required int callId,
    required bool isVideo,
  }) async {
    debugPrint('=============Accept Call: $callId');
    callStatus = CallStatus.ringing;

    try {
      final response = await getReceiverTokenFromServer(
        context,
        callId: callId,
      );

      _channelName = response['channelName'];
      // Wakelock.enable();
      await joinChannel(
        token: response['token'],
        channelName: _channelName!,
        isIncoming: true,
        isVideo: isVideo,
      );
      debugPrint('=============Answer Call Response: $response');
    } catch (error) {
      debugPrint('=============Error: $error');
      showSnackBar('Something went wrong. Please try again later.');
      rethrow;
    }
  }

  // request a call with the server by the call initiator
  // and get the token and channel name
  Future<Map<String, dynamic>> createCallWithServer({
    required int id,
    required bool isVideo,
  }) async {
    final data = FormData.fromMap({
      'user_id': '$id',
      'action_type': '${isVideo ? 2 : 1}',
    });
    debugPrint('=============Data: ${data.fields}');

    try {
      final response = await dio.post(Endpoints.initiateCall, data: data);
      if (response.statusCode == 200 && response.data['status']) {
        debugPrint('=============Response: ${response.data}');
        return {
          'token': response.data['token'],
          'channelName': response.data['channelName'],
        };
      } else if (response.statusCode == 200 && !response.data['status']) {
        return {};
      } else {
        throw Exception(response.data['message']);
      }
    } catch (error) {
      debugPrint('Error: $error');
      rethrow;
    }
  }

  // Receive the token and channel name from the server by the call receiver
  Future<Map<String, dynamic>> getReceiverTokenFromServer(
    BuildContext context, {
    required int callId,
  }) async {
    final data = FormData.fromMap({'call_id': '$callId'});

    try {
      final response = await dio.post(Endpoints.getCallToken, data: data);
      if (response.statusCode == 200 && response.data['status']) {
        debugPrint('=============Response: ${response.data}');
        return {
          'token': response.data['token'],
          'channelName': response.data['channelName'],
        };
      } else {
        throw Exception(response.data['message']);
      }
    } catch (error) {
      debugPrint('Error: $error');
      rethrow;
    }
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required bool isIncoming,
    required bool isVideo,
  }) async {
    debugPrint('=============Joining Channel: $channelName');

    if (isVideo) {
      await agoraEngine.startPreview();
    }

    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    try {
      await agoraEngine.joinChannel(
        token: token,
        channelId: channelName,
        options: options,
        uid: isIncoming ? 2 : 1,
      );
      if (isVideo) {
        await agoraEngine.setEnableSpeakerphone(true);
      } else {
        await agoraEngine.setEnableSpeakerphone(false);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    agoraEngine.muteLocalAudioStream(isMuted);
  }

  void toggleSpeaker() {
    isSpeaker = !isSpeaker;
    agoraEngine.setEnableSpeakerphone(isSpeaker);
  }

  void toggleCamera() {
    agoraEngine.muteLocalVideoStream(!isCameraOn);
    isCameraOn = !isCameraOn;
  }

  // switch to video while in audio call
  Future<bool> switchToVideo() async {
    await [Permission.camera].request();
    if (await Permission.camera.isGranted) {
      await agoraEngine.enableVideo();
      // Wakelock.enable();
      await agoraEngine.startPreview();
      await agoraEngine.setEnableSpeakerphone(true);
      await agoraEngine.muteLocalVideoStream(false);
      return true;
    } else {
      showSnackBar('Camera permission is required for video call.');
      return false;
    }
  }

  void leaveChannel() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    // Wakelock.disable();
    callStatus = CallStatus.ended;
    _remoteUid = null;
    navigatorKey.currentState!.pop();
  }

  getCallSettings(Chat chat) async {
    final userTokens = await AuthProvider().retrieveUserTokens();
    final data = FormData.fromMap({'user_id': '${chat.targetId}'});
    final headers = {"Authorization": "Bearer ${userTokens['access']}"};
    final response = await dio.post(
      Endpoints.getCallSettings,
      data: data,
      options: Options(headers: headers),
    );
    if (response.statusCode == 200) {
      if (response.data['status'] == true) {
        _videoAllowed = response.data['video_allowed'];
        _callAllowed = response.data['audio_allowed'];
        notifyListeners();
      } else {
        _videoAllowed = false;
        _callAllowed = false;
      }
    }
  }

  updateCallSettings(Chat chat) async {
    final userTokens = await AuthProvider().retrieveUserTokens();
    // log('user token $userTokens');
    log(chat.targetId.toString());
    bool audio = isCallAllowed;
    bool video = isVideoAllowed;
    final data = FormData.fromMap({
      'user_id': '${chat.targetId}',
      'audio': audio ? 1 : 0,
      'video': video ? 1 : 0,
    });
    final headers = {"Authorization": "Bearer ${userTokens['access']}"};
    final response = await dio.post(
      Endpoints.updateCallSettings,
      data: data,
      options: Options(headers: headers),
    );
    if (response.statusCode == 200) {
      final userBox = Hive.box('user');
      userBox.put('audio_allowed', response.data['audio_allowed']);
      userBox.put('video_allowed', response.data['video_allowed']);
    }
    return response;
  }

  sendCallCredits(String requestId, int actionType) async {
    // log('11111111111 sendCallCredits');
    final userTokens = await AuthProvider().retrieveUserTokens();
    final userBox = Hive.box('user');

    final data = FormData.fromMap({
      'request_id': requestId,
      'action_type': actionType,
    });
    final headers = {"Authorization": "Bearer ${userTokens['access']}"};
    final response = await dio.post(
      Endpoints.callCredits,
      data: data,
      options: Options(headers: headers),
    );
    if (response.statusCode == 200) {
      userBox.put('audio_call_balance', response.data['audio_call_balance']);
      userBox.put('video_call_balance', response.data['video_call_balance']);
      if (response.data['audio_call_balance'] == 0 && actionType == 1) {
        agoraEngine.leaveChannel();
        showSnackBar('Audio call balance exceeded, Please recharge!');
      } else if (response.data['video_call_balance'] == 0 && actionType == 2) {
        agoraEngine.leaveChannel();
        showSnackBar('Video call balance exceeded, Please recharge!');
      }
    }
  }
}
