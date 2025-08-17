import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bsty/features/auth/services/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/theme/colors.dart';

class BannerAd extends StatelessWidget {
  const BannerAd({Key? key, required this.size}) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    final authPro = context.read<AuthProvider>();
    return Container(
      width: authPro.isTab ? size.width * 0.5 : size.width * 0.66,
      height: authPro.isTab ? size.width * 0.1 : size.width * 0.16,
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: const BoxDecoration(
          gradient: AppColors.buttonBlueVertical,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                gradient: AppColors.buttonBlueVertical,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: const FaIcon(FontAwesomeIcons.crown,
                color: AppColors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Want to sell things?',
                    style: Theme.of(context).textTheme.titleMedium),
                const Text('Banner ads',
                    style: TextStyle(color: AppColors.white)),
              ]),
        ],
      ),
    );
  }
}
