
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../common_widgets/loading_animations.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../services/people_provider.dart';
import '../widgets/main_card.dart';

class LikedList extends StatelessWidget {
  const LikedList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final provider = context.read<PeopleProvider>();

    // final userPlan = Hive.box('user').get('plan') ?? 1;
    // final planExpired = Hive.box('user').get('plan_expired') ?? true;

    // if (userPlan > 2 && !planExpired) {
    return FutureBuilder(
        future: provider.fetchLikes(context),
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
                      textAlign: TextAlign.center)
                ]);
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Center(
                child: Text('No profiles found',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center));
          }
          // provider.likedList = snapshot.data;
          return Consumer<PeopleProvider>(builder: (context, peple, child) {
            // log(peple.likedList.toString());
            if (peple.likedList.isEmpty) {
              return Center(
                  child: Text('No profiles found',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center));
            }
            return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                itemCount: peple.likedList.length,
                itemBuilder: (context, index) {
                  // final user = snapshot.data[index].user;

                  return MainCard(
                    peple.likedList[index].user,
                    isFav: false,
                    index: index,
                  );
                },
                separatorBuilder: (_, __) => SizedBox(height: screenH * 0.03));
          });
        });
    // } else {
    //   return const UpgradePlanDialog();
    // }
  }
}
