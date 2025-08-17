import 'package:flutter/material.dart';

import '../utils/theme/colors.dart';
import 'custom_icon_btn.dart';

class CustomBackBtn extends StatelessWidget {
  const CustomBackBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomIconBtn(
        onTap: () => Navigator.of(context).pop(),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
        child: const Icon(Icons.arrow_back_rounded));
  }
}
