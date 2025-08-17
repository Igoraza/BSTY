import 'package:flutter/material.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/payout_request_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/theme/colors.dart';

class BottomSheetButton extends StatelessWidget {
  const BottomSheetButton({
    Key? key,
    required this.buttonName,
    required this.onTap,
  }) : super(key: key);

  final String buttonName;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Consumer<PayoutRequestProvider>(builder: (context, pro, _) {
        return Container(
          padding: EdgeInsets.symmetric(
              vertical: appHeight * 0.02, horizontal: appWidth * 0.1),
          width: appWidth,
          decoration: const BoxDecoration(
              gradient: AppColors.buttonBlue,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          margin: EdgeInsets.symmetric(horizontal: appWidth * 0.1),
          child: buttonName == 'Submit'
              ? pro.getLoading
                  ? SizedBox(
                      height: 25,
                      width: 25,
                      child: FittedBox(
                        child: Center(
                            child: CircularProgressIndicator(
                          color: AppColors.white,
                        )),
                      ),
                    )
                  : Text(
                      buttonName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: AppColors.white),
                    )
              : Text(
                  buttonName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.white),
                ),
        );
      }),
    );
  }
}
