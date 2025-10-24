import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/utils/functions.dart';
import 'package:bsty/utils/global_keys.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/background_image.dart';
import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../utils/constants/input_decorations.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/chat.dart';
import '../../../services/call_provider.dart';
import '../../../services/chat_provider.dart';
import '../widgets/chat_msgs_app_bar.dart';
import '../widgets/msgs_list.dart';
import '../widgets/no_chat_msgs_display.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.chat, {Key? key}) : super(key: key);

  final Chat chat;

  static const routeName = '/chat';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Stream<QuerySnapshot> messagesSteram;
  late ScrollController _scrollController;
  late TextEditingController _controller;
  String? chatId;
  String chatidd = '';

  // final addMediaBtns = [
  //   {
  //     'icon': 'assets/svg/chat/add_media/add_media_file.svg',
  //     'onPressed': () => debugPrint('file'),
  //   },
  //   {
  //     'icon': 'assets/svg/chat/add_media/add_media_cam.svg',
  //     'onPressed': () => debugPrint('cam'),
  //   },
  //   {
  //     'icon': 'assets/svg/chat/add_media/add_media_mic.svg',
  //     'onPressed': () => debugPrint('voice'),
  //   },
  // ];

  // final bool _isMenuOpen = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = TextEditingController();
    final chatProvider = context.read<ChatProvider>();
    chatProvider.currentTargetId = widget.chat.targetId;
    chatProvider.currentTargetName = widget.chat.name;
    chatProvider.currentTargetImage = widget.chat.image;
    chatProvider.lastMsgSeen = widget.chat.lastMsgSeen;
    chatProvider.currentTargetPushId = widget.chat.pushId;
    chatProvider.currentTargetLstMsg = widget.chat.lastMsg;
    context.read<CallsProvider>().currentTargetPushId = widget.chat.pushId;
    chatProvider.listentargetlastseen();

    log("***************************** chat :::: ${widget.chat}");

    setMessageSteram();
    log('------------ ${widget.chat.targetId}');
    debugPrint('=====================> Push ID: ${widget.chat.pushId}');
  }

  void setMessageSteram() async {
    final chatProvider = context.read<ChatProvider>();
    if (widget.chat.chatId != null) {
      debugPrint(
        '=====================> Chat id is not null: ${widget.chat.chatId}',
      );
      chatId = widget.chat.chatId;
      messagesSteram = chatProvider.messagesStream(widget.chat.chatId!);
      chatProvider.clearUnread(widget.chat.chatId!);
    } else {
      messagesSteram = chatProvider.messagesStream('____');
      debugPrint('=====================> Chat id is null');
      // log('0000000000000000000 0 ${widget.chat.targetId}111111 ${widget.chat.matchId}');
      final existingChatId = await chatProvider.getCurrentChatId();
      // log('000000000000000011111 ${existingChatId.toString()}');
      debugPrint('=====================> id: $existingChatId');
      if (existingChatId != null) {
        setState(() {
          chatId = existingChatId;
          messagesSteram = chatProvider.messagesStream(existingChatId);
        });
      }
    }
  }

  newChatId() async {
    final chatProvider = context.read<ChatProvider>();
    chatId ??= await chatProvider.createNewChat();
    chatId ??= await chatProvider.getCurrentChatId();

    log("===========>Initiating new chat==================");
    chatId = await chatProvider.initiateChat(
      widget.chat.targetId,
      widget.chat.matchId!,
    );
    chatProvider.inChatID = chatId;
    log('chat id _sendMessage() ${chatId! + _controller.text}');
    setState(() {});
    messagesSteram = chatProvider.messagesStream(chatId!);
  }

  Future<void> _sendMessage() async {
    log("===========>Trying send==================");
    final chatProvider = context.read<ChatProvider>();
    log(chatProvider.isBlocked.toString());
    log(widget.chat.isSent.toString());
    if ((chatProvider.isBlocked && !chatProvider.isSent) ||
        (chatProvider.isBlocked && chatProvider.isMutual)) {
      _controller.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      // showSnackBar("Blocked! You are unable to message this person.");
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          allowBackBtn: false,
          showCloseBtn: true,
          title: "Blocked",
          image: SvgPicture.asset(
            "assets/svg/dialog/minus_in_red_circle.svg",
            width: 150,
          ),
          desc: "You are unable to message this person.",
        ),
      );
      // await Future.delayed(Duration(milliseconds: 2000));
      // navigatorKey.currentState!.pop();
      return;
    }
    if (widget.chat.chatId != null) {
      chatidd = widget.chat.chatId!;
      chatProvider.inChatID = chatidd;
    } else {
      chatidd = chatId!;
    }
    chatProvider.sendMessage(chatidd, _controller.text.trim(), widget.chat);
    _controller.clear();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final chatProvider = context.read<ChatProvider>();

    log('build chatid ${chatId.toString()}');

    if (widget.chat.chatId == null && chatId == null) {
      newChatId();
    }
    if (widget.chat.chatId != null) {
      chatProvider.inChatID = widget.chat.chatId;
    }
    chatProvider.getTargetIsSent();

    /// [ Text field ] to send messages
    final textField = Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.03,
        right: size.width * 0.03,
        bottom: size.height * 0.02,
        top: size.height * 0.01,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height * 0.15),
        child: TextField(
          controller: _controller,
          textInputAction: TextInputAction.newline,
          maxLines: null,
          maxLength: 500,
          buildCounter:
              (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) => const SizedBox.shrink(),
          decoration: kInputDecoration.copyWith(
            hintText: 'Type a message',
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Consumer<ChatProvider>(
              builder: (_, ref, __) {
                // return ref.loadingState == LoadingState.loading
                //     ? Container(
                //         constraints: const BoxConstraints(
                //             maxHeight: 20, maxWidth: 20),
                //         padding: const EdgeInsets.all(5),
                //         child: const CircularProgressIndicator(
                //           strokeWidth: 2,
                //         ))
                //     :
                return IconButton(
                  onPressed: () {
                    /// [ Send message ] if text field is not empty
                    if (_controller.text.isNotEmpty) _sendMessage();
                  },
                  icon: SvgPicture.asset('assets/svg/chat/send.svg'),
                );
              },
            ),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ),
    );

    /// [ Messages ] stream builder
    final messagesStream = Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: messagesSteram,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return mainLoadingAnimationDark;
          } else if (snapshot.hasError) {
            debugPrint('Error: ${snapshot.error}');
            return const Text(
              'Something went wrong',
              textAlign: TextAlign.center,
            );
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            debugPrint(
              '=====================> Empty snapshot: ${snapshot.data!.docs}',
            );

            return NoMsgsDisplay(
              uid: widget.chat.targetId,
              userImage: widget.chat.image,
              userName: widget.chat.name,
            );
          }

          debugPrint(
            '=====================> last msg time: ${snapshot.data!.docs.last['time']}}',
          );

          final chatProvider = context.read<ChatProvider>();
          if (chatId != null) {
            chatProvider.clearUnread(chatId!);
            chatProvider.updateLastSeen(
              chatId!,
              snapshot.data!.docs.last['time'],
            );
            // chatProvider.lastMsgSeen =
            //     snapshot.data!.docs.last['time'].toDate();
          }

          final List<DocumentSnapshot> messages = snapshot.data!.docs;

          // messages.removeWhere((element) => element['isDeleted'] == 106);
          log(messages.last.id.toString());
          // chatProvider.lastChatId = messages.last.id;
          return MsgsList(
            msgs: messages,
            image: widget.chat.image,
            chatId:
                widget.chat.chatId ??
                chatId ??
                chatProvider.inChatID ??
                chatidd,
          );
        },
      ),
    );

    return BackgroundImage(
      child: Scaffold(
        appBar: ChatAppBar(chat: widget.chat, chatId: chatId),
        body: Column(
          children: [
            messagesStream,
            // chatpr.isBlocked && widget.chat.isSent
            //     ? Container(
            //         margin: EdgeInsets.symmetric(vertical: 10),
            //         padding:
            //             EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //         decoration: const BoxDecoration(
            //           color: AppColors.lightGrey,
            //           borderRadius: BorderRadius.all(Radius.circular(10)),
            //         ),
            //         child: const Text(
            //           'You blocked this Contact.',
            //           style: TextStyle(
            //             color: AppColors.black,
            //           ),
            //         ))
            //     // : Text('blocked')
            //     : const SizedBox.shrink(),
            textField,
          ],
        ),
      ),
    );
  }
}

