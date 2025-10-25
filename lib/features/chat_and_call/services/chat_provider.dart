import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/utils/functions.dart';

import '../../../api/api_helper.dart';
import '../../../api/endpoints.dart';
import '../../auth/services/auth_provider.dart';
import '../models/chat.dart';

enum LoadingState { loading, loaded, error }

class ChatProvider with ChangeNotifier {
  LoadingState _loadingState = LoadingState.loaded;

  LoadingState get loadingState => _loadingState;

  set loadingState(LoadingState value) {
    _loadingState = value;
    notifyListeners();
  }

  final chatsRef = FirebaseFirestore.instance.collection('chats');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final dio = Api().api;
  ValueNotifier lastmessagelable = ValueNotifier(10);

  int? currentTargetId;
  String? currentTargetName;
  String? currentTargetImage;
  String? currentTargetPushId;
  DateTime? lastMsgSeen;
  String? inChatID;
  String? currentTargetLstMsg;
  bool? targetIsSent;

  bool _isMutual = false;
  bool get isMutual => _isMutual;
  set isMutual(bool value) {
    _isMutual = value;
    notifyListeners();
  }

  bool _isBlocked = false;
  bool get isBlocked => _isBlocked;
  set isBlocked(bool value) {
    _isBlocked = value;
    notifyListeners();
  }

  bool _isSent = false;
  bool get isSent => _isSent;
  set isSent(bool value) {
    _isSent = value;
    notifyListeners();
  }

  listentargetlastseen() async {
    final int currentUserId = await Hive.box('user').get('id');

    usersRef
        .doc(currentUserId.toString())
        .collection("chats")
        .where("target_id", isEqualTo: currentTargetId)
        .snapshots()
        .listen((event) {})
        .onData((data) {
          if (data.docs.isNotEmpty) {
            if (data.docs.first.data().containsKey("last_msg_seen")) {
              if (data.docs.first.data().containsKey("isBlocked")) {
                isBlocked = data.docs.first.get("isBlocked") ?? false;
                log('listentargetlastseen $isBlocked');
                if (data.docs.first.data().containsKey("isMutual")) {
                  isMutual = data.docs.first.get("isMutual") ?? false;
                  log('listentargetlastseen $isMutual');
                }
              }
              lastMsgSeen = data.docs.first.get("last_msg_seen").toDate();
            } else {
              lastMsgSeen = DateTime.parse("2022-03-12 23:21:31.437890");
            }
          }
          lastmessagelable.value++;
        });
  }

  Stream<List<Chat>> getMatches() async* {
    try {
      List<Chat> matches = [];
      final response = await dio.get(Endpoints.myMatches);
      log("Response: ${response.data}");
      if (response.statusCode == 200 && response.data['status']) {
        final matchesJson = response.data['matches'] as List;
        log('====================>> Get matches: ${jsonEncode(matchesJson)}');

        final uid = Hive.box('user').get('id');
        if (jsonEncode(matchesJson).isNotEmpty) {
          for (var match in matchesJson) {
            final user = match['first_user']['id'] == uid
                ? match['second_user']
                : match['first_user'];

            final chat = Chat(
              targetId: user['id'],
              name: user['name'],
              image: user['display_image'],
              pushId: user['push_id'],
              chatId: match['chat_id'],
              matchId: match['id'],
            );
            matches.add(chat);
          }
        }

        // log('------matches ${matches.first.targetId}');
        // yield matches;
      }
      yield matches;
    } catch (e) {
      debugPrint('matches error $e');
      rethrow;
    }
    // return [];
  }

  unMatch(Chat chat) async {
    try {
      final userTokens = await AuthProvider().retrieveUserTokens();
      int matchId = 0;
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      if (chat.matchId == null) {
        final response = await dio.get(Endpoints.myMatches);
        // int matchId = 0;
        if (response.statusCode == 200 && response.data['status']) {
          final matchesJson = response.data['matches'] as List;
          log('====================>> Get matches: ${jsonEncode(matchesJson)}');
          // final uid = Hive.box('user').get('id');

          for (var match in matchesJson) {
            log(match['id'].toString());
            if (match['second_user']['id'] == chat.targetId ||
                match['first_user']['id'] == chat.targetId) {
              matchId = match['id'];
              break;
            }
          }
        }
      } else {
        matchId = chat.matchId!;
      }
      log('matchid 1--------- $matchId');
      final data = FormData.fromMap({'match_id': '$matchId'});
      log(chat.chatId.toString());
      log(matchId.toString());

      final unMatch = await dio.post(
        Endpoints.unMatch,
        data: data,
        options: Options(headers: headers),
      );
      notifyListeners();
      log("unmatchh ${unMatch.data.toString()}");
      log("unmatch 111 ${unMatch.statusCode.toString()}");
    } catch (error) {
      debugPrint('unmatch error $error');
    }
  }

