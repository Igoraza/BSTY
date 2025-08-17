import 'package:flutter/material.dart';

import '../utils/theme/colors.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    Key? key,
    this.text = '',
    this.texColor,
    this.bgColor,
    this.onpressed,
    this.isSelected = false,
  }) : super(key: key);

  final String text;
  final Color? texColor;
  final Color? bgColor;
  final bool isSelected;
  final Function()? onpressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(16),
        gradient: bgColor != null
            ? null
            : isSelected
                ? AppColors.buttonBlueVertical
                : null,
        border: Border.all(
          color: isSelected ? Colors.transparent : AppColors.borderBlue,
        ),
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: isSelected ? AppColors.white : AppColors.black)),
    );
  }
}
