import 'package:flutter/material.dart';

import '../widgets/tv_card.dart';

class WatchPageUpdatesList extends StatelessWidget {
  const WatchPageUpdatesList({Key? key, required this.screenH})
      : super(key: key);

  final double screenH;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: 10,
        itemBuilder: (context, index) => TVCardContainer(
              name: 'Andrea',
              userImg:
                  'https://1fid.com/wp-content/uploads/2022/07/girl-anime-wallaper-76-721x1024.jpg',
              img: 'https://picsum.photos/600/1200?random=${(index + 1) * 29}',
            ),
        separatorBuilder: (_, __) => SizedBox(height: screenH * 0.03));
  }
}
