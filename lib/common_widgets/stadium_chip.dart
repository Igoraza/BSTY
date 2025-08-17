import 'package:flutter/material.dart';

import '../utils/theme/colors.dart';

class SadiumChip extends StatelessWidget {
  const SadiumChip({
    super.key,
    required this.text,
    this.bgColor = AppColors.orange,
    this.textColor = AppColors.white,
    this.fontWeight = FontWeight.bold,
  });

  final String text;
  final Color? bgColor;
  final Color? textColor;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: bgColor,
      label: Text(text,
          style: TextStyle(
            color: textColor,
            fontWeight: fontWeight,
            fontSize: 14,
          )),
    );
  }
}
