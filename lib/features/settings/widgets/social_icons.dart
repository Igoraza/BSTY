import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/theme/colors.dart';

class SocialIcons extends StatelessWidget {
  const SocialIcons({
    Key? key,
    this.onTap,
    required this.name,
  }) : super(key: key);

  final Function()? onTap;
  final String name;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                    color: AppColors.blue,
                    blurRadius: 5.0,
                    spreadRadius: 0.0,
                    offset: Offset(0.3, 1.0))
              ],
              borderRadius: BorderRadius.all(Radius.circular(200))),
          child: SvgPicture.asset(
            'assets/svg/refer_earn/$name.svg',
            height: appHeight * 0.02,
          )),
    );
  }
}
