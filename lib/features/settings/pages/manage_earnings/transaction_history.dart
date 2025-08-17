import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bsty/common_widgets/custom_icon_btn.dart';
import 'package:bsty/common_widgets/loading_animations.dart';
import 'package:bsty/common_widgets/snapshot_error.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/redeem_transaction_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/mep_list_drop_head.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/redeem_coins_detail_card.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:provider/provider.dart';

import 'model/payout_request_model.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});
  static const String routeName = '/transaction-history';

  @override
  Widget build(BuildContext context) {
    final transHistory = context.read<RedeemTransactionProvider>();
    // final List transactionList = [
    //   PayoutRequestModel(
    //       transactionId: '1',
    //       transactionDate: 'Tue 10, 20:22 PM',
    //       transactionAmount: 'MK 200.00',
    //       transactionType: 'Subscription',
    //       transactionStatus: false),
    //   PayoutRequestModel(
    //       transactionId: '1',
    //       transactionDate: 'Tue 10, 20:22 PM',
    //       transactionAmount: '500 Coins',
    //       transactionType: 'Referral Reward',
    //       transactionStatus: true),
    //   PayoutRequestModel(
    //       transactionId: '2',
    //       transactionDate: 'Tue 10, 20:22 PM',
    //       transactionAmount: 'MK 320.00',
    //       transactionType: 'Redeem Coins',
    //       transactionStatus: false),
    // ];
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        // backgroundColor: AppColors.white,
        leading: CustomIconBtn(
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 2),
              color: AppColors.grey,
              blurRadius: 3.0,
              // blurStyle: BlurStyle.outer,
            ),
          ],
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Transactions'),
      ),
      body: FutureBuilder<List<Payout>?>(
        future: transHistory.getTransHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: mainLoadingAnimationDark,
            );
          } else if (snapshot.hasError) {
            String errorMsg = '';

            /// chieck if [ connection error ]
            if (snapshot.error.toString().contains('SocketException')) {
              errorMsg =
                  'Error retrieving calls.\nPlease check your internet connection';
            } else {
              errorMsg = 'Error retrieving calls. Try again later';
            }

            return SnapshotErrorWidget(errorMsg);
          } else if (snapshot.data == null || snapshot.data == []) {
            return Center(
              child: Text("No transctions yet",
                  style: Theme.of(context).textTheme.bodyLarge!),
            );
          }

          return Column(
            children: [
              const MepListDrop(leadTxt: 'Latest Transactions'),
              Expanded(
                child: ListView.builder(
                  physics: const RangeMaintainingScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final transData = snapshot.data![index];

                    DateTime tempDate = DateFormat("yyyy-MM-dd hh:mm")
                        .parse(transData.created!);

                    final String date =
                        DateFormat.MMMEd().add_jm().format(tempDate);

                    return ReedemCoinsDetailCard(
                      date: date,
                      amount: "${transData.amount}",
                      type: transData.trnType!,
                      status: transData.trnType == 3 ? false : true,
                      img: transData.trnType == 3
                          ? "assets/svg/mep/shopping.svg"
                          : 'assets/svg/mep/coin.svg',
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
