import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../models/enums.dart';
import '../../../services/call_provider.dart';

class VideoPreviews extends StatelessWidget {
  const VideoPreviews({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "8888888888888888888888888888\n1\n2\nBuild\n1\n2\n8888888888888888888888888888");
    final size = MediaQuery.of(context).size;

    return Expanded(
        child: Stack(alignment: Alignment.bottomRight, children: [
      /// Container for the [ Remote video ]
      Consumer<CallsProvider>(
          builder: (_, ref, __) => Container(
              color: AppColors.black,
              child: _remoteVideo(
                  ref.remoteUid, ref.agoraEngine, ref.channelName))),
      Consumer<CallsProvider>(builder: (_, ref, __) {
        return (ref.callStatus == CallStatus.ringing ||
                ref.callStatus == CallStatus.connected)
            ? Container(
                height: size.width * 0.4,
                width: size.width * 0.25,
                margin: EdgeInsets.all(size.width * 0.04),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.black,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(0, 0),
                          blurRadius: 10,
                          spreadRadius: 0)
                    ]),
                child: _localPreview(
                    ref.callStatus == CallStatus.ringing ||
                        ref.callStatus == CallStatus.connected,
                    ref.agoraEngine,
                    ref.isCameraOn))
            : const SizedBox.shrink();
      })
    ]));
  }
}

// Display local video preview
Widget _localPreview(bool isJoined, RtcEngine agoraEngine, bool isCameraOn) {
  return isJoined
      ? isCameraOn
          ? AgoraVideoView(
              controller: VideoViewController(
                  rtcEngine: agoraEngine, canvas: const VideoCanvas(uid: 0)))
          : const Center(
              child: FaIcon(FontAwesomeIcons.videoSlash,
                  color: AppColors.lighterGrey))
      : const SizedBox.shrink();
}

// Display remote user's video
Widget _remoteVideo(
    int? remoteUid, RtcEngine agoraEngine, String? channelName) {
  return remoteUid != null
      ? AgoraVideoView(
          controller: VideoViewController.remote(
              rtcEngine: agoraEngine,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(channelId: channelName)))
      : const Center(child: mainLoadingAnimationLight);
}
