import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/background_image.dart';
import '../../../../../common_widgets/custom_icon_btn.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/call.dart';
import '../../../models/enums.dart';
import '../../../services/call_provider.dart';
import '../widgets/video_previews.dart';

final String? appId = dotenv.env['AGORA_APP_ID'];

class OnGoingCallPage extends StatefulWidget {
  const OnGoingCallPage({
    Key? key,
    this.targetUser,
    required this.callId,
    required this.isIncoming,
    required this.isVideo,
    this.targetUserImg,
    this.targetUserName,
    this.targetUserId,
    required this.isOutgoing,
    this.targetPushId,
  }) : super(key: key);

  final CallUser? targetUser;
  final int callId;
  final bool isIncoming;
  final bool isVideo;
  final String? targetUserImg;
  final String? targetUserName;
  final int? targetUserId;
  final bool? isOutgoing;
  final String? targetPushId;

  static const routeName = '/ongoing_call';

  @override
  State<OnGoingCallPage> createState() => _OnGoingCallPageState();
}

class _OnGoingCallPageState extends State<OnGoingCallPage> {
  final _timerValueNotifier = ValueNotifier<int>(0);
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  late bool _isVideo;
  Timer? counterTime;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.isVideo;
    final callsProvider = context.read<CallsProvider>();
    callsProvider.callContext = context;
    callsProvider.initEngine(_isVideo).then((value) {
      log("Target ------------ push id :: ${widget.targetPushId}");
      if (widget.isIncoming) {
        callsProvider.answerCall(
          context,
          callId: widget.callId,
          isVideo: _isVideo,
        );
      } else {
        
        callsProvider.makeCall(
          context,
          uid: widget.targetUser?.id ?? widget.targetUserId ?? 0,
          isVideo: _isVideo,
          userName:
              widget.targetUser?.name ?? widget.targetUserName ?? 'Unknown',
          userImage: widget.targetUserImg!,
          targetPushId: widget.targetPushId!,
        );
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_stopwatch.elapsedMilliseconds >= 1000) {
        debugPrint('============Timer: ${DateTime.now()}');
        _timerValueNotifier.value++;
        _stopwatch.reset();
      }
    });

    _stopwatch.start();
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final math.Random _rnd = math.Random();

