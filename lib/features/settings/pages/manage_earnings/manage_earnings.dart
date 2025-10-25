// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:ui';

import 'package:bsty/common_widgets/upgrade_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/common_widgets/background_image.dart';
import 'package:bsty/common_widgets/loading_animations.dart';
import 'package:bsty/common_widgets/mep_custom_dialog.dart';
import 'package:bsty/common_widgets/snapshot_error.dart';
import 'package:bsty/common_widgets/stadium_button.dart';
import 'package:bsty/features/settings/pages/manage_earnings/model/mep_model.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/mep_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/payment_option_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/payout_request_provider.dart';
import 'package:bsty/features/settings/pages/manage_earnings/provider/redeem_transaction_provider.dart';
import 'package:bsty/utils/functions.dart';
import 'package:bsty/utils/global_keys.dart';
import 'package:bsty/utils/theme/colors.dart';
import 'package:provider/provider.dart';

import 'widgets/add_account_text_field.dart';
import 'widgets/bottom_sheet_button.dart';
import 'widgets/bottom_sheet_title_subtitle.dart';
import 'widgets/manage_earnings_details.dart';
import 'widgets/mep_container.dart';
import 'widgets/payout_options.dart';
import 'widgets/redeem_coins_button.dart';

class ManageEarningsPage extends StatefulWidget {
  const ManageEarningsPage({Key? key}) : super(key: key);

  static const String routeName = '/manage-earnings';

  @override
  State<ManageEarningsPage> createState() => _ManageEarningsPageState();
}

