import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common_widgets/primary_button.dart';
import '../../../utils/constants/input_decorations.dart';
import '../../../utils/theme/colors.dart';

class ReferCodeDialog extends StatelessWidget {
  const ReferCodeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    return SimpleDialog(
        contentPadding: EdgeInsets.all(appHeight * 0.02),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        children: [
          TextField(
              decoration: kInputDecoration.copyWith(
                  hintText: 'Enter Code',
                  prefixIcon: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SvgPicture.asset(
                        'assets/images/auth/referral_code.svg',
                      )))),
          SizedBox(height: appHeight * 0.025),
          PrimaryBtn(
              text: 'Submit Code',
              fontsize: 12,
              gradient: AppColors.orangeYelloH,
              constraints: const BoxConstraints(maxWidth: 100),
              onPressed: () {
                debugPrint('Referal pop up closed');
                Navigator.of(context).pop();
              })
        ]);
  }
}
