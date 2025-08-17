import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';

class ManageEarningsButton extends StatelessWidget {
  const ManageEarningsButton({Key? key, required this.onTap}) : super(key: key);

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: appWidth * 0.2),
        decoration: BoxDecoration(
            gradient: AppColors.orangeYelloH,
            borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Manage Earnings',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.white, fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }
}
