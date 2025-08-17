import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../common_widgets/boxed_text.dart';
import '../../../../../utils/theme/colors.dart';

class TVCardContainer extends StatelessWidget {
  const TVCardContainer({
    super.key,
    required this.img,
    this.enableShadow = true,
    this.name,
    this.userImg,
    this.showCommentBtn = true,
  });

  final String? name;
  final String? userImg;
  final String img;
  final bool? enableShadow;
  final bool? showCommentBtn;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Container(
      height: appWidth * 1.2,
      width: double.infinity,
      padding: EdgeInsets.all(appWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: enableShadow!
            ? [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]
            : null,
      ),
      child: Column(children: [
        Row(children: [
          /// [ Profile pic ]
          userImg != null
              ? CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(userImg!))
              : const SizedBox.shrink(),
          SizedBox(width: userImg != null ? appWidth * 0.025 : 0),

          /// [ Profile name ]
          name != null
              ? Text(name!, style: Theme.of(context).textTheme.titleMedium)
              : const SizedBox.shrink(),
        ]),
        SizedBox(height: appHeight * 0.015),

        /// [ User Image ]
        Expanded(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(img),
                      fit: BoxFit.cover,
                    )),
                child: const Align(
                    alignment: Alignment.topRight,
                    child: BoxedText(
                      text: '1/3',
                      margin: EdgeInsets.only(top: 20, right: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    )))),
        SizedBox(height: appHeight * 0.01),

        /// [ Bottom Row]
        Row(children: [
          /// [Likes]
          Column(children: [
            SvgPicture.asset('assets/svg/explore/like.svg'),
            SizedBox(height: appHeight * 0.0075),
            Text('12 Likes',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.black)),
          ]),
          SizedBox(width: appWidth * 0.03),

          /// [Star]
          Column(children: [
            SvgPicture.asset('assets/svg/explore/star.svg'),
            SizedBox(height: appHeight * 0.0075),
            Text('14 Star',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.black)),
          ]),
          SizedBox(width: appWidth * 0.03),

          /// [ TODO: Should align the DP as stack ]
          Row(children: [
            CircleAvatar(
              radius: appWidth * 0.03,
              foregroundImage: const CachedNetworkImageProvider(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqMQtkyDXM1OHzSV3YOnvIIyWPf8TLSLr3Frv7YuA&s'),
            ),
            CircleAvatar(
              radius: appWidth * 0.03,
              foregroundImage: const CachedNetworkImageProvider(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqMQtkyDXM1OHzSV3YOnvIIyWPf8TLSLr3Frv7YuA&s'),
            ),
            CircleAvatar(
              radius: appWidth * 0.03,
              foregroundImage: const CachedNetworkImageProvider(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqMQtkyDXM1OHzSV3YOnvIIyWPf8TLSLr3Frv7YuA&s'),
            ),
            SizedBox(width: appWidth * 0.015),

            /// [ TODO: Should pass the liked count ]
            Text('& 12 others',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.black)),
          ]),
          const Spacer(),

          /// [ TODO: should pass the comments provider ]
          showCommentBtn!
              ? GestureDetector(
                  onTap: () {
                    debugPrint('Comment section');
                  },
                  child: SvgPicture.asset('assets/svg/explore/comment.svg'))
              : const SizedBox.shrink(),
        ])
      ]),
    );
  }
}
