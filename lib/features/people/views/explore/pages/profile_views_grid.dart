import 'package:flutter/material.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../services/people_provider.dart';
import '../widgets/profile_view_card.dart';

class ProfileViewsGrid extends StatelessWidget {
  const ProfileViewsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    // final screenH = MediaQuery.of(context).size.height;
    final provider = context.read<PeopleProvider>();
    final authPro = context.read<AuthProvider>();

    // final userPlan = Hive.box('user').get('plan') ?? 1;
    // final planExpired = Hive.box('user').get('plan_expired') ?? true;

    // if (userPlan > 2 && !planExpired) {
    return FutureBuilder(
        future: provider.fetchProfileViews(context),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return mainLoadingAnimationDark;
          }
          if (snapshot.hasError) {
            String errorMsg = '';

            // chieck if connection error
            if (snapshot.error.toString().contains('SocketException')) {
              errorMsg =
                  'Error retrieving profiles.\nPlease check your internet connection';
            } else {
              errorMsg = 'Error retrieving profiles. Try again later';
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 50, color: AppColors.black),
                const SizedBox(height: 10, width: double.infinity),
                Text(errorMsg,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ],
            );
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Center(
              child: Text(
                'No profiles found',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          }

          return GridView.builder(
              padding: EdgeInsets.all(screenW * 0.04)
                  .copyWith(bottom: screenW * 0.06),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: authPro.isTab ? 3 : 2,
                crossAxisSpacing: screenW * 0.04,
                mainAxisSpacing: screenW * 0.04,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (_, i) {
                final user = snapshot.data[i].user;
                return ProfileViewCard(user);
              });
        });
    // } else {
    //   return const UpgradePlanDialog();
    // }
  }
}
