// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/common_widgets/show_me_dialog.dart';
import 'package:bsty/common_widgets/upgrade_plan_dialog.dart';
import 'package:bsty/features/auth/widgets/url_open.dart';
import 'package:bsty/features/profile/pages/under_review_page.dart';
import 'package:bsty/features/profile/pages/verify_identity_page.dart';
import 'package:bsty/utils/constants/input_decorations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/background_image.dart';
import '../../../common_widgets/custom_icon_btn.dart';
import '../../../common_widgets/loading_animations.dart';
import '../../../common_widgets/stadium_button.dart';
import '../../../utils/constants/web_view_urls.dart';
import '../../../utils/global_keys.dart';
import '../../../utils/theme/colors.dart';
import '../../auth/enums.dart';
import '../../auth/services/auth_provider.dart';
import '../../auth/services/initial_profile_provider.dart';
import '../../chat_and_call/views/chat_messages/widgets/chat_screen_alert_dialog.dart';
import '../../membership/pages/credits_and_renewal.dart';
import '../widgets/inner_page_button.dart';
import '../widgets/inner_page_options.dart';
import '../widgets/inner_page_text.dart';
import '../widgets/sernd_query_dialog.dart';

class SettingsInnerPage extends StatefulWidget {
  const SettingsInnerPage({Key? key}) : super(key: key);

  static const routeName = '/settings-inner-page';

  @override
  State<SettingsInnerPage> createState() => _SettingsInnerPageState();
}

