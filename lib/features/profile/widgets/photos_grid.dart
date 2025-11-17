import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:bsty/common_widgets/crop_image_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<File?> pickedImages = [null]; // last slot is always "add" tile

  @override
  void initState() {
    super.initState();
    serverImages = widget.images;
    _remoteConfigService = RemoteConfigService();
    _remoteConfigService.initialize().then((value) => setState(() {}));
  }

  /// RULE: Must always have >= 2 photos
  bool canDelete() {
    int total = serverImages.length + pickedImages.length - 1;
    return total > 2;
  }

  void pickImgFromGallery(int index) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      final imageBytes = await pickedFile.readAsBytes();
      final imageProvider = MemoryImage(imageBytes);

      if (!mounted) return;

      final Uint8List? croppedBytes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImageScreen(
            image: Image(image: imageProvider),
            aspectRatio: 8 / 11,
          ),
        ),
      );

      if (croppedBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(croppedBytes);

        editProfileProvider.pickedImages.insert(0, file);

        setState(() {
          pickedImages.insert(0, file);
        });
      }
    } catch (e, stack) {
      log("Error picking image from gallery: $e");
      log("Stack trace: $stack");
    }
  }

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
              : () => pickImgFromGallery(index),
          child: getImageWidget(index),
        );
      }),
    );
  }

  Widget getImageWidget(int index) {
    // ------------------------------
    // SERVER IMAGE
    // ------------------------------
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

          /// DELETE SERVER IMAGE (only when > 2 images exist)
          if (canDelete())
            Positioned(
              top: 8,
              right: 8,
              child: CustomIconBtn(
                onTap: () {
                  if (!canDelete()) return;
                  editProfileProvider.deletedImages.add(
                    serverImages[index]['id'],
                  );
                  editProfileProvider.serverImageCount = serverImages.length;

                  setState(() {
                    serverImages.removeAt(index);
                  });
                },
                bgColor: AppColors.white,
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.alertRed,
                ),
              ),
            ),
        ],
      );
    }

    // ------------------------------
    // NEWLY ADDED IMAGE
    // ------------------------------
    int pickedIndex = index - serverImages.length;

    if (pickedIndex < pickedImages.length - 1) {
      File imageFile = pickedImages[pickedIndex]!;

      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: FileImage(imageFile),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// DELETE PICKED IMAGE (only when > 2 images exist)
          if (canDelete())
            Positioned(
              top: 8,
              right: 8,
              child: CustomIconBtn(
                onTap: () {
                  if (!canDelete()) return;
                  setState(() {
                    pickedImages.removeAt(pickedIndex);
                  });
                },
                bgColor: Colors.white,
                child: const Icon(Icons.close_rounded, color: Colors.red),
              ),
            ),
        ],
      );
    }

    // ------------------------------
    // EMPTY SLOT
    // ------------------------------
    return mediaPickCard(mq.width);
  }

  /// MEDIA PICK CARD
  Widget mediaPickCard(double appWidth) => DottedBorder(
    options: RectDottedBorderOptions(
      color: AppColors.titleBlue,
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
}
