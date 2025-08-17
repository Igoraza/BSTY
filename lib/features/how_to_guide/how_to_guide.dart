import 'package:flutter/material.dart';
// import 'package:page_indicator/page_indicator.dart';

import '../../common_widgets/stadium_button.dart';
import '../../utils/theme/colors.dart';

class HowToGuidePages extends StatefulWidget {
  const HowToGuidePages({Key? key}) : super(key: key);

  static const String routeName = '/guide';

  @override
  State<HowToGuidePages> createState() => _HowToGuidePagesState();
}

class _HowToGuidePagesState extends State<HowToGuidePages> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'title': 'How to\nDeal',
      'desc': 'If you see something, say something',
      'btnText': 'Resources',
      'btnOnTap': () {},
    },
    {
      'title': 'How to\nUnmatch',
      'desc':
          'Whether you realize you just to let us know that someone acting inappropriately.',
      'btnText': 'Tools',
      'btnOnTap': () {},
    },
    {
      'title': 'How to\nReport',
      'desc':
          'Report is a safe way to let us know that someone acting inappropriately.',
      'btnText': 'Guide',
      'btnOnTap': () {},
    },
  ];

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: Text(pages[_currentPage]['btnText'])),
      body:SizedBox()
      //  Padding(
      //     padding: EdgeInsets.all(appWidth * 0.15),
      //     child: PageIndicatorContainer(
      //         length: pages.length,
      //         indicatorColor: AppColors.lightGrey,
      //         indicatorSelectorColor: AppColors.pink,
      //         padding: EdgeInsets.only(bottom: appHeight * 0.05),
      //         shape: IndicatorShape.circle(size: 8),
      //         align: IndicatorAlign.top,
      //         child: PageView.builder(
      //             itemCount: pages.length,
      //             onPageChanged: (int index) =>
      //                 setState(() => _currentPage = index),
      //             itemBuilder: (_, i) {
      //               return Column(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: [
      //                     SizedBox(
      //                         height: appHeight * 0.4,
      //                         child: Image.asset('assets/images/iphone.png')),
      //                     Text(pages[i]['title'],
      //                         textAlign: TextAlign.center,
      //                         style: TextStyle(
      //                             fontSize: appWidth * 0.1,
      //                             fontWeight: FontWeight.bold,
      //                             color: Colors.black)),
      //                     SizedBox(height: appHeight * 0.02),
      //                     Text(pages[i]['desc'],
      //                         textAlign: TextAlign.center,
      //                         style: TextStyle(
      //                             fontSize: appWidth * 0.04,
      //                             color: AppColors.darkGrey)),
      //                     SizedBox(height: appHeight * 0.04),
      //                     StadiumButton(
      //                         onPressed: pages[i]['btnOnTap'],
      //                         gradient: AppColors.buttonBlue,
      //                         text: pages[i]['btnText'])
      //                   ]);
      //             }))),
    );
  }
}
