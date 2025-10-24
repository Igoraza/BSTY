import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:bsty/common_widgets/crop_image_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/custom_icon_btn.dart';
import '../../../utils/global_keys.dart';
import '../../../utils/theme/colors.dart';
import '../../remote_config/remote_config_service.dart';
import '../services/edit_profile_provider.dart';

class PhotosGrid extends StatefulWidget {
  const PhotosGrid(this.images, {super.key});

  final List images;

  @override
  State<PhotosGrid> createState() => _PhotosGridState();
}

class _PhotosGridState extends State<PhotosGrid> {
  late RemoteConfigService _remoteConfigService;
  final mq = MediaQuery.of(navigatorKey.currentContext!).size;
  final editProfileProvider = navigatorKey.currentContext!
      .read<EditProfileProvider>();

  List serverImages = [];
  List<File?> pickedImages = [null];

  @override
  void initState() {
    super.initState();
    serverImages = widget.images;
    _remoteConfigService = RemoteConfigService();
    _remoteConfigService.initialize().then((value) => setState(() {}));
  }

  void pickImgFromGallery(int index) async {
  try {
    // Pick image from gallery
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    // Read image bytes and create MemoryImage
    final imageBytes = await pickedFile.readAsBytes();
    final imageProvider = MemoryImage(imageBytes);

    if (!mounted) return;

    // Open custom CropImageScreen and get cropped bytes
    final Uint8List? croppedBytes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropImageScreen(
          image: Image(image: imageProvider),
          aspectRatio: 8 / 11, // match previous 8:11 ratio
        ),
      ),
    );

    if (croppedBytes != null) {
      // Save cropped image to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(croppedBytes);

      // Update provider
      editProfileProvider.pickedImages.insert(0, file);

      // Update local state
      setState(() {
        if (index < pickedImages.length) {
          pickedImages[index] = file;
        } else {
          pickedImages.insert(0, file);
        }
      });
    }
  } catch (e, stack) {
    log("Error picking image from gallery: $e");
    log("Stack trace: $stack");
  }
}


  // void pickImgFromGallery(int index) async {
  //   final pickedFile = await ImagePicker().pickImage(
  //     source: ImageSource.gallery,
  //   );

  //   if (pickedFile == null) return;
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //     sourcePath: pickedFile.path,
  //     aspectRatio: const CropAspectRatio(ratioX: 8, ratioY: 11),
  //     maxWidth: _remoteConfigService.imageMaxWidth,
  //     maxHeight: _remoteConfigService.imageMaxHeight ,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Adjust the Image',
  //         toolbarColor: Colors.black,
  //         toolbarWidgetColor: AppColors.white,
  //         hideBottomControls: true,
  //       ),
  //       IOSUiSettings(
  //         title: 'Cropper',
  //         aspectRatioPickerButtonHidden: true,
  //         aspectRatioLockEnabled: true,
  //       ),
  //     ],
  //   );
  //   if (croppedFile != null) {
  //     editProfileProvider.pickedImages.insert(0, File(croppedFile.path));
  //     setState(() => pickedImages.insert(0, File(croppedFile.path)));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    final appHeight = MediaQuery.of(context).size.height;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: appWidth * 0.04,
      mainAxisSpacing: appWidth * 0.04,
      childAspectRatio: 0.8,
      padding: EdgeInsets.symmetric(vertical: appHeight * 0.03),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(6, (index) {
        return GestureDetector(
          onTap: index < serverImages.length
              ? null
              : () {
                  debugPrint('Pick image from gallery');
                  pickImgFromGallery(index);
                },
          child: getImageWidget(index),
        );
      }),
    );
  }

  Widget getImageWidget(int index) {
    if (index < serverImages.length) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: serverImages[index]['image'],
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: AppColors.borderBlue),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          CustomIconBtn(
            onTap: () {
              editProfileProvider.deletedImages.add(serverImages[index]['id']);
              editProfileProvider.serverImageCount = serverImages.length;
              setState(() {
                serverImages.removeWhere(
                  (element) => element['id'] == serverImages[index]['id'],
                );
              });
            },
            bgColor: AppColors.white,
            child: const Icon(Icons.close_rounded, color: AppColors.alertRed),
          ),
        ],
      );
    } else {
      return (index - serverImages.length < pickedImages.length - 1)
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: FileImage(pickedImages[index - serverImages.length]!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : mediaPickCard(mq.width);
    }
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
          onTap: () => setState(() => pickedImages[index] = null),
          child: Icon(
            Icons.delete,
            color: Colors.red,
            size: appWidth * 0.08,
          ) /*  SvgPicture.asset('assets/svg/media/delete.svg',
                  width: appWidth * 0.1) */,
        ),
      );
}
