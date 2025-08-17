import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:bsty/utils/functions.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/primary_button.dart';
import '../../../../utils/theme/colors.dart';
import '../../services/initial_profile_provider.dart';
import 'select_orientation_page.dart';

class SelectGender extends StatelessWidget {
  static const routeName = '/select-gender';

  const SelectGender({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialProfileProviderRead = context.read<InitialProfileProvider>();
    final authPro = context.read<AuthProvider>();
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    /// [ Widgets ]

    final gendersGrid = FutureBuilder(
        future: initialProfileProviderRead.getGenderList(),
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Expanded(
                child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            final genders = snapshot.data ?? [];
            log(genders.toString());
            return Consumer<InitialProfileProvider>(
              builder: (_, ref, __) => Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: genders
                    .map(
                      (gender) => GestureDetector(
                        onTap: () => initialProfileProviderRead.gender =
                            gender['id'].toString(),
                        // child: CustomChip(
                        //   text: gender['title'],
                        //   isSelected: ref.gender == gender['id'].toString(),
                        // ),
                        child: Container(
                          padding: EdgeInsets.all(appHeight * 0.02),
                          height: appHeight * 0.243,
                          width:
                              authPro.isTab ? appWidth * 0.3 : double.infinity,
                          constraints:
                              BoxConstraints(maxWidth: appWidth / 2 - 40),
                          decoration: BoxDecoration(
                              color: ref.gender == gender['id'].toString()
                                  ? AppColors.borderBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderBlue)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (gender['title'] == 'Male')
                                SvgPicture.asset(
                                  'assets/svg/gender/male_icon.svg',
                                  height: appHeight * 0.09,
                                  fit: BoxFit.scaleDown,
                                ),
                              if (gender['title'] == 'Female')
                                SvgPicture.asset(
                                  'assets/svg/gender/female_icon.svg',
                                  height: appHeight * 0.09,
                                  fit: BoxFit.scaleDown,
                                ),
                              if (gender['title'] == 'Other')
                                SvgPicture.asset(
                                  'assets/svg/gender/gender_other.svg',
                                  height: appHeight * 0.09,
                                  fit: BoxFit.scaleDown,
                                ),
                              if (gender['title'] == 'Other' ||
                                  gender['title'] == 'Female' ||
                                  gender['title'] == 'Male')
                                SizedBox(
                                  height: appHeight * 0.03,
                                ),
                              Text(
                                gender['title']! as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color:
                                          ref.gender == gender['id'].toString()
                                              ? AppColors.white
                                              : AppColors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          }
        });

    final displayGenderCheckbox = Consumer<InitialProfileProvider>(
        builder: (_, ref, child) =>
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Checkbox(
                value: ref.displayGender,
                onChanged: (value) => ref.toggleDisplayGender(),
                activeColor: AppColors.black,
              ),
              child!
            ]),
        child: const Text('Display my gender'));

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Gender')),
        body: Padding(
            padding: EdgeInsets.all(appWidth * 0.05)
                .copyWith(bottom: appHeight * 0.05),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'You are?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: appHeight * 0.025),
                  gendersGrid,
                  const Spacer(),
                  displayGenderCheckbox,
                  PrimaryBtn(
                    text: 'Continue',
                    gradient: AppColors.buttonBlue,
                    onPressed: () {
                      log(initialProfileProviderRead.gender.isEmpty.toString());
                      if (initialProfileProviderRead.gender.isEmpty) {
                        showSnackBar('Select your gender to continue');
                        return;
                      }
                      Navigator.of(context)
                          .pushNamed(SelectOrientation.routeName);
                    },
                  )
                ])),
      ),
    );
  }
}
