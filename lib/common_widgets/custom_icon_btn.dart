import 'package:flutter/material.dart';

import '../utils/theme/colors.dart';

class CustomIconBtn extends StatelessWidget {
  const CustomIconBtn({
    Key? key,
    required this.child,
    this.onTap,
    this.boxShadow,
    this.bgColor = AppColors.white,
    this.gradient,
    this.size = 40,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Color? bgColor;
  final LinearGradient? gradient;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
            margin: margin,
            width: size,
            height: size,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                boxShadow: boxShadow,
                gradient: gradient),
            child: Padding(padding: padding!, child: child)));
  }
}
