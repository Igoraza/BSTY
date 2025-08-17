import 'package:flutter/material.dart';

import '../../../../../common_widgets/custom_icon_btn.dart';
import '../../../../../utils/theme/colors.dart';

class ChatScreenAlertDialog extends StatelessWidget {
  const ChatScreenAlertDialog(
      {super.key, this.title, this.content, this.onConfirm});

  final String? title;
  final String? content;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(50), bottomLeft: Radius.circular(50)),
      ),
      title: Text(title ?? 'Confirm?', style: textTheme.headlineMedium),
      content: Text(content ?? 'Are you sure?', style: textTheme.bodyLarge),
      actions: [
        CustomIconBtn(
            onTap: () => Navigator.of(context).pop(),
            size: 50,
            margin: EdgeInsets.zero,
            // bgColor: AppColors.alertRed,
            gradient: AppColors.redVertical,
            child: const Icon(Icons.close, color: AppColors.white)),
        CustomIconBtn(
            onTap: () {
              onConfirm?.call();
              Navigator.of(context).pop();
            },
            size: 50,
            margin: EdgeInsets.zero,
            gradient: AppColors.buttonBlueVertical,
            child: const Icon(Icons.check, color: AppColors.white)),
      ],
    );
  }
}
