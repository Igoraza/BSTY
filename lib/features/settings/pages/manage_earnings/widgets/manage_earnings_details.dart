import 'package:flutter/material.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/referrals_list.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/two_payout_requests.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/two_transaction_history.dart';

import '../../../../../utils/theme/colors.dart';
import 'help_disclaimer.dart';

class ManageEarningsDetails extends StatelessWidget {
  const ManageEarningsDetails({
    Key? key,
    this.mepModel,
  }) : super(key: key);
  final MepModel? mepModel;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    // double appWidth = MediaQuery.of(context).size.width;

    /// [ TODO: Need to find another method instead of calling 3 containers ]
    return Container(
      margin: EdgeInsets.only(top: appHeight * 0.02),
      padding: EdgeInsets.only(top: appHeight * 0.02),
      child: Container(
        margin: EdgeInsets.only(top: appHeight * 0.015),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(50),
          ),
        ),
        child: Column(
          children: [
            Container(margin: EdgeInsets.only(top: appHeight * 0.06)),
            if (mepModel != null &&
                mepModel?.transactions != null &&
                mepModel?.transactions != [])
              TwoTransactionHistory(
                transactions: mepModel?.transactions ?? [],
              ),
            if (mepModel != null &&
                mepModel?.payouts != null &&
                mepModel?.payouts != [])
              TwoPayoutReuests(
                payOuts: mepModel?.payouts ?? [],
              ),
            if (mepModel != null &&
                mepModel?.referrals != null &&
                mepModel?.referrals != [])
              ReferralsList(
                referral: mepModel?.referrals ?? [],
              ),
            const HelpDisclaimer()
          ],
        ),
      ),
    );
  }
}
