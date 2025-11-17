import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/background_image.dart';
import '../../../common_widgets/custom_icon_btn.dart';
import '../../../common_widgets/loading_animations.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../common_widgets/snapshot_error.dart';
import '../../../common_widgets/stadium_button.dart';
import '../../../utils/constants/input_decorations.dart';
import '../../../utils/global_keys.dart';
import '../../../utils/theme/colors.dart';
import '../models/user_profile.dart';
import '../services/edit_profile_provider.dart';
import '../widgets/photos_grid.dart';

class EditProfile extends StatefulWidget {
  static const routeName = '/edit-profile';

  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final editProfileProvider = navigatorKey.currentContext!
      .read<EditProfileProvider>();
  final size = MediaQuery.of(navigatorKey.currentContext!).size;
  final titleTheme = Theme.of(
    navigatorKey.currentContext!,
  ).textTheme.titleMedium;

  late Future future;
  late TextEditingController nameController;
  late TextEditingController heightController;
  late TextEditingController professionController;
  late TextEditingController bioController;

  @override
  initState() {
    super.initState();
    future = editProfileProvider.fetchMyProfile();
    nameController = TextEditingController();
    heightController = TextEditingController();
    professionController = TextEditingController(text: '');
    bioController = TextEditingController(text: '');
  }

  void initialize(UserProfile profile) {
    nameController.text = profile.name;
    professionController.text = profile.profession ?? "";
    bioController.text = profile.bio ?? "";
    heightController.text = profile.height.toString();
  }

  Future<void> updateUserData() async {
    editProfileProvider.name = nameController.text;
    editProfileProvider.bio = bioController.text;
    editProfileProvider.profession = professionController.text;
    editProfileProvider.height = heightController.text;
    await editProfileProvider.updateProfile();
    navigatorKey.currentState!.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            CustomIconBtn(
              onTap: () => Navigator.of(context).pushNamed('/notifications'),
              // onTap: () async {
              //   final authProvider = context.read<AuthProvider>();
              //   final tokens = await authProvider.retrieveUserTokens();
              //   debugPrint('=======Tokens: $tokens');
              // },
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
              child: SvgPicture.asset('assets/svg/ui_icons/bell.svg'),
            ),
          ],
        ),
        body: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return mainLoadingAnimationDark;
            }

            if (snapshot.hasError) {
              String errorMsg = '';

              /// chieck if [ connection error ]
              if (snapshot.error.toString().contains('SocketException')) {
                errorMsg =
                    'Error retrieving your profile.\nPlease check your internet connection';
              } else {
                errorMsg = 'Error retrieving your profile. Try again later';
              }

              return SnapshotErrorWidget(errorMsg);
            }
            final UserProfile profile = snapshot.data['profile'];
            final images = snapshot.data['images'];
            log('images $images');

            initialize(profile);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: size.width * 0.3,
                      height: size.width * 0.3,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: CachedNetworkImage(
                        imageUrl: profile.displayImage ?? "",
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.1),
                  Text('Name', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  TextFormField(
                    controller: nameController,
                    decoration: kInputDecoration.copyWith(
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  if (profile.phone != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone', style: titleTheme),
                        SizedBox(height: size.height * 0.01),
                        TextFormField(
                          initialValue: profile.phone,
                          readOnly: true,
                          decoration: kInputDecoration.copyWith(
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                      ],
                    ),
                  if (profile.email != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: titleTheme),
                        SizedBox(height: size.height * 0.01),
                        TextFormField(
                          initialValue: profile.email,
                          readOnly: true,
                          decoration: kInputDecoration.copyWith(
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                      ],
                    ),
                  Text('Date of Birth', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  TextFormField(
                    initialValue: DateFormat('dd/MM/yyyy').format(profile.dob),
                    readOnly: true,
                    decoration: kInputDecoration.copyWith(
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Height', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  TextFormField(
                    controller: heightController,
                    decoration: kInputDecoration.copyWith(
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Gender', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  Consumer<EditProfileProvider>(
                    builder: (_, ref, __) {
                      return Wrap(
                        spacing: size.width * 0.02,
                        runSpacing: size.width * 0.02,
                        children: editProfileProvider.allGenders!
                            .map(
                              (e) => StadiumButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => ref.setGender(e['id']),
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.06,
                                  vertical: size.width * 0.01,
                                ),
                                textColor: ref.gender == e['id']
                                    ? AppColors.white
                                    : AppColors.black,
                                bgColor: ref.gender == e['id']
                                    ? AppColors.borderBlue
                                    : AppColors.white,
                                child: Text(e['title']),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Profession', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  TextFormField(
                    controller: professionController,
                    decoration: kInputDecoration.copyWith(
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Introduce', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  TextFormField(
                    controller: bioController,
                    maxLines: 5,
                    maxLength: 200,
                    decoration: kInputDecoration.copyWith(
                      fillColor: Colors.white,
                      hintText: 'Say something about you',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Photos', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  PhotosGrid(images),
                  SizedBox(height: size.height * 0.03),
                  Text('Interested in', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  Consumer<EditProfileProvider>(
                    builder: (_, ref, __) {
                      return Wrap(
                        spacing: size.width * 0.02,
                        runSpacing: size.width * 0.02,
                        children: editProfileProvider.allOrientations!
                            .map(
                              (e) => StadiumButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => ref.setOrientation(e['id']),
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.06,
                                  vertical: size.width * 0.01,
                                ),
                                textColor: ref.orientation == e['id']
                                    ? AppColors.white
                                    : AppColors.black,
                                bgColor: ref.orientation == e['id']
                                    ? AppColors.borderBlue
                                    : AppColors.white,
                                child: Text(e['title']),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Interests', style: titleTheme),
                  SizedBox(height: size.height * 0.01),
                  Consumer<EditProfileProvider>(
                    builder: (_, ref, __) {
                      return Wrap(
                        spacing: size.width * 0.02,
                        runSpacing: size.width * 0.02,
                        children: editProfileProvider.allInterests!
                            .map(
                              (e) => StadiumButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => ref.toggleInterest(e['id']),
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.06,
                                  vertical: size.width * 0.01,
                                ),
                                textColor: ref.interests.contains(e['id'])
                                    ? AppColors.white
                                    : AppColors.black,
                                bgColor: ref.interests.contains(e['id'])
                                    ? AppColors.borderBlue
                                    : AppColors.white,
                                child: Text(e['title']),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryBtn(
                          onPressed: updateUserData,
                          text: 'Save Changes',
                          color: AppColors.borderBlue,
                          textColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
