import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/theme/colors.dart';

class AvatarNameContact extends StatelessWidget {
  const AvatarNameContact({
    Key? key,
    required this.name,
    required this.image,
  }) : super(key: key);

  final String name;
  final String image;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
            margin: EdgeInsets.symmetric(horizontal: appWidth * 0.02),
            decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.grey,
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                      offset: Offset(1.0, 1.0))
                ],
                borderRadius: BorderRadius.all(Radius.circular(200))),
            child: SvgPicture.asset(image, height: appWidth * 0.15)),
        SizedBox(height: appHeight * 0.01),
        Text(name,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.disabled, fontWeight: FontWeight.normal),
            textAlign: TextAlign.center),
        GestureDetector(
            onTap: () {},
            child: Text('INVITE',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.blue, fontWeight: FontWeight.normal)))
      ],
    );
  }
}
