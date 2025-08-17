import 'package:flutter/material.dart';

import '../../../utils/theme/colors.dart';

class NotifsAppBar extends StatelessWidget {
  const NotifsAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const ShapeDecoration(
                  color: AppColors.white, shape: CircleBorder()),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.black))),
      title: const Text(
        'Notifications',
        style: TextStyle(color: AppColors.white),
      ),
    );
  }
}