/// Media menu
  // PortalTarget(
  //   visible: _isMenuOpen,
  //   anchor: const Aligned(
  //       follower: Alignment.bottomCenter,
  //       target: Alignment.topCenter),
  //   portalFollower: GestureDetector(
  //       behavior: HitTestBehavior.opaque,
  //       onTap: () => setState(() => _isMenuOpen = false),
  //       child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: addMediaBtns
  //               .map((e) => CustomIconBtn(
  //                     onTap:
  //                         e['onPressed'] as void Function(),
  //                     boxShadow: [
  //                       BoxShadow(
  //                           color: AppColors.black
  //                               .withOpacity(0.2),
  //                           blurRadius: 10,
  //                           offset: const Offset(0, 5))
  //                     ],
  //                     size: appWidth * 0.12,
  //                     padding:
  //                         EdgeInsets.all(appWidth * 0.035),
  //                     margin:
  //                         const EdgeInsets.only(bottom: 12),
  //                     child: SvgPicture.asset(
  //                         e['icon'] as String),
  //                   ))
  //               .toList())),
  //   child: CustomIconBtn(
  //       onTap: () =>
  //           setState(() => _isMenuOpen = !_isMenuOpen),
  //       size: appWidth * 0.12,
  //       padding: EdgeInsets.all(appWidth * 0.035),
  //       margin: EdgeInsets.zero,
  //       child: SvgPicture.asset(
  //           'assets/svg/chat/add_media/${_isMenuOpen ? 'add_media_close' : 'plus'}.svg')),
  // )