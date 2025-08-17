import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';

class BottomSheetTitleSubtitle extends StatelessWidget {
  const BottomSheetTitleSubtitle({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: appWidth * 0.2, vertical: appHeight * 0.01),
          child: Text(
            subtitle ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.disabled,
                ),
          ),
        ),
        SizedBox(height: appHeight * 0.02),
      ],
    );
  }
}