class _SettingsInnerPageState extends State<SettingsInnerPage> {
  double currentValue = 0;
  bool isNotifyToggled = true;
  bool isDeviceLockToggled = false;
  bool isIncognitoToggled = false;
  Color? notifyColor;
  Color? deviceLockColor;
  Color? incognitoColor;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _appVersion = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      _appVersion.value = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    // final editPro = context.read<EditProfileProvider>();
    final userPlan = Hive.box('user').get('plan') ?? 1;
    final planExpired = Hive.box('user').get('plan_expired') ?? true;
    final verified = Hive.box('user').get('verification_status') ?? 0;
    void showConfirmDialog({
      String? title,
      String? content,
      VoidCallback? onConfirm,
    }) =>
        showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => ChatScreenAlertDialog(
                  title: title,
                  content: content,
                  onConfirm: onConfirm,
                ));

    // final userBox = Hive.box('user');
    // final verificationStatus = userBox.get('verification_status');
    String verification = 'Get Verified';
    if (verified == 2) {
      verification = 'Under Review';
    } else if (verified == 3) {
      verification = 'Rejected!';
    } else if (verified == 1) {
      verification = 'Completed!';
    }

    return BackgroundImage(
      child: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      InnerPageOptions(
                        title: 'Credits & Renewal',
                        subtitle: 'Manage',
                        onTap: () => navigatorKey.currentState!
                            .pushNamed(CreditsAndRenewal.routeName),
                      ),
                      const Divider(),
                      // InnerPageOptions(
                      //     onTap: () {
                      //       if (planExpired) {

                                            // Navigator.pushNamed(context, UpgradePlanScreen.routeName);
                      //         showDialog(
                      //           context: context,
                      //           builder: (context) => UpgradePlanDialog(),
                      //         );
                      
                      //       }
                      //     },
                      //     title: 'Location',
                      //     subtitle: 'Current Location'),
                      // const Divider(),
                      // Padding(
                      //     padding: EdgeInsets.only(
                      //         left: appWidth * 0.03,
                      //         right: appWidth * 0.03,
                      //         top: appHeight * 0.01),
                      //     child: Row(children: [
                      //       Text('Maximum distance',
                      //           style: Theme.of(context).textTheme.titleMedium),
                      //       const Spacer(),
                      //       Text('${currentValue.toInt()} km',
                      //           style: Theme.of(context).textTheme.bodyMedium)
                      //     ])),
                      // Padding(
                      //     padding: EdgeInsets.only(bottom: appHeight * 0.01),
                      //     child: Slider(

                      //         /// [ TODO: need to change the color of the slider ]
                      //         activeColor: AppColors.alertRed,
                      //         inactiveColor: AppColors.lightBg,
                      //         thumbColor: AppColors.white,

                      //         ///[ The current value of the slider ]
                      //         value: currentValue,

                      //         /// [The minimum value of the slider ]
                      //         min: 0,

                      //         ///[ The maximum value of the slider ]
                      //         max: 200,
                      //         onChanged: (double newValue) {
                      //           setState(() {
                      //             currentValue = newValue;
                      //           });
                      //         })),
                      // const Divider(),
                      Consumer<InitialProfileProvider>(
                        builder: (context, proIni, child) {
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: appWidth * 0.03,
                                  vertical: appHeight * 0.01),
                              child: Row(children: [
                                Text('Notifications',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const Spacer(),
                                proIni.isLoading
                                    ? const Center(
                                        child: SizedBox(
                                        height: 40,
                                        child: CupertinoActivityIndicator(),
                                      ))
                                    : CupertinoSwitch(
                                        value: proIni.notification,
                                        activeColor: proIni.notification
                                            ? AppColors.alertRed
                                            : AppColors.lightBg,
                                        onChanged: (bool value) {
                                          proIni.notification = value;
                                          debugPrint(
                                              'Notifications button: $value ');
                                          proIni.updateNotific(value);
                                        })
                              ]));
                        },
                      ),
                      const Divider(),
                      Consumer<InitialProfileProvider>(
                        builder: (context, myType, child) {
                          return InnerPageOptions(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => ShowMeDialog(
                                  title: 'Show me',
                                  btnText: 'Select',
                                  btnGradient: AppColors.orangeYelloH,
                                ),
                              );
                            },
                            title: 'Show me',
                            subtitle: myType.showMe,
                          );
                        },
                      ),
                      const Divider(),
                      if (userPlan > 2 && !planExpired)
                        // if (verified != 1)
                        InnerPageOptions(
                          title: 'Verification',
                          subtitle: verification,
                          onTap: () {
                            log(verified.toString());

                            if (verified >= 2 || verified == 1) {
                              navigatorKey.currentState!
                                  .pushNamed(UnderReview.routeName)
                                  .then((value) {
                                setState(() {});
                              });
                              if (verified == 3) {
                                showDialog(
                                  context: context,
                                  builder: (context) => CustomDialog(
                                    title: 'Oops !',
                                    subTitle:
                                        'Your verification has been rejected',
                                    desc:
                                        'Your profile verification was not approved. We appreciate your effort and encourage you to re-submit with the necessary adjustments',
                                    image: SvgPicture.asset(
                                      'assets/svg/dialog/minus_in_red_circle.svg',
                                      // color: AppColors.alertRed,
                                    ),
                                    // btnColor: AppColors.white,
                                    btnTxtClr: AppColors.white,
                                    btnText: 'Re-Submit to Verify',
                                    btnGradient: AppColors.buttonBlueVertical,
                                    btnPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 20),
                                    onPressed: () => navigatorKey.currentState!
                                        .popAndPushNamed(
                                            VerifyIdentityPage.routeName)
                                        .then((value) {
                                      setState(() {});
                                    }),
                                  ),
                                );
                              }
                            } else {
                              navigatorKey.currentState!
                                  .pushNamed(VerifyIdentityPage.routeName)
                                  .then((value) {
                                setState(() {});
                              });
                            }
                          },
                        ),
                      if (userPlan > 2 && !planExpired) const Divider(),
                      // if (verified != 1)

                      // Padding(
                      //     padding: EdgeInsets.symmetric(
                      //         horizontal: appWidth * 0.03,
                      //         vertical: appHeight * 0.01),
                      //     child: Row(children: [
                      //       Text('Device Lock',
                      //           style: Theme.of(context).textTheme.titleMedium),
                      //       const Spacer(),
                      //       CupertinoSwitch(
                      //           value: isDeviceLockToggled,
                      //           activeColor: deviceLockColor,
                      //           onChanged: (bool value) {
                      //             setState(() {
                      //               isDeviceLockToggled = value;
                      //               debugPrint('Device Lock button: $value ');
                      //               deviceLockColor = value

                      //                   /// [ TODO: need to change the active state color  ]
                      //                   ? AppColors.alertRed
                      //                   : AppColors.lightBg;
                      //             });
                      //           })
                      //     ])),
                      // InnerPageText(
                      //   title: 'Turn on for Wallet security',
                      //   style: Theme.of(context).textTheme.bodyMedium,
                      // ),
                      // const Divider(),

                      Consumer<InitialProfileProvider>(
                        builder: (context, initiPro, child) {
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: appWidth * 0.03,
                                  vertical: appHeight * 0.01),
                              child: Row(children: [
                                Text('Incognito Mode',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const Spacer(),
                                initiPro.isLoading
                                    ? const Center(
                                        child: SizedBox(
                                            height: 40,
                                            child:
                                                CupertinoActivityIndicator()))
                                    : CupertinoSwitch(
                                        value: initiPro.incognito,
                                        activeColor: initiPro.incognito
                                            ? AppColors.alertRed
                                            : AppColors.lightBg,
                                        onChanged: (bool value) {
                                          log((userPlan).toString());
                                          if (userPlan <= 3 || planExpired) {
                                            Navigator.pushNamed(context, UpgradePlanScreen.routeName,arguments:"Premium" );
                                            return;
                                          }
                                          initiPro.incognito = value;
                                          debugPrint(
                                              'Incognito Mode button: $value ');
                                          initiPro.updateIncognito(value);
                                        }),
                              ]));
                        },
                      ),
                      // if (userPlan > 3 && !planExpired)
                      InnerPageText(
                          title:
                              'Your profile card will be shown only\nto your matches.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      if (userPlan > 3 && !planExpired) const Divider(),
                      SizedBox(height: appHeight * 0.02),
                      GestureDetector(
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) => SendQueryDialog()),
                        child: InnerPageText(
                            title: 'Send your query',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: AppColors.black,
                                )),
                      ),
                      GestureDetector(
                        onTap: () => openBrowser(WebViewUrls.termsOfService),
                        child: InnerPageText(
                            title: 'Terms of Service',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: AppColors.black,
                                )),
                      ),
                      GestureDetector(
                        onTap: () => openBrowser(WebViewUrls.privacyPolicy),
                        child: InnerPageText(
                            title: 'Privacy Policy',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: AppColors.black,
                                )),
                      ),
                      ValueListenableBuilder(
                          valueListenable: _appVersion,
                          builder: (_, String value, __) {
                            return InnerPageText(
                                title: 'Version $value',
                                style: Theme.of(context).textTheme.bodyMedium);
                          }),
                      SizedBox(height: appHeight * 0.02),
                      Consumer<AuthProvider>(builder: (_, ref, __) {
                        return GestureDetector(
                          onTap: () {
                            showConfirmDialog(
                                content: "Do you want to logout ?",
                                onConfirm: () {
                                  // ref.logout();
                                });
                          },
                          child: ref.authStatus == AuthStatus.checking
                              ? BtnLoadingAnimation(
                                  color: AppColors.black,
                                  size: appHeight * 0.037)
                              : const InnerPageButtons(
                                  name: 'logout',
                                  title: 'Log out',
                                ),
                        );
                      }),
                      SizedBox(height: appHeight * 0.01),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthProvider>().istyped = false;
                          showDialog(
                              context: context,
                              builder: (context) => DeleteAcDialog(
                                    formKey: _formKey,
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final authProvider =
                                            context.read<AuthProvider>();
                                        bool response =
                                            await authProvider.deleteAccount();
                                        Navigator.of(context).pop();
                                        if (response == true) {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const CustomDialog(
                                              desc:
                                                  'Your request has been successfully submitted. Your account will be permanently deleted within the next 24/48 hours.',
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ));
                          debugPrint('Delete Account button pressed');
                        },
                        child: const InnerPageButtons(
                          name: 'delete',
                          title: 'Delete Account',
                        ),
                      ),
                      SizedBox(height: appHeight * 0.03),
                    ])),
              ))),
    );
  }
}

