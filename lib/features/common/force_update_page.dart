import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/background_image.dart';
import '../../common_widgets/stadium_button.dart';
import '../../utils/theme/colors.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({Key? key}) : super(key: key);

  static const routeName = '/force-update';

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Please update the app to its latest version to continue using it.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 22),
                StadiumButton(
                  text: 'Update',
                  bgColor: AppColors.black,
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      const url =
                          'https://play.google.com/store/apps/details?id=com.wedconnect.bsty';
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalNonBrowserApplication,
                        );
                      } else {
                        throw 'Could not launch $url';
                      }
                    } else if (Platform.isIOS) {
                      const url =
                          'https://apps.apple.com/app/com.wedconnect.bsty';
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalNonBrowserApplication,
                        );
                      } else {
                        throw 'Could not launch $url';
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
