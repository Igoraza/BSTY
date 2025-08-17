import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/theme/colors.dart';

class InnerPageButtons extends StatelessWidget {
  const InnerPageButtons({
    Key? key,
    required this.name,
    required this.title,
  }) : super(key: key);

  final String name;
  final String title;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: appWidth * 0.03, vertical: appHeight * 0.01),
        child: Row(children: [
          SvgPicture.asset('assets/svg/settings/$name.svg'),
          SizedBox(width: appWidth * 0.02),
          Text(title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.black,
                  )),
        ]));
  }
}
