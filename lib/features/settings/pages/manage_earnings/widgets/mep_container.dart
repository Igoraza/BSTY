import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/theme/colors.dart';

class MEPCard extends StatelessWidget {
  const MEPCard({
    Key? key,
    required this.earned,
    // required this.expiring,
    required this.withdrawn,
    required this.withdrawable,
  }) : super(key: key);
  final int earned;
  // final int expiring;
  final int withdrawn;
  final int withdrawable;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    // final provider = Provider.of<MEPProvider>(context);

    return Container(
      // height: appHeight * 0.36,
      width: appWidth,
      margin: EdgeInsets.symmetric(
          horizontal: appWidth * 0.15, vertical: appHeight * 0.02),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(35)),
          gradient: AppColors.mepBlack,
          boxShadow: [
            BoxShadow(
                color: AppColors.black,
                offset: Offset(0, 5),
                blurRadius: 4,
                spreadRadius: 2)
          ]),
      child: Column(
        children: [
          SizedBox(height: appHeight * 0.04),
          Text('BSTY Earning Program',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: AppColors.white)),
          SizedBox(height: appHeight * 0.02),
          Text('Total Earned Coins',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.disabled, fontWeight: FontWeight.normal)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset('assets/svg/mep/small_coin.svg',
                height: appHeight * 0.02),
            SizedBox(width: appWidth * 0.03),
            Text(earned.toString(),
                //provider.getMepModel.totalEarnedCoins,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: AppColors.white, fontSize: 30)),
          ]),
          SizedBox(height: appHeight * 0.01),
          // Text('Expiring this Month',
          //     style: Theme.of(context).textTheme.titleMedium!.copyWith(
          //         color: AppColors.disabled, fontWeight: FontWeight.normal)),
          // Text("$expiring",
          //     // provider.getMepModel.expiringThisMonth,
          //     style: Theme.of(context)
          //         .textTheme
          //         .titleLarge!
          //         .copyWith(color: AppColors.white)),
          // SizedBox(height: appHeight * 0.01),
          Text('Withdrawn',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.disabled, fontWeight: FontWeight.normal)),
          Text("$withdrawn",
              // provider.getMepModel.withdrawn,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: AppColors.white)),
          SizedBox(height: appHeight * 0.01),
          Text('Withdrawable',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.disabled, fontWeight: FontWeight.normal)),
          Text(
            "$withdrawable",
            // provider.getMepModel.withdrawable,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.white,
                ),
          ),
          SizedBox(
            height: appHeight * 0.04,
          ),
        ],
      ),
    );
  }
}
