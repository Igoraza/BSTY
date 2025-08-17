import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/theme/colors.dart';

const Widget mainLoadingAnimationDark = SpinKitPulse(color: AppColors.black);
const Widget mainLoadingAnimationLight =
    SpinKitPulse(color: AppColors.lightGrey);

class BtnLoadingAnimation extends StatelessWidget {
  const BtnLoadingAnimation(
      {Key? key, this.color = AppColors.white, this.size = 20})
      : super(key: key);

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      SpinKitThreeBounce(color: color, size: size);
}
