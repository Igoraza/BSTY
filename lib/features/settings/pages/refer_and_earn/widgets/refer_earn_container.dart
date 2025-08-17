import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/theme/colors.dart';

class ReferEarnContainer extends StatelessWidget {
  const ReferEarnContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SvgPicture.asset('assets/svg/refer_earn/sheild.svg'),
        SizedBox(height: appHeight * 0.02),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: appWidth * 0.02),
                padding: EdgeInsets.symmetric(horizontal: appWidth * 0.05),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: appHeight * 0.02),
                      Text('Refer and Earn',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .merge(const TextStyle(
                                color: AppColors.toggleBlue,
                                fontSize: 30,
                              )),
                          textAlign: TextAlign.center),
                      SizedBox(height: appHeight * 0.01),
                      Text(
                          'Share this code with your friends and earn exciting rewards!',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: AppColors.disabled,
                                  fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center),
                      SizedBox(height: appHeight * 0.02),
                    ]))),
      ],
    );
  }
}
