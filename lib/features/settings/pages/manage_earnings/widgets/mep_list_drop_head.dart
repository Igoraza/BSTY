import 'package:flutter/material.dart';
import 'package:bsty/utils/theme/colors.dart';

class MepListDrop extends StatelessWidget {
  const MepListDrop({
    super.key,
    required this.leadTxt,
    // required this.trailTxt,
  });

  final String leadTxt;
  // final String trailTxt;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    return Container(
      color: AppColors.white,
      width: appWidth,
      padding: EdgeInsets.only(
        top: appHeight * 0.02,
        right: appWidth * 0.05,
        left: appWidth * 0.05,
        bottom: appHeight * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(leadTxt,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: const Color(0xFF6E6E6E),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
          GestureDetector(
            // onTap: onTap,
            child: Text(
              'This month',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: const Color(0xFF5A5A5A),
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
