import 'package:flutter/material.dart';

import '../../common_widgets/background_image.dart';
import 'widgets/settings_profile_card.dart';
import 'widgets/upgrade_ad_carousel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings-page';

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
              children: [const SettingsProfileCard(), UpgradeAdCarousel()])),
    );
  }
}
