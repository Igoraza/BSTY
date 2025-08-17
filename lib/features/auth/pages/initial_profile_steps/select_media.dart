import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bsty/screens/permission/permit_location.dart';
import 'package:provider/provider.dart';

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
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
        maxWidth: _remoteConfigService.imageMaxWidth,
        maxHeight: _remoteConfigService.imageMaxHeight,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust the Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: AppColors.white,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPickerButtonHidden: true,
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() => images[index] = File(croppedFile.path));
      }
    } catch (e, stack) {
      log("Error in picking image from gallery: $e");
      log("Stack trace: $stack");
    }
  }

  void uploadMedia() async {
    final validImages = images.where((image) => image != null).toList();
    if (validImages.length < 2) {
      showSnackBar('Please add at least 2 images');
    } else {
      context
          .read<InitialProfileProvider>()
          .uploadUserImages(context, validImages)
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
          child: Icon(
            Icons.delete,
            color: Colors.red,
            size: appWidth * 0.08,
          ) /* SvgPicture.asset('assets/svg/media/delete.svg',
                  width: appWidth * 0.1) */,
        ),
      );
}
