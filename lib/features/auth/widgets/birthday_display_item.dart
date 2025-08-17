import 'package:flutter/material.dart';

import '../../../utils/theme/colors.dart';

class BirthdayDisplayItem extends StatelessWidget {
  final String? title;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;

  const BirthdayDisplayItem(
      {Key? key, required this.title, this.onPressed, this.child, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            padding: padding ?? const EdgeInsets.all(20.0),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.borderBlue))),
        child: title != null
            ? Text(title!, style: Theme.of(context).textTheme.titleMedium)
            : child!);
  }
}
