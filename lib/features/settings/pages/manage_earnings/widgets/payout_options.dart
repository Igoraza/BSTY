import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/theme/colors.dart';
import '../provider/payment_option_provider.dart';

class PayoutOptions extends StatefulWidget {
  const PayoutOptions({Key? key}) : super(key: key);

  @override
  State<PayoutOptions> createState() => _PayoutOptionsState();
}

class _PayoutOptionsState extends State<PayoutOptions> {
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    final provder = Provider.of<PaymentOptionProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: SizedBox(
        height: appHeight * 0.2,
        child: ListView.separated(
          separatorBuilder: (context, index) => Container(
              padding: EdgeInsets.symmetric(
                vertical: appWidth * 0.008,
              ),
              child: const Divider()),
          itemBuilder: (context, index) {
            // provder.selectedOption = provder.paymentOptions[index];
            return Consumer<PaymentOptionProvider>(
              builder: (context, pay, child) {
                return GestureDetector(
                  onTap: () {
                    pay.selectedOption = pay.paymentOptions[index];
                    pay.payOptionId = pay.paymentOptions[index].id;
                    log(pay.payOptionId.toString());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pay.paymentOptions[index].title,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: (pay.selectedOption ??
                                          provder.paymentOptions[0]) ==
                                      provder.paymentOptions[index]
                                  ? AppColors.black
                                  : AppColors.grey,
                              fontWeight: (pay.selectedOption ??
                                          provder.paymentOptions[0]) ==
                                      provder.paymentOptions[index]
                                  ? FontWeight.bold
                                  : FontWeight.w300,
                            ),
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        decoration: const BoxDecoration(
                          color: Color(0xffEBEBEB),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Center(
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(25)),
                              color: (pay.selectedOption ??
                                          provder.paymentOptions[0]) ==
                                      provder.paymentOptions[index]
                                  ? AppColors.alertRed
                                  : const Color(0xffEBEBEB),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
                // return RadioListTile<PaymentOptionModel>(
                //   title: Text(
                //     provder.paymentOptions[index].title,
                //     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                //           color:
                //               (pay.selectedOption ?? provder.paymentOptions[0]) ==
                //                       provder.paymentOptions[index]
                //                   ? AppColors.black
                //                   : AppColors.grey,
                //           fontWeight:
                //               (pay.selectedOption ?? provder.paymentOptions[0]) ==
                //                       provder.paymentOptions[index]
                //                   ? FontWeight.bold
                //                   : FontWeight.w300,
                //         ),
                //   ),
                //   value: provder.paymentOptions[index],
                //   groupValue: pay.selectedOption ?? provder.paymentOptions[0],
                //   onChanged: (value) {
                //     /// [ TODO: Should check the implemented setState is correct or not ]
                //     debugPrint('Selected value is $value');

                //     pay.selectedOption = value!;
                //   },
                //   controlAffinity: ListTileControlAffinity.trailing,

                //   /// [ TODO: Need to implement the active color for the radio button]
                //   activeColor: AppColors.alertRed,
                // );
              },
            );
          },
          itemCount: provder.paymentOptions.length,
        ),
      ),
    );
  }
}
