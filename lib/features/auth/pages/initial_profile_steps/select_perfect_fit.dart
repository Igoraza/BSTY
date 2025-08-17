import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/loading_animations.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../screens/main/main_page.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/theme/colors.dart';
import '../../enums.dart';
import '../../services/initial_profile_provider.dart';
import 'select_media.dart';

class PerfectFit extends StatelessWidget {
  const PerfectFit({Key? key}) : super(key: key);

  static const routeName = '/perfect-fit';

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final authPro = context.read<AuthProvider>();

    // final fitItems = [
    //   {'id': '1', 'name': 'Love', 'icon': 'love'},
    //   {'id': '2', 'name': 'Friends', 'icon': 'friends'},
    //   {'id': '3', 'name': 'Meetings', 'icon': 'meetings'},
    //   {'id': '4', 'name': 'Professional', 'icon': 'professional'},
    // ];

    final newFitItems = [
      {'id': '1', 'name': 'Lifelong Companion', 'icon': 'life_long'},
      {'id': '2', 'name': 'Committed Relationship', 'icon': 'committed'},
      {'id': '3', 'name': 'Short but Meaningful', 'icon': 'short'},
      {'id': '4', 'name': 'Fun While It Lasts', 'icon': 'fun_while'},
      {'id': '5', 'name': 'Exploring Friendships', 'icon': 'exploring'},
      {
        'id': '6',
        'name': 'Figuring It Out Along the Way',
        'icon': 'figuring_out'
      },
    ];

    /// [ Functions ]

    Future<void> submitData() async {
      try {
        await context
            .read<InitialProfileProvider>()
            .submitInitialProfile(context)
            .then((value) {
          if (value) {
            Navigator.of(context).pushNamed(SelectMedia.routeName);
          } else {
            showSnackBar('Something went wrong');
          }
        });
      } catch (e) {
        debugPrint(e.toString());
        showSnackBar('Something went wrong');
      }
    }

    /// [ Widgets ]

    final perfectFitItemsGrid = Consumer<InitialProfileProvider>(
      builder: (_, ref, __) {
        return GridView.builder(
          shrinkWrap: true,
          itemCount: newFitItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: authPro.isTab ? 4 : 3,
            childAspectRatio: 0.83,
            crossAxisSpacing: appWidth * 0.03,
            mainAxisSpacing: appWidth * 0.03,
          ),
          itemBuilder: (_, i) {
            return GestureDetector(
              onTap: () => ref.fit = newFitItems[i]['id']!,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderBlue),
                  color: ref.fit == newFitItems[i]['id']
                      ? AppColors.borderBlue
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/perfect_fit/${newFitItems[i]['icon']}.svg',
                    ),
                    SizedBox(height: appWidth * 0.05),
                    Text(
                      newFitItems[i]['name']!,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 10,
                            color: ref.fit == newFitItems[i]['id']
                                ? AppColors.white
                                : AppColors.black,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    final submitBtn = Consumer<InitialProfileProvider>(
        builder: (_, ref, __) => StadiumButton(
            visualDensity: VisualDensity.standard,
            gradient: AppColors.buttonBlue,
            onPressed:
                ref.authStatus == AuthStatus.checking ? null : submitData,
            child: ref.authStatus == AuthStatus.checking
                ? const BtnLoadingAnimation()
                : Text('Continue',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: AppColors.white))));

    return BackgroundImage(
        child: Scaffold(
            appBar: AppBar(title: const Text('Perfect Fit'), actions: [
              TextButton(
                  onPressed: () {
                    debugPrint('Skipped');
                    Navigator.of(context).pushNamed(MainPage.routeName);
                  },
                  child: Text('Skip',
                      style: Theme.of(context).textTheme.bodyMedium))
            ]),
            body: Padding(
                padding: EdgeInsets.all(appWidth * 0.05)
                    .copyWith(bottom: appHeight * 0.05),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: authPro.isTab ? 0 : appHeight * 0.04),
                      Text('You are here for ?',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(
                          height: authPro.isTab
                              ? appHeight * 0.01
                              : appHeight * 0.02),
                      perfectFitItemsGrid,
                      const Spacer(),
                      submitBtn
                    ]))));
  }
}
