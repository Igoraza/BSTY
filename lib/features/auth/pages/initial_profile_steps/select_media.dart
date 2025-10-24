import 'dart:developer';
import 'dart:io';

import 'package:bsty/common_widgets/crop_image_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bsty/screens/permission/permit_location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

import '../../../../common_widgets/background_image.dart';
import '../../../../common_widgets/stadium_button.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/theme/colors.dart';
import '../../../remote_config/remote_config_service.dart';
import '../../enums.dart';
import '../../services/auth_provider.dart';
import '../../services/initial_profile_provider.dart';

class SelectMedia extends StatefulWidget {
  const SelectMedia({Key? key}) : super(key: key);

  static const routeName = '/select-media';

  @override
  State<SelectMedia> createState() => _SelectMediaState();
}

class _SelectMediaState extends State<SelectMedia> {
  late RemoteConfigService _remoteConfigService;

  List<File?> images = [null, null, null, null];

  @override
  void initState() {
    super.initState();
    _remoteConfigService = RemoteConfigService();
    _remoteConfigService.initialize().then((value) => setState(() {}));
  }

  void pickImgFromGallery(int index) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      // Read image bytes
      final imageBytes = await pickedFile.readAsBytes();
      final imageProvider = MemoryImage(imageBytes);

      if (!mounted) return;

      // Open crop screen
      final Uint8List? croppedBytes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImageScreen(
            image: Image(image: imageProvider),
            aspectRatio: 4 / 5,
          ),
        ),
      );

      if (croppedBytes != null) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(croppedBytes);

        // ✅ Update state directly
        setState(() {
          images[index] = file;
        });
      }
    } catch (e, stack) {
      log("Error picking image from gallery: $e");
      log("Stack trace: $stack");
    }
  }

  // void pickImgFromGallery(int index) async {
  //   try {
  //     final pickedFile = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //     );
  //     if (pickedFile == null) return;

  //     CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: pickedFile.path,
  //       aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
  //       maxWidth: _remoteConfigService.imageMaxWidth,
  //       maxHeight: _remoteConfigService.imageMaxHeight,
  //       uiSettings: [
  //         AndroidUiSettings(
  //           toolbarTitle: 'Adjust the Image',
  //           toolbarColor: Colors.black,
  //           toolbarWidgetColor: AppColors.white,
  //           statusBarColor: Colors.black,
  //           hideBottomControls: true,
  //           initAspectRatio: CropAspectRatioPreset.original,
  //           lockAspectRatio: true,
  //         ),
  //         IOSUiSettings(
  //           title: 'Adjust the Image',
  //           aspectRatioPickerButtonHidden: true,
  //           aspectRatioLockEnabled: true,
  //         ),
  //       ],
  //     );
  //     if (croppedFile != null) {
  //       setState(() => images[index] = File(croppedFile.path));
  //     }
  //   } catch (e, stack) {
  //     log("Error in picking image from gallery: $e");
  //     log("Stack trace: $stack");
  //   }
  // }

  void uploadMedia() async {
    final validImages = images.where((image) => image != null).toList();
    if (validImages.length < 2) {
      showSnackBar('Please add at least 2 images');
    } else {
      // Show loading indicator
      // showSnackBar('Compressing images...');

      // Compress images
      List<File> compressedImages = [];
      for (var image in validImages) {
        final compressedImage = await compressImage(image!);
        if (compressedImage != null) {
          compressedImages.add(compressedImage);
        }
      }

      if (compressedImages.isEmpty) {
        showSnackBar('Failed to compress images');
        return;
      }

      context
          .read<InitialProfileProvider>()
          .uploadUserImages(context, compressedImages)
          .then((value) {
            if (value) {
              context.read<AuthProvider>().saveLoggedInStatus(true);
              Navigator.of(context).pushNamedAndRemoveUntil(
                PermitLocation.routeName,
                (route) => false,
              );
            } else {
              showSnackBar('Something went wrong');
            }
          });
    }
  }

  Future<File?> compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final outPath = "${filePath.substring(0, lastIndex)}_compressed.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 60, // Adjust quality (0-100)
        minWidth: 1024, // Adjust dimensions as needed
        minHeight: 1024,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }
  // void uploadMedia() async {
  //   final validImages = images.where((image) => image != null).toList();
  //   if (validImages.length < 2) {
  //     showSnackBar('Please add at least 2 images');
  //   } else {
  //     context
  //         .read<InitialProfileProvider>()
  //         .uploadUserImages(context, validImages)
  //         .then((value) {
  //           if (value) {
  //             context.read<AuthProvider>().saveLoggedInStatus(true);
  //             Navigator.of(context).pushNamedAndRemoveUntil(
  //               PermitLocation.routeName,
  //               (route) => false,
  //             );
  //           } else {
  //             showSnackBar('Something went wrong');
  //           }
  //         });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final authPro = context.read<AuthProvider>();

    final continueBtn = Consumer<InitialProfileProvider>(
      builder: (_, ref, __) => StadiumButton(
        visualDensity: VisualDensity.standard,
        gradient: AppColors.buttonBlue,
        onPressed: ref.authStatus == AuthStatus.checking ? null : uploadMedia,
        child: ref.authStatus == AuthStatus.checking
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                  value: ref.uploadProgress,
                ),
              )
            : Text(
                'Continue',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: AppColors.white),
              ),
      ),
    );
    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Media')),
        body: Padding(
          padding: EdgeInsets.all(
            appWidth * 0.05,
          ).copyWith(bottom: appHeight * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: authPro.isTab ? 0 : appHeight * 0.075),
              Text(
                'Add minimum 2 photographs',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              /// [ images grid ]
              Expanded(
                child: GridView.count(
                  crossAxisCount: authPro.isTab ? 3 : 2,
                  crossAxisSpacing: appWidth * 0.04,
                  mainAxisSpacing: appWidth * 0.04,
                  childAspectRatio: 0.8,
                  padding: EdgeInsets.symmetric(vertical: appHeight * 0.03),
                  children: List.generate(4, (index) {
                    File? image = images[index];
                    return GestureDetector(
                      onTap: () {
                        debugPrint('Pick image from gallery');
                        pickImgFromGallery(index);
                      },
                      child: image == null
                          ? mediaPickCard(appWidth)
                          : pickedImageCard(appWidth, image, index),
                    );
                  }),
                ),
              ),
              continueBtn,
            ],
          ),
        ),
      ),
    );
  }

  /// [show before picking the image]
  Widget mediaPickCard(double appWidth) => DottedBorder(
    options: RectDottedBorderOptions(
      color: AppColors.titleBlue,
      // borderRadius: BorderRadius.circular(20),
      dashPattern: const [5, 5],
      strokeWidth: 1.5,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.toggleBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/svg/media/add.svg',
          width: appWidth * 0.15,
        ),
      ),
    ),
  );

  /// [show after picking the image]
  Container pickedImageCard(double appWidth, File image, int index) =>
      Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(appWidth * 0.03),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        ),
        child: GestureDetector(
          onTap: () => setState(() => images[index] = null),
          child: Icon(Icons.delete, color: Colors.red, size: appWidth * 0.08),
          /* SvgPicture.asset('assets/svg/media/delete.svg',
                  width: appWidth * 0.1) */
        ),
      );
}
