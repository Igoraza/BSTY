import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';
import '../widgets/tv_card.dart';

class WatchPageMyFeed extends StatelessWidget {
  const WatchPageMyFeed(
      {Key? key, required this.screenW, required this.screenH})
      : super(key: key);

  final double screenW;
  final double screenH;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(screenW * 0.05).copyWith(bottom: 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: screenH * 0.03),
          itemCount: 10,
          itemBuilder: (context, index) => TVCardContainer(
                name: index == 0 ? 'My Feed' : null,
                userImg: index == 0
                    ? 'https://1fid.com/wp-content/uploads/2022/07/girl-anime-wallaper-9.jpg'
                    : null,
                enableShadow: false,
                img:
                    'https://picsum.photos/600/1200?random=${(index + 1) * 16}',
                showCommentBtn: false,
              )),
    );
  }
}
