import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../features/auth/services/initial_profile_provider.dart';
import '../utils/theme/colors.dart';
import 'stadium_button.dart';

// ignore: must_be_immutable
class ShowMeDialog extends StatelessWidget {
  ShowMeDialog({
    Key? key,
    this.image,
    this.title,
    this.desc,
    this.btnText,
    this.btnChild,
    this.btnTxtClr,
    this.btnColor,
    this.btnGradient,
    this.onPressed,
    this.showCloseBtn = true,
    this.allowBackBtn = true,
  }) : super(key: key);

  final Widget? image;
  final String? title;
  final String? desc;
  final String? btnText;
  final Widget? btnChild;
  final Color? btnTxtClr;
  final Color? btnColor;
  final LinearGradient? btnGradient;
  final VoidCallback? onPressed;
  final bool showCloseBtn;
  final bool allowBackBtn;

  int interested = 0;

  final List<Map<String, dynamic>> genders = [
    {
      'name': 'Male',
      'icon': FontAwesomeIcons.mars,
      'value': 1,
    },
    {
      'name': 'Female',
      'icon': FontAwesomeIcons.venus,
      'value': 2,
    },
    {
      'name': 'Everyone',
      'icon': FontAwesomeIcons.venusMars,
      'value': 0,
    },
    {
      'name': 'Other',
      'icon': '',
      'value': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final initialProfileProviderRead = context.read<InitialProfileProvider>();
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => allowBackBtn,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                alignment: Alignment.center,
                insetPadding: EdgeInsets.symmetric(horizontal: screenW * 0.02),
                contentPadding: EdgeInsets.all(screenW * 0.08),
                children: [
                  image ?? const SizedBox.shrink(),
                  title != null
                      ? Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  SizedBox(height: screenH * 0.02),
                  Consumer<InitialProfileProvider>(
                    builder: (context, gend, child) {
                      return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: genders
                              .map((e) => StadiumButton(
                                  onPressed: () {
                                    gend.showMe = e['name'];
                                    interested = e['value'];
                                  },
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenW * 0.04,
                                      vertical: screenW * 0.01),
                                  textColor: gend.showMe == e['name']
                                      ? AppColors.reedemBlue
                                      : AppColors.black,
                                  bgColor: gend.showMe == e['name']
                                      ? null
                                      : AppColors.lighterGrey,
                                  gradient: gend.showMe == e['name']
                                      ? AppColors.purpleH
                                      : null,
                                  child: SizedBox(
                                    width: screenW * 0.26,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (e['icon'] != '')
                                            FaIcon(e['icon'],
                                                color: gend.showMe == e['name']
                                                    ? AppColors.reedemBlue
                                                    : AppColors.black,
                                                size: screenW * 0.05),
                                          SizedBox(width: screenW * 0.01),
                                          Text(
                                            e['name'],
                                            style: TextStyle(
                                              color: gend.showMe == e['name']
                                                  ? AppColors.reedemBlue
                                                  : AppColors.black,
                                            ),
                                          ),
                                        ]),
                                  )))
                              .toList());
                    },
                  ),
                  SizedBox(height: screenH * 0.02),
                  const SizedBox(height: 20),
                  btnText != null
                      ? StadiumButton(
                          text: btnText,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          bgColor: btnColor,
                          // textColor: btnTxtClr,
                          gradient: btnGradient,
                          onPressed: () {
                            initialProfileProviderRead.updateShowMe(interested);
                            Navigator.of(context).pop();
                          },
                          child: btnChild,
                        )
                      : const SizedBox.shrink(),
                ])
          ]),
    );
  }
}
