import 'package:flutter/material.dart';

import '../../../../../common_widgets/stadium_chip.dart';
import '../../../../../utils/theme/colors.dart';

class PersonDetailsInterestChips extends StatelessWidget {
  PersonDetailsInterestChips({
    super.key,
    required this.interests,
  });

  final List interests;

  final List<Color> colors = [
    AppColors.interestPinkRed,
    AppColors.interestOrange,
    AppColors.interestGreen,
    AppColors.interestBlue,
    AppColors.deepOrange,
    AppColors.darkBlue,
    AppColors.alertRed,
    AppColors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      children: interests
          .map((e) => SadiumChip(
                text: e,
                bgColor: colors[interests.indexOf(e) % colors.length],
              ))
          .toList(),
    );
  }
}
