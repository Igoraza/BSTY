import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';
import 'package:bsty/features/settings/pages/manage_earnings/transaction_history.dart';
import 'package:provider/provider.dart';

import '../provider/redeem_transaction_provider.dart';
import 'redeem_coins_detail_card.dart';
import 'redeem_title_view.dart';

class TwoTransactionHistory extends StatelessWidget {
  const TwoTransactionHistory({Key? key, required this.transactions})
      : super(key: key);
  final List<Payout?> transactions;
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    // final provider = Provider.of<RedeemTransactionProvider>(context);

    return Column(
      children: [
        RedeemTitleView(
            title: 'Transaction History',
            onTap: () {
              Navigator.pushNamed(context, TransactionHistory.routeName);
            }),
        SizedBox(height: appHeight * 0.01),
        ListView.builder(
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              DateTime tempDate = DateFormat("yyyy-MM-dd hh:mm")
                  .parse(transactions[index]!.created!);

              final String date = DateFormat.MMMEd().add_jm().format(tempDate);

              return ReedemCoinsDetailCard(
                date: date,
                amount: '${transactions[index]!.amount}',
                //  provider.getRedeemTransactions[0].transactionAmount,
                type: transactions[index]!.trnType ?? 0,
                status: transactions[index]!.trnType == 3 ? false : true,
                img: transactions[index]!.trnType == 3
                    ? "assets/svg/mep/shopping.svg"
                    : 'assets/svg/mep/coin.svg',
              );
            }),
        // ReedemCoinsDetailCard(
        //   date: provider.getRedeemTransactions[1].transactionDate,
        //   amount: '0',
        //   //  provider.getRedeemTransactions[1].transactionAmount,
        //   type: provider.getRedeemTransactions[1].transactionType,
        //   status: provider.getRedeemTransactions[1].transactionStatus,
        //   img: "assets/svg/mep/shopping.svg",
        // ),
        SizedBox(height: appHeight * 0.01),
      ],
    );
  }
}
