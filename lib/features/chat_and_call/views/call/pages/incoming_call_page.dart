import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../common_widgets/background_image.dart';
import '../../../../../common_widgets/custom_icon_btn.dart';
import '../../../../../common_widgets/ripples.dart';
import '../../../../../utils/theme/colors.dart';
import 'ongoing_call_page.dart';

class IncomingCall extends StatelessWidget {
  const IncomingCall(
      {Key? key,
      required this.callId,
      required this.isVideo,
      this.targetUserImage,
      this.targetUserName = 'Unknown'})
      : super(key: key);

  final int callId;
  final bool isVideo;
  final String? targetUserImage;
  final String targetUserName;

  static const routeName = '/incoming_call';

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    final callActions =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      CustomIconBtn(
          onTap: () => Navigator.of(context).pushReplacementNamed(
                OnGoingCallPage.routeName,
                arguments: {
                  'callId': callId,
                  'isIncoming': true,
                  'isVideo': isVideo,
                  'user_image': targetUserImage ?? '',
                  'user_name': targetUserName
                },
              ),
          size: appWidth * 0.3,
          child: SvgPicture.asset(
              'assets/svg/chat/${isVideo ? 'accept_video_call' : 'accept_call'}.svg')),
      CustomIconBtn(
          onTap: () => Navigator.of(context).pop(),
          size: appWidth * 0.3,
          child: SvgPicture.asset('assets/svg/chat/reject_call.svg'))
    ]);

    return BackgroundImage(
        child: Scaffold(
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: appWidth * 0.1),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(targetUserName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.darkBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: appHeight * 0.01),
                      const Text('Calling...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.disabled,
                            fontSize: 18,
                          )),
                      SizedBox(height: appHeight * 0.15),
                      Ripples(
                          color: AppColors.purple,
                          child: Container(
                              width: appWidth * 0.3,
                              height: appWidth * 0.3,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: targetUserImage == null
                                  ? const FaIcon(FontAwesomeIcons.solidUser,
                                      color: AppColors.lightGrey, size: 50)
                                  : CachedNetworkImage(
                                      fadeInDuration: Duration.zero,
                                      fadeOutDuration: Duration.zero,
                                      width: double.infinity,
                                      height: double.infinity,
                                      imageUrl: targetUserImage!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const SpinKitPulse(
                                              color: AppColors.lightGrey),
                                      errorWidget: (context, url, error) =>
                                          const SpinKitPulse(
                                              color: AppColors.lightGrey)))),
                      SizedBox(height: appHeight * 0.15),
                      callActions,
                    ]))));
  }
}
