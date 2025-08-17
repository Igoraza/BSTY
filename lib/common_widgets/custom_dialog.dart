import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/utils/theme/colors.dart';

import 'custom_icon_btn.dart';
import 'stadium_button.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
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
    this.subTitle,
    this.btnPadding,
  }) : super(key: key);

  final Widget? image;
  final String? title;
  final String? subTitle;
  final String? desc;
  final String? btnText;
  final Widget? btnChild;
  final Color? btnTxtClr;
  final Color? btnColor;
  final LinearGradient? btnGradient;
  final EdgeInsetsGeometry? btnPadding;
  final VoidCallback? onPressed;
  final bool showCloseBtn;
  final bool allowBackBtn;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

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
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                alignment: Alignment.center,
                insetPadding: EdgeInsets.symmetric(horizontal: screenW * 0.05),
                contentPadding: EdgeInsets.all(screenW * 0.1),
                children: [
                  image ?? const SizedBox.shrink(),
                  title != null
                      ? Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  subTitle != null
                      ? Text(
                          subTitle!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 17,
                                color: AppColors.grey,
                              ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  desc != null
                      ? Text(
                          desc!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 20),
                  btnText != null
                      ? StadiumButton(
                          text: btnText,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          bgColor: btnColor,
                          padding: btnPadding,
                          // textColor: btnColor,
                          gradient: btnGradient,
                          onPressed: onPressed,
                          child: btnChild,
                        )
                      : const SizedBox.shrink(),
                ])
          ]),
    );
  }
}
