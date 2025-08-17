import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';
import 'package:bsty/features/settings/pages/manage_earnings/redemption_request.dart';
import 'package:provider/provider.dart';

import '../provider/payout_request_provider.dart';
import 'redeem_coins_detail_card.dart';
import 'redeem_title_view.dart';

class TwoPayoutReuests extends StatelessWidget {
  const TwoPayoutReuests({
    Key? key,
    required this.payOuts,
  }) : super(key: key);
  final List<Payout?> payOuts;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    // final provider = Provider.of<PayoutRequestProvider>(context);

    return Column(
      children: [
        RedeemTitleView(
            title: 'Payout Requests',
            onTap: () {
              debugPrint('Payout Requests View All');
              Navigator.pushNamed(context, RedemptionRequest.routeName);
            }),
        SizedBox(height: appHeight * 0.01),
        ListView.builder(
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: payOuts.length,
            itemBuilder: (context, index) {
              DateTime tempDate = DateFormat("yyyy-MM-dd hh:mm")
                  .parse(payOuts[index]!.created!);

              final String date = DateFormat.MMMEd().add_jm().format(tempDate);
              return ReedemCoinsDetailCard(
                date: date,
                amount: "${payOuts[index]!.amount}",
                //  provider.getPayoutRequests[0].transactionAmount,
                type: payOuts[index]!.trnType ?? 1,
                status: payOuts[index]!.trnType == 3 ? false : true,
                img: payOuts[index]!.trnType == 3
                    ? "assets/svg/mep/shopping.svg"
                    : 'assets/svg/mep/coin.svg',
              );
            }),
      ],
    );
  }
}
