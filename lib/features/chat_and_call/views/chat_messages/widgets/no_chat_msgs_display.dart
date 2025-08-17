import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../utils/global_keys.dart';
import '../../../../../utils/theme/colors.dart';
import '../../../../people/views/detailed/person_details_page.dart';

class NoMsgsDisplay extends StatelessWidget {
  const NoMsgsDisplay(
      {Key? key,
      required this.uid,
      required this.userName,
      required this.userImage})
      : super(key: key);

  final int uid;
  final String userName;
  final String userImage;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return ListView(padding: EdgeInsets.all(appWidth * 0.15), children: [
      SvgPicture.asset('assets/svg/chat/no_chats.svg'),
      SizedBox(height: appHeight * 0.04),
      const Text('No messages, yet',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 28)),
      SizedBox(height: appHeight * 0.01),
      const Text('Start chatting with your new match!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: AppColors.disabled)),
      SizedBox(height: appHeight * 0.04),
      ElevatedButton(
          onPressed: () => navigatorKey.currentState!.pushNamed(
                PersonDetailedPage.routeName,
                arguments: {
                  'id': uid,
                  'name': userName,
                  'image': userImage,
                },
              ),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.symmetric(
                  horizontal: appWidth * 0.15, vertical: appHeight * 0.015),
              elevation: 0,
              backgroundColor: AppColors.orange),
          child: const Text('View Profile')),
    ]);
  }
}
