import 'package:flutter/widgets.dart';

class BackgroundImage extends StatelessWidget {
  final Widget? child;
  final String? image;

  const BackgroundImage({Key? key, this.child, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(image ?? 'assets/images/common/bg.jpg'),
                fit: BoxFit.cover)),
        child: child!);
  }
}
