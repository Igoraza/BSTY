import 'package:flutter/material.dart';

import '../../../../common_widgets/background_image.dart';
import '../manage_earnings/manage_earnings.dart';
import 'widgets/invite_friends.dart';
import 'widgets/manage_earnings_button.dart';
import 'widgets/refer_earn_container.dart';
import 'widgets/referral_code_container.dart';

class ReferEarnPage extends StatefulWidget {
  const ReferEarnPage({Key? key}) : super(key: key);

  static const String routeName = '/refer-earn';

  @override
  State<ReferEarnPage> createState() => _ReferEarnPageState();
}

class _ReferEarnPageState extends State<ReferEarnPage> {
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    return BackgroundImage(
      child: Scaffold(
          appBar: AppBar(title: const Text('Refer & Earn')),
          body: ListView(children: [
            SizedBox(height: appHeight * 0.03),
            const ReferEarnContainer(),
            SizedBox(height: appHeight * 0.01),
            ReferralCodeContainer(),
            SizedBox(height: appHeight * 0.03),
            ManageEarningsButton(onTap: () {
              debugPrint('Manage Earnings');
              Navigator.of(context).pushNamed(ManageEarningsPage.routeName);
            }),
            SizedBox(height: appHeight * 0.03),
            InviteFriends(),
            // SizedBox(height: appHeight * 0.03),
            // const SuggestedContacts(),
            SizedBox(height: appHeight * 0.03),
          ])),
    );
  }
}
