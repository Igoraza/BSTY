import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/theme/colors.dart';

class ReedemCoinsDetailCard extends StatelessWidget {
  const ReedemCoinsDetailCard({
    Key? key,
    required this.type,
    required this.date,
    required this.amount,
    required this.status,
    required this.img,
  }) : super(key: key);

  final int type;
  final String date;
  final String amount;
  final bool status;
  final String img;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    List trnType = ["Referral Reward", "Redeem Coins", "Subscription"];

    return Container(
        padding: EdgeInsets.all(appHeight * 0.02),
        margin: EdgeInsets.symmetric(
            vertical: appHeight * 0.008, horizontal: appWidth * 0.03),
        decoration: const BoxDecoration(
          color: AppColors.reedemBlue,
          borderRadius: BorderRadius.all(Radius.circular(60)),
        ),
        child: Row(children: [
          SvgPicture.asset(img),
          SizedBox(width: appWidth * 0.03),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trnType[type - 1],
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                /// [ TODO: Implement the time foramtting here ]
                SizedBox(height: appWidth * 0.01),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.grey,
                      ),
                )
              ]),
          const Spacer(),
          Text(amount,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: status == true
                      ? AppColors.reedemStatusGreen
                      : AppColors.alertRed)),
          SizedBox(width: appWidth * 0.01),
        ]));
  }
}
