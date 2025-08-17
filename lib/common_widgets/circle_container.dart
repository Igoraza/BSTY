import 'package:flutter/material.dart';

/// This is circle is used mostly to add ripple effect
class CircleContainer extends StatelessWidget {
  const CircleContainer({
    Key? key,
    required this.size,
    this.color,
    this.opacity = 1,
    this.gradient,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.alignment,
    this.transform,
  }) : super(key: key);

  final double size;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final double? opacity;
  final LinearGradient? gradient;
  final AlignmentGeometry? alignment;
  final Matrix4? transform;

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: opacity!,
        child: Container(
            width: size,
            height: size,
            constraints: BoxConstraints(minWidth: size, minHeight: size),
            alignment: alignment,
            transform: transform,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                gradient: color != null ? null : gradient,
                border: Border.all(color: borderColor!, width: borderWidth!))));
  }
}
