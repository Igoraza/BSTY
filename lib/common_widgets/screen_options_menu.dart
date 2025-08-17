// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:bsty/utils/theme/colors.dart';

class ScreenOptionsMenu extends StatelessWidget {
  final void Function()? onPressed;
  const ScreenOptionsMenu({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // void showConfirmDialog({
    //   String? title,
    //   String? content,
    //   VoidCallback? onConfirm,
    // }) =>
    //     showDialog(
    //         context: navigatorKey.currentContext!,
    //         builder: (context) => ChatScreenAlertDialog(
    //               title: title,
    //               content: content,
    //               onConfirm: onConfirm,
    //             ));

    final options = ['Cancel order'];

    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      alignment: Alignment.topRight,
      shape: const RoundedRectangleBorder(
          // borderRadius: BorderRadius.circular(10),
          ),
      insetPadding: EdgeInsets.only(
        right: 30,
        top: 30,
        bottom: 30,
        left: size.width * 0.5,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        height: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: List.generate(
            options.length,
            (index) => InkWell(
              onTap: onPressed,
              child: Text(options[index]),
            ),
          ),
        ),
      ),
    );
  }
}
