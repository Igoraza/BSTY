import 'package:flutter/material.dart';

import '../utils/theme/colors.dart';

class SnapshotErrorWidget extends StatelessWidget {
  const SnapshotErrorWidget(this.errorMsg, {super.key, this.color});

  final String errorMsg;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 50, color: color ?? AppColors.black),
          const SizedBox(height: 10),
          Text(errorMsg,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
