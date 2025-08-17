import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:bsty/common_widgets/loading_animations.dart';
import 'package:bsty/features/profile/widgets/selfie_cam_bottom_controls.dart';

import '../../../utils/theme/colors.dart';

class CameraArea extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraArea({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  State<CameraArea> createState() => _CameraAreaState();
}

class _CameraAreaState extends State<CameraArea> {
  // late List<CameraDescription> _cameras;
  late CameraController _controller;

  bool isCameraSelected = true;

  /// [find all cameras] and save it to _cameras
  Future<void> initCameras(CameraDescription cameraDescription) async {
    _controller = CameraController(cameraDescription, ResolutionPreset.max);

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initCameras(widget.cameras[1]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    return _controller.value.isInitialized
        ? Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_controller),
                      Positioned(
                        bottom: 10,
                        child: Text(
                          'Please show the number 3 with your fingers\nand close your left eye.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.lightGrey),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: AppColors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: screenW * 0.05,
                  vertical: screenH * 0.016,
                ),
                child: SelfieCameraBottomControls(
                  screenW: screenW,
                  controller: _controller,
                  cameras: widget.cameras,
                  onFlip: () {
                    initCameras(isCameraSelected
                        ? widget.cameras[1]
                        : widget.cameras[0]);
                    setState(() {
                      isCameraSelected = !isCameraSelected;
                    });
                  },
                ),
              )
            ],
          )
        : mainLoadingAnimationLight;
    // Container(
    //   color: Colors.black,
    //   width: double.infinity,
    //   alignment: Alignment.center,
    //   child: const Text('Display Camera'),
    // );
  }
}
