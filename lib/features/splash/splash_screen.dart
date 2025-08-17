import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:page_indicator/page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../common_widgets/background_image.dart';
import '../../common_widgets/primary_button.dart';
import '../../utils/theme/colors.dart';
import '../auth/pages/initial/sign_in_page.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentIndex = 0;
  late PageController pageController;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0, viewportFraction: 0.9);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// [ setAlreadyVisited ] is used to set the value of [ alreadyVisited ] to true.

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    /// [ Pages Data ]
    const introGuideItems = [
      {
        'title': 'Chat, Video\nUnlimited Fun !',
        'caption': 'Make genuine bonds',
        'captionTwo': 'anytime, anywhere!',
        // 'splash': 'splash_1',
        'splash': 'splash1',
      },
      {
        'title': 'Welcome to\nBSTY !',
        'caption': 'Discover meaningful relationships,',
        'captionTwo': 'love is just a swipe away!',
        // 'splash': 'splash_2'
        'splash': 'splash2',
      },
      {
        'title': 'Find your\nPerfect Match!',
        'caption': 'Find someone',
        'captionTwo': 'who completes you!',
        // 'splash': 'splash_3'
        'splash': 'splash3',
      },
    ];

    return BackgroundImage(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: appHeight * 0.02),

            /// [ display splash screen icons accord to selected page ]
            Padding(
              padding: EdgeInsets.all(appWidth * 0.1),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: Image.asset(
                  key: ValueKey(currentIndex),
                  'assets/svg/splash/${introGuideItems[currentIndex]['splash']}.png',
                  height: appHeight * 0.3,
                ),
                // SvgPicture.asset(
                //   key: ValueKey(currentIndex),
                //   'assets/svg/splash/${introGuideItems[currentIndex]['splash']}.svg',
                //   height: appHeight * 0.3,
                // )
              ),
            ),

            /// [ display title and caption accord to selected page ]
            SizedBox(
              height: appHeight * 0.253,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: introGuideItems.length,
                      onPageChanged: (i) => setState(() => currentIndex = i),
                      itemBuilder: (_, index) => Container(
                        height: appHeight * 0.2,
                        margin: EdgeInsets.symmetric(
                          horizontal: appWidth * 0.02,
                        ),
                        padding: EdgeInsets.all(appWidth * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Title
                            Text(
                              introGuideItems[index]['title']!,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .merge(
                                    const TextStyle(
                                      color: AppColors.toggleBlue,
                                      fontSize: 30,
                                    ),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: appHeight * 0.01),

                            /// Caption One
                            Text(
                              introGuideItems[index]['caption']!,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color: AppColors.disabled,
                                    fontWeight: FontWeight.normal,
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            /// Caption Two
                            Text(
                              introGuideItems[index]['captionTwo']!,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.disabled,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: appHeight * 0.015),

                  /// Page Indicator
                  SmoothPageIndicator(
                    controller: pageController,
                    count: introGuideItems.length,
                    effect: WormEffect(
                      dotColor: AppColors.lightGrey,
                      activeDotColor: AppColors.disabled,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: appHeight * 0.03),
            PrimaryBtn(
              text: 'Get Started',
              gradient: AppColors.buttonBlue,
              width: appWidth * 0.75,
              onPressed: () {
                debugPrint('Get Started');
                setAlreadyVisited();
                Navigator.pushNamed(context, SignInPage.routeName);
              },
            ),
            SizedBox(height: appHeight * 0.01),
            TextButton(
              onPressed: () {
                debugPrint('Skipped');
                setAlreadyVisited();
                Navigator.pushNamed(context, SignInPage.routeName);
              },
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.bodyMedium!.merge(
                  const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: appHeight * 0.02),
          ],
        ),
      ),
    );
  }

  setAlreadyVisited() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isViewed', true);
    debugPrint('isViewed: true');
  }
}