  String getRandomString(int length) => String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ),
  );

  void sendCallCredits() async {
    final callPro = context.read<CallsProvider>();
    // String random = getRandomString(10);
    // log('11111111111 message121212');
    // await callPro.sendCallCredits(random, _isVideo ? 2 : 1);
    counterTime = Timer.periodic(const Duration(minutes: 1), (t) async {
      String random = getRandomString(10);
      log('11111111111 $random');
      await callPro.sendCallCredits(random, _isVideo ? 2 : 1);
      log('11111111 time is ${t.tick}');
    });
  }

  @override
  void dispose() async {
    _timer?.cancel();
    _stopwatch.stop();
    counterTime?.cancel();
    _timerValueNotifier.dispose();
    // context.read<CallsProvider>().leaveChannel(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;
    final callsProvider = context.read<CallsProvider>();

    final callerPicture = Expanded(
      child: Container(
        // height: appWidth * 0.85,
        margin: EdgeInsets.symmetric(horizontal: appWidth * 0.1),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: CachedNetworkImage(
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          imageUrl:
              widget.targetUser?.displayImage ?? widget.targetUserImg ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const SpinKitPulse(color: AppColors.lightGrey),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.person, size: 100, color: AppColors.white),
          ),
        ),
      ),
    );

    final audioCallActions = Consumer<CallsProvider>(
      builder: (_, ref, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // CustomIconBtn(
            //     onTap: () {
            //       // context.read<CallsProvider>().sendCallNotification(
            //       //     name: 'John',
            //       //     image:
            //       //         'https://cynbus.sgp1.digitaloceanspaces.com/metfie/media/profile/f0212092144cxowhj.jpg');
            //       callsProvider.switchToVideo().then((success) {
            //         if (success) {
            //           setState(() => _isVideo = true);
            //         }
            //       });
            //     },
            //     padding: EdgeInsets.all(appWidth * 0.03),
            //     size: appWidth * 0.12,
            //     child: SvgPicture.asset('assets/svg/chat/video_enabled.svg')),
            CustomIconBtn(
              onTap: () => ref.toggleSpeaker(),
              padding: EdgeInsets.all(appWidth * 0.03),
              size: appWidth * 0.12,
              child: Opacity(
                opacity: ref.isSpeaker ? 1 : 0.5,
                child: SvgPicture.asset('assets/svg/chat/speaker_enabled.svg'),
              ),
            ),
            CustomIconBtn(
              onTap: () => ref.toggleMute(),
              padding: EdgeInsets.all(appWidth * 0.03),
              size: appWidth * 0.12,
              child: Opacity(
                opacity: ref.isMuted ? 0.5 : 1,
                child: SvgPicture.asset('assets/svg/chat/mic_enabled.svg'),
              ),
            ),
          ],
        );
      },
    );

    final videoCallActions = Consumer<CallsProvider>(
      builder: (_, ref, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // CustomIconBtn(
            //     onTap: () => ref.toggleCamera(),
            //     padding: EdgeInsets.zero,
            //     size: appWidth * 0.12,
            //     child: Opacity(
            //         opacity: ref.isCameraOn ? 1 : 0.5,
            //         child:
            //             SvgPicture.asset('assets/svg/chat/show_hide_video.svg'))),
            CustomIconBtn(
              onTap: () => ref.toggleMute(),
              padding: EdgeInsets.zero,
              size: appWidth * 0.12,
              bgColor: Colors.transparent,
              child: Opacity(
                opacity: ref.isMuted ? 0.5 : 1,
                child: SvgPicture.asset('assets/svg/chat/mic_enabled.svg'),
              ),
            ),
            CustomIconBtn(
              // switch camera
              onTap: () => ref.agoraEngine.switchCamera(),
              padding: EdgeInsets.zero,
              size: appWidth * 0.12,
              child: SvgPicture.asset('assets/svg/chat/switch_camer.svg'),
            ),
            CustomIconBtn(
              onTap: () {
                // _timer.cancel();
                ref.agoraEngine.leaveChannel();
                callsProvider.leaveChannel();
              },
              padding: EdgeInsets.zero,
              size: appWidth * 0.12,
              child: SvgPicture.asset('assets/svg/chat/end_call_video.svg'),
            ),
          ],
        );
      },
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: BackgroundImage(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: appHeight * 0.04),
                Text(
                  widget.targetUser?.name ?? widget.targetUserName ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: appHeight * 0.01),
                Consumer<CallsProvider>(
                  builder: (_, ref, __) {
                    log('----------------${ref.callStatus}');
                    // ref.callStatus = CallStatus.dialing;
                    String text = 'Dialing...';
                    if (ref.callStatus == CallStatus.dialing) {
                      text = 'Dialing...';
                    } else if (ref.callStatus == CallStatus.ringing) {
                      text = 'Ringing...';
                    } else if (ref.callStatus == CallStatus.connected) {
                      _startTimer();
                      log('11111111111 ${widget.isOutgoing.toString()}');
                      if (widget.isOutgoing != null &&
                          widget.isOutgoing == true) {
                        log('1111111111 ongoing11111111111111');
                        sendCallCredits();
                      }
                      return ValueListenableBuilder(
                        valueListenable: _timerValueNotifier,
                        builder: (_, val, __) => Text(
                          '${val ~/ 60}:${val % 60}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.darkBlue),
                        ),
                      );
                    } else if (ref.callStatus == CallStatus.ended) {
                      // text = 'Call Ended';
                    }
                    return Text(
                      text,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),

                SizedBox(height: appHeight * (_isVideo ? 0.03 : 0.08)),

                /// Show [video preview] if video call [else] show [caller picture]
                _isVideo ? const VideoPreviews() : callerPicture,

                /// shown [Big end call button] only if [audio call]
                if (!_isVideo) ...[
                  SizedBox(height: appHeight * 0.06),
                  CustomIconBtn(
                    onTap: () {
                      // callsProvider.agoraEngine.leaveChannel();
                      callsProvider.leaveChannel();
                    },
                    size: appWidth * 0.3,
                    child: SvgPicture.asset('assets/svg/chat/end_call.svg'),
                  ),
                ],

                SizedBox(height: appHeight * 0.01),
                _isVideo ? videoCallActions : audioCallActions,
                SizedBox(height: appHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
