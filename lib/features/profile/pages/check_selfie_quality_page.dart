// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bsty/common_widgets/custom_dialog.dart';
import 'package:bsty/features/profile/services/edit_profile_provider.dart';
import 'package:bsty/utils/global_keys.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/background_image.dart';
import '../../../common_widgets/custom_back_btn.dart';
import '../../../common_widgets/stadium_button.dart';
import '../../../utils/theme/colors.dart';
import 'take_selfie_page.dart';

class CheckSelfieQualityPage extends StatelessWidget {
  final File selfie;
  const CheckSelfieQualityPage({Key? key, required this.selfie})
      : super(key: key);

  static const routeName = '/check-selfie-quality';

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(
          leading: const CustomBackBtn(),
          title: const Text('Selfie'),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: screenW * 0.15, right: screenW * 0.15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset('assets/svg/profile/check_selfie_quality.svg'),
                SizedBox(height: screenH * 0.005),
                Text(
                  'Check quality',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 24),
                ),
                SizedBox(height: screenH * 0.01),
                Text(
                  'Make sure your face is not blurred\nor out of frame before submission.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: screenH * 0.06),
                Container(
                    height: screenW * 0.8,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.file(selfie)
                    // CachedNetworkImage(
                    //   fadeInDuration: Duration.zero,
                    //   fadeOutDuration: Duration.zero,
                    //   imageUrl:
                    //       'https://t3.ftcdn.net/jpg/05/37/38/08/360_F_537380846_crIC9gBeBH0YGqsxnJGSEDp6v9G7sGFq.jpg',
                    //   fit: BoxFit.cover,
                    //   placeholder: (context, url) =>
                    //       const SpinKitPulse(color: AppColors.lightGrey),
                    //   errorWidget: (context, url, error) =>
                    //       const SpinKitPulse(color: AppColors.lightGrey),
                    // ),
                    ),
                SizedBox(height: screenH * 0.03),
                Consumer<EditProfileProvider>(
                  builder: (context, state, child) {
                    return StadiumButton(
                      onPressed: () async {
                        if (state.isLoading) {
                          return;
                        }
                        log(selfie.path.toString());

                        int? statusCode = await state.uploadImage(selfie);
                        //  await convertFileToImage(selfie);
                        // EditProfileProvider().copyCrop(src);
                        Navigator.of(context).pop();
                        navigatorKey.currentState!.pop();
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context, UnderReview.routeName, (route) => false);
                        if (statusCode == 200) {
                          showDialog(
                            context: context,
                            builder: (context) => CustomDialog(
                              title: "Done !",
                              desc:
                                  'Your verification has been received.\nWe are reviewing your profile to\nensure the best experience\nfor our users.',
                              image: SvgPicture.asset(
                                'assets/svg/dialog/done.svg',
                                height: screenH * 0.2,
                              ),
                            ),
                          );
                        }
                      },
                      gradient: AppColors.buttonBlue,
                      // text: 'Submit to verify',
                      child: !state.isLoading
                          ? const Text('Submit to verify')
                          : const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                              ),
                            ),
                    );
                  },
                ),
                SizedBox(height: screenH * 0.01),
                TextButton(
                  onPressed: () {
                    availableCameras().then((cameras) {
                      debugPrint('Cameras: ');
                      Navigator.of(context).pushReplacementNamed(
                        TakeSelfiePage.routeName,
                        arguments: cameras,
                      );
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text('Take a new photo'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
