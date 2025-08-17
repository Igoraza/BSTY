import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common_widgets/background_image.dart';
import '../../../features/profile/pages/take_selfie_page.dart';
import '../../../utils/theme/colors.dart';

class VerifyIdentityPage extends StatelessWidget {
  const VerifyIdentityPage({Key? key}) : super(key: key);

  static const routeName = '/verify-identity';

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify Identity')),
        body: Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                screenW * 0.15, 0, screenW * 0.15, screenW * 0.05),
            margin: EdgeInsets.all(screenW * 0.05),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/svg/profile/identify_with_selfie.svg'),
                Text('Identify with Selfie',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: AppColors.blue)),
                const SizedBox(height: 8),
                Text(
                    'It’s required to verify your identity for being a verified member.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextButton.icon(
                  // find available cameras and pass it to the camera page
                  onPressed: () {
                    debugPrint('Take new selfie');
                    availableCameras().then((cameras) {
                      log('Cameras: $cameras');
                      Navigator.of(context).pushNamed(
                        TakeSelfiePage.routeName,
                        arguments: cameras,
                      );
                    });
                  },
                  icon: SvgPicture.asset(
                      'assets/svg/profile/take_selfie_outline.svg',
                      color: AppColors.blue),
                  label: const Text(
                    'Take new selfie',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
