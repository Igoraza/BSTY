import 'package:flutter/material.dart';

import '../utils/theme/colors.dart';

class StadiumButton extends StatelessWidget {
  const StadiumButton({
    Key? key,
    this.text,
    this.bgColor,
    this.gradient,
    this.child,
    this.onPressed,
    this.textColor,
    this.padding,
    this.margin,
    this.visualDensity,
    this.boxShadow,
    this.height,
    this.width,
  }) : super(key: key);

  final String? text;
  final Widget? child;
  final Color? bgColor;
  final Color? textColor;
  final LinearGradient? gradient;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VisualDensity? visualDensity;
  final List<BoxShadow>? boxShadow;
  final double? height, width;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(50),
        boxShadow: boxShadow,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          visualDensity: visualDensity ?? VisualDensity.adaptivePlatformDensity,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: screenW * 0.2,
                vertical: screenW * 0.03,
              ),
          splashFactory: NoSplash.splashFactory,
          foregroundColor: textColor ?? AppColors.white,
          textStyle: TextStyle(fontWeight: FontWeight.w700),
        ),
        child: text != null
            ? Text(
                text!,
                style: const TextStyle(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              )
            : child ?? Container(),
      ),
    );
  }
}
