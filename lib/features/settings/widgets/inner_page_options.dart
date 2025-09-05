import 'package:flutter/material.dart';

import '../../../utils/theme/colors.dart';

class InnerPageOptions extends StatelessWidget {
  const InnerPageOptions({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: appWidth * 0.03,
              vertical: appHeight * 0.02,
            ),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: appWidth * 0.02,
              vertical: appHeight * 0.02,
            ),
            child: Row(
              children: [
                /// [ Todo: need to change the options to listed options ]
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.disabled,
                  size: appWidth * 0.04,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
