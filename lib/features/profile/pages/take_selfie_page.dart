import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/custom_icon_btn.dart';
import '../../../utils/theme/colors.dart';
import '../widgets/camera_area.dart';

class TakeSelfiePage extends StatelessWidget {
  const TakeSelfiePage({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  final List<CameraDescription>? cameras;

  static const routeName = '/take-selfie';

  @override
  Widget build(BuildContext context) {
    // final screenH = MediaQuery.of(context).size.height;
    // final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        leading: CustomIconBtn(
          bgColor: AppColors.white.withOpacity(0.2),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onTap: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Selfie',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: CameraArea(
            cameras: cameras!,
          )),
          // Container(
          //   color: AppColors.black,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: screenW * 0.05,
          //     vertical: screenH * 0.03,
          //   ),
          //   child: SelfieCameraBottomControls(screenW: screenW),
          // )
        ],
      ),
    );
  }
}
