import 'package:flutter/material.dart';

import '../../../../../utils/theme/colors.dart';
import 'my_feed.dart';
import 'updates_list.dart';

class WatchList extends StatelessWidget {
  const WatchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              centerTitle: false,
              title: SizedBox(
                  width: screenW * 0.5,
                  child: TabBar(
                    labelColor: AppColors.deepOrange,
                    unselectedLabelColor: AppColors.black,
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                    indicatorColor: const Color.fromARGB(255, 45, 23, 12),
                    tabs: const [Tab(text: 'Updates'), Tab(text: 'My Feed')],
                  ))),
          body: TabBarView(children: [
            WatchPageUpdatesList(screenH: screenH),
            WatchPageMyFeed(screenW: screenW, screenH: screenH),
          ])),
    );
  }
}
