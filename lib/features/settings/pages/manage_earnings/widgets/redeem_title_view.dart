import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';

class RedeemTitleView extends StatelessWidget {
  const RedeemTitleView({
    Key? key,
    required this.title,
    this.buttonName = 'View All',
    this.onTap,
  }) : super(key: key);

  final String title;
  final String buttonName;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    return Container(
        color: AppColors.white,
        width: appWidth,
        padding: EdgeInsets.only(
          top: appHeight * 0.02,
          right: appWidth * 0.05,
          left: appWidth * 0.05,
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.disabled)),
          GestureDetector(
            onTap: onTap,
            child: Text(buttonName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.blue)),
          ),
        ]));
  }
}
