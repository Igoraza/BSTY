import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bsty/common_widgets/custom_icon_btn.dart';
import 'package:bsty/common_widgets/loading_animations.dart';
import 'package:bsty/common_widgets/snapshot_error.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/redeem_transaction_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/referred_peeps_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/mep_list_drop_head.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/redeem_coins_detail_card.dart';
import 'package:bsty/features/settings/pages/manage_earnings/widgets/referred_peeps.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:provider/provider.dart';

class YourReferrals extends StatelessWidget {
  const YourReferrals({super.key});
  static const String routeName = '/your-referrals';

  @override
  Widget build(BuildContext context) {
    final transHistory = context.read<ReferredPeepsProvider>();

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
        title: const Text('Your referrals'),
      ),
      body: FutureBuilder<List<Referral>?>(
        future: transHistory.getReferrals(),
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
              const MepListDrop(leadTxt: 'Latest referrals'),
              Expanded(
                  child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemCount: 10,
                // snapshot.data!.length,
                itemBuilder: (context, index) {
                  final referrals = snapshot.data![1];
                  return ReferredPeeps(
                    numberOrMail: referrals.name!,
                    avatar: referrals.displayImage,
                    verified: false,
                  );
                },
              )
                  //  ListView.builder(
                  //     shrinkWrap: true,
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: referral.length,
                  //     itemBuilder: (context, index) {
                  //       return ReferredPeeps(
                  //         numberOrMail: referral[index].name!,
                  //         avatar: referral[index].displayImage,
                  //         verified: provider.getReferredPeeps[index].verified,
                  //       );
                  //     }),
                  ),
            ],
          );
        },
      ),
    );
  }
}