class _ManageEarningsPageState extends State<ManageEarningsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  final redeemCoinsController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchNameController = TextEditingController();
  final accountHolderName = TextEditingController();

  final phoneNumberController = TextEditingController();

  int withDrawAmount = 0;

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    final mepPro = context.read<MEPProvider>();

    return BackgroundImage(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('BSTYEP'),
          actions: [
            SvgPicture.asset('assets/svg/mep/question.svg'),
            SizedBox(width: appWidth * 0.05),
          ],
        ),
        body: FutureBuilder<MepModel?>(
          future: mepPro.getMep(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: mainLoadingAnimationDark);
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
            }
            final data = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  MEPCard(
                    earned: data?.totalCoins ?? 0,
                    withdrawable: data?.withdrawable ?? 0,
                    withdrawn: data?.withdrawn ?? 0,
                  ),
                  Stack(
                    children: [
                      ManageEarningsDetails(mepModel: data),
                      Align(
                        alignment: Alignment.topCenter,
                        child: RedeemCoinsButton(
                          onTap: () {
                            // await mepPro.getMep();
                            // debugPrint('Redeeming coins');
                            withDrawAmount = data?.withdrawable ?? 0;
                            redeemCoinsController.clear();
                            showFirstBottomSheet(context);
                            // showCoinNotAvailableDialog();
                            // showDialog(
                            //   context: context,
                            //   builder: (context) => CustomDialog(
                            //     image: SvgPicture.asset(
                            //         'assets/svg/upgrade_dialog/redeem_coin.svg'),
                            //     title: 'Upgrade',
                            //     desc:
                            //         'You need to subscribe to any plan to\nredeem coin.',
                            //     btnText: 'View Plans',
                            //     // btnTxtClr: AppColors.white,
                            //     btnGradient: AppColors.orangeYelloH,
                            //     onPressed: () {

                            // Navigator.pushNamed(context, UpgradePlanScreen.routeName);
                            //       showDialog(
                            //           context: context,
                            //           builder: (context) => UpgradePlanDialog());
                            //     },
                            //   ),
                            // );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// [ TODO: While clicking on blured portion the bottomsheet should go down ]
  ///

  void showCoinNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                "You don't have any coins to redeem",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              StadiumButton(
                text: 'Ok',
                bgColor: AppColors.black,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showFirstBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        double appHeight = MediaQuery.of(context).size.height;
        double appWidth = MediaQuery.of(context).size.width;

        double conversionRate = 11.0;
        final provider = Provider.of<RedeemTransactionProvider>(context);
        // final coins = redeemCoinsController.text.isEmpty
        //     ? 0
        //     : int.parse(redeemCoinsController.text);

        /// [ TODO: implement the convertion inside the textfield as suffix ]
        // setState(() {
        //   redeemCoinsController.value = redeemCoinsController.value;
        // });

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SingleChildScrollView(
            child: Container(
              width: appWidth,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: appHeight * 0.05),
                  const BottomSheetTitleSubtitle(
                    title: 'Redeem From Wallet',
                    subtitle: 'Coins will be redeemed from Wallet as Cash.',
                  ),
                  SizedBox(height: appHeight * 0.02),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: appWidth * 0.1,
                      vertical: appHeight * 0.01,
                    ),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        onChanged: (value) {
                          log(value);
                          final coins = value.isEmpty ? 0 : int.parse(value);
                          provider.convertedAmount = coins / conversionRate;
                          // log(provider.convertedAmount.toString());
                        },
                        controller: redeemCoinsController,
                        keyboardType: TextInputType.number,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(color: AppColors.blue),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              'assets/svg/mep/small_coin.svg',
                            ),
                          ),
                          suffix: Consumer<RedeemTransactionProvider>(
                            builder: (context, pro, child) {
                              // log('consumer');
                              return Text(
                                '= ${pro.convertedAmount.round()} Malawian Kwacha',
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: AppColors.disabled),
                              );
                            },
                          ),
                          labelText: 'Redeem Coins',
                          labelStyle: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: AppColors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.disabled,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.disabled,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.disabled,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || int.parse(value) < 3000) {
                            return "You need minimum of 3000 coins";
                          } else if (int.parse(value) > withDrawAmount) {
                            return "Enter valid coins";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: appWidth * 0.14),
                    child: Text(
                      'Disclaimer : You need a minimum of 3000 coins. Applicable tax will be deducted from the final amount.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.disabled,
                      ),
                    ),
                  ),
                  SizedBox(height: appHeight * 0.1),
                  BottomSheetButton(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        showSecondBottomSheet(context);
                        return;
                      }
                      debugPrint('Payout Method');

                      // showSecondBottomSheet(context);
                    },
                    buttonName: 'Redeem',
                  ),
                  SizedBox(height: appHeight * 0.05),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSecondBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        double appHeight = MediaQuery.of(context).size.height;
        double appWidth = MediaQuery.of(context).size.width;
        final provider = Provider.of<PaymentOptionProvider>(context);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SingleChildScrollView(
            child: Container(
              width: appWidth,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: appHeight * 0.02),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: SvgPicture.asset('assets/svg/mep/payment.svg'),
                  ),
                  const BottomSheetTitleSubtitle(
                    title: 'Select Payment Method',
                    subtitle: 'Choose payment method on your demand',
                  ),

                  /// [ TODO: Need to implement the radio button with options ]
                  const PayoutOptions(),
                  SizedBox(height: appHeight * 0.008),
                  BottomSheetButton(
                    onTap: () {
                      debugPrint('Payout Details ${provider.payOptionId}');
                      // Navigator.pop(context);
                      if (provider.payOptionId == 1) {
                        showAirtelMoneyBottomSheet(context);
                      } else if (provider.payOptionId == 2) {
                        showMpambaBottomSheet(context);
                      } else if (provider.payOptionId == 3) {
                        showBankAccountBottomSheet(context);
                      }
                      // Navigator.pop(context);
                    },
                    buttonName: 'Payout',
                  ),
                  SizedBox(height: appHeight * 0.5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showAirtelMoneyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        double appHeight = MediaQuery.of(context).size.height;
        double appWidth = MediaQuery.of(context).size.width;

        final payOutPr = Provider.of<PayoutRequestProvider>(context);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: appWidth,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: appHeight * 0.02),
                const BottomSheetTitleSubtitle(
                  title: 'Payout',
                  subtitle:
                      'Please enter your mobile number\nregistered with Airtel Money',
                ),
                SizedBox(height: appHeight * 0.01),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: appWidth * 0.1,
                    vertical: appHeight * 0.01,
                  ),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.number,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: AppColors.blue),
                      decoration: InputDecoration(
                        labelText: 'Enter Mobile Number',
                        labelStyle: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: AppColors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.disabled,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.disabled,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.disabled,
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (phoneNumberController.text.isEmpty) {
                          return "Enter a phone number !";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: appHeight * 0.1),
                BottomSheetButton(
                  onTap: () async {
                    debugPrint('Submitting payout method via Airtel Money');
                    if (_formKey.currentState!.validate()) {
                      final result = await payOutPr.payoutRequest(
                        amount: redeemCoinsController.text,
                        name: "NA",
                        accNumber: "NA",
                        bnkName: "NA",
                        brnName: "NA",
                        phnNumber: phoneNumberController.text,
                        paymentMethod: 1,
                      );
                      if (result) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => MepCustomDialog(
                            image: SvgPicture.asset(
                              "assets/svg/dialog/tick_mep.svg",
                            ),
                            title: "Successful",
                            subTitle: "Your Payout Request Submitted!",
                            btnText: "Go to Wallet",
                            // scBtnText: "View Details",
                            btnGradient: AppColors.orangeYelloH,
                            scBtnGradient: AppColors.buttonBlueVertical,
                            showCloseBtn: false,
                            onPressed: () => navigatorKey.currentState!.pop(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showSnackBar('Something went wrong !');
                      }
                    }
                  },
                  buttonName: 'Submit',
                ),
                SizedBox(height: appHeight * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMpambaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        double appHeight = MediaQuery.of(context).size.height;
        double appWidth = MediaQuery.of(context).size.width;

        // final phoneNumberController = TextEditingController();
        final payOutPr = Provider.of<PayoutRequestProvider>(context);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: appWidth,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: appHeight * 0.02),
                const BottomSheetTitleSubtitle(
                  title: 'Payout',
                  subtitle:
                      'Please enter your mobile number registered with Mpamba',
                ),
                SizedBox(height: appHeight * 0.01),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: appWidth * 0.1,
                    vertical: appHeight * 0.01,
                  ),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.number,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: AppColors.blue),
                      decoration: InputDecoration(
                        labelText: 'Enter Mobile Number',
                        labelStyle: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: AppColors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.disabled,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.disabled,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.disabled,
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (phoneNumberController.text.isEmpty) {
                          return "Enter a phone number !";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: appHeight * 0.1),
                BottomSheetButton(
                  onTap: () async {
                    debugPrint('Submitting payout method via Mpamba');

                    if (_formKey.currentState!.validate()) {
                      final result = await payOutPr.payoutRequest(
                        amount: redeemCoinsController.text,
                        name: "NA",
                        accNumber: "NA",
                        bnkName: "NA",
                        brnName: "NA",
                        phnNumber: phoneNumberController.text,
                        paymentMethod: 2,
                      );
                      if (result) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => MepCustomDialog(
                            image: SvgPicture.asset(
                              "assets/svg/dialog/tick_mep.svg",
                            ),
                            title: "Successful",
                            subTitle: "Your Payout Request Submitted!",
                            btnText: "Go to Wallet",
                            // scBtnText: "View Details",
                            btnGradient: AppColors.orangeYelloH,
                            scBtnGradient: AppColors.buttonBlueVertical,
                            showCloseBtn: false,
                            onPressed: () => navigatorKey.currentState!.pop(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showSnackBar('Something went wrong !');
                      }
                    }
                  },
                  buttonName: 'Submit',
                ),
                SizedBox(height: appHeight * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }

  void showBankAccountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        double appHeight = MediaQuery.of(context).size.height;
        double appWidth = MediaQuery.of(context).size.width;

        final payOutPr = Provider.of<PayoutRequestProvider>(context);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: appWidth,
            // height: 200,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: appHeight * 0.03),
                    const BottomSheetTitleSubtitle(
                      title: 'Add Account Details',
                    ),
                    AddAccountTextField(
                      horizontal: appWidth * 0,
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      labelText: ' Account Number',
                      validator: (p0) {
                        if (accountNumberController.text.isEmpty) {
                          return 'Enter a valid Account Number !';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: appHeight * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: AddAccountTextField(
                            horizontal: appWidth * 0,
                            controller: bankNameController,
                            keyboardType: TextInputType.text,
                            labelText: 'Bank Name',
                            validator: (p0) {
                              if (accountNumberController.text.isEmpty) {
                                return 'Enter a valid Bank name !';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: appWidth * 0.04),
                        Expanded(
                          child: AddAccountTextField(
                            horizontal: appWidth * 0,
                            controller: branchNameController,
                            keyboardType: TextInputType.text,
                            labelText: 'Branch Name',
                            validator: (p0) {
                              if (accountNumberController.text.isEmpty) {
                                return 'Enter a valid Branch name !';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: appHeight * 0.03),
                    AddAccountTextField(
                      horizontal: appWidth * 0,
                      controller: accountHolderName,
                      keyboardType: TextInputType.text,
                      labelText: 'Account Holder\'s Name',
                      validator: (p0) {
                        if (accountNumberController.text.isEmpty) {
                          return 'Enter a valid name !';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: appHeight * 0.1),
                    BottomSheetButton(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final result = await payOutPr.payoutRequest(
                            amount: redeemCoinsController.text,
                            name: accountHolderName.text,
                            accNumber: accountNumberController.text,
                            bnkName: bankNameController.text,
                            brnName: branchNameController.text,
                            phnNumber: "NA",
                            paymentMethod: 3,
                          );
                          if (result) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => MepCustomDialog(
                                image: SvgPicture.asset(
                                  "assets/svg/dialog/tick_mep.svg",
                                ),
                                title: "Successful",
                                subTitle: "Your Payout Request Submitted!",
                                btnText: "Go to Wallet",
                                // scBtnText: "View Details",
                                btnGradient: AppColors.orangeYelloH,
                                scBtnGradient: AppColors.buttonBlueVertical,
                                showCloseBtn: false,
                                onPressed: () =>
                                    navigatorKey.currentState!.pop(),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            showSnackBar('Something went wrong !');
                          }
                        }
                        debugPrint(
                          'Submitting payout method via Bank Transfer',
                        );
                      },
                      buttonName: 'Submit',
                    ),
                    SizedBox(height: appHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
