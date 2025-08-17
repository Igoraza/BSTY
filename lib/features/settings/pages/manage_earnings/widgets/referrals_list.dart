import 'package:flutter/material.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';
import 'package:bsty/features/settings/pages/manage_earnings/your_referrals.dart';

import 'redeem_title_view.dart';
import 'referred_peeps.dart';

class ReferralsList extends StatelessWidget {
  const ReferralsList({
    Key? key,
    required this.referral,
  }) : super(key: key);
  final List<Referral> referral;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    // final size = MediaQuery.of(context).size;
    // final provider = Provider.of<ReferredPeepsProvider>(context);

    return Column(
      children: [
        RedeemTitleView(
            title: 'Your Referrals',
            buttonName: 'View All',
            onTap: () {
              debugPrint('Remind All Pending Button');
              debugPrint('Payout Requests View All');
              Navigator.pushNamed(context, YourReferrals.routeName);
            }),
        SizedBox(height: appHeight * 0.02),
        SizedBox(
          height: 100,
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: referral.length,
              itemBuilder: (context, index) {
                return ReferredPeeps(
                  numberOrMail: referral[index].name!,
                  avatar: referral[index].displayImage,
                  verified: false,
                );
              }),
        ),
        // ReferredPeeps(
        //   numberOrMail: provider.getReferredPeeps[0].numberOrMail,
        //   avatar: provider.getReferredPeeps[0].avatar,
        //   verified: provider.getReferredPeeps[0].verified,
        // ),
      ],
    );
  }
}
