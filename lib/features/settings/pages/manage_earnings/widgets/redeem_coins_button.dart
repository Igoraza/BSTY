import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';

class RedeemCoinsButton extends StatelessWidget {
  const RedeemCoinsButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: appWidth * 0.75,
          // height: appHeight * 0.13,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.disabled,
                    offset: Offset(0, 5),
                    blurRadius: 4,
                    spreadRadius: 0)
              ]),
          child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  gradient: AppColors.redeemCoinsBlue,
                  borderRadius: BorderRadius.circular(30)),
              child: Center(
                  child: Text('REDEEM COINS',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold))))),
    );
  }
}