  Future<String?> getCurrentChatId() async {
    final int currentUserId = Hive.box('user').get('id');
    try {
      final chatId = await usersRef
          .doc(currentUserId.toString())
          .collection('chats')
          .where('target_id', isEqualTo: currentTargetId)
          .get();
      if (chatId.docs.isEmpty) {
        return null;
      }
      return chatId.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  Future<String> createNewChat() async {
    // loadingState = LoadingState.loading;

    String chatId = '';
    final int currentUserId = Hive.box('user').get('id');
    final String currentUserName = Hive.box('user').get('name');
    final String currentUserImage = Hive.box('user').get('display_image') ?? '';

    try {
      await chatsRef.add({}).then((value) => chatId = value.id);

      final senderData = {
        'target_id': currentTargetId,
        'name': currentTargetName,
        'image': currentTargetImage,
        'time': DateTime.now(),
        'unread': 0,
        'last_msg': '',
        'last_msg_seen': DateTime.parse("2022-03-12 23:21:31.437890"),
        'chat_id': chatId,
        'push_id': currentTargetPushId,
      };

      final recieverData = {
        'target_id': currentUserId,
        'name': currentUserName,
        'image': currentUserImage,
        'time': DateTime.now(),
        'unread': 0,
        'last_msg': '',
        'chat_id': chatId,
        'push_id': Hive.box('user').get('push_id'),
      };

      await usersRef
          .doc(currentUserId.toString())
          .collection('chats')
          .doc(chatId)
          .set(senderData);

      await usersRef
          .doc(currentTargetId.toString())
          .collection('chats')
          .doc(chatId)
          .set(recieverData);
      // loadingState = LoadingState.loaded;
      return chatId;
    } catch (e) {
      // loadingState = LoadingState.loaded;
      rethrow;
    }
  }

  Future<void> sendMessage(String chatId, String msg, Chat chat) async {
    final int currentUserId = Hive.box('user').get('id');
    log('-----------$currentUserId');
    final time = DateTime.now();
    final msgData = {'sender': currentUserId, 'text': msg, 'time': time};
    await chatsRef.doc(chatId).collection('messages').add(msgData);
    final name = Hive.box('user').get('name');
    if (currentTargetPushId != null) {
      log(
        "User name :: $name    /////////////////   target push id :: ${chat.pushId}",
      );
      log(
        "///////////////// sending notification to targetPushId :: $currentTargetPushId  /////////////",
      );
      sendNotification(name, msg, currentTargetPushId!, chat, chatId);
    }
    updateLastMsg(msg, chatId, time);
  }

  //update last message
  Future<void> updateLastMsg(
    String msg,
    String chatId,
    DateTime time, {
    bool? isBlocked,
    String? targetMsg,
    String? curreUsMsg,
  }) async {
    final int currentUserId = Hive.box('user').get('id');
    await usersRef
        .doc(currentUserId.toString())
        .collection('chats')
        .doc(chatId)
        .update({
          'last_msg': curreUsMsg ?? msg,
          'time': time,
          'is_sent': true,
          if (isBlocked != null) 'isBlocked': isBlocked,
        });
    await usersRef
        .doc(currentTargetId.toString())
        .collection('chats')
        .doc(chatId)
        .update({
          'last_msg': currentTargetLstMsg == '' ? msg : currentTargetLstMsg,
          'time': DateTime.now(),
          'unread': FieldValue.increment(1),
          'is_sent': false,
          if (isBlocked != null) 'isBlocked': isBlocked,
        });
  }

  Future<void> blockUser(String chatId, String msg) async {
    final int currentUserId = Hive.box('user').get('id');
    log('-----------$currentUserId');
    final time = DateTime.now();
    // final name = Hive.box('user').get('name');
    if (isBlocked && !isSent) {
      if (isMutual) {
        showSnackBar('You already blocked this contact.');
        return;
      }
      isSent = false;
      await usersRef
          .doc(currentUserId.toString())
          .collection('chats')
          .doc(inChatID)
          .update({
            'last_msg': "You blocked this contact",
            'time': time,
            'is_sent': false,
            'isMutual': true,
          });
      await usersRef
          .doc(currentTargetId.toString())
          .collection('chats')
          .doc(inChatID)
          .update({
            'time': DateTime.now(),
            'unread': FieldValue.increment(1),
            'is_sent': false,
            'isMutual': true,
          });
      return;
    } else if (isBlocked && isSent) {
      showSnackBar('You already blocked this contact.');
      return;
    }
    isBlocked = true;
    isSent = true;
    targetIsSent = false;
    updateLastMsg(
      msg,
      inChatID!,
      time,
      isBlocked: true,
      targetMsg: "This user blocked you",
      curreUsMsg: "You blocked this contact",
    );
  }

  unBlockUser() async {
    final int currentUserId = Hive.box('user').get('id');
    final time = DateTime.now();

    final lstUp = await usersRef
        .doc(currentTargetId.toString())
        .collection('chats')
        .doc(inChatID)
        .get();
    targetIsSent = lstUp.data()!['is_sent'];
    isMutual = lstUp.data()!['isMutual'] ?? false;
    log("isMutual $isMutual");
    if (isMutual) {
      isBlocked = true;
      isSent = false;
      isMutual = false;
      await usersRef
          .doc(currentUserId.toString())
          .collection('chats')
          .doc(inChatID)
          .update({
            'last_msg': "You unblocked this contact",
            'time': time,
            'isBlocked': true,
            'is_sent': false,
            'isMutual': false,
          });
      await usersRef
          .doc(currentTargetId.toString())
          .collection('chats')
          .doc(inChatID)
          .update({
            'time': DateTime.now(),
            'unread': FieldValue.increment(1),
            'isBlocked': true,
            'is_sent': true,
            'isMutual': false,
          });
      showSnackBar('You unblocked this Contact.');
      return;
    }
    isBlocked = false;
    isSent = true;
    await usersRef
        .doc(currentUserId.toString())
        .collection('chats')
        .doc(inChatID)
        .update({
          'last_msg': "You unblocked this contact",
          'time': time,
          'isBlocked': false,
          'is_sent': true,
        });
    await usersRef
        .doc(currentTargetId.toString())
        .collection('chats')
        .doc(inChatID)
        .update({
          'time': DateTime.now(),
          'unread': FieldValue.increment(1),
          'isBlocked': false,
          'is_sent': false,
        });
    showSnackBar('You unblocked this Contact.');
  }

  getTargetIsSent() async {
    final lstUp = await usersRef
        .doc(currentTargetId.toString())
        .collection('chats')
        .doc(inChatID)
        .get();
    if (lstUp.data() != null) {
      targetIsSent = lstUp.data()!['is_sent'] ?? false;
      isMutual = lstUp.data()!['isMutual'] ?? false;
    }
  }

  initiateChat(int userId, int matchId) async {
    try {
      log("===========>Trying Initiating new chat ==================");
      final int currentUserId = Hive.box('user').get('id');
      final String currentUserName = Hive.box('user').get('name');
      final String currentUserImage =
          Hive.box('user').get('display_image') ?? '';
      // log('initiateChat');
      final userTokens = await AuthProvider().retrieveUserTokens();
      final headers = {"Authorization": "Bearer ${userTokens['access']}"};
      var formData = FormData.fromMap({"match_id": matchId, "user_id": userId});
      log('################# initiateChat $matchId $userId');
      final response = await dio.post(
        Endpoints.initiateChat,
        data: formData,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        final recieverData = {
          'target_id': currentUserId,
          'name': currentUserName,
          'image': currentUserImage,
          'time': DateTime.now(),
          'unread': 0,
          'last_msg': '',
          'chat_id': response.data['chat_id'],
          'push_id': Hive.box('user').get('push_id'),
          'match_id': matchId,
        };

        final senderData = {
          'target_id': currentTargetId,
          'name': currentTargetName,
          'image': currentTargetImage,
          'time': DateTime.now(),
          'unread': 0,
          'last_msg': '',
          'last_msg_seen': DateTime.parse("2022-03-12 23:21:31.437890"),
          'chat_id': response.data['chat_id'],
          'push_id': currentTargetPushId,
          'match_id': matchId,
        };

        await usersRef
            .doc(currentUserId.toString())
            .collection('chats')
            .doc(response.data['chat_id'])
            .set(senderData);

        await usersRef
            .doc(currentTargetId.toString())
            .collection('chats')
            .doc(response.data['chat_id'])
            .set(recieverData);
      }
      log("Initiate chat status code :: ${response.statusCode}");
      log("Initiate chat data :: ${response.data}");
      return response.data['chat_id'];
    } catch (e) {
      log("Initiate chat error ::: ${e}");
    }
  }

  Future<void> deleteChat(String chatId, String msgId, bool lstMsg) async {
    final int currentUserId = Hive.box('user').get('id');
    // final time = DateTime.now();
    log('currentUserId $currentUserId ');
    // final msgData = {
    //   'sender': currentUserId,
    //   'text': msg,
    //   'time': time,
    // };
    String msg = 'Message was deleted !';
    await chatsRef.doc(chatId).collection('messages').doc(msgId).update({
      'text': msg,
    });

    log('message ${chatId.toString()}');

    if (lstMsg) {
      await usersRef
          .doc(currentUserId.toString())
          .collection('chats')
          .doc(chatId)
          .update({'last_msg': msg, 'is_sent': true});
      await usersRef
          .doc(currentTargetId.toString())
          .collection('chats')
          .doc(chatId)
          .update({'last_msg': msg, 'is_sent': false});
    }
    // chatmsg.docs.forEach((element) {
    //   log('9999999999999999 ${element.data()}');
    // });
  }

  Future<void> clearUnread(String chatId) async {
    log(chatId);
    final int currentUserId = Hive.box('user').get('id');
    await usersRef
        .doc(currentUserId.toString())
        .collection('chats')
        .doc(chatId)
        .update({'unread': 0});
  }

  /// Update last seen message time
  Future<void> updateLastSeen(String chatId, Timestamp time) async {
    await usersRef
        .doc(currentTargetId.toString())
        .collection('chats')
        .doc(chatId)
        .update({'last_msg_seen': time});
  }

  Stream<QuerySnapshot> chatsStream() {
    debugPrint(
      '====================>>currentUserId: ${Hive.box('user').get('id')}',
    );
    final int currentUserId = Hive.box('user').get('id');
    return usersRef
        .doc(currentUserId.toString())
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> messagesStream(String chatId) {
    debugPrint('====================>> $chatId');
    return chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  void sendNotification(
    String name,
    String msg,
    String pushId,
    Chat chat,
    chatId,
  ) {
    final dio = Dio();
    final apiKey = dotenv.env['ONE_SIGNAL_REST_API_KEY'];
    final appId = dotenv.env['ONE_SIGNAL_APP_ID'];
    final options = Options(
      headers: {
        'Authorization': 'Basic $apiKey',
        'Content-Type': 'application/json',
      },
    );
    final chatsChannelId = dotenv.env['ONE_SIGNAL_CHATS_CHANNEL_ID'];
    final data = {
      "include_external_user_ids": [pushId],
      "app_id": appId,
      "headings": {"en": name},
      "contents": {"en": msg},
      "data": {
        "type": "chat",
        "last_msg": msg,
        "is_sent": chat.isSent,
        "image": chat.image,
        "unread": chat.unread,
        "name": name,
        "chatId": chatId,
        "target_id": chat.targetId,
        "pushId": chat.pushId,
        "matchId": chat.matchId,
      },
      "android_channel_id": chatsChannelId,
    };
    debugPrint('====================>> Chat notif data: ${jsonEncode(data)}');

    dio
        .post(
          'https://onesignal.com/api/v1/notifications',
          data: data,
          options: options,
        )
        .then(
          (value) => debugPrint(
            '====================>> Chat notif send result: $value',
          ),
        );
  }
}
