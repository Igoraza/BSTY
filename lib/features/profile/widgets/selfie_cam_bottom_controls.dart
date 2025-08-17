// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common_widgets/custom_icon_btn.dart';
import '../../../utils/theme/colors.dart';
import '../pages/check_selfie_quality_page.dart';

class SelfieCameraBottomControls extends StatefulWidget {
  CameraController controller;
  final List<CameraDescription> cameras;
  void Function()? onFlip;
  SelfieCameraBottomControls(
      {Key? key,
      required this.controller,
      required this.cameras,
      required this.screenW,
      this.onFlip})
      : super(key: key);

  final double screenW;

  @override
  State<SelfieCameraBottomControls> createState() =>
      _SelfieCameraBottomControlsState();
}

class _SelfieCameraBottomControlsState
    extends State<SelfieCameraBottomControls> {
  Future<XFile?> takePicture() async {
    final CameraController? cameraController = widget.controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> initCameras(CameraDescription cameraDescription) async {
    widget.controller =
        CameraController(cameraDescription, ResolutionPreset.max);
    // widget.controller.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   setState(() {});
    // }).catchError((Object e) {
    //   if (e is CameraException) {
    //     switch (e.code) {
    //       case 'CameraAccessDenied':
    //         // Handle access errors here.
    //         break;
    //       default:
    //         // Handle other errors here.
    //         break;
    //     }
    //   }
    // });
  }

  @override
  void initState() {
    super.initState();
    // initCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      CustomIconBtn(
          size: widget.screenW * 0.13,
          bgColor: AppColors.white.withOpacity(0.2),
          child: const Icon(
            Icons.flash_off_rounded,
            color: AppColors.white,
          ),
          onTap: () async {}),
      CustomIconBtn(
          size: widget.screenW * 0.18,
          padding: EdgeInsets.zero,
          bgColor: Colors.transparent,
          child: SvgPicture.asset('assets/svg/profile/click_selfie_check.svg'),
          onTap: () async {
            debugPrint('Take Selfie');
            XFile? image = await takePicture();
            log(image.toString());
            if (image != null) {
              log(widget.controller.toString());
              Navigator.of(context).pushReplacementNamed(
                  CheckSelfieQualityPage.routeName,
                  arguments: File(image.path));
            }
          }),
      CustomIconBtn(
          size: widget.screenW * 0.13,
          bgColor: AppColors.white.withOpacity(0.2),
          onTap: widget.onFlip,
          child: const Icon(
            Icons.flip_camera_android_rounded,
            color: AppColors.white,
          ))
    ]);
  }
}
