import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bsty/utils/functions.dart';

import '../../../../../utils/theme/colors.dart';

class ReferralCodeContainer extends StatelessWidget {
  ReferralCodeContainer({
    Key? key,
  }) : super(key: key);

  final String referral_code = Hive.box('user').get('referral_code');

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

    double appWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: appWidth * 0.1),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(20)),
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            /// [ TODO : while copying the code not copying the text ]
            Text(textController.text = referral_code,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.disabled,
                      fontWeight: FontWeight.normal,
                    )),
            SizedBox(width: appWidth * 0.1),
            SvgPicture.asset('assets/svg/refer_earn/copy.svg'),
            SizedBox(width: appWidth * 0.01),
            GestureDetector(
                onTap: () {
                  debugPrint('Copied the referral code');

                  /// [ Copy Code to Clipboard ]
                  Clipboard.setData(ClipboardData(text: textController.text));
                  showSnackBar('Referral code has been copied');
                },
                child: Text('Copy Code',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppColors.pink,
                          fontWeight: FontWeight.normal,
                        ))),
            // const Spacer(),
            // GestureDetector(
            //     onTap: () {
            //       debugPrint('Share Code');
            //       final box = context.findRenderObject() as RenderBox;
            //       Share.share(
            //         '${referral_code}',
            //         subject: 'Refer',
            //         sharePositionOrigin:
            //             box.localToGlobal(Offset.zero) & box.size,
            //       );
            //     },
            //     child: SvgPicture.asset('assets/svg/refer_earn/share.svg')),
            // SizedBox(width: appWidth * 0.01),
          ])),
    );
  }
}
