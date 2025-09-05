import 'package:flutter/material.dart';

import '../common_widgets/upgrade_plan_dialog.dart';
import 'global_keys.dart';

void showSnackBar(String message, {Color? color}) {
  rootScaffoldMessengerKey.currentState!.clearSnackBars();
  rootScaffoldMessengerKey.currentState!.showSnackBar(
    SnackBar(content: Text(message), backgroundColor: color),
  );
}

// void showUpgradePlanDialog() {
//   showDialog(
//     context: navigatorKey.currentState!.overlay!.context,
//     builder: (context) => UpgradePlanDialog(),
//   );
// }

String getPlanName(int plan) {
  switch (plan) {
    case 1:
      return 'Basic';
    case 2:
      return 'Lite';
    case 3:
      return 'Plus';
    case 4:
      return 'Premium';
    default:
      return 'NA';
  }
}
