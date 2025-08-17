import 'package:flutter/material.dart';

class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({
    Key? key,
    this.onPressed,
    this.text = 'Primary Button',
    this.color,
    this.gradient,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.fromLTRB(32, 16, 32, 16),
    this.constraints,
    this.fontsize = 16,
    this.width,
  }) : super(key: key);

  final String text;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final LinearGradient? gradient;
  final Color textColor;
  final VoidCallback? onPressed;
  final BoxConstraints? constraints;
  final double? fontsize;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
            width: width,
            padding: padding,
            constraints: constraints,
            decoration: ShapeDecoration(
                gradient: gradient, color: color, shape: const StadiumBorder()),
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textColor,
                    fontSize: fontsize,
                    fontWeight: FontWeight.bold))));
  }
}
