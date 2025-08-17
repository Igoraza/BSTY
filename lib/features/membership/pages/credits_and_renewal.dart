import 'package:flutter/material.dart';
import 'package:bsty/features/membership/widgets/change_plan.dart';

import '../../../common_widgets/background_image.dart';
import '../../../utils/theme/colors.dart';
import '../widgets/credits.dart';
import '../widgets/renewal.dart';

class CreditsAndRenewal extends StatelessWidget {
  const CreditsAndRenewal({Key? key}) : super(key: key);

  static const routeName = '/credits-and-renewal';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return BackgroundImage(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Membership'),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(mq.height * 0.04),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  labelColor: AppColors.deepOrange,
                  unselectedLabelColor: AppColors.black,
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  indicatorColor: AppColors.deepOrange,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Credits'),
                    Tab(text: 'Renewal'),
                    Tab(text: 'Change Plan')
                  ],
                ),
              ),
            ),
          ),
          body: const TabBarView(
            children: [
              Credits(),
              Renewal(),
              ChangePlan(),
            ],
          ),
        ),
      ),
    );
  }
}
