import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../../utils/theme/colors.dart';

class MediaPickIcon extends StatelessWidget {
  const MediaPickIcon({Key? key, this.onPressed}) : super(key: key);

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;

return GestureDetector(
  onTap: onPressed,
  child: DottedBorder(
    options: RectDottedBorderOptions(
      color: AppColors.titleBlue,
      // borderRadius: BorderRadius.circular(20),
      dashPattern: const [5, 5],
      strokeWidth: 1,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.toggleBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: appWidth * 0.15,
          height: appWidth * 0.15,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: AppColors.buttonBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: AppColors.white,
            size: appWidth * 0.08,
          ),
        ),
      ),
    ),
  ),
);

  }
}
