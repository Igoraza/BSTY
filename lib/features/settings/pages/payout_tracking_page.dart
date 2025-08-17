import 'package:flutter/material.dart';
import 'package:bsty/common_widgets/background_image.dart';

import '../../../utils/theme/colors.dart';

class PayoutTrackingPage extends StatelessWidget {
  const PayoutTrackingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    final data = {
      'Amount': 'MK 1,250.00',
      'Payout Date': '01-11-2022',
      'Transfer Method': 'Online',
      'Transaction Fee': 'MK 2.00',
      'Destination': 'Bank Account',
      'Status': 'Completed',
      'Completed Date': '02-11-2022',
    };

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Payout Tracking')),
        body: Center(
            child: Container(
          margin: EdgeInsets.all(mq.width * 0.05),
          padding: EdgeInsets.all(mq.width * 0.1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.2),
                // blurRadius: 10,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Payout Details', style: textTheme.titleMedium),
              const SizedBox(height: 20),
              ...data.entries.map((e) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: textTheme.titleSmall),
                      Text(e.value, style: textTheme.bodyLarge),
                    ],
                  ))),
            ],
          ),
        )),
      ),
    );
  }
}
