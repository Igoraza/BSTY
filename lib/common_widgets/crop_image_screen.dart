import 'dart:async';
import 'dart:typed_data';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:crop_image/crop_image.dart';

class CropImageScreen extends StatefulWidget {
  final Image image;
  final double aspectRatio;

  const CropImageScreen({
    Key? key,
    required this.image,
    required this.aspectRatio,
  }) : super(key: key);

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  late final CropController cropController;
  bool isCropping = false; // ← added

  @override
  void initState() {
    super.initState();
    cropController = CropController(aspectRatio: widget.aspectRatio);
  }

  @override
  void dispose() {
    cropController.dispose();
    super.dispose();
  }

  /// Convert Image widget to Uint8List
  Future<Uint8List?> _getCroppedBytes() async {
    try {
      // Step 1: Get cropped Image widget
      final Image croppedImageWidget = await cropController.croppedImage();

      // Step 2: Convert Image to ui.Image
      final completer = Completer<ui.Image>();
      croppedImageWidget.image
          .resolve(const ImageConfiguration())
          .addListener(
            ImageStreamListener((info, _) {
              completer.complete(info.image);
            }),
          );

      final ui.Image croppedUiImage = await completer.future;

      // Step 3: Convert ui.Image to bytes
      final byteData = await croppedUiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e, st) {
      log("Error getting cropped bytes: $e");
      log("Stack trace: $st");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adjust the Image',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              setState(() => isCropping = true); // Start loading

              final croppedBytes = await _getCroppedBytes();

              if (!mounted) return;

              setState(() => isCropping = false); // Stop loading

              if (croppedBytes != null) {
                Navigator.pop(context, croppedBytes);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to crop image")),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CropImage(
              controller: cropController,
              image: widget.image,
              paddingSize: 25.0,
              alwaysMove: true,
            ),

            /// LOADING OVERLAY
            if (isCropping)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
