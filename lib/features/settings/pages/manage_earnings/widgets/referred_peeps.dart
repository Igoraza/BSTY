import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/theme/colors.dart';

class ReferredPeeps extends StatelessWidget {
  const ReferredPeeps({
    Key? key,
    required this.avatar,
    required this.numberOrMail,
    this.verified = false,
  }) : super(key: key);

  final String? avatar;
  final String numberOrMail;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: appWidth * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.symmetric(horizontal: appWidth * 0.02),
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.grey,
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: Offset(1.0, 1.0))
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(60))),
              child: avatar == null
                  ? SvgPicture.asset('assets/svg/refer_earn/avatar.svg',
                      height: appWidth * 0.15)
                  : FittedBox(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(60)),
                        child: Image.network(
                          avatar!,
                          height: appWidth * 0.15,
                          width: appWidth * 0.15,
                          fit: BoxFit.fill,
                        ),
                      ),
                    )),
          SizedBox(height: appHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: appWidth * 0.16,
                child: Text(
                  numberOrMail,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.black,
                        fontSize: 10,
                      ),
                ),
              ),
              // SizedBox(width: appWidth * 0.01),
              // verified
              //     ? SvgPicture.asset('assets/svg/mep/tick.svg',
              //         height: appHeight * 0.01)
              //     : SvgPicture.asset('assets/svg/mep/info.svg',
              //         height: appHeight * 0.01),
            ],
          ),
        ],
      ),
    );
  }
}
