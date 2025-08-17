import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/features/chat_and_call/models/chat.dart';
import 'package:bsty/features/chat_and_call/services/call_provider.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:provider/provider.dart';

import 'custom_icon_btn.dart';
import 'stadium_button.dart';

class ConnectCallDialog extends StatelessWidget {
  const ConnectCallDialog({
    Key? key,
    this.image,
    this.title,
    this.desc,
    this.btnText,
    this.btnChild,
    this.btnColor,
    this.btnTxtClr,
    this.btnGradient,
    this.onPressed,
    this.showCloseBtn = true,
    this.allowBackBtn = true,
    required this.chat,
  }) : super(key: key);

  final Widget? image;
  final String? title;
  final String? desc;
  final String? btnText;
  final Widget? btnChild;
  final Color? btnTxtClr;
  final Color? btnColor;
  final LinearGradient? btnGradient;
  final VoidCallback? onPressed;
  final bool showCloseBtn;
  final bool allowBackBtn;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    // final caller = context.watch<CallsProvider>();

    return WillPopScope(
      onWillPop: () async => allowBackBtn,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCloseBtn) ...[
              CustomIconBtn(
                  onTap: () => Navigator.of(context).pop(),
                  bgColor: Colors.transparent,
                  size: screenW * 0.15,
                  child:
                      SvgPicture.asset('assets/svg/dialog/close_outlined.svg'))
            ],
            SimpleDialog(
                surfaceTintColor: AppColors.white,
                backgroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                alignment: Alignment.center,
                insetPadding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
                contentPadding: EdgeInsets.all(screenW * 0.06),
                children: [
                  title != null
                      ? Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontSize: 18),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  SvgPicture.asset('assets/svg/dialog/video_call.svg'),
                  const SizedBox(height: 10),
                  desc != null
                      ? Text(
                          desc!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.lightGrey),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: screenW * .58,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'I would like to have a conversation with ${chat.name} over a voice call',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.visible,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(fontSize: 12),
                            ),
                            Text(
                              'At any point, you have the freedom to change your decision',
                              textAlign: TextAlign.justify,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                      Consumer<CallsProvider>(
                        builder: (context, ref, child) {
                          return CupertinoSwitch(
                              value: ref.isCallAllowed,
                              activeColor: AppColors.deepOrange,
                              onChanged: (bool value) {
                                // setState(() {
                                ref.isCallAllowed = value;
                                log(ref.isCallAllowed.toString());
                              });
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(color: AppColors.lightGrey),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: screenW * .58,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "I would like to have a conversation with ${chat.name} over a video call",
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.visible,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(fontSize: 12),
                            ),
                            Text(
                              'At any point, you have the freedom to change your decision',
                              textAlign: TextAlign.justify,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                      Consumer<CallsProvider>(
                        builder: (context, ref, child) {
                          return CupertinoSwitch(
                              value: ref.isVideoAllowed,
                              activeColor: AppColors.deepOrange,
                              onChanged: (bool value) {
                                // setState(() {
                                ref.isVideoAllowed = value;
                                log(ref.isVideoAllowed.toString());
                              });
                        },
                      )
                      // CupertinoSwitch(
                      //     value: caller.isVideoAllowed,
                      //     activeColor: AppColors.deepOrange,
                      //     onChanged: (bool value) {
                      //       // setState(() {
                      //       caller.isCallAllowed = value;
                      //     }),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(color: AppColors.lightGrey),
                  const SizedBox(
                    height: 10,
                  ),
                  // btnText != null
                  // ?
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenW * .1),
                    child: StadiumButton(
                      text: 'Done',
                      // margin: EdgeInsets.symmetric(horizontal: screenW * .8),
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      bgColor: Colors.red,
                      textColor: AppColors.white,
                      gradient: btnGradient,
                      onPressed: onPressed,
                      child: btnChild,
                    ),
                  )
                  // : const SizedBox.shrink(),
                ])
          ]),
    );
  }
}
