import 'package:flutter/material.dart';

import '../utils/theme/colors.dart';

class BoxedText extends StatelessWidget {
  const BoxedText({
    Key? key,
    this.text,
    this.bgColor,
    this.textColor = AppColors.white,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.margin = const EdgeInsets.all(0),
    this.fontSize = 14,
  }) : super(key: key);

  final String? text;
  final Color? bgColor;
  final Color? textColor;
  final int? fontSize;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        margin: margin,
        decoration: ShapeDecoration(
            color: bgColor ?? AppColors.black.withOpacity(0.5),
            shape: const StadiumBorder()),

        /// if text is not null], then show [Text]. [Otherwise], show [child]
        child: text != null
            ? Text(text!,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: textColor, fontSize: fontSize?.toDouble()))
            : child);
  }
}