class DeleteAcDialog extends StatelessWidget {
  DeleteAcDialog({
    super.key,
    required GlobalKey<FormState> formKey,
    this.onPressed,
  }) : _formKey = formKey;

  final VoidCallback? onPressed;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _deleteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    // context.read<AuthProvider>().istyped = false;
    return WillPopScope(
      onWillPop: () async => true,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...[
              CustomIconBtn(
                  onTap: () => Navigator.of(context).pop(),
                  bgColor: Colors.transparent,
                  size: appWidth * 0.15,
                  child:
                      SvgPicture.asset('assets/svg/dialog/close_outlined.svg'))
            ],
            SimpleDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                alignment: Alignment.center,
                insetPadding: EdgeInsets.symmetric(horizontal: appWidth * 0.05),
                contentPadding: EdgeInsets.all(appWidth * 0.1),
                children: [
                  Text(
                    'Delete Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text:
                          'Confirm you want to delete this account by typing:',
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: const [
                        TextSpan(
                          text: ' Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _deleteController,
                        // autovalidateMode: AutovalidateMode.always,
                        decoration: kInputDecoration.copyWith(
                          hintText: 'Delete',
                        ),
                        onChanged: (value) {
                          if (value == "Delete" || value == "delete") {
                            context.read<AuthProvider>().istyped = true;
                          } else {
                            context.read<AuthProvider>().istyped = false;
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            AuthProvider().istyped = false;
                            return 'Enter the value';
                          }
                          if (value != 'Delete' && value != 'delete') {
                            AuthProvider().istyped = false;
                            return 'You didn\'t enter the value correctly';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 20),
                  Consumer<AuthProvider>(builder: (context, ref, child) {
                    return StadiumButton(
                      gradient: ref.istyped
                          ? AppColors.redVertical
                          : AppColors.grayDisabled,
                      onPressed: onPressed,
                      child: ref.isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
                          : const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  })
                ])
          ]),
    );
  }
}
